# == Schema Information
#
# Table name: outfits
#
#  id          :bigint           not null, primary key
#  armoireable :boolean          default(FALSE)
#  gender      :string(255)
#  name_chs    :string(255)
#  name_de     :string(255)      not null
#  name_en     :string(255)      not null
#  name_fr     :string(255)      not null
#  name_ja     :string(255)      not null
#  name_tc     :string(255)
#  patch       :string(255)
#  tradeable   :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  item_id     :integer
#
class Outfit < ApplicationRecord
  include Collectable
  translates :name

  scope :include_related, -> { include_sources.includes(:items, :item) }
  scope :ordered, -> { order(patch: :desc, id: :desc) }

  # The items that comprise the outfit
  has_many :outfit_items, dependent: :delete_all
  has_many :items, through: :outfit_items

  # Override tradeable logic since outfits cannot be linked to a single item
  delegate :tradeable?, to: self
  delegate :image_url, to: :item

  def tradeable?
    self.tradeable
  end

  def self.available_filters
    %i(owned tradeable gender premium limited ranked_pvp armoire unknown)
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(items)
  end
end
