# == Schema Information
#
# Table name: emote_categories
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

class EmoteCategory < ApplicationRecord
  translates :name
  has_many :emotes, foreign_key: 'category_id'
end
