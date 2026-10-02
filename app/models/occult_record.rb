# == Schema Information
#
# Table name: occult_records
#
#  id              :bigint           not null, primary key
#  description_chs :text(65535)
#  description_de  :text(65535)
#  description_en  :text(65535)
#  description_fr  :text(65535)
#  description_ja  :text(65535)
#  description_tc  :text(65535)
#  image_url       :string(255)
#  location_chs    :text(65535)
#  location_de     :string(255)
#  location_en     :string(255)
#  location_fr     :string(255)
#  location_ja     :string(255)
#  location_tc     :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)
#  name_en         :string(255)
#  name_fr         :string(255)
#  name_ja         :string(255)
#  name_tc         :string(255)
#  patch           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class OccultRecord < ApplicationRecord
  include Collectable

  translates :name, :description, :location

  alias_attribute :order, :id

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(:id) }

  def self.available_filters
    %i(owned)
  end
end
