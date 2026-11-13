class MinionsController < ApplicationController
  include PrivateCollection
  include Tooltipable

  before_action -> { check_privacy!(:minions) }, except: :tooltip
  before_action :set_ids!, only: [:index, :verminion]

  def index
    @q = Minion.summonable.ransack(params[:q])
    @minions = @q.result.available.include_related.with_filters(cookies).ordered.distinct
    @types = source_types(:minion)
  end

  def verminion
    search_params = params[:q].dup || {}

    if params[:strength].present?
      search_params["#{params[:strength]}_true"] = 1
    end

    @q = Minion.verminion.ransack(search_params)
    @minions = @q.result.available.include_related.with_filters(cookies).ordered.distinct
  end

  def dark_helmet
  end

  def show
    id = params[:id].to_i
    if Minion.unsummonable_ids.include?(id)
      id = Minion.parent_id(id)
    end

    @minion = Minion.include_sources.find(id)
    @variants = @minion.variants
  end
end
