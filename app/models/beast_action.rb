# == Schema Information
#
# Table name: beast_actions
#
#  id             :bigint           not null, primary key
#  description_de :text(65535)
#  description_en :text(65535)
#  description_fr :text(65535)
#  description_ja :text(65535)
#  description_tc :text(65535)
#  image_url      :string(255)
#  name_de        :string(255)
#  name_en        :string(255)
#  name_fr        :string(255)
#  name_ja        :string(255)
#  name_tc        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class BeastAction < ApplicationRecord
  translates :name, :description
end
