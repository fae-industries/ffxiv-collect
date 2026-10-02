class ApplicationController < ActionController::Base
  before_action :set_locale, :set_characters, :display_announcements

  SUPPORTED_LOCALES = %i(en de fr ja zh-tw).freeze

  def new_session_path(scope)
    new_user_session_path
  end

  def redirect_to_previous
    redirect_to session.delete(:return_to) || root_path
  end

  def set_permanent_cookie(key, value)
    cookies[key] = { value: value, expires: 20.years.from_now, same_site: :lax }
  end

  def render_private_character_flash!(character)
    flash[:error] = t('alerts.private_character',
                      link: view_context.link_to(t('alerts.here'), verify_character_path(character)))
  end

  def verify_signed_in!
    unless user_signed_in?
      flash[:alert] = t('alerts.not_signed_in')
      redirect_to_previous
    end
  end

  def verify_character!
    unless @character.present?
      flash[:alert] = t('alerts.character_not_selected')
      redirect_to root_path
    end
  end

  def verify_group_membership!
    unless @group.public? || @group.valid_member?(user: current_user, character: @character)
      flash[:alert] = t('alerts.groups.membership_failure')
      redirect_to root_path
    end
  end

  # Verify that the user is signed in with a verified character selected
  def verify_user!
    unless user_signed_in? && @character&.verified_user?(current_user)
      redirect_to_previous
    end
  end

  def log_backtrace(exception)
    Rails.logger.error(exception.inspect)
    exception.backtrace.first(3).each { |line| Rails.logger.error(line) }
  end

  private
  def set_locale
    if cookies[:locale].nil?
      locale = AcceptLanguage.parse(request.headers.fetch('HTTP_ACCEPT_LANGUAGE', 'en')).match(*SUPPORTED_LOCALES)

      # Map the BCP 47 language tags to the shorthand used by the application
      locale = case locale
      when :'zh-tw'
        :tc
      else
        locale
      end

      set_permanent_cookie(:locale, locale || I18n.default_locale)
    end

    I18n.locale = cookies[:locale]
  end

  def set_characters
    if cookies[:peek].present?
      @character = Character.find_by(id: cookies[:peek])
      @peeking = true

      if @character&.private?
        cookies[:peek] = nil
        flash[:error] = t('alerts.character_set_to_private')
        return redirect_to root_path
      end
    elsif user_signed_in?
      @character = current_user.character

      if @character&.private?(current_user)
        current_user.update(character_id: nil)
        flash[:error] = t('alerts.character_set_to_private')
        return redirect_to root_path
      end
    elsif cookies[:character].present?
      @character = Character.find_by(id: cookies[:character])

      if @character&.private?
        cookies[:character] = nil
        flash[:error] = t('alerts.character_set_to_private')
        return redirect_to root_path
      end
    end

    if @character&.stale?
      @character.sync
    end
  end

  def append_info_to_payload(payload)
    super

    payload[:character_id] = @character&.id
    payload[:user_id] = current_user&.id
  end

  def display_announcements
    # flash.now[:success_fixed] = 'This is an announcement.'
  end
end
