# == Schema Information
#
# Table name: orchestrion_categories
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

class OrchestrionCategory < ApplicationRecord
  has_many :orchestrions, foreign_key: 'category_id'
  translates :name

  scope :hide_premium, -> (hide) do
    where.not(id: 8) if hide
  end

  scope :hide_limited, -> (hide) do
    where.not(id: 7) if hide
  end

  scope :with_filters, -> (filters, character = nil) do
    hide_premium(filters[:premium] == 'hide')
      .hide_limited(filters[:limited] == 'hide')
  end
end
