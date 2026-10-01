namespace :fashions do
  desc 'Create the fashion accessories'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating fashion accessories'

    count = Fashion.count
    fashions = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('Ornament', locale: locale).each do |fashion|
        next unless fashion['Singular'].present?
        next if Fashion.facewear_ids.include?(fashion['#'].to_i)

        data = h[fashion['#']] || { id: fashion['#'], order: fashion['Order'],
                                    image_url: XIVData.image_url(fashion['Icon']) }

        data["name_#{locale}"] = sanitize_name(fashion['Singular'], locale: locale)
        h[data[:id]] = data
      end
    end

    fashions.values.each do |fashion|
      fashion[:large_image_url] = fashion[:image_url].gsub(/008(\d{3})/, '067\1')

      if existing = Fashion.find_by(id: fashion[:id])
        existing.update!(fashion) if updated?(existing, fashion)
      else
        Fashion.create!(fashion)
      end
    end

    puts "Created #{Fashion.count - count} new fashion accessories"
  end
end
