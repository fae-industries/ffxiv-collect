# == Schema Information
#
# Table name: leve_categories
#
#  id         :bigint           not null, primary key
#  craft_chs  :string(255)
#  craft_de   :string(255)      not null
#  craft_en   :string(255)      not null
#  craft_fr   :string(255)      not null
#  craft_ja   :string(255)      not null
#  craft_tc   :string(255)
#  items      :boolean          default(FALSE)
#  name_chs   :string(255)
#  name_de    :string(255)      not null
#  name_en    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  name_tc    :string(255)
#  order      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LeveCategory < ApplicationRecord
  self.table_name = 'leve_categories'

  translates :name, :craft

  has_many :leves, foreign_key: 'category_id'

  scope :ordered, -> { order(:order) }

  def self.crafts
    %w(battlecraft tradecraft fieldcraft)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(items)
  end
end
