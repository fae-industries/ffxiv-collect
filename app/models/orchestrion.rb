# == Schema Information
#
# Table name: orchestrions
#
#  id              :bigint           not null, primary key
#  description_chs :string(255)
#  description_de  :string(255)      not null
#  description_en  :string(255)      not null
#  description_fr  :string(255)      not null
#  description_ja  :string(255)      not null
#  description_tc  :string(255)
#  details         :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  order           :integer
#  patch           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :integer          not null
#  item_id         :integer
#

class Orchestrion < ApplicationRecord
  include Collectable
  translates :name, :description

  belongs_to :category, class_name: 'OrchestrionCategory'

  scope :include_related, -> { include_sources.includes(:category) }
  scope :ordered, -> { order(patch: :desc, order: :desc, id: :desc) }

  def image_url
    'orchestrion.webp'.freeze
  end

  def self.available_filters
    %i(owned tradeable premium limited unknown)
  end
end
