namespace 'sources:crafting' do
  desc 'Create sources from craftable items'
  task update: :environment do
    PaperTrail.enabled = false

    puts 'Creating Crafting sources'

    # Create crafting sources for items that have associated unlocks
    Item.where.not(unlock_type: nil).where.not(recipe_id: nil).each do |item|
      create_crafting_source(item, item.unlock)
    end

    # Create crafting sources for outfits based on their associated items
    Outfit.includes(:items).all.each do |outfit|
      next if outfit.sources.any?

      outfit.items.each do |item|
        if item.recipe_id.present?
          create_crafting_source(item, outfit)
          break
        end
      end
    end
  end

  def create_crafting_source(item, collectable)
    source_type = SourceType.find_by(name_en: 'Crafting')

    # Skip creation if the collectable has any crafting sources (the text will be different)
    return if collectable.sources.exists?(type: source_type)

    texts = ALL_LOCALES.each_with_object({}) do |locale, h|
      case collectable
      when Outfit
        # Outfits have multiple recipes, so skip identifying the crafter
        h["text_#{locale}"] = I18n.t('sources.crafted', locale: locale)
      else
        job = I18n.t("leves.categories.#{item.crafter.downcase}", locale: locale)
        h["text_#{locale}"] = I18n.t('sources.crafted_by', job: job, locale: locale)
      end
    end

    related_id = item.recipe_id unless collectable.is_a?(Outfit)

    collectable.sources.create!(**texts, type: source_type, related_id: related_id)
  end
end
