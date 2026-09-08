# == Schema Information
#
# Table name: spells
#
#  id             :bigint           not null, primary key
#  description_de :string(1000)     not null
#  description_en :string(1000)     not null
#  description_fr :string(1000)     not null
#  description_ja :string(1000)     not null
#  description_tc :string(1000)
#  image_url      :string(255)
#  name_de        :string(255)      not null
#  name_en        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  name_tc        :string(255)
#  order          :integer
#  patch          :string(255)
#  rank           :integer          not null
#  tooltip_de     :string(1000)     not null
#  tooltip_en     :string(1000)     not null
#  tooltip_fr     :string(1000)     not null
#  tooltip_ja     :string(1000)     not null
#  tooltip_tc     :string(1000)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  aspect_id      :integer          not null
#  type_id        :integer          not null
#

class Spell < ApplicationRecord
  include Collectable
  translates :name, :description, :tooltip

  belongs_to :type, class_name: 'SpellType'
  belongs_to :aspect, class_name: 'SpellAspect'

  scope :include_related, -> { include_sources.includes(:type, :aspect) }
  scope :ordered, -> { order(:order) }

  def self.available_filters
    %i(owned)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(rank aspect_id)
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(aspect)
  end
end
