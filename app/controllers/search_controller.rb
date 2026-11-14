class SearchController < ApplicationController
  include PrivateCollection
  include Typeable

  before_action -> { check_privacy!(:mounts, :minions, :facewear, :emotes) }

  skip_before_action :set_owned!, :set_ids!

  def index
    @types = collectable_types
    @hidden_types = cookies[:hidden_types]&.split(',')&.map(&:constantize) || []
    @source_types = SourceType.with_filters(cookies).ordered
    @models = @types.pluck(:model)

    @owned = @types.each_with_object({}) do |type, h|
      key = type[:value].downcase.pluralize

      h[type[:model]] = {
        count: Redis.current.hgetall("#{key}-count"),
        percentage: Redis.current.hgetall(key)
      }
    end

    # Collect a distinct set of patches across all models
    @patches = @models.flat_map { |model| model.distinct.pluck(:patch) }.compact.uniq
    @search = ransack_with_patch_search(@patches)

    @collectables = @models.flat_map do |model|
      # The search form needs a query, so we will eventually set it to the last search
      @q = model.ransack(@search)

      collectables = @q.result.available.include_sources.with_filters(cookies, @character).ordered
      collectables = collectables.summonable if model == Minion # Exclude variant minions
      collectables
    end

    if @character.present?
      @keyed_collection_ids = @models.flat_map do |model|
        collection = model.to_s.underscore
        @character.send("#{collection}_ids").map { |id| "#{collection}-#{id}"}
      end
    end
  end
end
