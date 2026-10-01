TITLE_COLUMNS = %w(ID Name_* NameFemale_* IsPrefix Order GameContentLinks)

namespace :titles do
  desc 'Create the titles'
  task create: :environment do
    puts 'Creating titles'
    count = Title.count

    titles = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('Title', locale: locale).each do |title|
        next unless title['Masculine'].present?

        data = h[title['#']] || { id: title['#'], order: title['Order'] }

        if title['IsPrefix'] == 'True'
          data["name_#{locale}"] = sanitize_text("#{title['Masculine']}…")
          data["female_name_#{locale}"] = sanitize_text("#{title['Feminine']}…")
        else
          data["name_#{locale}"] = sanitize_text("…#{title['Masculine']}")
          data["female_name_#{locale}"] = sanitize_text("…#{title['Feminine']}")
        end

        h[data[:id]] = data
      end
    end

    XIVData.sheet('Achievement').each do |achievement|
      if title = titles[achievement['Title']]
        title[:achievement_id] = achievement['#']
      end
    end

    titles.values.each do |title|
      if existing = Title.find_by(id: title[:id])
        existing.update!(title) if updated?(existing, title)
      elsif title[:achievement_id].present?
        Title.create!(title)
      end
    end

    puts "Created #{Title.count - count} new titles"
  end
end
