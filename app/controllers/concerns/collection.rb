module Collection
  extend ActiveSupport::Concern

  include Wishlistable

  included do
    before_action :set_owned!, only: [:index, :type]
    before_action :set_ids!, on: :index
    before_action :set_prices!, on: :index
  end

  def ransack_with_patch_search(patches)
    search = params[:q] || {}
    search[:patch_eq] ||= patches.sort.last

    # Hack the ransack params for searches that span multiple patches
    if search[:patch_eq] == 'all'
      # All achievements
      search.delete(:patch_eq)
    elsif search[:patch_eq].match?(/\A\d\z/)
      # Expansion search
      search[:patch_start] = search[:patch_eq]
      search.delete(:patch_eq)
    end

    search
  end

  def searchable_patches(legacy: false)
    patches = Achievement.pluck(:patch).compact.uniq
    patches.delete('1.0') unless legacy
    patches
  end

  def source_types(model)
    SourceType.joins(:sources).where('sources.collectable_type = ?', model)
      .with_filters(cookies).ordered.distinct
  end

  private
  def set_owned!
    key = controller_name

    @owned = {
      count: Redis.current.hgetall("#{key}-count"),
      percentage: Redis.current.hgetall(key)
    }
  end

  def set_ids!
    collection = controller_name.singularize
    @collection_ids = @character&.send("#{collection}_ids") || []
    @keyed_collection_ids = @collection_ids.map { |id| "#{collection}-#{id}"}
  end

  def set_prices!
    data_center = @character&.pricing_data_center || @character&.data_center || 'Primal'
    key = "prices-#{data_center.downcase}"
    last_updated = Redis.current.get("#{key}-last-updated")

    @price_cache_key = "#{key}-#{last_updated}"

    begin
      @prices = Redis.current.hgetall(key).each_with_object({}) do |(k, v), h|
        h[k.to_i] = JSON.parse(v)
      end
    rescue
      Rails.logger.error("There was a problem retrieving Universalis prices for #{data_center}")
      @prices = {}
    end
  end
end
