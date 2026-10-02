# == Schema Information
#
# Table name: cards
#
#  id               :bigint           not null, primary key
#  bottom           :integer          not null
#  buy_price        :integer
#  deck_order       :integer
#  description_chs  :text(65535)
#  description_de   :text(65535)      not null
#  description_en   :text(65535)      not null
#  description_fr   :text(65535)      not null
#  description_ja   :text(65535)      not null
#  description_tc   :text(65535)
#  formatted_number :string(255)      not null
#  image_url        :string(255)
#  large_image_url  :string(255)
#  left             :integer          not null
#  name_chs         :string(255)
#  name_de          :string(255)      not null
#  name_en          :string(255)      not null
#  name_fr          :string(255)      not null
#  name_ja          :string(255)      not null
#  name_tc          :string(255)
#  order            :integer
#  order_group      :integer
#  patch            :string(255)
#  right            :integer          not null
#  sell_price       :integer          not null
#  stars            :integer          not null
#  top              :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  card_type_id     :integer          not null
#  item_id          :integer
#

class Card < ApplicationRecord
  include Collectable

  translates :name, :description

  belongs_to :type, class_name: 'CardType', foreign_key: :card_type_id
  has_many :npc_cards
  has_many :npcs, through: :npc_cards
  has_many :npc_rewards
  has_many :npc_sources, through: :npc_rewards, source: :npc
  has_many :sources, as: :collectable, dependent: :delete_all
  has_many :deck_cards
  has_many :decks, through: :deck_cards
  has_many :pack_cards
  has_many :packs, through: :pack_cards
  has_one :achievement, required: false

  after_save :touch_related

  scope :include_related, -> { includes(:type, :item, sources: [:type, related: :location]) }
  scope :ordered, -> { order(patch: :desc, order_group: :desc, order: :desc) }
  scope :numeric_ordered, -> { order(:order) }
  scope :standard, -> { where(order_group: 0) }
  scope :ex, -> { where.not(order_group: 0) }

  def ex?
    order_group != 0
  end

  def formatted_number
    ex? ? "Ex. #{order}" : "No. #{order}"
  end

  def stat(side)
    value = self[side]
    value == 10 ? 'A' : value
  end

  def stats
    "#{top} #{right} #{bottom} #{left}".gsub(/10/, 'A')
  end

  def total_stats
    top + right + bottom + left
  end

  def item_id
    nil
  end

  def self.no(number)
    Card.find_by(formatted_number: "No. #{number}")
  end

  def self.ex(number)
    Card.find_by(formatted_number: "Ex. #{number}")
  end

  def self.available_filters
    %i(owned limited unknown)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(card_type_id stars top right bottom left buy_price sell_price deck_order)
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(race skill_type)
  end

  private
  def touch_related
    npcs.touch_all
    npc_sources.touch_all
    decks.touch_all
    packs.touch_all
  end
end
