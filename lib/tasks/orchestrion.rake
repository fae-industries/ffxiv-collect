namespace :orchestrions do
  desc 'Create the orchestrion rolls'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating orchestrion categories'
    categories = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('OrchestrionCategory', locale: locale).each do |category|
        next if category['Order'] == '0'

        data = h[category['#']] || { id: category['#'], order: category['Order'] }
        data["name_#{locale}"] = category ['Name']
        h[data[:id]] = data
      end
    end

    categories.values.each do |category|
      if existing = OrchestrionCategory.find_by(id: category[:id])
        existing.update!(category) if updated?(existing, category)
      else
        OrchestrionCategory.create!(category)
      end
    end

    puts 'Creating orchestrion rolls'
    count = Orchestrion.count
    orchestrions = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('Orchestrion', locale: locale).each do |orchestrion|
        next unless orchestrion['Name'].present?

        data = h[orchestrion['#']] || { id: orchestrion['#'] }
        data.merge!("name_#{locale}" => sanitize_name(orchestrion['Name'], locale: locale),
                    "description_#{locale}" => sanitize_text(orchestrion['Description']))
        h[data[:id]] = data
      end
    end

    XIVData.sheet('OrchestrionUiparam').each do |orchestrion|
      next unless orchestrions.has_key?(orchestrion['#'])
      orchestrions[orchestrion['#']].merge!(order: orchestrion['Order'] == '65535' ? nil : orchestrion['Order'],
                                            category_id: orchestrion['OrchestrionCategory'])
    end

    orchestrions.values.each do |orchestrion|
      if existing = Orchestrion.find_by(id: orchestrion[:id])
        existing.update!(orchestrion) if updated?(existing, orchestrion)
      else
        Orchestrion.create!(orchestrion)
      end
    end

    puts "Created #{Orchestrion.count - count} new orchestrion rolls"
  end
end
