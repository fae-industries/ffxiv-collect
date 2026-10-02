# == Schema Information
#
# Table name: mounts
#
#  id                       :bigint           not null, primary key
#  custom_music             :boolean          default(FALSE)
#  description_chs          :string(255)
#  description_de           :string(255)      not null
#  description_en           :string(255)      not null
#  description_fr           :string(255)      not null
#  description_ja           :string(255)      not null
#  description_tc           :string(255)
#  enhanced_description_chs :string(1000)
#  enhanced_description_de  :string(1000)     not null
#  enhanced_description_en  :string(1000)     not null
#  enhanced_description_fr  :string(1000)     not null
#  enhanced_description_ja  :string(1000)     not null
#  enhanced_description_tc  :string(1000)
#  footprint_image_url      :string(255)
#  image_url                :string(255)
#  large_image_url          :string(255)
#  movement                 :string(255)      not null
#  name_chs                 :string(255)
#  name_de                  :string(255)      not null
#  name_en                  :string(255)      not null
#  name_fr                  :string(255)      not null
#  name_ja                  :string(255)      not null
#  name_tc                  :string(255)
#  order                    :integer          not null
#  order_group              :integer
#  patch                    :string(255)
#  seats                    :integer          not null
#  tooltip_chs              :string(255)
#  tooltip_de               :string(255)      not null
#  tooltip_en               :string(255)      not null
#  tooltip_fr               :string(255)      not null
#  tooltip_ja               :string(255)      not null
#  tooltip_tc               :string(255)
#  video                    :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  item_id                  :integer
#

class Mount < ApplicationRecord
  include Collectable
  translates :name, :description, :enhanced_description, :tooltip

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(patch: :desc, order: :desc) }

  def multi_seated?
    seats > 1
  end

  def self.automatic_collection?
    true
  end

  def self.available_filters
    %i(owned tradeable premium limited ranked_pvp unknown)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(movement seats)
  end
end
