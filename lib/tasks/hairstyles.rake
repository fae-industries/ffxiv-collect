namespace :hairstyles do
  desc 'Create the hairstyles'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating hairstyles'

    count = Hairstyle.count

    hairstyles = XIVData.sheet('CharaMakeCustomize').each_with_object({}) do |custom, h|
      # Skip most hairstyle that are not unlocked by items
      next if custom['HintItem'] == '0' && custom['UnlockLink'] != '228'

      id = custom['UnlockLink']

      # If the initial data exists, just add the image
      if data = h[id]
        data[:image_urls] << XIVData.image_url(custom['Icon'])
        next
      end

      data = { id: id, image_urls: [XIVData.image_url(custom['Icon'])] }

      item = Item.find_by(id: custom['HintItem'])

      # The rest of the data will be set manually for hairstyles without linked items
      unless item.present?
        h[id] = data
        next
      end

      # Set the Hairstyle name to the item name sans the "Modern Aesthetics"
      data['name_en'] = sanitize_name(item['name_en'], locale: :en)
        .gsub(/.+-\s(.+)/, '\1')

      data['name_de'] = sanitize_name(item['name_de'], locale: :de)
        .gsub(/.+„(.+?)“/, '\1') # Quote marks
        .gsub(/.+(?:Ästhetik\s-|,)\s(.+)/, '\1') # Prefixes
        .upcase_first

      data['name_fr'] = sanitize_name(item['name_fr'], locale: :fr)
        .gsub(/.+“(.+?)”/, '\1') # Hairstyles
        .gsub(/.+:\s(.+)/, '\1') # Facepaint
        .upcase_first

      data['name_ja'] = sanitize_name(item['name_ja'], locale: :ja)
        .gsub(/.+:(.+)/, '\1')

      data['name_tc'] = sanitize_name(item['name_tc'], locale: :tc)
        .gsub(/.+：(.+)/, '\1')

      data.merge!(item.slice(Item.locale_columns(:description)))

      data[:item_id] = item.id.to_s

      case item.description_en
      when /♂/ then data[:gender] = 'male'
      when /♀/ then data[:gender] = 'female'
      end

      data[:vierable] = !item.description_en.match(/viera/i)
      data[:femhrothable] = !item.description_en.match(/hrothgar/i) && data[:gender] != 'male'
      data[:hrothable] = !item.description_en.match(/(?<!female )hrothgar/i) && data[:gender] != 'female'

      h[id] = data
    end

    hairstyles['228'].merge!(name_en: 'Eternal Bonding', name_de: 'Ewige Bund',
                             name_fr: 'Lien Éternel', name_ja: 'Eternal Bonding',
                             name_tc: '永恆誓約', patch: '2.4',
                             vierable: true, hrothable: true, femhrothable: true)

    hairstyles.values.each do |hairstyle|
      # Skip incomplete hairstyles
      next unless hairstyle['name_en'].present?

      # Use the second (cuter) image as the primary image
      hairstyle[:image_url] = hairstyle[:image_urls].second

      # Store image URLs as a comma separated list
      hairstyle[:image_urls] = hairstyle[:image_urls].join(',')

      if existing = Hairstyle.find_by(id: hairstyle[:id])
        existing.update!(hairstyle) if updated?(existing, hairstyle)
      else
        Hairstyle.create!(hairstyle)
      end
    end

    puts "Created #{Hairstyle.count - count} new hairstyles"
  end
end
