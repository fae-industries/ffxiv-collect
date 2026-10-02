# == Schema Information
#
# Table name: bardings
#
#  id              :bigint           not null, primary key
#  description_chs :string(255)
#  description_de  :string(255)
#  description_en  :string(255)
#  description_fr  :string(255)
#  description_ja  :string(255)
#  description_tc  :string(255)
#  image_url       :string(255)
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
#  item_id         :integer
#

class Barding < ApplicationRecord
  include Collectable
  translates :name, :description

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(patch: :desc, order: :desc) }

  def self.available_filters
    %i(owned tradeable premium limited unknown)
  end
end
