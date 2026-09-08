class SpellsController < ApplicationController
  include ManualCollection
  include Tooltipable

  before_action :set_ids!, on: :battle
  before_action :set_spells!, only: [:index, :battle]
  skip_before_action :set_prices!

  def index
  end

  def battle
  end

  def show
    @spell = Spell.include_sources.find(params[:id])
  end

  def add
    add_collectable(@character.spells, Spell.find(params[:id]))
  end

  def remove
    remove_collectable(@character.spells, params[:id])
  end

  private
  def set_spells!
    @q = Spell.ransack(params[:q])
    @spells = @q.result.available.include_related.with_filters(cookies).ordered.distinct
    @aspects = SpellAspect.all.order("name_#{I18n.locale}").pluck("name_#{I18n.locale}").uniq
  end
end
