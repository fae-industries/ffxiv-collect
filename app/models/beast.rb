# == Schema Information
#
# Table name: beasts
#
#  id                  :bigint           not null, primary key
#  description_de      :text(65535)
#  description_en      :text(65535)
#  description_fr      :text(65535)
#  description_ja      :text(65535)
#  description_tc      :text(65535)
#  image_url           :string(255)
#  name_de             :string(255)
#  name_en             :string(255)
#  name_fr             :string(255)
#  name_ja             :string(255)
#  name_tc             :string(255)
#  patch               :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  tempered_release_id :integer
#  trick_id            :integer
#
class Beast < ApplicationRecord
  include Collectable

  translates :name, :description

  belongs_to :trick, class_name: 'BeastAction'
  belongs_to :tempered_release, class_name: 'BeastAction'

  alias_attribute :order, :id
  alias_attribute :large_image_url, :image_url

  scope :include_related, -> { include_sources.includes(:trick, :tempered_release) }
  scope :ordered, -> { order(id: :desc) }

  def self.available_filters
    %i(owned)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(tempered_release_id trick_id)
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(tempered_release trick)
  end
end
