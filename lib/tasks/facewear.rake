namespace :facewear do
  desc 'Create the facewear'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating facewear'

    facewears = XIVData.sheet('GlassesStyle', locale: 'en').each_with_object({}) do |facewear, h|
      next unless facewear['Name'].present? && facewear['Icon'] != '0'

      id = (facewear['#'].to_i + 1).to_s

      h[id] = {
        id: id,
        name_en: sanitize_name(facewear['Name']),
        lodestone_name: sanitize_name(facewear['Singular'], capitalize: true),
        order: facewear['Order'],
        image_urls: [],
      }
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('GlassesStyle', locale: locale).each do |facewear|
        next unless facewear['Name'].present? && facewear['Icon'] != '0'

        id = (facewear['#'].to_i + 1).to_s

        facewears[id]["name_#{locale}"] = sanitize_name(facewear['Name'], locale: locale)
      end
    end

    XIVData.sheet('Glasses').each do |facewear|
      id = (facewear['Style'].to_i + 1).to_s

      next unless facewear['Name'].present?

      facewears[id][:image_urls] << XIVData.image_url(facewear['Icon'])
    end

    count = Facewear.count

    facewears.values.each do |facewear|
      # Skip incomplete facewear
      next if facewear[:image_urls].empty?

      # Use the first image as the primary image
      facewear[:image_url] = facewear[:image_urls].first

      # Store image URLs as a comma separated list
      facewear[:image_urls] = facewear[:image_urls].join(',')

      if existing = Facewear.find_by(id: facewear[:id])
        existing.update!(facewear) if updated?(existing, facewear)
      else
        Facewear.create!(facewear)
      end
    end

    puts "Created #{Facewear.count - count} new facewear"
  end
end
