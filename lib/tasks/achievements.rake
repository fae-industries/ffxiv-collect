namespace :achievements do
  desc 'Create the achievements'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating achievement types'
    types = XIVData.sheet('AchievementKind', locale: 'en').each_with_object({}) do |type, h|
      next unless type['Order'] != '0'
      h[type['#']] = { id: type['#'], name_en: type['Name'], order: type['Order'] }
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('AchievementKind', locale: locale).each do |type|
        next unless type['Order'] != '0'
        types[type['#']]["name_#{locale}"] = type['Name']
      end
    end

    types.values.each do |type|
      if existing = AchievementType.find_by(id: type[:id])
        existing.update!(type) if updated?(existing, type)
      else
        AchievementType.create!(type)
      end
    end

    puts 'Creating achievement categories'
    categories = XIVData.sheet('AchievementCategory', locale: 'en').each_with_object({}) do |category, h|
      next unless category['Order'] != '0'
      h[category['#']] = { id: category['#'], name_en: category['Name'], order: category['Order'],
                           type_id: AchievementType.find(category['AchievementKind']).id.to_s }
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('AchievementCategory', locale: locale).each do |category|
        next unless category['Order'] != '0'
        categories[category['#']]["name_#{locale}"] = category['Name']
      end
    end

    categories.values.each do |category|
      if existing = AchievementCategory.find_by(id: category[:id])
        existing.update!(category) if updated?(existing, category)
      else
        AchievementCategory.create!(category)
      end
    end

    puts 'Creating achievements'
    count = Achievement.count

    achievements = XIVData.sheet('Achievement', locale: 'en').each_with_object({}) do |achievement, h|
      next unless achievement['Name'].present? && achievement['AchievementCategory'] != '0'

      data = { id: achievement['#'], name_en: sanitize_name(achievement['Name']),
               description_en: sanitize_text(achievement['Description']), points: achievement['Points'],
               category_id: achievement['AchievementCategory'], order: achievement['Order'],
               image_url: XIVData.image_url(achievement['Icon']) }

      if achievement['Item'] != '0'
        data[:item_id] = Item.find(achievement['Item']).id.to_s
      end

      h[achievement['#']] = data
    end

    OTHER_LOCALES.each do |locale|
      XIVData.sheet('Achievement', locale: locale).each do |achievement|
        next unless achievement['Name'].present? && achievement['AchievementCategory'] != '0'

        achievements[achievement['#']].merge!("name_#{locale}" => sanitize_name(achievement['Name'], locale: locale),
                                              "description_#{locale}" => sanitize_text(achievement['Description']))
      end
    end

    achievements.values.each do |achievement|
      if existing = Achievement.find_by(id: achievement[:id])
        existing.update!(achievement) if updated?(existing, achievement)
      else
        Achievement.create!(achievement)
      end
    end

    puts "Created #{Achievement.count - count} new achievements"
  end
end
