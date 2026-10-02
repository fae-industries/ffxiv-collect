# == Schema Information
#
# Table name: relics
#
#  id             :bigint           not null, primary key
#  image_url      :string(255)
#  name_chs       :string(255)
#  name_de        :string(255)      not null
#  name_en        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  name_tc        :string(255)
#  order          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  achievement_id :integer
#  type_id        :integer
#
class Relic < ApplicationRecord
  has_many "character_#{name.pluralize}".to_sym
  has_many :characters, through: "character_#{name.pluralize}".to_sym
  belongs_to :type, class_name: 'RelicType'
  belongs_to :achievement, required: false
  belongs_to :item, foreign_key: :id

  translates :name

  scope :include_related, -> { includes(:type) }
  scope :ordered, -> { joins(:type).order('relic_types.category desc', expansion: :desc, order: :desc) }

  def self.categories
    %w(weapons ultimate armor tools).freeze
  end
end
