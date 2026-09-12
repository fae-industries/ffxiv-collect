class Api::BeastsController < ApiController
  def index
    query = Beast.all.ransack(@query)
    @beasts = query.result.available.include_related.ordered.distinct.limit(params[:limit])
  end

  def show
    @beast = Beast.include_sources.find_by(id: params[:id])
    render_not_found unless @beast.present?
  end
end
