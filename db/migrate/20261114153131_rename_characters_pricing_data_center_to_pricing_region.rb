class RenameCharactersPricingDataCenterToPricingRegion < ActiveRecord::Migration[8.1]
  def change
    rename_column :characters, :pricing_data_center, :pricing_region
  end
end
