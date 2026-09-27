# == Schema Information
#
# Table name: rules
#
#  id             :bigint           not null, primary key
#  description_de :string(255)      not null
#  description_en :string(255)      not null
#  description_fr :string(255)      not null
#  description_ja :string(255)      not null
#  description_tc :string(255)
#  name_de        :string(255)      not null
#  name_en        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  name_tc        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Rule < ApplicationRecord
  has_many :decks
  has_and_belongs_to_many :npcs

  translates :name, :description

  scope :ordered, -> { order(Rule.current_locale_column(:name)) }
end
