namespace :sources do
  desc 'Create the source types'
  task create_types: :environment do

    puts 'Creating source types'

    types_names = [
      { name_en: 'Achievement', name_de: 'Errungenschaft', name_fr: 'Hauts faits', name_ja: '' },
      { name_en: 'Beastmaster', name_de: 'Bestienbändiger', name_fr: 'Dresseur', name_ja: '' },
      { name_en: 'Bozja', name_de: 'Bozja', name_fr: 'Bozja', name_ja: '' },
      { name_en: 'Blue Mage', name_de: 'Blaumagier', name_fr: 'Mage bleu', name_ja: '' },
      { name_en: 'Chaotic Raid', name_de: 'Chaotische Raid', name_fr: 'Raid chaotique', name_ja: '滅アライアンスレイド' },
      { name_en: 'Cosmic Exploration', name_de: 'Die Kosmo-Erkundung', name_fr: 'Exploration cosmique', name_ja: 'コスモエクスプローラー' },
      { name_en: 'Crafting', name_de: 'Handwerk', name_fr: 'Artisanat', name_ja: '' },
      { name_en: 'Deep Dungeon', name_de: 'Tiefes Gewölbe', name_fr: 'Donjon sans fond', name_ja: '' },
      { name_en: 'Dungeon', name_de: 'Dungeon', name_fr: 'Donjon', name_ja: '' },
      { name_en: 'Eureka', name_de: 'Eureka', name_fr: 'Eurêka', name_ja: '' },
      { name_en: 'Event', name_de: 'Event', name_fr: 'Événement saisonnier', name_ja: '' },
      { name_en: 'FATE', name_de: 'FATE', name_fr: 'ALEA', name_ja: '' },
      { name_en: 'Gathering', name_de: 'Sammeln', name_fr: 'Récolte', name_ja: '' },
      { name_en: 'Gold Saucer', name_de: 'Gold Saucer', name_fr: 'Gold Saucer', name_ja: '' },
      { name_en: 'Hunts', name_de: 'Hohe Jagd', name_fr: 'Chasse', name_ja: '' },
      { name_en: 'Island Sanctuary', name_de: 'Inselparadies', name_fr: 'Félicité insulaire', name_ja: '' },
      { name_en: 'NPC', name_de: 'NPC', name_fr: 'PNJ', name_ja: '' },
      { name_en: 'Occult Crescent', name_de: 'Kreszentia', name_fr: "L'île de Lunule", name_ja: '蜃気楼の島' },
      { name_en: 'Other', name_de: 'Andere', name_fr: 'Autre', name_ja: '' },
      { name_en: 'Premium', name_de: 'Premium', name_fr: 'Premium', name_ja: '' },
      { name_en: 'Purchase', name_de: 'Kauf', name_fr: 'Achetable', name_ja: '' },
      { name_en: 'PvP', name_de: 'PvP', name_fr: 'JcJ', name_ja: '' },
      { name_en: 'Quest', name_de: 'Quest', name_fr: 'Quête', name_ja: '' },
      { name_en: 'Raid', name_de: 'Raid', name_fr: 'Raid', name_ja: '' },
      { name_en: 'Skybuilders', name_de: 'Himmelsstadt', name_fr: 'Azurée', name_ja: '' },
      { name_en: 'Treasure Hunt', name_de: 'Schatzsuche', name_fr: 'Chasse aux trésors', name_ja: '' },
      { name_en: 'Trial', name_de: 'Prüfung', name_fr: 'Défi', name_ja: '' },
      { name_en: 'Tribal', name_de: 'Stammesvolk', name_fr: 'Tribus', name_ja: '' },
      { name_en: 'Ultimate Raid', name_de: 'Fataler Raid', name_fr: 'Raid fatal', name_ja: '' },
      { name_en: 'V&C Dungeon', name_de: 'Unstetes/Kurioses Gewölbe', name_fr: 'Donjon à embranchements', name_ja: '' },
      { name_en: 'Venture', name_de: 'Gehilfenunternehmung', name_fr: 'Tâches de servant', name_ja: '' },
      { name_en: 'Voyages', name_de: 'Expedition', name_fr: 'Expéditions', name_ja: '' },
      { name_en: 'Wondrous Tails', name_de: 'Khloes Abenteueralbum', name_fr: 'Aventures imaginaires', name_ja: '' }
    ].freeze

    types_names.each do |names|
      type = SourceType.find_by(name_en: names[:name_en])

      if type.present?
        type.update!(names)
      else
        SourceType.create!(names)
      end
    end
  end

  desc 'Set automated collectable sources'
  task update: :environment do
    Rake::Task['sources:achievements:update'].invoke
    Rake::Task['sources:crafting:update'].invoke
    Rake::Task['sources:orchestrions:update'].invoke
    Rake::Task['sources:pvp:update'].invoke
    Rake::Task['sources:quests:update'].invoke
    Rake::Task['sources:shops:update'].invoke
    Rake::Task['sources:triad:update'].invoke
  end
end
