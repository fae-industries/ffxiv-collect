# == Schema Information
#
# Table name: minion_races
#
#  id         :bigint           not null, primary key
#  name_chs   :string(255)
#  name_de    :string(255)      not null
#  name_en    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  name_tc    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MinionRace < ApplicationRecord
  translates :name

  has_many :minions

  scope :ordered, -> { order(MinionRace.current_locale_column(:name)) }
end
