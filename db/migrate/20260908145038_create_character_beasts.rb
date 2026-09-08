class CreateCharacterBeasts < ActiveRecord::Migration[8.1]
  def change
    create_table :character_beasts do |t|
      t.integer :character_id
      t.integer :beast_id

      t.timestamps
    end

    add_index :character_beasts, :character_id
    add_index :character_beasts, :beast_id
    add_index :character_beasts, [:character_id, :beast_id], unique: true

    add_column :characters, :beasts_count, :integer, default: 0
    add_index :characters, :beasts_count
  end
end
