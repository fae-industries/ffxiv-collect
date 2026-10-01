namespace 'sources:pvp' do
  desc 'Create PvP sources'
  task update: :environment do
    PaperTrail.enabled = false
    pvp_type = SourceType.find_by(name_en: 'PvP')

    puts 'Creating PvP Series sources'

    XIVData.sheet('PvPSeries').each do |series|
      32.times do |level|
        item_id = series["LevelRewards[#{level}].LevelRewardItem[0]"]

        if item_id != '0' && unlock = Item.find(item_id).unlock
          next if unlock.sources.any?

          texts = ALL_LOCALES.each_with_object({}) do |locale, h|
            h["text_#{locale}"] = I18n.t('sources.pvp', series: series['#'], level: level, locale: locale)
          end

          unlock.sources.create!(**texts, type: pvp_type, limited: true)
        end
      end
    end
  end
end
