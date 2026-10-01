namespace :bardings do
  desc 'Create the bardings'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating bardings'

    count = Barding.count

    bardings = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('BuddyEquip', locale: locale).each do |barding|
        next unless barding['Name'].present? && barding['Order'] != '0'

        data = h[barding['#']] || { id: barding['#'], order: barding['Order'],
                                    image_url: XIVData.image_url(barding['IconBody'] == '0' ? barding['IconHead'] : barding['IconBody']) }

        data["name_#{locale}"] = sanitize_name(barding['Name'], locale: locale)
        h[data[:id]] = data
      end
    end

    bardings.values.each do |barding|
      if existing = Barding.find_by(id: barding[:id])
        existing.update!(barding) if updated?(existing, barding)
      else
        Barding.create!(barding)
      end
    end

    puts "Created #{Barding.count - count} new bardings"
  end
end
