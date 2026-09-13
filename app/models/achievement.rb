# == Schema Information
#
# Table name: achievements
#
#  id             :bigint           not null, primary key
#  description_de :string(255)      not null
#  description_en :string(255)      not null
#  description_fr :string(255)      not null
#  description_ja :string(255)      not null
#  description_tc :string(255)
#  image_url      :string(255)
#  name_de        :string(255)      not null
#  name_en        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  name_tc        :string(255)
#  order          :integer          not null
#  patch          :string(255)
#  points         :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_id    :integer          not null
#  item_id        :integer
#

class Achievement < ApplicationRecord
  after_save :touch_title

  belongs_to :category, class_name: 'AchievementCategory'
  belongs_to :item, required: false
  has_one :title, required: false
  has_many :character_achievements
  has_many :characters, through: :character_achievements
  has_many :relics

  delegate :type, to: :category

  translates :name, :description, :item_name

  scope :available, -> { where.not(patch: nil) }

  scope :exclude_time_limited, -> do
    joins(category: :type)
      .where('achievement_types.name_en <> ?', 'Legacy')
      .where('achievement_categories.name_en not in (?)', ['Seasonal Events', 'Ranking'])
      .where.not('achievements.id in (?)', Achievement.time_limited_ids)
  end

  scope :exclude_ranked_pvp, -> do
    where.not('achievements.description_en regexp ?', 'feast season|conflict season|championship|pvp team|crucible rankings')
  end

  scope :include_related, -> { includes(:item, :title) }
  scope :include_sources, -> { all }

  scope :with_filters, -> (filters, character = nil) do
    results = all

    if filters[:limited] == 'hide'
      results = results.exclude_time_limited
    end

    if filters[:ranked_pvp] == 'hide'
      results = results.exclude_ranked_pvp
    end

    results
  end

  scope :ordered, -> do
    joins(category: :type)
      .includes(:title, category: :type, item: :unlock)
      .order('achievements.patch DESC, achievement_types.order, achievement_categories.order, ' \
             'achievements.order DESC, achievements.id DESC')
  end

  def sources
    []
  end

  def time_limited?
    Achievement.time_limited_ids.include?(id) || Achievement.time_limited_category_ids.include?(category_id)
  end

  def tradeable?
    false
  end

  def self.time_limited_ids
    Rails.application.config_for(:achievements).time_limited_ids.freeze
  end

  def self.time_limited_category_ids
    Rails.application.config_for(:achievements).time_limited_category_ids.freeze
  end

  def self.automatic_collection?
    true
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(points category_id)
  end

  private
  def touch_title
    title&.update_column(:updated_at, Time.now)
  end
end
