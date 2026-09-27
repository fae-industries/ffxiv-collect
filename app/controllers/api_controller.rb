class ApiController < ApplicationController
  # Skip irrelevant application controller hooks
  skip_before_action :set_locale, :set_characters, :display_announcements

  before_action :set_defaults, :set_language, :set_owned

  def render_not_found
    render json: { status: 404, error: 'Not found' }, status: :not_found
  end

  private
  def sanitize_query_params
    # Construct the search query from the params, excluded meta params
    query = params.except(:format, :controller, :action)

    # Blacklist all user & character params
    query.reject! { |param| param.match?('user_') || param.match?('character_') }

    query.each do |k, v|
      if k =~ /_in\Z/
        case v
        when /,/
          query[k] = v.split(/,\s?/)
        when /\b\.{3}\b/
          query[k] = Range.new(*v.scan(/\d+/), exclusive: true)
        when /\b\.{2}\b/
          query[k] = Range.new(*v.scan(/\d+/))
        end
      end
    end
  end

  def set_defaults
    request.format = :json unless params[:format]

    if params[:action] == 'index'
      @query = sanitize_query_params
    end
  end

  def set_language
    language = params[:language]&.to_sym

    if language.present? && I18n.available_locales.include?(language)
      I18n.locale = language
    else
      I18n.locale = :en
    end
  end

  def set_owned
    collectable = controller_name.downcase

    case action_name
    when 'index'
      @owned = Redis.current.hgetall(collectable)
    when 'show'
      @owned = { params[:id] => Redis.current.hget(collectable, params[:id]) }
    end
  end
end
