class ApplicationRecord < ActiveRecord::Base
  before_save :nilify_blanks

  self.abstract_class = true

  def self.ransackable_attributes(auth_object = nil)
    attributes = %w(id name gender order order_group patch type_id item_id)
    attributes += self.locale_columns.map(&:to_s) if respond_to?(:locale_columns)
    attributes
  end

  def self.ransackable_associations(auth_object = nil)
    %w(sources category type item location)
  end

  private
  def nilify_blanks
    attributes.each do |attribute, value|
      if %w(gender patch pricing_data_center text_en text_de text_fr text_ja text_tc text_chs).include?(attribute)
        self[attribute] = nil unless value.present?
      end
    end
  end
end
