class BeastsController < ApplicationController
  include ManualCollection
  include Tooltipable

  skip_before_action :set_prices!

  def index
    @q = Beast.ransack(params[:q])
    @beasts = @q.result.available.include_related.with_filters(cookies).ordered.reverse_order.distinct
  end

  def show
    @beast = Beast.include_sources.find(params[:id])
    @trick = @beast.trick
    @tempered_release = @beast.tempered_release
  end

  def add
    add_collectable(@character.beasts, Beast.find(params[:id]))
  end

  def remove
    remove_collectable(@character.beasts, params[:id])
  end
end


