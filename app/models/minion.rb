# == Schema Information
#
# Table name: minions
#
#  id                       :bigint           not null, primary key
#  arcana                   :boolean          not null
#  area_attack              :boolean          not null
#  attack                   :integer          not null
#  cost                     :integer          not null
#  defense                  :integer          not null
#  description_chs          :string(1000)
#  description_de           :string(1000)
#  description_en           :string(1000)
#  description_fr           :string(1000)
#  description_ja           :string(1000)
#  description_tc           :string(1000)
#  enhanced_description_chs :string(1000)
#  enhanced_description_de  :string(1000)
#  enhanced_description_en  :string(1000)
#  enhanced_description_fr  :string(1000)
#  enhanced_description_ja  :string(1000)
#  enhanced_description_tc  :string(1000)
#  eye                      :boolean          not null
#  footprint_image_url      :string(255)
#  gate                     :boolean          not null
#  hp                       :integer          not null
#  image_url                :string(255)
#  large_image_url          :string(255)
#  name_chs                 :string(255)
#  name_de                  :string(255)      not null
#  name_en                  :string(255)      not null
#  name_fr                  :string(255)      not null
#  name_ja                  :string(255)      not null
#  name_tc                  :string(255)
#  order                    :integer
#  patch                    :string(255)
#  shield                   :boolean          not null
#  skill_angle              :integer          not null
#  skill_chs                :string(255)
#  skill_cost               :integer          not null
#  skill_de                 :string(255)
#  skill_description_chs    :string(255)
#  skill_description_de     :string(255)
#  skill_description_en     :string(255)
#  skill_description_fr     :string(255)
#  skill_description_ja     :string(255)
#  skill_description_tc     :string(255)
#  skill_en                 :string(255)
#  skill_fr                 :string(255)
#  skill_ja                 :string(255)
#  skill_tc                 :string(255)
#  speed                    :integer          not null
#  tooltip_chs              :string(255)
#  tooltip_de               :string(255)
#  tooltip_en               :string(255)
#  tooltip_fr               :string(255)
#  tooltip_ja               :string(255)
#  tooltip_tc               :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  behavior_id              :integer          not null
#  item_id                  :integer
#  race_id                  :integer          not null
#  skill_type_id            :integer
#

class Minion < ApplicationRecord
  include Collectable
  translates :name, :description, :enhanced_description, :tooltip, :skill, :skill_description

  belongs_to :behavior, class_name: 'MinionBehavior'
  belongs_to :race, class_name: 'MinionRace'
  belongs_to :skill_type, class_name: 'MinionSkillType', optional: true

  scope :include_related, -> { include_sources.includes(:behavior, :race, :skill_type) }
  scope :ordered, -> { order(patch: :desc, order: :desc, id: :desc) }
  scope :summonable, -> { where.not(id: unsummonable_ids) }
  scope :verminion,  -> { where.not(id: variant_ids) }

  def strengths
    { 'Gates' => gate, 'Search Eyes' => eye, 'Shields' => shield, 'Arcana Stones' => arcana }
  end

  def variant?
    Minion.unsummonable_ids.include?(id)
  end

  def variants?
    Minion.variant_ids.include?(id)
  end

  def variants
    Minion.where(id: (id + 1)..(id + 3)) if variants?
  end

  def self.parent_id(id)
    variant_ids.find { |vid| id - 3 <= vid }
  end

  def self.angles
    Rails.application.config_for(:minions).angles.freeze
  end

  def self.variant_ids
    Rails.application.config_for(:minions).variant_ids.freeze
  end

  def self.unsummonable_ids
    Rails.application.config_for(:minions).unsummonable_ids.freeze
  end

  def self.automatic_collection?
    true
  end

  def self.available_filters
    %i(owned tradeable premium limited unknown)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(
      skill_en skill_de skill_fr skill_ja
      skill_description_en skill_description_de skill_description_fr skill_description_ja
      cost attack defense hp speed area_attack skill_angle skill_cost arcana eye gate shield
      behavior_id race_id skill_type_id
    )
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(race skill_type)
  end
end
