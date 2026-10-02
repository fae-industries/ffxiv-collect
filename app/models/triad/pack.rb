# == Schema Information
#
# Table name: packs
#
#  id         :bigint           not null, primary key
#  cost       :integer          not null
#  name_chs   :string(255)
#  name_de    :string(255)      not null
#  name_en    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  name_tc    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :integer
#

class Pack < ApplicationRecord
  has_many :pack_cards
  has_many :cards, -> { numeric_ordered }, through: :pack_cards, dependent: :delete_all

  scope :include_related, -> { includes(cards: :type) }
  scope :ordered, -> { order(:id) }

  after_save :touch_related

  translates :name

  private
  def touch_related
    cards.touch_all
  end
end
