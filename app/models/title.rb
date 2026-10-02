# == Schema Information
#
# Table name: titles
#
#  id              :bigint           not null, primary key
#  female_name_chs :string(255)
#  female_name_de  :string(255)      not null
#  female_name_en  :string(255)      not null
#  female_name_fr  :string(255)      not null
#  female_name_ja  :string(255)      not null
#  female_name_tc  :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  order           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  achievement_id  :integer          not null
#

class Title < ApplicationRecord
  translates :name, :female_name
  belongs_to :achievement, touch: true

  scope :available, -> { joins(:achievement).where.not('achievements.patch' => nil) }
  scope :include_related, -> { includes(achievement: { category: :type }) }
  scope :ordered, -> { joins(:achievement).order('achievements.patch desc', order: :desc) }

  def self.available_filters
    %i(owned limited ranked_pvp)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(female_name_en female_name_de female_name_fr female_name_ja female_name_tc achievement_id)
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(achievement)
  end
end
