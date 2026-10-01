namespace :occult_records do
  desc 'Create the occult records'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating occult records'

    count = OccultRecord.count

    records = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('MKDLore', locale: locale).each do |record|
        next unless record['Name'].present?

        data = h[record['#']] || { id: record['#'], image_url: XIVData.image_url(record['Image']) }

        data["name_#{locale}"] = sanitize_name(record['Name'], locale: locale)
        data["description_#{locale}"] = sanitize_text(record['Description'], preserve_space: true)
        h[data[:id]] = data
      end
    end

    records.values.each do |record|
      if existing = OccultRecord.find_by(id: record[:id])
        existing.update!(record) if updated?(existing, record)
      else
        OccultRecord.create!(record)
      end
    end

    OccultRecord.where(id: 1..30).update_all(
      location_en: 'South Horn',
      location_de: 'Südliches Kreszentia',
      location_fr: "L'île de Lunule Méridionale",
      patch: '7.25'
    )

    OccultRecord.where(id: 31..60).update_all(
      location_en: 'North Horn',
      location_de: 'Nördliche Kreszentia',
      location_fr: "L'île de Lunule septentrionale",
      patch: '7.55'
    )

    puts "Created #{OccultRecord.count - count} new occult records"
  end
end
