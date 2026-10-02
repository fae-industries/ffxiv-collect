module ApplicationHelper
  def flash_class(level)
    case level
    when /notice/  then 'alert-dark'
    when /success/ then 'alert-success'
    when /error/   then 'alert-danger'
    when /alert/   then 'alert-warning'
    end
  end

  def active_path?(path)
    path.match?("/#{controller_name}")
  end

  def nav_link(text, icon, path, fab: false, action: nil)
    icon = fab ? fab_icon(icon, text: text) : fa_icon(icon, text: text)

    if action.present?
      bold = action_name == action
    else
      bold = active_path?(path)
    end

    link_to icon, path, class: "nav-link#{' bold' if bold}"
  end

  def provider_icon(provider, text)
    icon = case provider.to_s
    when 'discord'
      fab_icon('discord')
    when 'google_oauth2'
      fab_icon('google')
    when 'xivauth'
      fa_icon('key')
    end

    "#{icon} #{text}".html_safe
  end

  def safe_image_url(src, options = {})
    begin
      image_url(src, options)
    rescue Sprockets::Rails::Helper::AssetNotFound, ArgumentError
      # Fail gracefully when asset is missing from pipeline or image URL is nil
      nil
    end
  end

  def safe_image_tag(src, options = {})
    begin
      image_tag(src, options)
    rescue Sprockets::Rails::Helper::AssetNotFound, ArgumentError
      # Fail gracefully when asset is missing from pipeline or image URL is nil
      content_tag(:div, nil, options.slice(:class))
    end
  end

  def format_date(date)
    date.in_time_zone('America/New_York').strftime('%e %b %Y %H:%M')
  end

  def format_date_short(date)
    date&.utc&.strftime('%b %-d, %Y')
  end

  def user_avatar(user)
    if avatar_url = user&.avatar_url
      image_tag(avatar_url, class: 'avatar', referrerpolicy: 'no-referrer')
    end
  end

  def username(user)
    if identity = user&.current_identity
      provider_icon(identity.provider, identity.username)
    end
  end

  def fa_check(condition, text = true)
    condition ? fa_icon('check', text: (t('yes') if text)) : fa_icon('times', text: (t('no') if text))
  end

  def gender_symbol(gender)
    return nil unless gender.present?
    fa_icon(gender == 'male' ? 'mars' : 'venus', data: { toggle: 'tooltip', title: t("only.#{gender}") })
  end

  def stars(value)
    (fa_icon('star') * value).html_safe
  end

  def region
    case(I18n.locale)
    when :fr then 'fr'
    when :de then 'de'
    when :ja then 'jp'
    when :tc then 'tw'
    else 'na'
    end
  end

  def new_feature_badge(small: false)
    content_tag(:span, small ? '!' : t('new'), class: "badge badge-success#{ ' badge-pill' if small}")
  end

  def universalis_url(item_id)
    "https://universalis.app/market/#{item_id}"
  end

  def language_attribute
    case I18n.locale
    when :tc
      'zh-Hant'
    when :chs
      'zh-Hans'
    else
      I18n.locale.to_s
    end
  end
end
