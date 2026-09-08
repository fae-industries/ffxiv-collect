# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_08_145038) do
  create_table "achievement_categories", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.integer "type_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_achievement_categories_on_name_de"
    t.index ["name_en"], name: "index_achievement_categories_on_name_en"
    t.index ["name_fr"], name: "index_achievement_categories_on_name_fr"
    t.index ["name_ja"], name: "index_achievement_categories_on_name_ja"
    t.index ["name_tc"], name: "index_achievement_categories_on_name_tc"
    t.index ["order"], name: "index_achievement_categories_on_order"
    t.index ["type_id"], name: "index_achievement_categories_on_type_id"
  end

  create_table "achievement_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_achievement_types_on_name_de"
    t.index ["name_en"], name: "index_achievement_types_on_name_en"
    t.index ["name_fr"], name: "index_achievement_types_on_name_fr"
    t.index ["name_ja"], name: "index_achievement_types_on_name_ja"
    t.index ["name_tc"], name: "index_achievement_types_on_name_tc"
    t.index ["order"], name: "index_achievement_types_on_order"
  end

  create_table "achievements", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", null: false
    t.string "description_en", null: false
    t.string "description_fr", null: false
    t.string "description_ja", null: false
    t.string "description_tc"
    t.string "image_url"
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.string "patch"
    t.integer "points", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category_id"], name: "index_achievements_on_category_id"
    t.index ["name_de"], name: "index_achievements_on_name_de"
    t.index ["name_en"], name: "index_achievements_on_name_en"
    t.index ["name_fr"], name: "index_achievements_on_name_fr"
    t.index ["name_ja"], name: "index_achievements_on_name_ja"
    t.index ["name_tc"], name: "index_achievements_on_name_tc"
    t.index ["order"], name: "index_achievements_on_order"
    t.index ["patch"], name: "index_achievements_on_patch"
  end

  create_table "armoire_categories", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_armoire_categories_on_name_de"
    t.index ["name_en"], name: "index_armoire_categories_on_name_en"
    t.index ["name_fr"], name: "index_armoire_categories_on_name_fr"
    t.index ["name_ja"], name: "index_armoire_categories_on_name_ja"
    t.index ["name_tc"], name: "index_armoire_categories_on_name_tc"
    t.index ["order"], name: "index_armoire_categories_on_order"
  end

  create_table "armoires", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de"
    t.string "description_en"
    t.string "description_fr"
    t.string "description_ja"
    t.string "description_tc"
    t.string "gender"
    t.integer "item_id", null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.integer "order_group"
    t.boolean "outfitable", default: false
    t.string "patch"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category_id"], name: "index_armoires_on_category_id"
    t.index ["gender"], name: "index_armoires_on_gender"
    t.index ["item_id"], name: "index_armoires_on_item_id"
    t.index ["name_de"], name: "index_armoires_on_name_de"
    t.index ["name_en"], name: "index_armoires_on_name_en"
    t.index ["name_fr"], name: "index_armoires_on_name_fr"
    t.index ["name_ja"], name: "index_armoires_on_name_ja"
    t.index ["name_tc"], name: "index_armoires_on_name_tc"
    t.index ["order"], name: "index_armoires_on_order"
    t.index ["order_group"], name: "index_armoires_on_order_group"
    t.index ["patch"], name: "index_armoires_on_patch"
  end

  create_table "bardings", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de"
    t.string "description_en"
    t.string "description_fr"
    t.string "description_ja"
    t.string "description_tc"
    t.string "image_url"
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_bardings_on_name_de"
    t.index ["name_en"], name: "index_bardings_on_name_en"
    t.index ["name_fr"], name: "index_bardings_on_name_fr"
    t.index ["name_ja"], name: "index_bardings_on_name_ja"
    t.index ["name_tc"], name: "index_bardings_on_name_tc"
    t.index ["order"], name: "index_bardings_on_order"
    t.index ["patch"], name: "index_bardings_on_patch"
  end

  create_table "beast_actions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_de"
    t.text "description_en"
    t.text "description_fr"
    t.text "description_ja"
    t.text "description_tc"
    t.string "image_url"
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.datetime "updated_at", null: false
  end

  create_table "beasts", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_de"
    t.text "description_en"
    t.text "description_fr"
    t.text "description_ja"
    t.text "description_tc"
    t.string "image_url"
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.string "patch"
    t.integer "tempered_release_id"
    t.integer "trick_id"
    t.datetime "updated_at", null: false
    t.index ["name_de"], name: "index_beasts_on_name_de"
    t.index ["name_en"], name: "index_beasts_on_name_en"
    t.index ["name_fr"], name: "index_beasts_on_name_fr"
    t.index ["name_ja"], name: "index_beasts_on_name_ja"
    t.index ["name_tc"], name: "index_beasts_on_name_tc"
  end

  create_table "card_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_card_types_on_name_de", unique: true
    t.index ["name_en"], name: "index_card_types_on_name_en", unique: true
    t.index ["name_fr"], name: "index_card_types_on_name_fr", unique: true
    t.index ["name_ja"], name: "index_card_types_on_name_ja", unique: true
    t.index ["name_tc"], name: "index_card_types_on_name_tc"
  end

  create_table "cards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "bottom", null: false
    t.integer "buy_price"
    t.integer "card_type_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "deck_order"
    t.text "description_de", null: false
    t.text "description_en", null: false
    t.text "description_fr", null: false
    t.text "description_ja", null: false
    t.text "description_tc"
    t.string "formatted_number", null: false
    t.string "image_url"
    t.integer "item_id"
    t.string "large_image_url"
    t.integer "left", null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.integer "order_group"
    t.string "patch"
    t.integer "right", null: false
    t.integer "sell_price", null: false
    t.integer "stars", null: false
    t.integer "top", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_type_id"], name: "index_cards_on_card_type_id"
    t.index ["deck_order"], name: "index_cards_on_deck_order"
    t.index ["item_id"], name: "index_cards_on_item_id"
    t.index ["name_de"], name: "index_cards_on_name_de"
    t.index ["name_en"], name: "index_cards_on_name_en"
    t.index ["name_fr"], name: "index_cards_on_name_fr"
    t.index ["name_ja"], name: "index_cards_on_name_ja"
    t.index ["name_tc"], name: "index_cards_on_name_tc"
    t.index ["order"], name: "index_cards_on_order"
    t.index ["order_group"], name: "index_cards_on_order_group"
    t.index ["patch"], name: "index_cards_on_patch"
    t.index ["stars"], name: "index_cards_on_stars"
  end

  create_table "character_achievements", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "achievement_id"
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["achievement_id"], name: "index_character_achievements_on_achievement_id"
    t.index ["character_id", "achievement_id"], name: "index_character_achievements_on_character_id_and_achievement_id", unique: true
    t.index ["character_id"], name: "index_character_achievements_on_character_id"
  end

  create_table "character_armoires", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "armoire_id"
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["armoire_id"], name: "index_character_armoires_on_armoire_id"
    t.index ["character_id", "armoire_id"], name: "index_character_armoires_on_character_id_and_armoire_id", unique: true
    t.index ["character_id"], name: "index_character_armoires_on_character_id"
  end

  create_table "character_bardings", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "barding_id"
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["barding_id"], name: "index_character_bardings_on_barding_id"
    t.index ["character_id", "barding_id"], name: "index_character_bardings_on_character_id_and_barding_id", unique: true
    t.index ["character_id"], name: "index_character_bardings_on_character_id"
  end

  create_table "character_beasts", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "beast_id"
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beast_id"], name: "index_character_beasts_on_beast_id"
    t.index ["character_id", "beast_id"], name: "index_character_beasts_on_character_id_and_beast_id", unique: true
    t.index ["character_id"], name: "index_character_beasts_on_character_id"
  end

  create_table "character_cards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "card_id"
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_id"], name: "index_character_cards_on_card_id"
    t.index ["character_id", "card_id"], name: "index_character_cards_on_character_id_and_card_id", unique: true
    t.index ["character_id"], name: "index_character_achievements_on_character_id"
  end

  create_table "character_emotes", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "emote_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "emote_id"], name: "index_character_emotes_on_character_id_and_emote_id", unique: true
    t.index ["character_id"], name: "index_character_emotes_on_character_id"
    t.index ["emote_id"], name: "index_character_emotes_on_emote_id"
  end

  create_table "character_facewear", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.integer "facewear_id"
    t.datetime "updated_at", null: false
    t.index ["character_id", "facewear_id"], name: "character_id_and_facewear_id", unique: true
    t.index ["character_id"], name: "index_character_facewear_on_character_id"
    t.index ["facewear_id"], name: "index_character_facewear_on_facewear_id"
  end

  create_table "character_fashions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "fashion_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "fashion_id"], name: "index_character_fashions_on_character_id_and_fashion_id", unique: true
    t.index ["character_id"], name: "index_character_fashions_on_character_id"
    t.index ["fashion_id"], name: "index_character_fashions_on_fashion_id"
  end

  create_table "character_field_records", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "field_record_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "field_record_id"], name: "idx_on_character_id_field_record_id_e85f42d7de", unique: true
    t.index ["character_id"], name: "index_character_field_records_on_character_id"
    t.index ["field_record_id"], name: "index_character_field_records_on_field_record_id"
  end

  create_table "character_frames", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.integer "frame_id"
    t.datetime "updated_at", null: false
    t.index ["character_id", "frame_id"], name: "character_id_and_frame_id", unique: true
    t.index ["character_id"], name: "index_character_frames_on_character_id"
    t.index ["frame_id"], name: "index_character_frames_on_frame_id"
  end

  create_table "character_hairstyles", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "hairstyle_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "hairstyle_id"], name: "index_character_hairstyles_on_character_id_and_hairstyle_id", unique: true
    t.index ["character_id"], name: "index_character_hairstyles_on_character_id"
    t.index ["hairstyle_id"], name: "index_character_hairstyles_on_hairstyle_id"
  end

  create_table "character_leves", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "leve_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "leve_id"], name: "index_character_leves_on_character_id_and_leve_id", unique: true
    t.index ["character_id"], name: "index_character_achievements_on_character_id"
    t.index ["leve_id"], name: "index_character_leves_on_leve_id"
  end

  create_table "character_minions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "minion_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "minion_id"], name: "index_character_minions_on_character_id_and_minion_id", unique: true
    t.index ["character_id"], name: "index_character_minions_on_character_id"
    t.index ["minion_id"], name: "index_character_minions_on_minion_id"
  end

  create_table "character_mounts", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "mount_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "mount_id"], name: "index_character_mounts_on_character_id_and_mount_id", unique: true
    t.index ["character_id"], name: "index_character_mounts_on_character_id"
    t.index ["mount_id"], name: "index_character_mounts_on_mount_id"
  end

  create_table "character_npcs", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "npc_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "npc_id"], name: "index_character_npcs_on_character_id_and_npc_id", unique: true
    t.index ["character_id"], name: "index_character_achievements_on_character_id"
    t.index ["npc_id"], name: "index_character_npcs_on_npc_id"
  end

  create_table "character_occult_records", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.integer "occult_record_id"
    t.datetime "updated_at", null: false
    t.index ["character_id", "occult_record_id"], name: "character_id_and_occult_record_id", unique: true
    t.index ["character_id"], name: "index_character_occult_records_on_character_id"
    t.index ["occult_record_id"], name: "index_character_occult_records_on_occult_record_id"
  end

  create_table "character_orchestrions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "orchestrion_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "orchestrion_id"], name: "index_character_orchestrions_on_character_id_and_orchestrion_id", unique: true
    t.index ["character_id"], name: "index_character_orchestrions_on_character_id"
    t.index ["orchestrion_id"], name: "index_character_orchestrions_on_orchestrion_id"
  end

  create_table "character_outfits", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.integer "outfit_id"
    t.datetime "updated_at", null: false
    t.index ["character_id", "outfit_id"], name: "index_character_outfits_on_character_id_and_outfit_id", unique: true
    t.index ["character_id"], name: "index_character_outfits_on_character_id"
    t.index ["outfit_id"], name: "index_character_outfits_on_outfit_id"
  end

  create_table "character_relics", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "relic_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "relic_id"], name: "index_character_relics_on_character_id_and_relic_id", unique: true
    t.index ["character_id"], name: "index_character_relics_on_character_id"
    t.index ["relic_id"], name: "index_character_relics_on_relic_id"
  end

  create_table "character_spells", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "spell_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["character_id", "spell_id"], name: "index_character_spells_on_character_id_and_spell_id", unique: true
    t.index ["character_id"], name: "index_character_spells_on_character_id"
    t.index ["spell_id"], name: "index_character_spells_on_spell_id"
  end

  create_table "character_survey_records", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.integer "survey_record_id"
    t.datetime "updated_at", null: false
    t.index ["character_id", "survey_record_id"], name: "character_id_and_survey_record_id", unique: true
    t.index ["character_id"], name: "index_character_survey_records_on_character_id"
    t.index ["survey_record_id"], name: "index_character_survey_records_on_survey_record_id"
  end

  create_table "characters", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "achievement_points", default: 0
    t.integer "achievements_count", default: 0
    t.integer "armoires_count", default: 0
    t.string "avatar", null: false
    t.boolean "banned", default: false
    t.integer "bardings_count", default: 0
    t.integer "beasts_count", default: 0
    t.integer "cards_count", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.string "data_center"
    t.integer "emotes_count", default: 0
    t.integer "facewear_count", default: 0
    t.integer "fashions_count", default: 0
    t.integer "field_records_count", default: 0
    t.integer "frames_count", default: 0
    t.string "free_company_id"
    t.string "gender"
    t.integer "hairstyles_count", default: 0
    t.datetime "last_parsed", precision: nil
    t.datetime "last_ranked_achievement_time", precision: nil
    t.integer "leves_count", default: 0
    t.integer "minions_count", default: 0
    t.integer "mounts_count", default: 0
    t.string "name", null: false
    t.integer "npcs_count", default: 0
    t.integer "occult_records_count", default: 0
    t.integer "orchestrions_count", default: 0
    t.integer "outfits_count", default: 0
    t.string "portrait"
    t.string "pricing_data_center"
    t.boolean "public", default: true
    t.boolean "public_achievements", default: false
    t.boolean "public_emotes", default: false
    t.boolean "public_facewear", default: true
    t.boolean "public_minions", default: true
    t.boolean "public_mounts", default: true
    t.boolean "public_profile", default: true
    t.datetime "queued_at", precision: nil, default: "1970-01-01 00:00:00"
    t.integer "ranked_achievement_points", default: 0
    t.integer "ranked_minions_count", default: 0
    t.integer "ranked_mounts_count", default: 0
    t.datetime "refreshed_at", precision: nil, default: "1970-01-01 00:00:00"
    t.integer "relics_count", default: 0
    t.string "server", null: false
    t.integer "spells_count", default: 0
    t.boolean "supporter", default: false
    t.integer "survey_records_count", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.integer "verified_user_id"
    t.index ["achievement_points"], name: "index_characters_on_achievement_points"
    t.index ["achievements_count"], name: "index_characters_on_achievements_count"
    t.index ["armoires_count"], name: "index_characters_on_armoires_count"
    t.index ["bardings_count"], name: "index_characters_on_bardings_count"
    t.index ["beasts_count"], name: "index_characters_on_beasts_count"
    t.index ["cards_count"], name: "index_characters_on_cards_count"
    t.index ["data_center"], name: "index_characters_on_data_center"
    t.index ["emotes_count"], name: "index_characters_on_emotes_count"
    t.index ["facewear_count"], name: "index_characters_on_facewear_count"
    t.index ["fashions_count"], name: "index_characters_on_fashions_count"
    t.index ["field_records_count"], name: "index_characters_on_field_records_count"
    t.index ["frames_count"], name: "index_characters_on_frames_count"
    t.index ["free_company_id"], name: "index_characters_on_free_company_id"
    t.index ["hairstyles_count"], name: "index_characters_on_hairstyles_count"
    t.index ["last_ranked_achievement_time"], name: "index_characters_on_last_ranked_achievement_time"
    t.index ["leves_count"], name: "index_characters_on_leves_count"
    t.index ["minions_count"], name: "index_characters_on_minions_count"
    t.index ["mounts_count"], name: "index_characters_on_mounts_count"
    t.index ["name"], name: "index_characters_on_name"
    t.index ["npcs_count"], name: "index_characters_on_npcs_count"
    t.index ["occult_records_count"], name: "index_characters_on_occult_records_count"
    t.index ["orchestrions_count"], name: "index_characters_on_orchestrions_count"
    t.index ["outfits_count"], name: "index_characters_on_outfits_count"
    t.index ["public"], name: "index_characters_on_public"
    t.index ["public_facewear"], name: "index_characters_on_public_facewear"
    t.index ["public_minions"], name: "index_characters_on_public_minions"
    t.index ["public_mounts"], name: "index_characters_on_public_mounts"
    t.index ["ranked_achievement_points"], name: "index_characters_on_ranked_achievement_points"
    t.index ["ranked_minions_count"], name: "index_characters_on_ranked_minions_count"
    t.index ["ranked_mounts_count"], name: "index_characters_on_ranked_mounts_count"
    t.index ["relics_count"], name: "index_characters_on_relics_count"
    t.index ["server"], name: "index_characters_on_server"
    t.index ["spells_count"], name: "index_characters_on_spells_count"
    t.index ["survey_records_count"], name: "index_characters_on_survey_records_count"
    t.index ["updated_at"], name: "index_characters_on_updated_at"
  end

  create_table "content_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", null: false
  end

  create_table "deck_cards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "card_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "deck_id"
    t.integer "position"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_id"], name: "index_deck_cards_on_card_id"
    t.index ["deck_id"], name: "index_deck_cards_on_deck_id"
  end

  create_table "decks", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "notes", limit: 1000
    t.integer "npc_id"
    t.integer "rating"
    t.integer "rule_id"
    t.boolean "updated", default: true
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.string "user_uid"
    t.index ["npc_id"], name: "index_decks_on_npc_id"
    t.index ["rule_id"], name: "index_decks_on_rule_id"
    t.index ["updated"], name: "index_decks_on_updated"
    t.index ["user_id"], name: "index_decks_on_user_id"
    t.index ["user_uid"], name: "index_decks_on_user_uid"
  end

  create_table "emote_categories", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_emote_categories_on_name_de"
    t.index ["name_en"], name: "index_emote_categories_on_name_en"
    t.index ["name_fr"], name: "index_emote_categories_on_name_fr"
    t.index ["name_ja"], name: "index_emote_categories_on_name_ja"
    t.index ["name_tc"], name: "index_emote_categories_on_name_tc"
  end

  create_table "emotes", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "command_de"
    t.string "command_en"
    t.string "command_fr"
    t.string "command_ja"
    t.string "command_tc"
    t.datetime "created_at", precision: nil, null: false
    t.string "image_url"
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category_id"], name: "index_emotes_on_category_id"
    t.index ["name_de"], name: "index_emotes_on_name_de"
    t.index ["name_en"], name: "index_emotes_on_name_en"
    t.index ["name_fr"], name: "index_emotes_on_name_fr"
    t.index ["name_ja"], name: "index_emotes_on_name_ja"
    t.index ["name_tc"], name: "index_emotes_on_name_tc"
    t.index ["order"], name: "index_emotes_on_order"
    t.index ["patch"], name: "index_emotes_on_patch"
  end

  create_table "facewear", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "image_url"
    t.text "image_urls"
    t.integer "item_id"
    t.string "lodestone_name"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.string "patch"
    t.datetime "updated_at", null: false
    t.index ["name_de"], name: "index_facewear_on_name_de"
    t.index ["name_en"], name: "index_facewear_on_name_en"
    t.index ["name_fr"], name: "index_facewear_on_name_fr"
    t.index ["name_ja"], name: "index_facewear_on_name_ja"
    t.index ["name_tc"], name: "index_facewear_on_name_tc"
    t.index ["order"], name: "index_facewear_on_order"
    t.index ["patch"], name: "index_facewear_on_patch"
  end

  create_table "fashions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", limit: 1000
    t.string "description_en", limit: 1000
    t.string "description_fr", limit: 1000
    t.string "description_ja", limit: 1000
    t.string "description_tc", limit: 1000
    t.string "image_url"
    t.integer "item_id"
    t.string "large_image_url"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.string "patch"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_fashions_on_name_de"
    t.index ["name_en"], name: "index_fashions_on_name_en"
    t.index ["name_fr"], name: "index_fashions_on_name_fr"
    t.index ["name_ja"], name: "index_fashions_on_name_ja"
    t.index ["name_tc"], name: "index_fashions_on_name_tc"
    t.index ["order"], name: "index_fashions_on_order"
    t.index ["patch"], name: "index_fashions_on_patch"
  end

  create_table "field_records", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description_de", null: false
    t.text "description_en", null: false
    t.text "description_fr", null: false
    t.text "description_ja", null: false
    t.text "description_tc"
    t.string "image_url"
    t.string "large_image_url"
    t.integer "linked_record_id"
    t.string "location_de"
    t.string "location_en"
    t.string "location_fr"
    t.string "location_ja"
    t.string "location_tc"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "patch"
    t.integer "rarity", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["linked_record_id"], name: "index_field_records_on_linked_record_id"
    t.index ["name_de"], name: "index_field_records_on_name_de"
    t.index ["name_en"], name: "index_field_records_on_name_en"
    t.index ["name_fr"], name: "index_field_records_on_name_fr"
    t.index ["name_ja"], name: "index_field_records_on_name_ja"
    t.index ["name_tc"], name: "index_field_records_on_name_tc"
  end

  create_table "frames", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.boolean "portrait_only", default: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_frames_on_item_id"
    t.index ["name_de"], name: "index_frames_on_name_de"
    t.index ["name_en"], name: "index_frames_on_name_en"
    t.index ["name_fr"], name: "index_frames_on_name_fr"
    t.index ["name_ja"], name: "index_frames_on_name_ja"
    t.index ["name_tc"], name: "index_frames_on_name_tc"
    t.index ["order"], name: "index_frames_on_order"
    t.index ["patch"], name: "index_frames_on_patch"
  end

  create_table "free_companies", id: :string, charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "queued_at", precision: nil, default: "1970-01-01 00:00:00"
    t.boolean "syncing", default: false
    t.string "tag"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "group_memberships", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.integer "group_id"
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_group_memberships_on_character_id"
    t.index ["group_id", "character_id"], name: "index_group_memberships_on_group_id_and_character_id", unique: true
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
  end

  create_table "groups", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.boolean "public", default: true
    t.datetime "queued_at", precision: nil, default: "1970-01-01 00:00:00"
    t.string "slug", null: false
    t.boolean "syncing", default: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_groups_on_owner_id"
    t.index ["slug"], name: "index_groups_on_slug", unique: true
  end

  create_table "hairstyles", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", limit: 1000
    t.string "description_en", limit: 1000
    t.string "description_fr", limit: 1000
    t.string "description_ja", limit: 1000
    t.string "description_tc", limit: 1000
    t.boolean "femhrothable", default: false
    t.string "gender"
    t.boolean "hrothable", default: false
    t.string "image_url"
    t.text "image_urls"
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "patch"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "vierable", default: false
    t.index ["gender"], name: "index_hairstyles_on_gender"
    t.index ["name_de"], name: "index_hairstyles_on_name_de"
    t.index ["name_en"], name: "index_hairstyles_on_name_en"
    t.index ["name_fr"], name: "index_hairstyles_on_name_fr"
    t.index ["name_ja"], name: "index_hairstyles_on_name_ja"
    t.index ["name_tc"], name: "index_hairstyles_on_name_tc"
    t.index ["patch"], name: "index_hairstyles_on_patch"
  end

  create_table "identities", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "username"
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "instances", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "content_id"
    t.integer "content_type_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_en"], name: "index_instances_on_name_en"
  end

  create_table "items", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.string "crafter"
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", limit: 1000, null: false
    t.string "description_en", limit: 1000, null: false
    t.string "description_fr", limit: 1000, null: false
    t.string "description_ja", limit: 1000, null: false
    t.string "description_tc", limit: 1000
    t.string "image_url"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "plural_de"
    t.string "plural_en"
    t.string "plural_fr"
    t.string "plural_ja"
    t.string "plural_tc"
    t.integer "price"
    t.integer "quest_id"
    t.integer "recipe_id"
    t.boolean "tradeable"
    t.integer "unlock_id"
    t.string "unlock_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_items_on_name_de"
    t.index ["name_en"], name: "index_items_on_name_en"
    t.index ["name_fr"], name: "index_items_on_name_fr"
    t.index ["name_ja"], name: "index_items_on_name_ja"
    t.index ["name_tc"], name: "index_items_on_name_tc"
    t.index ["quest_id"], name: "index_items_on_quest_id"
    t.index ["unlock_type"], name: "index_items_on_unlock_type"
  end

  create_table "leve_categories", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.string "craft_de", null: false
    t.string "craft_en", null: false
    t.string "craft_fr", null: false
    t.string "craft_ja", null: false
    t.string "craft_tc"
    t.datetime "created_at", null: false
    t.boolean "items", default: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.datetime "updated_at", null: false
    t.index ["craft_de"], name: "index_leve_categories_on_craft_de"
    t.index ["craft_en"], name: "index_leve_categories_on_craft_en"
    t.index ["craft_fr"], name: "index_leve_categories_on_craft_fr"
    t.index ["craft_ja"], name: "index_leve_categories_on_craft_ja"
    t.index ["craft_tc"], name: "index_leve_categories_on_craft_tc"
    t.index ["name_de"], name: "index_leve_categories_on_name_de"
    t.index ["name_en"], name: "index_leve_categories_on_name_en"
    t.index ["name_fr"], name: "index_leve_categories_on_name_fr"
    t.index ["name_ja"], name: "index_leve_categories_on_name_ja"
    t.index ["name_tc"], name: "index_leve_categories_on_name_tc"
    t.index ["order"], name: "index_leve_categories_on_order"
  end

  create_table "leves", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "cost", default: 1
    t.datetime "created_at", null: false
    t.string "issuer_name_de", null: false
    t.string "issuer_name_en", null: false
    t.string "issuer_name_fr", null: false
    t.string "issuer_name_ja", null: false
    t.string "issuer_name_tc"
    t.decimal "issuer_x", precision: 3, scale: 1, null: false
    t.decimal "issuer_y", precision: 3, scale: 1, null: false
    t.integer "item_id"
    t.integer "item_quantity"
    t.integer "level", null: false
    t.boolean "limited", default: false
    t.integer "location_id", null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "patch"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_leves_on_category_id"
    t.index ["item_id"], name: "index_leves_on_item_id"
    t.index ["location_id"], name: "index_leves_on_location_id"
    t.index ["name_de"], name: "index_leves_on_name_de"
    t.index ["name_en"], name: "index_leves_on_name_en"
    t.index ["name_fr"], name: "index_leves_on_name_fr"
    t.index ["name_ja"], name: "index_leves_on_name_ja"
    t.index ["name_tc"], name: "index_leves_on_name_tc"
    t.index ["patch"], name: "index_leves_on_patch"
  end

  create_table "locations", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "region_de", null: false
    t.string "region_en", null: false
    t.string "region_fr", null: false
    t.string "region_ja", null: false
    t.string "region_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_locations_on_name_de", unique: true
    t.index ["name_en"], name: "index_locations_on_name_en", unique: true
    t.index ["name_fr"], name: "index_locations_on_name_fr", unique: true
    t.index ["name_ja"], name: "index_locations_on_name_ja", unique: true
    t.index ["name_tc"], name: "index_locations_on_name_tc"
    t.index ["region_de"], name: "index_locations_on_region_de"
    t.index ["region_en"], name: "index_locations_on_region_en"
    t.index ["region_fr"], name: "index_locations_on_region_fr"
    t.index ["region_ja"], name: "index_locations_on_region_ja"
    t.index ["region_tc"], name: "index_locations_on_region_tc"
  end

  create_table "minion_behaviors", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "minion_races", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "minion_skill_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "minions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.boolean "arcana", null: false
    t.boolean "area_attack", null: false
    t.integer "attack", null: false
    t.integer "behavior_id", null: false
    t.integer "cost", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "defense", null: false
    t.string "description_de", limit: 1000
    t.string "description_en", limit: 1000
    t.string "description_fr", limit: 1000
    t.string "description_ja", limit: 1000
    t.string "description_tc", limit: 1000
    t.string "enhanced_description_de", limit: 1000
    t.string "enhanced_description_en", limit: 1000
    t.string "enhanced_description_fr", limit: 1000
    t.string "enhanced_description_ja", limit: 1000
    t.string "enhanced_description_tc", limit: 1000
    t.boolean "eye", null: false
    t.string "footprint_image_url"
    t.boolean "gate", null: false
    t.integer "hp", null: false
    t.string "image_url"
    t.integer "item_id"
    t.string "large_image_url"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.integer "race_id", null: false
    t.boolean "shield", null: false
    t.integer "skill_angle", null: false
    t.integer "skill_cost", null: false
    t.string "skill_de"
    t.string "skill_description_de"
    t.string "skill_description_en"
    t.string "skill_description_fr"
    t.string "skill_description_ja"
    t.string "skill_description_tc"
    t.string "skill_en"
    t.string "skill_fr"
    t.string "skill_ja"
    t.string "skill_tc"
    t.integer "skill_type_id"
    t.integer "speed", null: false
    t.string "tooltip_de"
    t.string "tooltip_en"
    t.string "tooltip_fr"
    t.string "tooltip_ja"
    t.string "tooltip_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["behavior_id"], name: "index_minions_on_behavior_id"
    t.index ["name_de"], name: "index_minions_on_name_de"
    t.index ["name_en"], name: "index_minions_on_name_en"
    t.index ["name_fr"], name: "index_minions_on_name_fr"
    t.index ["name_ja"], name: "index_minions_on_name_ja"
    t.index ["name_tc"], name: "index_minions_on_name_tc"
    t.index ["order"], name: "index_minions_on_order"
    t.index ["patch"], name: "index_minions_on_patch"
    t.index ["race_id"], name: "index_minions_on_race_id"
    t.index ["skill_type_id"], name: "index_minions_on_skill_type_id"
  end

  create_table "mounts", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "custom_music", default: false
    t.string "description_de", null: false
    t.string "description_en", null: false
    t.string "description_fr", null: false
    t.string "description_ja", null: false
    t.string "description_tc"
    t.string "enhanced_description_de", limit: 1000, null: false
    t.string "enhanced_description_en", limit: 1000, null: false
    t.string "enhanced_description_fr", limit: 1000, null: false
    t.string "enhanced_description_ja", limit: 1000, null: false
    t.string "enhanced_description_tc", limit: 1000
    t.string "footprint_image_url"
    t.string "image_url"
    t.integer "item_id"
    t.string "large_image_url"
    t.string "movement", null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.integer "order_group"
    t.string "patch"
    t.integer "seats", null: false
    t.string "tooltip_de", null: false
    t.string "tooltip_en", null: false
    t.string "tooltip_fr", null: false
    t.string "tooltip_ja", null: false
    t.string "tooltip_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.string "video"
    t.index ["name_de"], name: "index_mounts_on_name_de"
    t.index ["name_en"], name: "index_mounts_on_name_en"
    t.index ["name_fr"], name: "index_mounts_on_name_fr"
    t.index ["name_ja"], name: "index_mounts_on_name_ja"
    t.index ["name_tc"], name: "index_mounts_on_name_tc"
    t.index ["order"], name: "index_mounts_on_order"
    t.index ["patch"], name: "index_mounts_on_patch"
  end

  create_table "npc_cards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.boolean "fixed", default: true, null: false
    t.integer "npc_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_id"], name: "index_npc_cards_on_card_id"
    t.index ["npc_id"], name: "index_npc_cards_on_npc_id"
  end

  create_table "npc_rewards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "npc_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_id"], name: "index_npc_rewards_on_card_id"
    t.index ["npc_id"], name: "index_npc_rewards_on_npc_id"
  end

  create_table "npcs", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.decimal "difficulty", precision: 3, scale: 2
    t.boolean "excluded", default: false
    t.integer "location_id", null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "patch"
    t.integer "quest_id"
    t.integer "resident_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "x", precision: 3, scale: 1
    t.decimal "y", precision: 3, scale: 1
    t.index ["location_id"], name: "index_npcs_on_location_id"
    t.index ["name_de"], name: "index_npcs_on_name_de", unique: true
    t.index ["name_en"], name: "index_npcs_on_name_en", unique: true
    t.index ["name_fr"], name: "index_npcs_on_name_fr", unique: true
    t.index ["name_ja"], name: "index_npcs_on_name_ja", unique: true
    t.index ["name_tc"], name: "index_npcs_on_name_tc"
    t.index ["patch"], name: "index_npcs_on_patch"
  end

  create_table "npcs_rules", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "npc_id"
    t.integer "rule_id"
    t.index ["npc_id", "rule_id"], name: "index_npcs_rules_on_npc_id_and_rule_id", unique: true
    t.index ["npc_id"], name: "index_npcs_rules_on_npc_id"
    t.index ["rule_id"], name: "index_npcs_rules_on_rule_id"
  end

  create_table "occult_records", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_de"
    t.text "description_en"
    t.text "description_fr"
    t.text "description_ja"
    t.text "description_tc"
    t.string "image_url"
    t.string "location_de"
    t.string "location_en"
    t.string "location_fr"
    t.string "location_ja"
    t.string "location_tc"
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.string "patch"
    t.datetime "updated_at", null: false
    t.index ["name_de"], name: "index_occult_records_on_name_de"
    t.index ["name_en"], name: "index_occult_records_on_name_en"
    t.index ["name_fr"], name: "index_occult_records_on_name_fr"
    t.index ["name_ja"], name: "index_occult_records_on_name_ja"
    t.index ["name_tc"], name: "index_occult_records_on_name_tc"
    t.index ["patch"], name: "index_occult_records_on_patch"
  end

  create_table "orchestrion_categories", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_orchestrion_categories_on_name_de"
    t.index ["name_en"], name: "index_orchestrion_categories_on_name_en"
    t.index ["name_fr"], name: "index_orchestrion_categories_on_name_fr"
    t.index ["name_ja"], name: "index_orchestrion_categories_on_name_ja"
    t.index ["name_tc"], name: "index_orchestrion_categories_on_name_tc"
    t.index ["order"], name: "index_orchestrion_categories_on_order"
  end

  create_table "orchestrions", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", null: false
    t.string "description_en", null: false
    t.string "description_fr", null: false
    t.string "description_ja", null: false
    t.string "description_tc"
    t.string "details"
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category_id"], name: "index_orchestrions_on_category_id"
    t.index ["name_de"], name: "index_orchestrions_on_name_de"
    t.index ["name_en"], name: "index_orchestrions_on_name_en"
    t.index ["name_fr"], name: "index_orchestrions_on_name_fr"
    t.index ["name_ja"], name: "index_orchestrions_on_name_ja"
    t.index ["name_tc"], name: "index_orchestrions_on_name_tc"
    t.index ["order"], name: "index_orchestrions_on_order"
    t.index ["patch"], name: "index_orchestrions_on_patch"
  end

  create_table "outfit_items", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "item_id"
    t.integer "outfit_id"
    t.index ["item_id"], name: "index_outfit_items_on_item_id"
    t.index ["outfit_id"], name: "index_outfit_items_on_outfit_id"
  end

  create_table "outfits", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.boolean "armoireable", default: false
    t.datetime "created_at", null: false
    t.string "gender"
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.string "patch"
    t.boolean "tradeable", default: false
    t.datetime "updated_at", null: false
    t.index ["armoireable"], name: "index_outfits_on_armoireable"
    t.index ["gender"], name: "index_outfits_on_gender"
    t.index ["name_de"], name: "index_outfits_on_name_de"
    t.index ["name_en"], name: "index_outfits_on_name_en"
    t.index ["name_fr"], name: "index_outfits_on_name_fr"
    t.index ["name_ja"], name: "index_outfits_on_name_ja"
    t.index ["name_tc"], name: "index_outfits_on_name_tc"
    t.index ["patch"], name: "index_outfits_on_patch"
  end

  create_table "pack_cards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "pack_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_id"], name: "index_pack_cards_on_card_id"
    t.index ["pack_id"], name: "index_pack_cards_on_pack_id"
  end

  create_table "packs", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "cost", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "item_id"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["item_id"], name: "index_packs_on_item_id"
    t.index ["name_de"], name: "index_packs_on_name_de", unique: true
    t.index ["name_en"], name: "index_packs_on_name_en", unique: true
    t.index ["name_fr"], name: "index_packs_on_name_fr", unique: true
    t.index ["name_ja"], name: "index_packs_on_name_ja", unique: true
    t.index ["name_tc"], name: "index_packs_on_name_tc"
  end

  create_table "quests", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "event"
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_en"], name: "index_quests_on_name_en"
  end

  create_table "relic_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "expansion"
    t.integer "jobs"
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.integer "order"
    t.datetime "updated_at", null: false
    t.index ["expansion"], name: "index_relic_types_on_expansion"
    t.index ["order"], name: "index_relic_types_on_order"
  end

  create_table "relics", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "achievement_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "image_url"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.integer "type_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["achievement_id"], name: "index_relics_on_achievement_id"
    t.index ["order"], name: "index_relics_on_order"
    t.index ["type_id"], name: "index_relics_on_type_id"
  end

  create_table "rules", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", null: false
    t.string "description_en", null: false
    t.string "description_fr", null: false
    t.string "description_ja", null: false
    t.string "description_tc"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_rules_on_name_de", unique: true
    t.index ["name_en"], name: "index_rules_on_name_en", unique: true
    t.index ["name_fr"], name: "index_rules_on_name_fr", unique: true
    t.index ["name_ja"], name: "index_rules_on_name_ja", unique: true
    t.index ["name_tc"], name: "index_rules_on_name_tc"
  end

  create_table "source_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de"
    t.string "name_en", null: false
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_en"], name: "index_source_types_on_name_en", unique: true
  end

  create_table "sources", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "collectable_id", null: false
    t.string "collectable_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.boolean "limited", default: false
    t.boolean "premium", default: false
    t.integer "related_id"
    t.string "related_type"
    t.string "text_de"
    t.string "text_en"
    t.string "text_fr"
    t.string "text_ja"
    t.string "text_tc"
    t.integer "type_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["collectable_id", "collectable_type"], name: "index_sources_on_collectable_id_and_collectable_type"
    t.index ["limited"], name: "index_sources_on_limited"
    t.index ["premium"], name: "index_sources_on_premium"
    t.index ["related_id", "related_type"], name: "index_sources_on_related_id_and_related_type"
    t.index ["type_id"], name: "index_sources_on_type_id"
  end

  create_table "spell_aspects", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_spell_aspects_on_name_de"
    t.index ["name_en"], name: "index_spell_aspects_on_name_en"
    t.index ["name_fr"], name: "index_spell_aspects_on_name_fr"
    t.index ["name_ja"], name: "index_spell_aspects_on_name_ja"
    t.index ["name_tc"], name: "index_spell_aspects_on_name_tc"
  end

  create_table "spell_types", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name_de"], name: "index_spell_types_on_name_de"
    t.index ["name_en"], name: "index_spell_types_on_name_en"
    t.index ["name_fr"], name: "index_spell_types_on_name_fr"
    t.index ["name_ja"], name: "index_spell_types_on_name_ja"
    t.index ["name_tc"], name: "index_spell_types_on_name_tc"
  end

  create_table "spells", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "aspect_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "description_de", limit: 1000, null: false
    t.string "description_en", limit: 1000, null: false
    t.string "description_fr", limit: 1000, null: false
    t.string "description_ja", limit: 1000, null: false
    t.string "description_tc", limit: 1000
    t.string "image_url"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.integer "rank", null: false
    t.string "tooltip_de", limit: 1000, null: false
    t.string "tooltip_en", limit: 1000, null: false
    t.string "tooltip_fr", limit: 1000, null: false
    t.string "tooltip_ja", limit: 1000, null: false
    t.string "tooltip_tc", limit: 1000
    t.integer "type_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["aspect_id"], name: "index_spells_on_aspect_id"
    t.index ["name_de"], name: "index_spells_on_name_de"
    t.index ["name_en"], name: "index_spells_on_name_en"
    t.index ["name_fr"], name: "index_spells_on_name_fr"
    t.index ["name_ja"], name: "index_spells_on_name_ja"
    t.index ["name_tc"], name: "index_spells_on_name_tc"
    t.index ["order"], name: "index_spells_on_order"
    t.index ["type_id"], name: "index_spells_on_type_id"
  end

  create_table "survey_record_series", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.datetime "updated_at", null: false
  end

  create_table "survey_records", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_de"
    t.text "description_en"
    t.text "description_fr"
    t.text "description_ja"
    t.text "description_tc"
    t.string "image_url"
    t.string "large_image_url"
    t.string "name_de"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_ja"
    t.string "name_tc"
    t.integer "order"
    t.string "patch"
    t.integer "series_id"
    t.string "solution_de", limit: 1000
    t.string "solution_en", limit: 1000
    t.string "solution_fr", limit: 1000
    t.string "solution_ja", limit: 1000
    t.string "solution_tc", limit: 1000
    t.datetime "updated_at", null: false
    t.index ["order"], name: "index_survey_records_on_order"
    t.index ["series_id"], name: "index_survey_records_on_series_id"
  end

  create_table "titles", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "achievement_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "female_name_de", null: false
    t.string "female_name_en", null: false
    t.string "female_name_fr", null: false
    t.string "female_name_ja", null: false
    t.string "female_name_tc"
    t.string "name_de", null: false
    t.string "name_en", null: false
    t.string "name_fr", null: false
    t.string "name_ja", null: false
    t.string "name_tc"
    t.integer "order", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["achievement_id"], name: "index_titles_on_achievement_id"
  end

  create_table "tomestone_rewards", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "collectable_id"
    t.string "collectable_type"
    t.integer "cost"
    t.datetime "created_at", precision: nil, null: false
    t.string "tomestone"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["collectable_id", "collectable_type"], name: "index_tomestone_rewards_on_collectable_id_and_collectable_type"
    t.index ["tomestone"], name: "index_tomestone_rewards_on_tomestone"
  end

  create_table "user_characters", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["character_id"], name: "index_user_characters_on_character_id"
    t.index ["user_id", "character_id"], name: "index_user_characters_on_user_id_and_character_id", unique: true
    t.index ["user_id"], name: "index_user_characters_on_user_id"
  end

  create_table "users", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.boolean "admin", default: false
    t.string "avatar_url"
    t.integer "character_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "current_identity_id"
    t.string "database", default: "garland", null: false
    t.integer "discriminator"
    t.boolean "mod", default: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.index ["character_id"], name: "index_users_on_character_id"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "collectable_id"
    t.string "collectable_type", limit: 191
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.text "object", size: :long
    t.text "object_changes", size: :long
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "votes", charset: "utf8", collation: "utf8_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "deck_id"
    t.integer "score", default: 1
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["deck_id", "user_id"], name: "index_votes_on_deck_id_and_user_id", unique: true
    t.index ["deck_id"], name: "index_votes_on_deck_id"
  end
end
