# == Schema Information
#
# Table name: source_types
#
#  id         :bigint           not null, primary key
#  name_chs   :string(255)
#  name_de    :string(255)
#  name_en    :string(255)      not null
#  name_fr    :string(255)
#  name_ja    :string(255)
#  name_tc    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SourceType < ApplicationRecord
  translates :name

  has_many :sources, foreign_key: 'type_id'

  scope :ordered, -> { order(SourceType.current_locale_column(:name)) }

  scope :with_filters, -> (filters) do
    excluded = filters[:premium] == 'hide' ? ['Premium'] : []
    excluded += %w(Event Limited) if filters[:limited] == 'hide'
    where.not(name_en: excluded)
  end
end
