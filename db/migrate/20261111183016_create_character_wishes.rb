class CreateCharacterWishes < ActiveRecord::Migration[8.1]
  def change
    create_table :character_wishes do |t|
      t.integer :character_id, null: false
      t.integer :collectable_id, null: false
      t.string :collectable_type, null: false

      t.timestamps
    end

    add_index :character_wishes, [:character_id, :collectable_id, :collectable_type], unique: true
  end
end
