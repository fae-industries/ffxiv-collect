namespace :outfits do
  desc 'Create the outfits'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating outfits'

    count = Outfit.count

    XIVData.sheet('MirageStoreSetItem').each do |outfit|
      next if outfit['#'] == '0'

      item_ids = outfit
        .values_at('MainHand', 'OffHand', 'Head', 'Body', 'Hands', 'Legs', 'Feet', 'Earrings', 'Necklace', 'Bracelets', 'Ring')
        .reject { |id| id == '0' }
        .map(&:to_i)

      next if item_ids.empty?

      item = Item.find(outfit['#'])

      data = { id: outfit['#'], item_id: outfit['#'], item_ids: item_ids, gender: nil }

      ALL_LOCALES.each do |locale|
        data["name_#{locale}"] = item["name_#{locale}"]
      end

      # Check the associated items for tradeability and gender restrictions
      Item.where(id: item_ids).each do |item|
        data[:tradeable] ||= true if item.tradeable? # Consider the outfit tradeable if any item is tradeable

        gender = case item.description_en
                 when /♂/ then 'male'
                 when /♀/ then 'female'
                 end

        if gender != nil
          data[:gender] = gender
          break
        end
      end

      if existing = Outfit.find_by(id: data[:id])
        existing.update!(data) if updated?(existing, data)
      else
        created = Outfit.create!(data)
      end
    end

    puts "Created #{Outfit.count - count} new outfits"
  end

  task find_armoires: :environment do
    Outfit.where(armoireable: false).each do |outfit|
      armoire = Armoire.find_by(item_id: outfit.item_ids.first)
      next unless armoire.present?

      outfit.update!(armoireable: true)

      # Mirror the sources from the matching armoire
      armoire.sources.each do |source|
        outfit.sources.create!(source.slice(:text_en, :text_de, :text_fr, :text_ja, :premium, :limited,
                                              :type_id, :related_id, :related_type))
      end
    end
  end
end
