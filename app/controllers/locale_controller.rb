class LocaleController < ApplicationController
  def update
    locale = params[:locale]&.to_sym
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)

    set_permanent_cookie(:locale, locale.downcase)

    redirect_back(fallback_location: root_path)
  end
end
