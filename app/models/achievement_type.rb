# == Schema Information
#
# Table name: achievement_types
#
#  id         :bigint           not null, primary key
#  name_chs   :string(255)
#  name_de    :string(255)      not null
#  name_en    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  name_tc    :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AchievementType < ApplicationRecord
  has_many :categories, class_name: 'AchievementCategory', foreign_key: 'type_id'
  has_many :achievements, through: :categories

  translates :name

  scope :ordered, -> { order(:order) }
  scope :with_filters, -> (filters) do
    if filters[:limited] == 'hide'
      where.not(name_en: 'Legacy')
    end
  end
end
