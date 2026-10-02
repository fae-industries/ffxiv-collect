# == Schema Information
#
# Table name: armoires
#
#  id              :bigint           not null, primary key
#  description_chs :string(255)
#  description_de  :string(255)
#  description_en  :string(255)
#  description_fr  :string(255)
#  description_ja  :string(255)
#  description_tc  :string(255)
#  gender          :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  order           :integer          not null
#  order_group     :integer
#  outfitable      :boolean          default(FALSE)
#  patch           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :integer          not null
#  item_id         :integer          not null
#

class Armoire < ApplicationRecord
  include Collectable
  translates :name, :description
  belongs_to :category, class_name: 'ArmoireCategory'
  belongs_to :item

  delegate :image_url, to: :item

  scope :include_related, -> { include_sources.includes(:category, :item) }
  scope :ordered, -> { order(patch: :desc, order_group: :desc, order: :desc) }

  def tradeable?
    false
  end

  def self.available_filters
    %i(owned gender premium limited outfit unknown)
  end
end
