# == Schema Information
#
# Table name: field_records
#
#  id               :bigint           not null, primary key
#  description_chs  :text(65535)
#  description_de   :text(65535)      not null
#  description_en   :text(65535)      not null
#  description_fr   :text(65535)      not null
#  description_ja   :text(65535)      not null
#  description_tc   :text(65535)
#  image_url        :string(255)
#  large_image_url  :string(255)
#  location_chs     :text(65535)
#  location_de      :string(255)
#  location_en      :string(255)
#  location_fr      :string(255)
#  location_ja      :string(255)
#  location_tc      :string(255)
#  name_chs         :string(255)
#  name_de          :string(255)      not null
#  name_en          :string(255)      not null
#  name_fr          :string(255)      not null
#  name_ja          :string(255)      not null
#  name_tc          :string(255)
#  patch            :string(255)
#  rarity           :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  linked_record_id :integer
#
class FieldRecord < ApplicationRecord
  include Collectable

  belongs_to :linked_record, class_name: 'FieldRecord', optional: true
  translates :name, :description, :location

  alias_attribute :order, :id

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(:id) }

  def self.available_filters
    %i(owned)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(rarity location linked_record_id)
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(linked_record)
  end
end
