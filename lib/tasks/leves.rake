require 'xiv_data'

namespace :leves do
  desc 'Create the Leves'
  task create: :environment do
    PaperTrail.enabled = false

    battle = { craft_en: 'Battlecraft', craft_de: 'Gefecht', craft_fr: 'Mercenariat', craft_ja: '傭兵稼業' }
    trade =  { craft_en: 'Tradecraft', craft_de: 'Fertigung', craft_fr: 'Artisanat', craft_ja: '製作稼業' }
    field =  { craft_en: 'Fieldcraft', craft_de: 'Sammel', craft_fr: 'Récolte', craft_ja: '採集稼業' }
    item_categories = ['Carpenter', 'Blacksmith', 'Armorer', 'Goldsmith', 'Leatherworker',
                       'Weaver', 'Alchemist', 'Culinarian', 'Fisher']
    location_categories = ['1', '13', '14', '15'] # Battlecraft, The Maelstrom, Order of the Twin Adder, Immortal Flames

    puts 'Creating leve categories'
    categories = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('LeveAssignmentType', locale: locale).each do |category|
        next unless category['Name'].present?

        unless data = h[category['#']]
          data = { id: category['#'], order: category['#'] }

          # Add craft
          case category['Name']
          when /Battlecraft|Maelstrom|Adder|Flames|Brotherhood|Azeyma|Horn/
            data.merge!(battle)
          when /Carpenter|Blacksmith|Armorer|Goldsmith|Leatherworker|Weaver|Alchemist|Culinarian/
            data.merge!(trade)
          when /Miner|Botanist|Fisher/
            data.merge!(field)
          end

          # Flag categories with turn-in items
          if item_categories.include?(category['Name'])
            data[:items] = true
          end
        end

        data["name_#{locale}"] = category['Name']
        h[data[:id]] = data
      end
    end

    # Override the Battlecraft category name to General
    categories['1'].merge!(name_en: 'General', name_de: 'Generell', name_fr: 'Général')

    categories.values.each do |category|
      if existing = LeveCategory.find_by(id: category[:id])
        existing.update!(category) if updated?(existing, category)
      else
        LeveCategory.create!(category)
      end
    end

    puts 'Creating leves'
    count = Leve.count

    leves = ALL_LOCALES.each_with_object({}) do |locale, h|
      # Initialize the leves
      XIVData.sheet('Leve', locale: locale).each do |leve|
        next unless leve['Name'].present?

        unless data = h[leve['#']]
          category_id = leve['LeveAssignmentType']

          data = { id: leve['#'], category_id: category_id, level: leve['ClassJobLevel'], cost: leve['AllowanceCost'] }

          if location_categories.include?(category_id)
            data[:location] = leve['LevelLevemete']
          end
        end

        data["name_#{locale}"] = sanitize_name(leve['Name'], locale: locale)

        h[data[:id]] = data
      end
    end

    # Delete unobtainable leves
    [
      502, 519, 542, 544, # No longer available
      508, 514, 525, 531, 552, 554, 562, 564, 582, 597, 822, 827, 832 # Unimplemented
    ].each do |id|
      leves.delete(id.to_s)
    end

    # Mark introductory leves as time-limited
    %w(546 556 566).each do |id|
      leves[id][:limited] = true
    end

    # Add item ID and quantity for deliverable leves
    XIVData.sheet('CraftLeve').each do |leve|
      next if leve['Leve'] == '0'

      quantity = (0..2).sum { |i| leve["ItemCount[#{i}]"].to_i }
      leves[leve['Leve']].merge!(item_id: leve['Item[0]'], item_quantity: quantity.to_s)
    end

    # Add location data for Battlecraft leves
    level_ids = leves.values.pluck(:location).compact.uniq
    XIVData.sheet('Level').each do |level|
      if level_ids.include?(level['#'])
        # Compile the level data
        data = { issuer_x: level['X'].to_f, issuer_y: level['Z'].to_f,
                 map_id: level['Map'], npc_id: level['Object'] }

        # And assign it to each leve for the given location
        leves.values.select { |leve| leve[:location] == level['#'] }.each do |leve|
          leve.merge!(data)
          leve.delete(:location)
        end
      end
    end

    map_ids = leves.values.pluck(:map_id).uniq
    maps = maps_with_locations(map_ids)

    leves.values.each do |leve|
      if leve[:map_id].present?
        map = maps[leve.delete(:map_id)]
        leve[:location_id] = map[:location_id]
        leve[:issuer_x] = get_coordinate(leve[:issuer_x], map[:x_offset], map[:size_factor])
        leve[:issuer_y] = get_coordinate(leve[:issuer_y], map[:y_offset], map[:size_factor])
      end
    end

    # Add NPC issuer names
    npc_ids = leves.values.pluck(:npc_id).uniq
    npcs = ALL_LOCALES.each_with_object(Hash.new { |h, k| h[k] = {} }) do |locale, h|
      XIVData.sheet('ENpcResident', locale: locale).each do |npc|
        if npc_ids.include?(npc['#'])
          h[npc['#']]["issuer_name_#{locale}"] = sanitize_name(npc['Singular'], locale: locale)
        end
      end
    end

    leves.values.each do |leve|
      leve.merge!(npcs[leve.delete(:npc_id)])
    end

    # Add issuer data for non-battlecraft leves, where the levemete in the game data
    # is the client, not the issuer.

    # Load the mapping of NPCs to leves
    issuers = JSON.parse(File.read(Rails.root.join('vendor', 'leve_issuers.json')))
    issuers.each do |npc_id, leves|
      issuers[npc_id] = { npc_id: npc_id, leves: leves }
    end

    # Find the NPC and save their names
    npc_ids = issuers.values.pluck(:npc_id)
    ALL_LOCALES.each do |locale|
      XIVData.sheet('ENpcResident', locale: locale).each do |npc|
        if npc_ids.include?(npc['#'])
          issuers[npc['#']]["issuer_name_#{locale}"] = sanitize_name(npc['Singular'], locale: locale)
        end
      end
    end

    # Link the NPCs to their locations
    npc_id_regex = /#{npc_ids.join('|')}/
    XIVData.sheet('Level').each do |level|
      if level['Object'].match?(npc_id_regex)
        data = { issuer_x: level['X'].to_f, issuer_y: level['Z'].to_f, map_id: level['Map'] }
        issuers[level['Object']].merge!(data)
      end
    end

    map_ids = issuers.values.pluck(:map_id).uniq
    maps = maps_with_locations(map_ids)

    issuers.values.each do |issuer|
      map = maps[issuer.delete(:map_id)]
      issuer[:location_id] = map[:location_id]
      issuer[:issuer_x] = get_coordinate(issuer[:issuer_x], map[:x_offset], map[:size_factor])
      issuer[:issuer_y] = get_coordinate(issuer[:issuer_y], map[:y_offset], map[:size_factor])
    end

    # Update the leve data
    issuers.values.each do |issuer|
      data = issuer.slice('issuer_name_en', 'issuer_name_de', 'issuer_name_fr', 'issuer_name_ja',
                          :location_id, :issuer_x, :issuer_y)

      issuer[:leves].each do |leve_id|
        leves[leve_id.to_s]&.merge!(data)
      end
    end

    leves.values.each do |leve|
      if existing = Leve.find_by(id: leve[:id])
        existing.update!(leve) if updated?(existing, leve)
      else
        Leve.create!(leve)
      end
    end

    puts "Created #{Leve.count - count} new leves"
  end
end
