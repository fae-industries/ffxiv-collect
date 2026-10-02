# == Schema Information
#
# Table name: facewear
#
#  id             :bigint           not null, primary key
#  image_url      :string(255)
#  image_urls     :text(65535)
#  lodestone_name :string(255)
#  name_chs       :string(255)
#  name_de        :string(255)      not null
#  name_en        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  name_tc        :string(255)
#  order          :integer          not null
#  patch          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  item_id        :integer
#
class Facewear < ApplicationRecord
  include Collectable
  translates :name

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(patch: :desc, order: :desc) }

  def reclaimable?
    id < 5
  end

  def self.automatic_collection?
    true
  end

  def self.available_filters
    %i(owned tradeable limited ranked_pvp unknown)
  end
end
