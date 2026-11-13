class TomestonesController < ApplicationController
  include PrivateCollection

  skip_before_action :set_owned!, :set_ids!

  before_action -> { check_privacy!(:mounts, :minions, :emotes) }

  before_action :set_prices!

  def index
    @tomestones = Item.where('name_en like ?', 'Irregular Tomestone%')
      .where('name_en regexp ?', TomestoneReward.pluck(:tomestone).uniq.join('|'))
      .order(:created_at)

    if params[:action] == 'index'
      @tomestone = @tomestones.last
    else
      @tomestone = Item.find_by(name_en: "Irregular Tomestone Of #{params[:id]}")
    end

    @title = "#{t('tomestones.page_title', name: @tomestone.tomestone_name(locale: I18n.locale))}"
    @rewards = collectables(@tomestone.tomestone_name)
    @items = items(@tomestone.tomestone_name)

    if @character.present?
      @keyed_collection_ids = @rewards.collectables.map(&:collectable_type).uniq.flat_map do |type|
        collection = type.underscore
        @character.send("#{collection}_ids").map { |id| "#{collection}-#{id}"}
      end
    end
  end

  # Leverage ID param to dynamically route to tomestone rewards by name
  def show
    index
    render :index
  end

  private
  def collectables(tomestone)
    TomestoneReward.collectables.where(tomestone: tomestone).include_related.ordered
  end

  def items(tomestone)
    TomestoneReward.items.where(tomestone: tomestone).include_related.ordered
  end
end
