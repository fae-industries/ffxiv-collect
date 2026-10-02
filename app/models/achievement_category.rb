# == Schema Information
#
# Table name: achievement_categories
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
#  type_id    :integer          not null
#

class AchievementCategory < ApplicationRecord
  belongs_to :type, class_name: 'AchievementType'
  has_many :achievements, foreign_key: 'category_id'

  translates :name

  scope :ordered, -> { order(:order) }
  scope :with_filters, -> (filters) do
    results = all

    if filters[:limited] == 'hide'
      results = results.where.not(name_en: ['Seasonal Events', 'Ranking'])
    end

    if filters[:ranked_pvp] == 'hide'
      results = results.where.not(name_en: 'Ranking')
    end

    results
  end
end
