# == Schema Information
#
# Table name: character_beasts
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  beast_id     :integer
#  character_id :integer
#
class CharacterBeast < ApplicationRecord
  belongs_to :character, counter_cache: :beasts_count, touch: true
  belongs_to :beast
end
