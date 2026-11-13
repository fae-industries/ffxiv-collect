class LevesController < ApplicationController
  include ManualCollection

  before_action :display_verify_alert!, only: [:battlecraft, :tradecraft, :fieldcraft]
  before_action :set_ids!, only: [:battlecraft, :tradecraft, :fieldcraft]
  before_action :set_prices!, only: [:tradecraft, :fieldcraft]

  def index
    @leves = Leve.available.include_related.where('leve_categories.craft_en = ?', @craft).with_filters(cookies).ordered
    @categories = LeveCategory.where(id: @leves.pluck(:category_id).uniq).ordered.to_a
    @category = @categories.first.id

    render :index
  end

  def battlecraft
    @craft = 'battlecraft'
    index
  end

  def tradecraft
    @craft = 'tradecraft'
    index
  end

  def fieldcraft
    @craft = 'fieldcraft'
    index
  end

  def add
    add_collectable(@character.leves, Leve.find(params[:id]))
  end

  def remove
    remove_collectable(@character.leves, params[:id])
  end
end
