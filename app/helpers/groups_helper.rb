module GroupsHelper
  def group_collectable_td(character, collectable)
    owned = @owned_ids[character.id].include?(collectable.id)

    content_tag(:td, fa_check(owned, false),
                class: "text-center #{owned ? 'text-success' : 'text-danger'} expansion-#{collectable.expansion}")
  end

  def group_collection_options(selected)
    options = %w(mounts minions hairstyles emotes spells beasts bardings fashions facewear cards field_records survey_records).map do |option|
      [t("#{option}.title"), option]
    end

    options_for_select(options, selected)
  end

  def group_ownership_options(selected = nil)
    options_for_select([[t('show_all'), 'all'], [t('only.missing'), 'missing']], selected)
  end

  def group_type(group)
    group.class.to_s.titleize
  end

  def polymorphic_group_path(group, path)
    if group.class == FreeCompany
      send("free_company_#{path}_path", group.id)
    else
      send("group_#{path}_path", group.slug)
    end
  end
end
