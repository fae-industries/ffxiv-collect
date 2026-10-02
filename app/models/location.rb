# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  name_chs   :string(255)
#  name_de    :string(255)      not null
#  name_en    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  name_tc    :string(255)
#  region_chs :string(255)
#  region_de  :string(255)      not null
#  region_en  :string(255)      not null
#  region_fr  :string(255)      not null
#  region_ja  :string(255)      not null
#  region_tc  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ApplicationRecord
  has_many :npcs
  has_many :alphabetical_npcs, -> { order(Location.current_locale_column(:name)) }, class_name: 'NPC'

  translates :name, :region

  def self.ransackable_attributes(auth_object = nil)
    super + %w(region_en region_de region_fr region_ja region_tc)
  end
end
