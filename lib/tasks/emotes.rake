namespace :emotes do
  desc 'Create the emotes'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating emotes'

    categories = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('EmoteCategory', locale: locale).each do |category|
        next unless category['Name'].present?

        data = h[category['#']] || { id: category['#'] }
        data["name_#{locale}"] = sanitize_name(category['Name'], locale: locale)
        h[category['#']] = data
      end
    end

    categories.values.each do |category|
      if existing = EmoteCategory.find_by(id: category[:id])
        existing.update!(category) if updated?(existing, category)
      else
        EmoteCategory.create!(category)
      end
    end

    commands = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('TextCommand', locale: locale).each do |command|
        next unless command['Command'].present?

        data = h[command['#']] || {}
        data["command_#{locale}"] = command.values_at('Command', 'Alias', 'ShortCommand', 'ShortAlias')
          .compact.reject(&:empty?).uniq.join(', ')
        h[command['#']] = data
      end
    end

    emotes = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('Emote', locale: locale).each do |emote|
        next unless emote['Name'].present? && emote['TextCommand'] != '0' && emote['UnlockLink'] != '0'

        data = h[emote['#']] ||
          {
            id: emote['#'], order: emote['Order'], image_url: XIVData.image_url(emote['Icon']),
            category_id: emote['EmoteCategory']
          }.merge(commands[emote['TextCommand']])

        data["name_#{locale}"] = sanitize_name(emote['Name'], locale: locale)
        h[data[:id]] = data
      end
    end

    count = Emote.count

    emotes.values.each do |emote|
      if existing = Emote.find_by(id: emote[:id])
        existing.update!(emote) if updated?(existing, emote)
      else
        Emote.create!(emote)
      end
    end

    puts "Created #{Emote.count - count} new emotes"
  end
end
