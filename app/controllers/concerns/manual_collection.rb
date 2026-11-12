module ManualCollection
  extend ActiveSupport::Concern
  include Collection

  included do
    before_action :display_verify_alert!, only: :index

    rate_limit to: 10, within: 1.second, only: [:add, :remove], by: -> { @character.id }
  end

  def add_collectable(collection, collectable)
    if verified?
      collection << collectable
      head :no_content
    else
      head :forbidden
    end
  end

  def remove_collectable(collection, collectable)
    if verified?
      collection.destroy(collectable)
      head :no_content
    else
      head :forbidden
    end
  end

  private
  def display_verify_alert!
    return if !@character.present? || @peeking

    if user_signed_in?
      unless verified?
        link = view_context.link_to(t('alerts.verify_ownership'), verify_character_path(@character))
        flash.now[:alert_fixed] = t('alerts.not_verified', link: link)
      end
    else
      link = view_context.link_to(t('alerts.signed_in'), new_user_session_path)
      flash.now[:alert_fixed] = t('alerts.sign_in_to_track', link: link)
    end
  end
end
