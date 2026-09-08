class CreateBeasts < ActiveRecord::Migration[8.1]
  def change
    create_table :beasts do |t|
      t.string :name_en
      t.string :name_de
      t.string :name_fr
      t.string :name_ja
      t.string :name_tc
      t.text :description_en
      t.text :description_de
      t.text :description_fr
      t.text :description_ja
      t.text :description_tc
      t.string :image_url
      t.string :patch
      t.integer :trick_id
      t.integer :tempered_release_id

      t.timestamps
    end
    add_index :beasts, :name_en
    add_index :beasts, :name_de
    add_index :beasts, :name_fr
    add_index :beasts, :name_ja
    add_index :beasts, :name_tc
  end
end
