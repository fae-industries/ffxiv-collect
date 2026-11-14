module SettingsHelper
  def database_options(selected = nil)
    options_for_select([['Garland Tools', 'garland'], ['FFXIV Teamcraft', 'teamcraft']], selected)
  end

  def pricing_region_options(character)
    options = Character.universalis_regions.values.map do |region|
      [region.titleize, region.underscore]
    end

    options_for_select(options, character.pricing_region)
  end

  def identity_status(identities, provider)
    identity = identities[provider]

    if identity.present?
      fa_icon('check-circle', text: identity.username)
    else
      button_to t('connect'), omniauth_authorize_path(User, provider), class: "btn btn-secondary btn-sm"
    end
  end

  def unlink_identity_button(identities, provider)
    if identities[provider].present?
      can_delete = identities.size > 1

      link_to(fa_icon('trash', text: t('delete')), unlink_identity_path(provider: provider),
        method: :delete, class: "btn btn-danger btn-sm#{ ' disabled' unless can_delete}")
    end
  end
end
