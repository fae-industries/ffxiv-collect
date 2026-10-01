namespace :field_records do
  desc 'Create the field records'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating field records'

    count = FieldRecord.count
    links = Hash.new { [] }

    records = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('MYCWarResultNotebook', locale: locale).each do |record|
        next unless record['Name'].present?

        # Set record links on the first pass
        unless h.has_key?(record['Number']) || record['Link'] == '0'
          links[record['Link']] <<= record['Number']
        end

        data = h[record['Number']] || { id: record['Number'], rarity: record['Rarity'],
                                        image_url: XIVData.image_url(record['Icon']),
                                        large_image_url: XIVData.image_url(record['Image']) }

        data["name_#{locale}"] = sanitize_name(record['Name'], locale: locale)
        data["description_#{locale}"] = sanitize_text(record['Description'], preserve_space: true)
        h[data[:id]] = data
      end
    end

    links.values.each do |link|
      records[link[0]][:linked_record_id] = link[1]
      records[link[1]][:linked_record_id] = link[0]
    end

    records.values.each do |record|
      # Append I/II suffixes to records with multiple entries
      if record[:linked_record_id].present? && !record['name_en'].match?(/^Lyon /)
        suffix = record[:linked_record_id].to_i > record[:id].to_i ? 'I' : 'II'
        ALL_LOCALES.each do |locale|
          name = "name_#{locale}"
          record[name] = "#{record[name]} #{suffix}"
        end
      end

      if existing = FieldRecord.find_by(id: record[:id])
        existing.update!(record) if updated?(existing, record)
      else
        FieldRecord.create!(record)
      end
    end

    FieldRecord.where(id: 1..20).update_all(
      location_en: 'Southern Front',
      location_de: 'Südfront',
      location_fr: 'Front sud de Bozja',
      patch: '5.35'
    )

    FieldRecord.where(id: 21..30).update_all(
      location_en: 'Delubrium Reginae',
      location_de: 'Delubrium Reginae',
      location_fr: 'Delubrium Reginae',
      patch: '5.45'
    )

    FieldRecord.where(id: 31..50).update_all(
      location_en: 'Zadnor',
      location_de: 'Zadnor-Hochebene',
      location_fr: 'Hauts plateaux de Zadnor',
      patch: '5.55'
    )

    puts "Created #{FieldRecord.count - count} new field records"
  end
end
