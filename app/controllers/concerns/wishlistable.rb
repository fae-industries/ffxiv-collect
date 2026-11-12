module Wishlistable
  extend ActiveSupport::Concern

  included do
    before_action :set_collectable, only: [:wish, :unwish]
  end

  def wish
    @character.wishes.create!(collectable: @collectable)

    head :no_content
  end

  def unwish
    @character.wishes.find_by(collectable: @collectable).destroy!

    head :no_content
  end

  private
  def set_collectable
    unless verified?
      head :forbidden
    end

    collection = controller_name.classify.constantize
    @collectable = collection.include_sources.find(params[:id])
  end
end
