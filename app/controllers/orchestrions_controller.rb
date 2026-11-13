class OrchestrionsController < ApplicationController
  include ManualCollection
  include Tooltipable

  before_action :set_categories!, only: [:index, :select]
  before_action :set_ids!, only: [:index, :select]
  before_action :verify_user!, only: [:select]

  def index
    @q = Orchestrion.ransack(params[:q])
    @orchestrions = @q.result.available.include_related.with_filters(cookies).ordered
    @categories = OrchestrionCategory.with_filters(cookies).order(:order)
    @types = source_types(:orchestrion)
  end

  def select
    @orchestrions = Orchestrion.includes(:category).order(order: :asc, id: :asc).all
  end

  def show
    @orchestrion = Orchestrion.find(params[:id])
  end

  def add
    add_collectable(@character.orchestrions, Orchestrion.find(params[:id]))
  end

  def remove
    remove_collectable(@character.orchestrions, params[:id])
  end

  private
  def set_categories!
    @categories = OrchestrionCategory.all.order(:order)
  end
end
