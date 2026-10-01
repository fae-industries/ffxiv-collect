namespace :frames do
  desc "Create the framer's kits"
  task create: :environment do
    PaperTrail.enabled = false

    puts "Creating framer's kits"

    # Create frames only when a BannerBg is present. This should include all Framer's Kits
    # and quest/instance unlocks. It will ignore clutter like minion accents.
    frames = XIVData.sheet('BannerBg', locale: 'en').each_with_object({}) do |bg, h|
      id = bg['UnlockCondition']
      next if id == '0' || id == '1'

      h[id] = { id: id, order: bg['SortKey'], 'name_en' => sanitize_name(bg['Name']) }
    end

    # Add Tataru's Bespoke kit which lacks a BannerBg
    frames['573'] = { id: '573', order: '0',
                      'name_en' => "Tataru's Bespoke",
                      'name_de' => 'Tatarus Wohlstandsmanufaktur',
                      'name_fr' => 'La Tarufacture de Tataru',
                      'name_ja' => 'タタルの大繁盛商店' }

    # Act like the township frames don't exist because they don't have unique BannerCondition IDs
    frames.delete('299')
    frames.delete('346')

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('BannerBg', locale: locale).each do |bg|
        id = bg['UnlockCondition']

        if frames.key?(id)
          frames[id]["name_#{locale}"] = sanitize_name(bg['Name'], locale: locale)
        end
      end
    end

    # Set a generic name for the Vana'diel kit since it contains a variety of components
    frames['1097'].merge!({
      name_en: "Echoes of Vana'diel",
      name_de: "Echos aus Vana'diel",
      name_fr: "Échos de Vana'diel",
      name_ja: "エコーズ オブ ヴァナ・ディール",
    })

    XIVData.sheet('BannerCondition').each do |condition|
      next unless frame = frames[condition['#']]

      case condition['UnlockType1']
      when '1'
        frame.merge!(unlock_type: 'Quest', unlock_id: condition['UnlockCriteria1[0]'])
      when '4'
        frame.merge!(unlock_type: 'Instance', unlock_id: condition['UnlockCriteria1[0]'])
      # when '6'
      #   frame.merge!(unlock_type: 'Minion', unlock_id: condition['UnlockCriteria1[0]'])
      when '9'
        # For type 9, the criterion links to an item
        frame[:item_link] = condition['UnlockCriteria1[0]']
      # when '11'
        # Crystalline Conflict Seasonal Rewards
        # These don't properly link to items any more
      end
    end

    # Links Item AdditionalData to Frame ID so they can be looked up from Item
    frame_links = frames.each_with_object({}) do |(key, frame), h|
      if frame.key?(:item_link)
        h[frame.delete(:item_link)] = frame[:id]
      end
    end

    XIVData.sheet('Item').each do |item|
      if item['ItemAction'] == '2234'
        frame = frames[frame_links[item['AdditionalData']]]

        # Skip items that can't be linked back to a frame (should just be for type 11 above)
        next if frame.nil?

        frame[:item_id] = item['#']
        Item.find(item['#']).update!(unlock_type: 'Frame', unlock_id: frame[:id])
      end
    end

    count = Frame.count
    PVP_TYPE = SourceType.find_by(name_en: 'PvP').freeze
    QUEST_TYPE = SourceType.find_by(name_en: 'Quest').freeze

    frames.values.each do |frame|
      data = frame.except(:unlock_type, :unlock_id)

      # Remove item linkages for Crystalline Conflict seasonal rewards since they got messed up
      data[:item_id] = nil if frame['name_en'].match?(/.+ Conflict \d+/)

      if existing = Frame.find_by(id: frame[:id])
        existing.update!(data) if updated?(existing, data)
      else
        created = Frame.create!(data)

        if frame['name_en'].match?(/Conflict \d+/)
          texts = ALL_LOCALES.each_with_object({}) do |locale, h|
            h["text_#{locale}"] = I18n.t('sources.crystalline_conflict', locale: locale)
          end

          created.sources.create!(**texts, type: PVP_TYPE, limited: true)
        elsif frame[:unlock_type] == 'Quest'
          texts = ALL_LOCALES.each_with_object({}) do |locale, h|
            h["text_#{locale}"] = Quest.find(frame[:unlock_id])["name_#{locale}"]
          end

          created.sources.create!(**texts, type: QUEST_TYPE, related_type: 'Quest',
                                  related_id: frame[:unlock_id])
        elsif frame[:unlock_type] == 'Instance'
          instance = Instance.find_by(content_id: frame[:unlock_id])
          instance_type = instance.content_type.name_en

          texts = ALL_LOCALES.each_with_object({}) do |locale, h|
            h["text_#{locale}"] = instance["name_#{locale}"]
          end

          created.sources.create!(**texts, type: SourceType.find_by(name_en: instance_type),
                                  related_type: 'Instance', related_id: frame[:unlock_id])
        end
      end
    end

    puts "Created #{Frame.count - count} new framer's kits"

    next if ENV['SKIP_IMAGES']

    puts "Creating framer's kit images"

    frames.each { |k, _| frames[k] = {} }

    XIVData.sheet('CharaCardBase', locale: 'en').each do |base|
      id = base['UnlockCondition']

      if frames.key?(id)
        frames[id][:base] = XIVData.image_path(base['Image'], hd: true)
      end
    end

    XIVData.sheet('CharaCardDecoration', locale: 'en').each do |decoration|
      id = decoration['UnlockCondition']

      if frames.key?(id)
        key = case decoration['Component']
              when '1' then :backing
              when '2' then :overlay
              when '3' then :plate_portrait
              when '4' then :plate_frame
              when '5' then :accent
              end

        frames[id][key] = XIVData.image_path(decoration['Image'], hd: true)
      end
    end

    { background: 'BannerBg', portrait_frame: 'BannerFrame', portrait_accent: 'BannerDecoration' }.each do |key, sheet|
      XIVData.sheet(sheet, locale: 'en').each do |banner|
        id = banner['UnlockCondition']

        if frames.key?(id)
          frames[id][key] = XIVData.image_path(banner['Image'], hd: true)
        end
      end
    end

    XIVData.sheet('CharaCardHeader', locale: 'en').each do |header|
      id = header['UnlockCondition']

      if frames.key?(id)
        frames[id][:top_border] = XIVData.image_path(header['TopImage'], hd: true) if header['TopImage'] != '0'
        frames[id][:bottom_border] = XIVData.image_path(header['BottomImage'], hd: true) if header['BottomImage'] != '0'
      end
    end

    FRAME_IMAGES_DIR = Rails.root.join('public/images/frames').freeze
    FRAME_ELEMENTS = %i(base backing overlay plate_frame).freeze

    frames.each do |id, images|
      frame = Frame.find(id)
      frame.update!(portrait_only: !images.keys.intersect?(FRAME_ELEMENTS))

      output_path = FRAME_IMAGES_DIR.join("#{id}.png")

      unless output_path.exist?
        # Download BLOBs for each image layer
        layers = images.each_with_object({}) do |(k, image), h|
          h[k] = XIVData.download_image(image).body
        end

        if frame.portrait_only?
          image = ChunkyPNG::Image.new(512, 840, ChunkyPNG::Color::TRANSPARENT)

          layers.values.each do |layer|
            image.compose!(ChunkyPNG::Image.from_blob(layer))
          end

          image.save(output_path)
        else
          # Create two frame versions to support standard and mirrored portraits
          save_frame_image(layers, output_path)
          save_frame_image(layers, output_path, mirrored: true)
        end
      end
    end
  end

  def save_frame_image(layers, output_path, mirrored: false)
    if mirrored
      portrait_x = 604
      path = output_path.to_s.sub('.png', '_2.png')
    else
      portrait_x = 1444
      path = output_path.to_s
    end

    image = ChunkyPNG::Image.new(2560, 1612, ChunkyPNG::Color::TRANSPARENT)

    image.compose!(ChunkyPNG::Image.from_blob(layers[:backing]), 0, 0) if layers.key?(:backing)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:base]), 540, 300) if layers.key?(:base)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:overlay]), 540, 300) if layers.key?(:overlay)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:background]), portrait_x, 300) if layers.key?(:background)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:portrait_frame]), portrait_x, 300) if layers.key?(:portrait_frame)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:portrait_accent]), portrait_x, 300) if layers.key?(:portrait_accent)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:plate_portrait]), portrait_x - 192, 0) if layers.key?(:plate_portrait)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:plate_frame]), 320, 172) if layers.key?(:plate_frame)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:top_border]), 320, 172) if layers.key?(:top_border)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:bottom_border]), 320, 956) if layers.key?(:bottom_border)
    image.compose!(ChunkyPNG::Image.from_blob(layers[:accent]), mirrored ? portrait_x - 256 : portrait_x + 262, 760) if layers.key?(:accent)

    image.trim!
    image.save(path)
  end
end
