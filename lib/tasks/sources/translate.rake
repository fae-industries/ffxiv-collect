namespace 'sources' do
  namespace 'related' do
    desc 'Translate sources with related IDs'
    task translate: :environment do
      PaperTrail.enabled = false
      Source.skip_callback(:save, :before, :assign_relations!)

      puts 'Translating automated sources'

      # Related sources (e.g. achievements)
      Source.where.not(related_type: nil).where.not(related_id: nil).includes(:related).each do |source|
        OTHER_LOCALES.each do |locale|
          source["text_#{locale}"] = source.related["name_#{locale}"]
        end

        source.save!
      end

      # Crafting sources
      crafting_type = SourceType.find_by(name_en: 'Crafting')
      Item.where.not(unlock_type: nil).where.not(recipe_id: nil).each do |item|
        source = Source.find_by(collectable_id: item.unlock_id, collectable_type: item.unlock_type,
                                type: crafting_type)

        texts = ALL_LOCALES.each_with_object({}) do |locale, h|
          job = I18n.t("leves.categories.#{item.crafter.downcase}", locale: locale)
          h["text_#{locale}"] = I18n.t("sources.crafted_by", job: job, locale: locale)
        end

        source.update!(**texts)
      end
    end
  end
end
