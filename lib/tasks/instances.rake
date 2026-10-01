namespace :instances do
  desc 'Create the instances'
  task create: :environment do
    puts 'Creating instances'

    count = Instance.count

    # Create the ContentTypes (Dungeon, Raid, etc.)
    types = XIVData.sheet('ContentType', locale: 'en').each_with_object({}) do |type, h|
      next unless type['Name'].present?

      name = type['Name'].singularize.sub('Chaotic Alliance', 'Chaotic').sub(' Finder', '')

      h[type['#']] = { id: type['#'], name_en: name }
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('ContentType', locale: locale).each do |type|
        next unless types.has_key?(type['#'])
        types[type['#']]["name_#{locale}"] = type['Name']
      end
    end

    types.values.each do |type|
      if existing = ContentType.find_by(id: type[:id])
        existing.update!(type) if updated?(existing, type)
      else
        ContentType.create!(type)
      end
    end

    # Identify the content types for instances we use as source types
    content_type_ids = ContentType.instance_types.pluck(:id).map(&:to_s)

    # Create Instances
    instances = XIVData.sheet('ContentFinderCondition', locale: 'en').each_with_object({}) do |instance, h|
      next unless instance['Name'].present? && content_type_ids.include?(instance['ContentType'])
        # Content ID is used to sync with the ID used by the DB sites
        h[instance['#']] = { id: instance['#'], content_id: instance['Content'], content_type_id: instance['ContentType'],
                             name_en: sanitize_name(instance['Name'], upcase_first_only: true) }
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('ContentFinderCondition', locale: locale).each do |instance|
        next unless instances.has_key?(instance['#'])
        instances[instance['#']]["name_#{locale}"] = sanitize_name(instance['Name'], locale: locale, upcase_first_only: true)
      end
    end

    instances.values.each do |instance|
      if existing = Instance.find_by(id: instance[:id])
        existing.update!(instance) if updated?(existing, instance)
      else
        Instance.create!(instance)
      end
    end

    puts "Created #{Instance.count - count} new instances"
  end
end
