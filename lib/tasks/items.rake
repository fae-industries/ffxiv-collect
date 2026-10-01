CRAFTERS = ['Carpenter', 'Blacksmith', 'Armorer', 'Goldsmith', 'Leatherworker', 'Weaver', 'Alchemist', 'Culinarian'].freeze

namespace :items do
  desc 'Create the items'
  task create: :environment do
    puts 'Creating items'
    count = Item.count

    items = XIVData.sheet('Item', locale: 'en').each_with_object({}) do |item, h|
      next unless item['Name'].present?

      tradeable = item['ItemSearchCategory'] != '0'

      data = { id: item['#'], name_en: sanitize_name(item['Name']),
               plural_en: item['Plural'].present? ? sanitize_name(item['Plural'], capitalize: true) : nil,
               description_en: sanitize_text(item['Description'], preserve_space: true),
               tradeable: tradeable, price: item['PriceMid'], image_url: XIVData.image_url(item['Icon']) }

      h[data[:id]] = data
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('Item', locale: locale).each do |item|
        next unless item['Name'].present?

        items[item['#']]&.merge!("name_#{locale}" => sanitize_name(item['Name'], locale: locale),
                                 "plural_#{locale}" => item['Plural'].present? ? sanitize_name(item['Plural'], locale: locale) : nil,
                                 "description_#{locale}" => sanitize_text(item['Description'], preserve_space: true))
      end
    end

    XIVData.sheet('Recipe').each do |recipe|
      next unless items.has_key?(recipe['ItemResult'])
      item = items[recipe['ItemResult']]
      item.merge!(crafter: CRAFTERS[recipe['CraftType'].to_i], recipe_id: recipe['#'])
    end

    items.values.each do |item|
      if existing = Item.find_by(id: item[:id])
        existing.update!(item) if updated?(existing, item)
      else
        Item.create!(item)
      end
    end

    puts "Created #{Item.count - count} new items"
  end

  desc 'Sets collectable unlocks for items'
  task set_unlocks: :environment do
    PaperTrail.enabled = false
    puts 'Setting collectable unlocks for items'

    items = XIVData.sheet('Item', locale: 'en').each_with_object({}) do |item, h|
      next unless item['Name'].present? && item['ItemAction'] != '0'

      action_id = item['ItemAction']

      case action_id
      when '2235'
        # Orchestrion roll unlock links live in the item's AdditionalData
        the_item = Item.find(item['#'])
        orchestrion_id = item['AdditionalData']

        the_item.update!(unlock_type: 'Orchestrion', unlock_id: orchestrion_id)
        Orchestrion.find(orchestrion_id).update!(item_id: the_item.id)
      when '2251'
        # Match Facewear by the item name
        the_item = Item.find(item['#'])
        name = item['Name'].split(' - ').last

        if facewear = Facewear.find_by(name_en: name)
          the_item.update!(unlock_type: 'Facewear', unlock_id: facewear.id)
          facewear.update!(item_id: the_item.id)
        else
          puts "Could not find matching facewear: #{name}"
        end
      else
        h[action_id] = { id: item['#'], name_en: sanitize_name(item['Name']) }
      end
    end

    XIVData.sheet('ItemAction').each do |action|
      next unless data = items[action['#']]

      unlock_type = case action['Action']
                    when '853'  then 'Minion'
                    when '1013' then 'Barding'
                    when '1322' then 'Mount'
                    when '2633'
                      if data[:name_en].match?('Aesthetics')
                        'Hairstyle'
                      elsif data[:name_en].match?('Etiquette')
                        'Emote'
                      else
                        next
                      end
                    when '3357' then 'Card'
                    when '20086' then 'Fashion'
                    # when '25183' then 'Orchestrion'
                    # when '37312' then 'Facewear'
                    else
                      next
                    end

      unlock_class = unlock_type.constantize
      item = Item.find(data[:id])

      (0..9).reverse_each do |i|
        data = action["Data[#{i}]"]

        if data != '0' && collectable = unlock_class.find_by(id: data)
          # Set the item unlock data
          item.update!(unlock_type: unlock_type, unlock_id: data)

          collectable.update!(item_id: item.id)
          break
        end
      end
    end
  end

  desc 'Sets extra data for collectables based on item unlocks'
  task set_extras: :environment do
    PaperTrail.enabled = false
    puts 'Setting extra data for collectables based on item unlocks'

    descriptions = Item.locale_columns(:description)

    Item.where(unlock_type: 'Barding').each do |item|
      Barding.find_by(id: item.unlock_id)&.update!(item.slice(descriptions))
    end

    Item.where(unlock_type: 'Fashion').each do |item|
      Fashion.find_by(id: item.unlock_id)&.update!(item.slice(descriptions))
    end
  end
end
