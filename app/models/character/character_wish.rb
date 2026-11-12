# == Schema Information
#
# Table name: character_wishes
#
#  id               :bigint           not null, primary key
#  collectable_type :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  character_id     :integer          not null
#  collectable_id   :integer          not null
#
class CharacterWish < ApplicationRecord
  belongs_to :character
  belongs_to :collectable, polymorphic: true
end
