class OutfitsController < ApplicationController
  include ManualCollection
  include Tooltipable

  skip_before_action :set_prices!

  def index
    @q = Outfit.ransack(params[:q])
    @outfits = @q.result.available.include_related.with_filters(cookies, @character).ordered.distinct
    @types = source_types(:outfit)
  end

  def show
    @outfit = Outfit.include_sources.find(params[:id])
  end

  def add
    add_collectable(@character.outfits, Outfit.find(params[:id]))
  end

  def remove
    remove_collectable(@character.outfits, params[:id])
  end
end
