require 'xiv_data'

namespace :triad do
  namespace :npcs do
    desc 'Create the NPCs'
    task create: :environment do
      PaperTrail.enabled = false

      puts 'Creating Triple Triad NPCs'
      counts = { npc: NPC.count, npc_card: NPCCard.count, npc_reward: NPCReward.count,
                 locations: Location.count }

      # Find all of the Triple Triad NPC Residents and create the base NPC object
      puts '  Fetching resident data'
      npcs = XIVData.sheet('ENpcBase').each_with_object({}) do |npc, h|
        32.times do |i|
          id = npc["ENpcData[#{i}]"]

          if id =~ /229\d{4}/
            h.delete_if { |_, npc| npc[:id] == id } # Delete duplicates to ensure we use the last NPC in the data
            h[npc['#']] = { id: id, resident_id: npc['#'] }
            break
          end
        end
      end

      ALL_LOCALES.each do |locale|
        XIVData.sheet('ENpcResident', locale: locale).each do |npc|
          if npcs.has_key?(npc['#'])
            npcs[npc['#']]["name_#{locale}"] = sanitize_name(npc['Singular'], locale: locale,
                                                             capitalize: locale == :en,
                                                             upcase_first_only: locale == :de || locale == :fr)
          end
        end
      end

      # Find the associated Level data for each NPC Resident and add the location data
      puts '  Fetching location coordinate data'
      XIVData.sheet('Level').each do |level|
        if npcs.has_key?(level['Object'])
          npcs[level['Object']].merge!(x: level['X'].to_f, y: level['Z'].to_f, map_id: level['Map'])
        end
      end

      map_ids = npcs.values.pluck(:map_id).uniq
      maps = maps_with_locations(map_ids)

      # Look up the relevant maps and set the coordinate data
      npcs.each do |id, npc|
        if map = maps[npc.delete(:map_id)]
          npc[:location_id] = map[:location_id]
          npc[:x] = get_coordinate(npc[:x], map[:x_offset], map[:size_factor])
          npc[:y] = get_coordinate(npc[:y], map[:y_offset], map[:size_factor])
        else
          # Skip and delete weird duplicate Battlehall NPCs with nil locations
          npcs.delete(id)
          next
        end
      end

      # Add their opponent data
      puts '  Fetching opponent data'
      XIVData.sheet('TripleTriad').each do |opponent|
        npc = npcs.values.find { |val| val[:id] == opponent['#'] }
        next unless npc.present?

        # Card rewards
        npc[:rewards] = 4.times.filter_map do |i|
          item_id = opponent["ItemPossibleReward[#{i}]"]

          # Find the Card unlock associated with the Item and add it to the list
          Item.find(item_id).unlock_id if item_id != '0'
        end

        # Fixed cards in the NPC's deck
        npc[:fixed_cards] = 5.times.filter_map do |i|
          card_id = opponent["TripleTriadCardFixed[#{i}]"]
          card_id if card_id != '0'
        end

        # Variable cards in the NPC's deck
        npc[:variable_cards] = 5.times.filter_map do |i|
          card_id = opponent["TripleTriadCardVariable[#{i}]"]
          card_id if card_id != '0'
        end

        # Rules
        npc[:rule_ids] = 2.times.filter_map do |i|
          rule_id = opponent["TripleTriadRule[#{i}]"]
          rule_id if rule_id != '0'
        end

        # Remove duplicate rules (Looking at you, Rowena.)
        npc[:rule_ids].uniq!

        # Required quest
        2.times do |i|
          quest_id = opponent["PreviousQuest[#{i}]"]
          npc[:quest_id] = quest_id if quest_id != '0'
        end
      end

      # Create the NPCs and their cards
      npcs.values.each do |data|
        fixed_cards = data.delete(:fixed_cards)
        variable_cards = data.delete(:variable_cards)
        rewards = data.delete(:rewards)

        # Create or update the NPC
        if npc = NPC.find_by(id: data[:id])
          data.except!(:quest_id, :rule_ids)
          npc.update!(data) if updated?(npc, data)
        else
          npc = NPC.create!(data)
        end

        fixed_cards.each do |card_id|
          NPCCard.find_or_create_by!(npc_id: npc.id, card_id: card_id, fixed: true)
        end

        variable_cards.each do |card_id|
          NPCCard.find_or_create_by!(npc_id: npc.id, card_id: card_id, fixed: false)
        end

        # Create the NPC rewards along with a Source for the Card
        npc_type = SourceType.find_by(name_en: 'NPC')

        texts = ALL_LOCALES.each_with_object({}) do |locale, h|
          h["text_#{locale}"] = npc["name_#{locale}"]
        end

        rewards.each do |card_id|
          NPCReward.find_or_create_by!(npc_id: npc.id, card_id: card_id)

          next if Source.exists?(collectable_id: card_id, collectable_type: 'Card', type: npc_type)

          Source.find_or_create_by!(**texts, collectable_id: card_id, collectable_type: 'Card',
                                    type: npc_type, related_id: npc.id, related_type: 'NPC')
        end

        difficulty = weighted_average(npc.fixed_cards, npc.fixed_cards.length) +
          weighted_average(npc.variable_cards, 5 - npc.fixed_cards.length)
        npc.update!(difficulty: difficulty)
      end

      counts.each do |klass, count|
        class_name = klass.to_s.classify
        puts "Created #{class_name.constantize.send(:count) - count} new #{class_name}s"
      end
    end
  end

  def weighted_average(cards, count)
    return 0 if count == 0
    cards.average(:stars) * (count / 5.0)
  end
end
