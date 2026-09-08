class CharactersController < ApplicationController
  before_action :verify_signed_in!, only: [:verify, :validate, :destroy]
  before_action :set_search, only: [:search, :search_lodestone]
  before_action :set_selected, only: [:search_lodestone_id, :view, :select, :peek]
  after_action  :save_selected, only: [:select]
  before_action :set_profile, only: [:show, :stats_recent, :stats_rarity, :verify, :validate]
  before_action :set_stats_limit, only: [:stats_recent, :stats_rarity]
  before_action :set_verification_code, only: [:verify, :validate]
  before_action :verify_privacy!, only: [:show, :stats_recent, :stats_rarity]

  COLLECTIONS = %w(achievements mounts minions orchestrions spells beasts hairstyles emotes bardings armoires
  outfits fashions facewear frames cards field_records survey_records occult_records).freeze
  STATS_COLLECTIONS = COLLECTIONS.dup.insert(1, 'titles').freeze

  def show
    @rankings = @profile.rankings

    # TODO: Make the shape of this object more consistent
    @scores = COLLECTIONS.each_with_object({}) do |collection, h|
      next unless @profile.send("#{collection}_count") > 0

      collectables = collection.classify.constantize.available.with_filters(cookies, @profile)
      collectables = collectables.summonable if collection == 'minions'

      owned_ids = @profile.send("#{collection.singularize}_ids")

      # Count collectables with matching IDs to ensure we respect filters/etc
      h[collection] = {
        value: collectables.where(id: owned_ids).count,
        max: collectables.count
      }
    end

    # Add point data to Achievements
    if @scores['achievements'].present?
      achievements = Achievement.available.with_filters(cookies, @profile)
      owned_ids = @profile.achievement_ids

      @scores['achievements'][:points] = achievements.where(id: owned_ids).sum(:points)
      @scores['achievements'][:points_max] = achievements.sum(:points)
    end

    # Add NPC data to Cards
    if @scores['cards'].present?
      npcs = NPC.available.valid.with_filters(cookies, @profile)
      owned_ids = @profile.npc_ids

      @scores['cards'][:npcs] = npcs.where(id: owned_ids).count
      @scores['cards'][:npcs_max] = npcs.count
    end

    # Add Levequests
    if @profile.leves.any?
      @crafts = LeveCategory.crafts
      @scores['leves'] = @crafts.each_with_object({}) do |craft, h|
        leves = Leve.available
          .with_filters(cookies)
          .joins(:category)
          .where('leve_categories.craft_en = ?', craft)

        owned_ids = @profile.leve_ids

        h[craft] = leves.where(id: owned_ids).count
        h["#{craft}_max"] = leves.count
      end
    end
  end

  def profile
    if @character.present?
      redirect_to(action: :show, id: @character.id)
    else
      redirect_to root_path
    end
  end

  def stats_recent
    @collections = STATS_COLLECTIONS.each_with_object({}) do |collection, h|
      h[collection] = @profile.most_recent(collection, filters: cookies, limit: @limit)
    end
  end

  def stats_rarity
    @collections = STATS_COLLECTIONS.each_with_object({}) do |collection, h|
      h[collection] = @profile.most_rare(collection, filters: cookies, limit: @limit)
    end
  end

  def search
    if @search
      @characters = Character.where('name like ?', "%#{search_params[:name]}%").limit(10)

      %i(data_center server).each do |param|
        value = search_params[param]
        @characters = @characters.where(param => value) if value.present?
      end

      # Turn this relation into an array to ensure subsequent operations on it do not hit the database.
      # Sort by name afterwards instead of ordering all characters to improve query speed.
      @characters = @characters.to_a.sort_by(&:name)

      redirect_to search_lodestone_characters_path(search_params) if @characters.empty?
    elsif user_signed_in?
      @characters = current_user.characters.to_a
        .sort_by { |character| [character.verified_user_id == current_user.id ? 0 : 1, character.name] }
    else
      @characters = Character.none
    end

    @known_characters = @characters.pluck(:id)
  end

  def search_lodestone
    begin
      @characters = Lodestone.search(name: @name, server: @server, data_center: @data_center)
      @known_characters = Character.where(id: @characters.pluck(:id)).pluck(:id)

      if @characters.empty?
        flash.now[:alert] = t('alerts.no_characters_found')
      end
    rescue RestClient::BadGateway, RestClient::ServiceUnavailable
      flash.now[:error] = t('alerts.lodestone_maintenance')
    rescue StandardError => e
      flash.now[:error] = t('alerts.lodestone_error')
      Rails.logger.error("There was a problem searching for \"#{params[:name]}\"")
      log_backtrace(e)
    end

    render 'search'
  end

  def search_lodestone_id
    select
  end

  def view
    redirect_to character_path(@selected)
  end

  def select
    if user_signed_in?
      # If the user is signed in, update their selected character in the database
      current_user.update(character_id: params[:id])
    else
      # Otherwise, persist the selected character as a cookie
      set_permanent_cookie(:character, params[:id])
    end

    flash[:success] = t('alerts.character_set') unless flash[:notice].present?

    redirect_to character_path(@selected)
  end

  def peek
    set_permanent_cookie(:peek, @selected.id)
    flash[:success] = t('alerts.peek_set') unless flash[:notice].present?
    redirect_to character_path(@selected)
  end

  def unpeek
    cookies.delete(:peek)
    redirect_back(fallback_location: root_path)
  end

  def forget
    if user_signed_in?
      current_user.update(character_id: nil)
    else
      cookies.delete(:character)
    end

    flash[:success] = t('alerts.no_longer_tracking')
    redirect_to root_path
  end

  def destroy
    current_user.characters.delete(params[:id])
    redirect_to search_characters_path
  end

  def refresh
    # Refresh the character profile if provided, otherwise refresh the currently selected character
    is_profile = params[:id].present?
    key = is_profile ? 'profile' : 'character'
    character = is_profile ? Character.find(params[:id]) : @character

    if !character.refreshable?
      flash[:alert] = t("alerts.#{key}_already_refreshed")
    else
      begin
        fetched = fetch_character(character.id)

        if fetched.present?
          fetched.update(refreshed_at: Time.now)
          flash[:success] = t("alerts.#{key}_refreshed")
        else
          flash[:error] = t('alerts.lodestone_error')
        end
      rescue RestClient::BadGateway, RestClient::ServiceUnavailable
        flash[:error] = t('alerts.lodestone_maintenance')
      rescue Lodestone::PrivateProfileError, Lodestone::HiddenProfileError
        flash[:error] = t('alerts.private_profile')
      rescue
        flash[:error] = t("alerts.problem_refreshing_#{key}")
      end
    end

    redirect_back(fallback_location: root_path)
  end

  def verify
    session[:return_to] = request.referer
  end

  def validate
    begin
      if @profile.verify!(current_user)
        flash[:success] = t('alerts.character_verified')
        return redirect_to_previous
      else
        flash[:error] = t('alerts.character_verification_error')
        @code = @profile.verification_code(current_user)
      end
    rescue Lodestone::PrivateProfileError, Lodestone::HiddenProfileError
      flash[:error] = t('alerts.problem_verifying_private')
    rescue StandardError => e
      flash[:error] = t('alerts.problem_verifying')
      Rails.logger.error("There was a problem verifying character #{@profile.id}")
      log_backtrace(e)
    end

    render :verify
  end

  private
  def set_profile
    @profile = Character.find_by(id: params[:id])

    unless @profile.present?
      flash[:error] = t('alerts.character_not_found')
      redirect_to root_path
    end
  end

  def search_params
    params.permit(:name, :server, :data_center)
  end

  def set_search
    @name, @server, @data_center = search_params.values_at(:name, :server, :data_center)

    if @name.present?
      @name = @name.strip.gsub(/[‘’]/, "'")
      @search = true
    end
  end

  def set_selected
    begin
      @selected = Character.find_by(id: params[:id]) || fetch_character(params[:id])
    rescue Lodestone::PrivateProfileError, Lodestone::HiddenProfileError
      flash[:error] = t('alerts.private_profile')
      return redirect_back(fallback_location: root_path)
    rescue
      # The exception has been logged in the fetch. Now let the following logic alert the user.
    end

    if !@selected.present?
      flash[:error] = t('alerts.problem_selecting_character')
      redirect_back(fallback_location: root_path)
    elsif @selected.private?(current_user)
      render_private_character_flash!(@selected)
      redirect_back(fallback_location: root_path)
    end
  end

  def set_stats_limit
    if params[:limit].present?
      @limit = [params[:limit].to_i, 100].min
    else
      @limit = 10
    end
  end

  def save_selected
    if user_signed_in? && !current_user.characters.exists?(@selected.id)
      current_user.characters << @selected
    end
  end

  def set_verification_code
    @code = @profile.verification_code(current_user)
  end

  def verify_privacy!
    unless @profile.public? || @profile.verified_user?(current_user)
      render_private_character_flash!(@profile)
      redirect_back(fallback_location: root_path)
    end
  end

  def fetch_character(id)
    begin
      Character.fetch(id)
    rescue RestClient::BadGateway, RestClient::ServiceUnavailable
      Rails.logger.info('Lodestone is down for maintenance.')
      raise
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("There was a problem fetching character #{id}")
      Rails.logger.error(e.response)
      raise
    rescue StandardError => e
      Rails.logger.error("There was a problem fetching character #{id}")
      log_backtrace(e)
      raise
    end
  end
end
