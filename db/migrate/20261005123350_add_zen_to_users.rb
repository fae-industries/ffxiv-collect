class AddZenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :zen, :boolean, default: false
  end
end
