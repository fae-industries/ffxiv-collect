namespace 'sources:achievements' do
  desc 'Create sources from Achievement rewards for non-time limited quests'
  task update: :environment do
    PaperTrail.enabled = false
    achievement_type = SourceType.find_by(name_en: 'Achievement')

    puts 'Creating Achievement sources'

    achievements = Achievement.exclude_time_limited.joins(:item)
      .where('items.unlock_type is not null')

    achievements.each do |achievement|
      collectable_id = achievement.item.unlock_id
      collectable_type = achievement.item.unlock_type

      next if Source.exists?(collectable_id: collectable_id, collectable_type: collectable_type,
                             type: achievement_type)

      texts = ALL_LOCALES.each_with_object({}) do |locale, h|
        h["text_#{locale}"] = achievement["name_#{locale}"]
      end

      Source.create!(
        collectable_id: collectable_id,
        collectable_type: collectable_type,
        type: achievement_type,
        related_id: achievement.id,
        **texts,
      )
    end
  end
end
