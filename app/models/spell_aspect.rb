# == Schema Information
#
# Table name: spell_aspects
#
#  id         :bigint           not null, primary key
#  name_chs   :string(255)
#  name_de    :string(255)
#  name_en    :string(255)
#  name_fr    :string(255)
#  name_ja    :string(255)
#  name_tc    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SpellAspect < ApplicationRecord
  translates :name
end
