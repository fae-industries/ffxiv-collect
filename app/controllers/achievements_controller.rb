class AchievementsController < ApplicationController
  include PrivateCollection
  include Tooltipable

  before_action -> { check_privacy!(:achievements) }
  before_action :verify_character!, only: :index
  before_action :set_owned!, on: :items
  before_action :set_ids!, on: [:type, :items]
  skip_before_action :set_prices!

  def index
    @types = AchievementType.all.with_filters(cookies).ordered
    @achievements = @types.each_with_object({}) do |type, h|
      h[type.id] = type.achievements.with_filters(cookies)
    end
  end

  def show
    @achievement = Achievement.find(params[:id])
  end

  def type
    @type = AchievementType.find(params[:id])
    @categories = @type.categories.with_filters(cookies).ordered
    @achievements = @categories.each_with_object({}) do |category, h|
      h[category.id] = category.achievements.available.with_filters(cookies).includes(:item, :title).order(:order, :id)
    end
  end

  def items
    @q = Achievement.where.not(item_id: nil).ransack(params[:q])
    @achievements = @q.result.available.with_filters(cookies).ordered
    @owned = {
      count: Redis.current.hgetall('achievements-count'),
      percentage: Redis.current.hgetall('achievements')
    }
  end

  def search
    @patches = searchable_patches(legacy: cookies[:limited] != 'hide')
    @search = ransack_with_patch_search(@patches)

    @q = Achievement.ransack(@search)
    @achievements = @q.result.available.with_filters(cookies).ordered

    @types = AchievementType.all.ordered
  end
end
