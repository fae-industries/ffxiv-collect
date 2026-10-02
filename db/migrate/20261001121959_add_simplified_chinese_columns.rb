class AddSimplifiedChineseColumns < ActiveRecord::Migration[8.1]
  def change
    # Achievement Categories
    add_column :achievement_categories, :name_chs, :string
    add_index :achievement_categories, :name_chs

    # Achievement Types
    add_column :achievement_types, :name_chs, :string
    add_index :achievement_types, :name_chs

    # Achievements
    add_column :achievements, :name_chs, :string
    add_column :achievements, :description_chs, :string
    add_index :achievements, :name_chs

    # Armoire Categories
    add_column :armoire_categories, :name_chs, :string
    add_index :armoire_categories, :name_chs

    # Armoires
    add_column :armoires, :name_chs, :string
    add_column :armoires, :description_chs, :string
    add_index :armoires, :name_chs

    # Bardings
    add_column :bardings, :name_chs, :string
    add_column :bardings, :description_chs, :string
    add_index :bardings, :name_chs

    # Beasts
    add_column :beasts, :name_chs, :string
    add_column :beasts, :description_chs, :string

    add_column :beast_actions, :name_chs, :string
    add_column :beast_actions, :description_chs, :string

    # Card Types
    add_column :card_types, :name_chs, :string
    add_index :card_types, :name_chs

    # Cards
    add_column :cards, :name_chs, :string
    add_column :cards, :description_chs, :text
    add_index :cards, :name_chs

    # Content Types
    add_column :content_types, :name_chs, :string

    # Emote Categories
    add_column :emote_categories, :name_chs, :string
    add_index :emote_categories, :name_chs

    # Emotes
    add_column :emotes, :name_chs, :string
    add_column :emotes, :command_chs, :string
    add_index :emotes, :name_chs

    # Facewear
    add_column :facewear, :name_chs, :string
    add_index :facewear, :name_chs

    # Fashions
    add_column :fashions, :name_chs, :string
    add_column :fashions, :description_chs, :string, limit: 1000
    add_index :fashions, :name_chs

    # Field Records
    add_column :field_records, :name_chs, :string
    add_column :field_records, :description_chs, :text
    add_column :field_records, :location_chs, :text
    add_index :field_records, :name_chs

    # Frames
    add_column :frames, :name_chs, :string
    add_index :frames, :name_chs

    # Hairstyles
    add_column :hairstyles, :name_chs, :string
    add_column :hairstyles, :description_chs, :string, limit: 1000
    add_index :hairstyles, :name_chs

    # Instances
    add_column :instances, :name_chs, :string

    # Items
    add_column :items, :name_chs, :string
    add_column :items, :description_chs, :string, limit: 1000
    add_column :items, :plural_chs, :string
    add_index :items, :name_chs

    # Leve Categories
    add_column :leve_categories, :name_chs, :string
    add_column :leve_categories, :craft_chs, :string
    add_index :leve_categories, :name_chs
    add_index :leve_categories, :craft_chs

    # Leves
    add_column :leves, :name_chs, :string
    add_column :leves, :issuer_name_chs, :string
    add_index :leves, :name_chs

    # Locations
    add_column :locations, :name_chs, :string
    add_column :locations, :region_chs, :string
    add_index :locations, :name_chs
    add_index :locations, :region_chs

    # Minion Behaviors
    add_column :minion_behaviors, :name_chs, :string

    # Minion Races
    add_column :minion_races, :name_chs, :string

    # Minion Skill Types
    add_column :minion_skill_types, :name_chs, :string

    # Minions
    add_column :minions, :name_chs, :string
    add_column :minions, :description_chs, :string, limit: 1000
    add_column :minions, :tooltip_chs, :string
    add_column :minions, :skill_chs, :string
    add_column :minions, :skill_description_chs, :string
    add_column :minions, :enhanced_description_chs, :string, limit: 1000
    add_index :minions, :name_chs

    # Mounts
    add_column :mounts, :name_chs, :string
    add_column :mounts, :description_chs, :string
    add_column :mounts, :enhanced_description_chs, :string, limit: 1000
    add_column :mounts, :tooltip_chs, :string
    add_index :mounts, :name_chs

    # NPCs
    add_column :npcs, :name_chs, :string
    add_index :npcs, :name_chs

    # Occult Records
    add_column :occult_records, :name_chs, :string
    add_column :occult_records, :description_chs, :text
    add_column :occult_records, :location_chs, :text
    add_index :occult_records, :name_chs

    # Orchestrion Categories
    add_column :orchestrion_categories, :name_chs, :string
    add_index :orchestrion_categories, :name_chs

    # Orchestrions
    add_column :orchestrions, :name_chs, :string
    add_column :orchestrions, :description_chs, :string
    add_index :orchestrions, :name_chs

    # Outfits
    add_column :outfits, :name_chs, :string
    add_index :outfits, :name_chs

    # Packs
    add_column :packs, :name_chs, :string
    add_index :packs, :name_chs

    # Quests
    add_column :quests, :name_chs, :string

    # Relic Types
    add_column :relic_types, :name_chs, :string

    # Relics
    add_column :relics, :name_chs, :string

    # Rules
    add_column :rules, :name_chs, :string
    add_column :rules, :description_chs, :string
    add_index :rules, :name_chs

    # Source Types
    add_column :source_types, :name_chs, :string

    # Sources
    add_column :sources, :text_chs, :string

    # Spell Aspects
    add_column :spell_aspects, :name_chs, :string
    add_index :spell_aspects, :name_chs

    # Spell Types
    add_column :spell_types, :name_chs, :string
    add_index :spell_types, :name_chs

    # Spells
    add_column :spells, :name_chs, :string
    add_column :spells, :description_chs, :string, limit: 1000
    add_column :spells, :tooltip_chs, :string, limit: 1000
    add_index :spells, :name_chs

    # Survey Record Series
    add_column :survey_record_series, :name_chs, :string

    # Survey Records
    add_column :survey_records, :name_chs, :string
    add_column :survey_records, :description_chs, :text
    add_column :survey_records, :solution_chs, :string, limit: 1000

    # Titles
    add_column :titles, :name_chs, :string
    add_column :titles, :female_name_chs, :string
  end
end
