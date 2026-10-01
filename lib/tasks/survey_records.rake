namespace :survey_records do
  desc 'Create the survey records'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating survey records'

    SurveyRecordSeries.find_or_create_by!(id: 1, name_en: "The Sil'dihn Subterrane", name_de: "Unterstadt Von Sil'dih",
                                          name_fr: "Canalisations Sildiennes", name_ja: "シラディハ水道")
    SurveyRecordSeries.find_or_create_by!(id: 2, name_en: 'Mount Rokkon', name_de: 'Der Rokkon',
                                          name_fr: 'Le mont Rokkon', name_ja: '六根山')
    SurveyRecordSeries.find_or_create_by!(id: 3, name_en: 'Aloalo Island', name_de: 'Aloalo',
                                          name_fr: "L'île d'Aloalo", name_ja: 'アロアロ島')
    SurveyRecordSeries.find_or_create_by!(id: 4, name_en: "The Merchant's Tale", name_de: 'Des Händlers Liebesmüh',
                                          name_fr: 'Contes du Camelot', name_ja: '商客物語')

    series_record_ids = XIVData.sheet('VVDNotebookSeries').each_with_object({}) do |series, h|
      next unless series['Name'].present?

      h[series['#']] = series.filter_map do |k, v|
        v if k =~ /Contents/ && v != '0'
      end
    end

    count = SurveyRecord.count

    records = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('VVDNotebookContents', locale: locale).each do |record|
        next unless record['Name'].present?

        data = h[record['#']] || { id: record['#'], image_url: XIVData.image_url(record['Icon']),
                                   large_image_url: XIVData.image_url(record['Image']) }
        data["name_#{locale}"] = sanitize_name(record['Name'], locale: locale)
        data["description_#{locale}"] = sanitize_text(record['Description'].gsub(/(?<!\n)\n(?!\n)/, "\n\n"),
                                                      preserve_space: true)
        h[data[:id]] = data
      end
    end

    # Assign the series ID and order to each record
    series_record_ids.each do |series_id, record_ids|
      record_ids.each.with_index(1) do |record_id, order|
        records[record_id][:series_id] = series_id
        records[record_id][:order] = order.to_s
      end
    end

    records.values.each do |record|
      if existing = SurveyRecord.find_by(id: record[:id])
        existing.update!(record) if updated?(existing, record)
      else
        SurveyRecord.create!(record)
      end
    end

    puts "Created #{SurveyRecord.count - count} new Survey Records"
  end
end
