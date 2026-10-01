namespace 'sources:orchestrions' do
  desc 'Sets initial sources for Orchestrion rolls based on description (automated) and details (legacy)'
  task update: :environment do
    PaperTrail.enabled = false

    puts 'Creating Orchestrion sources'

    Orchestrion.all.each do |orchestrion|
      # Only set sources for an Orchestrion roll if none exist to avoid messing with manually entered data
      next if orchestrion.sources.any?

      case orchestrion.category.name_en
      when 'Ambient'
        type = SourceType.find_by(name_en: 'Purchase')
      when /Dungeons/
        type = SourceType.find_by(name_en: 'Dungeon')
        if text = instance_text(orchestrion)
          related = Instance.find_by(name_en: text)
        end
      when /Locales/
        type = SourceType.find_by(name_en: 'Other')
      when 'Online Store & Bonuses'
        type = SourceType.find_by(name_en: 'Premium')
      when 'Others'
        type = SourceType.find_by(name_en: 'Other')
      when 'Quests'
        type = SourceType.find_by(name_en: 'Quest')
      when /Raids/
        type = SourceType.find_by(name_en: 'Raid')
        if text = instance_text(orchestrion)
          related = Instance.find_by(name_en: text)
        end
      when 'Seasonal'
        type = SourceType.find_by(name_en: 'Event')
        limited = true
      when 'Trials'
        type = SourceType.find_by(name_en: 'Trial')
        if text = instance_text(orchestrion)
          related = Instance.find_by(name_en: text)
        end
      else
        type = SourceType.find_by(name_en: 'Other')
      end

      limited ||= false

      texts = ALL_LOCALES.each_with_object({}) do |locale, h|
        if related.present?
          h["text_#{locale}"] = related["name_#{locale}"]
        else
          h["text_#{locale}"] = orchestrion["description_#{locale}"]
        end
      end

      orchestrion.sources.create!(**texts, type: type, related_id: related&.id, limited: limited)
    end
  end
end

private
def instance_text(orchestrion)
  if matches = orchestrion.description_en.match(/obtained (?:on|in|at) (.+?)\./i)
    matches[1]
  end
end
