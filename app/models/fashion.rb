# == Schema Information
#
# Table name: fashions
#
#  id              :bigint           not null, primary key
#  description_chs :string(1000)
#  description_de  :string(1000)
#  description_en  :string(1000)
#  description_fr  :string(1000)
#  description_ja  :string(1000)
#  description_tc  :string(1000)
#  image_url       :string(255)
#  large_image_url :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  order           :integer          not null
#  patch           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  item_id         :integer
#
class Fashion < ApplicationRecord
  include Collectable
  translates :name, :description

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(patch: :desc, order: :desc) }

  # IDs of fashion accessories that were migrated to facewear
  def self.facewear_ids
    Rails.application.config_for(:fashions).facewear_ids.freeze
  end

  def self.available_filters
    %i(owned tradeable premium limited unknown)
  end
end
