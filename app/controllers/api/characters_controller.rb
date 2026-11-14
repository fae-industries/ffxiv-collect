class Api::CharactersController < ApiController
  before_action :set_character
  before_action :set_collection, :set_owned, :set_prices, only: [:owned, :missing]
  before_action :check_latest

  def show
    if params[:times].present?
      @times = CharacterAchievement.where(character_id: @character.id).map do |achievement|
        { id: achievement.achievement_id, time: achievement.created_at }
      end
    end
  end

  def owned
    render 'api/characters/ownership'
  end

  def missing
    render 'api/characters/ownership'
  end

  private
  def check_latest
    if params[:latest] && @character&.stale?
      @character = Character.fetch(@character.id)
    end
  end

  def set_collection
    @collection = params[:collection]
    @partial = "api/#{@collection}/#{@collection.singularize}"

    if @collection.match?(/cards|npcs/)
      @partial.sub!(/^api/, 'api/triad')
    end

    unless view_context.public_collection?(@character, @collection)
      return render json: { status: 403, error: 'Collection is set to private' }, status: :forbidden
    end

    model = @collection.classify.constantize

    # Titles need special handling since ownership is based on achievement ID
    if @collection == 'titles'
      owned_ids = @character.achievement_ids

      if action_name == 'owned'
        @collectables = model.where(achievement_id: owned_ids)
      else
        @collectables = model.where.not(achievement_id: owned_ids)
      end
    else
      owned_ids = @character.send("#{@collection.singularize}_ids")

      if action_name == 'owned'
        @collectables = model.where(id: owned_ids)
      else
        @collectables = model.where.not(id: owned_ids)
      end
    end

    # Exclude unsummonable minion variants
    if model == Minion
      @collectables = @collectables.summonable
    end

    # Add scopes
    @collectables = @collectables.ordered.include_related.ordered
  end

  def set_character
    @character = Character.find_by(id: params[:id] || params[:character_id])

    if !@character.present?
      render json: { status: 404, error: 'Not found' }, status: :not_found
    elsif !@character.public?
      render json: { status: 403, error: 'Character is set to private' }, status: :forbidden
    end
  end

  def set_owned
    @owned = Redis.current.hgetall(params[:collection].downcase)
  end

  def set_prices
    region = @character&.pricing_region || @character&.universalis_region || Character.default_pricing_region

    begin
      @prices = Redis.current.hgetall("prices-#{region}").each_with_object({}) do |(k, v), h|
        h[k.to_i] = JSON.parse(v)
      end
    rescue
      Rails.logger.error("There was a problem retrieving Universalis prices for #{region}")
    end
  end
end
