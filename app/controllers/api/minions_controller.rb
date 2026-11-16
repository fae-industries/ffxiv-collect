class Api::MinionsController < ApiController
  def index
    query = Minion.ransack(@query)
    @minions = query.result.available.include_related.ordered.distinct.limit(params[:limit])
  end

  def show
    @minion = Minion.include_sources.find(params[:id])
  end
end
