class SettingsController < ApplicationController
  before_action :verify_signed_in!
  before_action :set_user

  def edit
    if @character.present? && !@character.verified_user?(@user)
      link = view_context.link_to(t('alerts.verify_ownership'), verify_character_path(@character))
      flash.now[:alert_fixed] = t('alerts.settings_not_verified', link: link)
    end

    @identities = @user.identities.each_with_object({}) do |identity, h|
      h[identity.provider.to_sym] = identity
    end
  end

  def unlink_identity
    unless @user.identities.count > 1
      flash[:error] = t('alerts.authentication_method_needed')
      return redirect_to settings_path
    end

    provider = params[:provider].to_sym

    if User.omniauth_providers.include?(provider)
      identity = @user.identities.find_by(provider: provider)
      identity.destroy!

      # Replace the user's current identity if needed
      if @user.current_identity_id == identity.id
        @user.update!(current_identity: @user.identities.last)
      end

      flash[:success] = t('alerts.authentication_method_deleted')
    end

    redirect_to settings_path
  end

  def update_user
    if current_user.update(user_params)
      flash[:success] = t('alerts.settings_updated')
      redirect_to settings_path
    else
      flash[:error] = t('alerts.settings_error')
      render :edit
    end
  end

  def update_character
    if @character.present? && @character.verified_user?(current_user) && @character.update(character_params)
      flash[:success] = t('alerts.settings_updated')
      redirect_to settings_path
    else
      flash[:error] = t('alerts.settings_error')
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:database, :zen)
  end

  def character_params
    params.require(:character).permit(:public, :pricing_data_center)
  end

  def set_user
    @user = current_user
  end
end
