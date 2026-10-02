# == Schema Information
#
# Table name: emotes
#
#  id          :bigint           not null, primary key
#  command_chs :string(255)
#  command_de  :string(255)
#  command_en  :string(255)
#  command_fr  :string(255)
#  command_ja  :string(255)
#  command_tc  :string(255)
#  image_url   :string(255)
#  name_chs    :string(255)
#  name_de     :string(255)      not null
#  name_en     :string(255)      not null
#  name_fr     :string(255)      not null
#  name_ja     :string(255)      not null
#  name_tc     :string(255)
#  order       :integer
#  patch       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer          not null
#  item_id     :integer
#

class Emote < ApplicationRecord
  include Collectable
  translates :name, :command
  belongs_to :category, class_name: 'EmoteCategory'

  scope :include_related, -> { include_sources.includes(:category) }
  scope :ordered, -> { order(patch: :desc, order: :desc) }

  def self.automatic_collection?
    true
  end

  def self.available_filters
    %i(owned tradeable premium limited unknown)
  end
end
