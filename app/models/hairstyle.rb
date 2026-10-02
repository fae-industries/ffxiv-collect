# == Schema Information
#
# Table name: hairstyles
#
#  id              :bigint           not null, primary key
#  description_chs :string(1000)
#  description_de  :string(1000)
#  description_en  :string(1000)
#  description_fr  :string(1000)
#  description_ja  :string(1000)
#  description_tc  :string(1000)
#  femhrothable    :boolean          default(FALSE)
#  gender          :string(255)
#  hrothable       :boolean          default(FALSE)
#  image_url       :string(255)
#  image_urls      :text(65535)
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  patch           :string(255)
#  vierable        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  item_id         :integer
#

class Hairstyle < ApplicationRecord
  include Collectable
  translates :name, :description

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(patch: :desc, id: :desc) }

  def self.available_filters
    %i(owned tradeable gender premium limited unknown)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(vierable hrothable femhrothable)
  end
end
