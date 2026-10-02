# == Schema Information
#
# Table name: relic_types
#
#  id         :bigint           not null, primary key
#  category   :string(255)
#  expansion  :integer
#  jobs       :integer
#  name_chs   :string(255)
#  name_de    :string(255)
#  name_en    :string(255)
#  name_fr    :string(255)
#  name_ja    :string(255)
#  name_tc    :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class RelicType < ApplicationRecord
  has_many :relics, foreign_key: 'type_id', dependent: :delete_all

  translates :name

  scope :include_related, -> { includes(:relics) }

  def relics_by_tier
    if category == 'armor' || name_en == 'GARO Armor'
      # Armor will be displayed from head to toe
      relics.includes(:achievement).order(:order).each_slice(5).to_a.transpose
    elsif category == 'ultimate'
      # Ultimate weapons are displayed naturally
      relics.sort_by(&:order).to_a
    else
      # Other relics will be sliced by tier
      relics.includes(:achievement).order(:order).each_slice(jobs).to_a
    end
  end
end
