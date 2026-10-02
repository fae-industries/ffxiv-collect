# == Schema Information
#
# Table name: items
#
#  id              :bigint           not null, primary key
#  crafter         :string(255)
#  description_chs :string(1000)
#  description_de  :string(1000)     not null
#  description_en  :string(1000)     not null
#  description_fr  :string(1000)     not null
#  description_ja  :string(1000)     not null
#  description_tc  :string(1000)
#  image_url       :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  plural_chs      :string(255)
#  plural_de       :string(255)
#  plural_en       :string(255)
#  plural_fr       :string(255)
#  plural_ja       :string(255)
#  plural_tc       :string(255)
#  price           :integer
#  tradeable       :boolean
#  unlock_type     :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  quest_id        :integer
#  recipe_id       :integer
#  unlock_id       :integer
#
class Item < ApplicationRecord
  translates :name, :description, :plural

  belongs_to :unlock, polymorphic: true, required: false
  belongs_to :quest, required: false
  has_many :outfit_items
  has_many :outfits, through: :outfit_items

  scope :collectable, -> { where.not(unlock_id: nil) }
  scope :tradeable, -> { where(tradeable: true) }

  def tomestone_name(locale: :en)
    name = I18n.with_locale(locale) { self.name }

    case locale
    when :en, :tc, :chs
      name.sub(/.+ Of (.+)/i, '\1')
    when :de
      name.sub(/.+ De[rs] (.+)/i, '\1')
    when :fr
      name.sub(/.+ Inhabituel (.+)/i, '\1\2').upcase_first
    when :ja
      name.sub(/.+:(.+)/, '\1')
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(
      tradeable crafter price unlock_type
      unlock_id recipe_id quest_id
    )
  end

  def self.ransackable_associations(auth_object = nil)
    %w(unlock)
  end
end
