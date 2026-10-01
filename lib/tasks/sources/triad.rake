namespace :sources do
  namespace :triad do
    desc 'Create card sources from in-game acquisition details'
    task update: :environment do
      PaperTrail.enabled = false

      achievement_type = SourceType.find_by(name_en: 'Achievement').freeze
      gold_saucer_type = SourceType.find_by(name_en: 'Gold Saucer').freeze

      puts 'Creating Card acquisition sources'
      XIVData.sheet('TripleTriadCardResident').each do |card|
        acquisition_type = card['AcquisitionType'].to_i
        acquisition_id = card['Acquisition']

        case acquisition_type
        when 2, 3
          if instance = Instance.find(acquisition_id)
            source_type = SourceType.find_by(name_en: instance.content_type.name_en)
            texts = ALL_LOCALES.each_with_object({}) do |locale, h|
              h["text_#{locale}"] = instance["name_#{locale}"]
            end
          end
        # when 4, 5
        #   Eureka/FATE
        # when 6
        #   NPC Opponent
        when 8
          # Pack item id
          source_type = gold_saucer_type
          pack = Pack.find_by(item_id: acquisition_id)
          PackCard.find_or_create_by!(pack_id: pack.id, card_id: card['#'])

          texts = ALL_LOCALES.each_with_object({}) do |locale, h|
            h["text_#{locale}"] = pack["name_#{locale}"]
          end
        # when 9
        #   Deep Dungeon Sack
        # when 10
        #   Shop
        when 11
          source_type = achievement_type
          achievement = Achievement.find(acquisition_id)

          texts = ALL_LOCALES.each_with_object({}) do |locale, h|
            h["text_#{locale}"] = achievement["name_#{locale}"]
          end
        end

        if source_type.present?
          card = Card.find(card['#'])

          next if card.sources.any?

          card.sources.create!(**texts, type: source_type)
        end
      end
    end
  end
end
