namespace :triad do
  namespace :packs do
    BRONZE_CARDS   = ['Spriggan', 'Pudding', 'Coblyn', 'Goobbue', 'Scarface Bugaal Ja', 'Behemoth',
                      'Magitek Death Claw', 'Liquid Flame', 'Delivery Moogle'].freeze

    SILVER_CARDS   = ["Amalj'aa", 'Sylph', 'Kobold', 'Tataru Taru', 'Ixal', 'Lahabrea', 'Urianger', 'Minfilia'].freeze

    GOLD_CARDS     = ['Mother Miounne', 'Momodi Modi', 'Baderon Tenfingers', 'Hoary Boulder & Coultenet', 'Gerolt',
                      'Ultima Weapon', 'Cid Garlond', 'Warrior of Light', 'Zidane Tribal'].freeze

    MYTHRIL_CARDS  = ['Vedrfolnir', 'Pipin Tarupin', 'Gilgamesh & Enkidu', 'Odin', 'Coeurlregina', 'Brachiosaur',
                      'Terra Branford', 'Bartz Klauser', 'Onion Knight'].freeze

    PLATINUM_CARDS = ['Tidus', 'Firion', 'Cecil Harvey', 'Lightning', 'Nanamo Ul Namo', 'Shiva', 'Lahabrea',
                      'Ultima Weapon'].freeze

    IMPERIAL_CARDS = ['Magitek Gunship', 'Magitek Sky Armor', 'Magitek Vanguard', 'Regula van Hydrus',
                      'Magitek Predator', 'Armored Weapon'].freeze

    DREAM_CARDS    = ['Hobgoblin', 'Fuath', 'Iguana', 'Titania', 'Philia', 'Leannan Sith', 'Storge', 'Eros',
                      'Oracle of Light', 'Innocence', 'Archaeotania'].freeze

    desc 'Create the card packs'
    task create: :environment do
      PaperTrail.enabled = false

      puts 'Creating card packs'
      count = Pack.count

      bronze = Pack.find_or_create_by!(id: 1, name_en: 'Bronze Triad Card', name_de: 'Boosterkarte (Bronze)',
                                       name_fr: 'Pochette Triple Triade Bronze', name_ja: 'トライアドパック・ブロンズ',
                                       cost: 520, item_id: 10128)
      bronze.cards = Card.where(name_en: BRONZE_CARDS)
      bronze.save
      create_card_sources(bronze)

      silver = Pack.find_or_create_by!(id: 2, name_en: 'Silver Triad Card', name_de: 'Boosterkarte (Silber)',
                                       name_fr: 'Pochette Triple Triade Argent', name_ja: 'トライアドパック・シルバー',
                                       cost: 1150, item_id: 10129)
      silver.cards = Card.where(name_en: SILVER_CARDS)
      silver.save
      create_card_sources(silver)

      gold = Pack.find_or_create_by!(id: 3, name_en: 'Gold Triad Card', name_de: 'Boosterkarte (Gold)',
                                     name_fr: 'Pochette Triple Triade Or', name_ja: 'トライアドパック・ゴールド',
                                     cost: 2160, item_id: 10130)
      gold.cards = Card.where(name_en: GOLD_CARDS)
      gold.save
      create_card_sources(gold)

      mythril = Pack.find_or_create_by!(id: 4, name_en: 'Mythril Triad Card', name_de: 'Boosterkarte (Mithril)',
                                        name_fr: 'Pochette Triple Triade Mithrite', name_ja: 'トライアドパック・ミスライト',
                                        cost: 8000, item_id: 13380)
      mythril.cards = Card.where(name_en: MYTHRIL_CARDS)
      mythril.save
      create_card_sources(mythril)

      platinum = Pack.find_or_create_by!(id: 5, name_en: 'Platinum Triad Card', name_de: 'Boosterkarte (Platin)',
                                         name_fr: 'Pochette Triple Triade Platine', name_ja: 'トライアドパック・プラチナ',
                                         cost: 0, item_id: 10077)
      platinum.cards = Card.where(name_en: PLATINUM_CARDS)
      platinum.save
      create_card_sources(platinum)

      imperial = Pack.find_or_create_by!(id: 6, name_en: 'Imperial Triad Card', name_de: 'Garleische Triple Triad-Karte',
                                         name_fr: 'Pochette Triple Triade Impériale', name_ja: 'インペリアルトライアドパック',
                                         cost: 2160, item_id: 17702)
      imperial.cards = Card.where(name_en: IMPERIAL_CARDS)
      imperial.save
      create_card_sources(imperial)

      dream = Pack.find_or_create_by!(id: 7, name_en: 'Dream Triad Card', name_de: 'Boosterkarte (Traum)',
                                      name_fr: 'Pochette Triple Triade Onirique', name_ja: 'トライアドパック・ドリーム',
                                      cost: 3240, item_id: 28652)
      dream.cards = Card.where(name_en: DREAM_CARDS)
      dream.save
      create_card_sources(dream)

      puts "Created #{Pack.count - count} new card packs"
    end

    def create_card_sources(pack)
      gold_saucer_type = SourceType.find_by(name_en: 'Gold Saucer').freeze

      texts = ALL_LOCALES.each_with_object({}) do |locale, h|
        h["text_#{locale}"] = pack["name_#{locale}"]
      end

      pack.cards.each do |card|
        card.sources.find_or_create_by!(**texts, type: gold_saucer_type)
      end
    end
  end
end
