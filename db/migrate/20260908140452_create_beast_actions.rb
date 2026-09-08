class CreateBeastActions < ActiveRecord::Migration[8.1]
  def change
    create_table :beast_actions do |t|
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

      t.timestamps
    end
  end
end
