# == Schema Information
#
# Table name: content_types
#
#  id         :bigint           not null, primary key
#  name_chs   :string(255)
#  name_de    :string(255)      not null
#  name_en    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  name_tc    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ContentType < ApplicationRecord
  translates :name

  scope :instance_types, -> { where(name_en: ContentType.instance_type_names) }

  def self.instance_type_names
    Rails.application.config_for(:instances).type_names
  end
end
