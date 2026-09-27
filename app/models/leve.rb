# == Schema Information
#
# Table name: leves
#
#  id             :bigint           not null, primary key
#  cost           :integer          default(1)
#  issuer_name_de :string(255)      not null
#  issuer_name_en :string(255)      not null
#  issuer_name_fr :string(255)      not null
#  issuer_name_ja :string(255)      not null
#  issuer_name_tc :string(255)
#  issuer_x       :decimal(3, 1)    not null
#  issuer_y       :decimal(3, 1)    not null
#  item_quantity  :integer
#  level          :integer          not null
#  limited        :boolean          default(FALSE)
#  name_de        :string(255)      not null
#  name_en        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  name_tc        :string(255)
#  patch          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_id    :integer          not null
#  item_id        :integer
#  location_id    :integer          not null
#
class Leve < ApplicationRecord
  include Collectable
  translates :name, :issuer_name

  belongs_to :item, optional: true
  belongs_to :location
  belongs_to :category, class_name: 'LeveCategory'
  delegate :craft, to: :category

  scope :include_related, -> { includes(:category, :location, :item) }
  scope :ordered, -> { order("leve_categories.#{LeveCategory.current_locale_column(:craft)}", "leve_categories.order", :level, :id) }

  scope :hide_limited, -> (hide) do
    where('leves.limited = FALSE') if hide
  end

  def self.available_filters
    %i(owned limited)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + %w(
      issuer_name_en issuer_name_de issuer_name_fr issuer_name_ja
      issuer_x issuer_y item_quantity limited cost
    )
  end
end
