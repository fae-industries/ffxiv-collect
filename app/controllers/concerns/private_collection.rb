module PrivateCollection
  extend ActiveSupport::Concern
  include Collection

  def check_privacy!(*collections)
    check_private_verified_user!(*collections)
    check_lodestone_privacy!(*collections)
  end

  def check_lodestone_privacy!(*collections)
    return unless @character.present?

    unless @character.public_profile?
      display_privacy_alert!
      return
    end

    collections.each do |collection|
      unless public_collection?(collection)
        display_privacy_alert!
        return
      end
    end
  end

  def check_private_verified_user!(*collections)
    return unless @character.present?

    collections.each do |collection|
      unless public_collection?(collection) || verified?
        if generic_page?
          flash[:error] = t('alerts.private_collection_not_verified_generic')
        else
          flash[:error] = t('alerts.private_collection_not_verified')
        end

        return redirect_to_previous
      end
    end
  end

  private
  def public_collection?(collection)
    @character.send("public_#{collection}?")
  end

  def generic_page?
    !%w(achievements titles mounts minions facewear).include?(controller_name)
  end

  def display_privacy_alert!
    alert = generic_page? ? 'alerts.private_collection_generic' : 'alerts.private_collection'

    link = view_context.link_to(
      t('alerts.here'),
      "https://#{view_context.region}.finalfantasyxiv.com/lodestone/my/setting/account/",
      target: '_blank'
    )

    flash.now[:alert] = t(alert, link: link)
  end
end
