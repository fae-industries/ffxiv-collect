# == Schema Information
#
# Table name: instances
#
#  id              :bigint           not null, primary key
#  name_chs        :string(255)
#  name_de         :string(255)      not null
#  name_en         :string(255)      not null
#  name_fr         :string(255)      not null
#  name_ja         :string(255)      not null
#  name_tc         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  content_id      :integer
#  content_type_id :integer          not null
#

class Instance < ApplicationRecord
  translates :name

  belongs_to :content_type

  def self.ransackable_attributes(auth_object = nil)
    super + %w(content_type)
  end
end
