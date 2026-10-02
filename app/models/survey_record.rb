# == Schema Information
#
# Table name: survey_records
#
#  id              :bigint           not null, primary key
#  description_chs :text(65535)
#  description_de  :text(65535)
#  description_en  :text(65535)
#  description_fr  :text(65535)
#  description_ja  :text(65535)
#  description_tc  :text(65535)
#  image_url       :string(255)
#  large_image_url :string(255)
#  name_chs        :string(255)
#  name_de         :string(255)
#  name_en         :string(255)
#  name_fr         :string(255)
#  name_ja         :string(255)
#  name_tc         :string(255)
#  order           :integer
#  patch           :string(255)
#  solution_chs    :string(1000)
#  solution_de     :string(1000)
#  solution_en     :string(1000)
#  solution_fr     :string(1000)
#  solution_ja     :string(1000)
#  solution_tc     :string(1000)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  series_id       :integer
#
class SurveyRecord < ApplicationRecord
  include Collectable

  belongs_to :series, class_name: 'SurveyRecordSeries', required: false
  translates :name, :description, :solution

  alias_method :category, :series
  alias_attribute :category_id, :series_id

  scope :include_related, -> { includes(:series) }
  scope :ordered, -> { order(:series_id, :order) }

  def self.available_filters
    %i(owned)
  end
end
