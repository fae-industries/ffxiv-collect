class AddOrderToSources < ActiveRecord::Migration[8.1]
  def change
    add_column :sources, :order, :integer
    add_index :sources, :order
  end
end
