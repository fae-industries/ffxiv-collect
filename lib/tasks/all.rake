require 'open-uri'
require 'sprite_factory'
require 'xiv_data'

# Conjunctions/prepositions + Garlean ranks + special characters
WORDS_TO_IGNORE = %w(a an and as at by de for from in into la of on or over the to up with
  aan goe mal oen pyr quo rem sas tol van yae
  α β γ δ).freeze

ALL_LOCALES = Rails.application.config.i18n.available_locales
OTHER_LOCALES = ALL_LOCALES[1..-1]

namespace :data do
  desc 'Initialize all data'
  task initialize: :environment do
    Rake::Task['triad:card_types:create'].invoke
    Rake::Task['triad:packs:create'].invoke
    Rake::Task['triad:rules:create'].invoke

    Rake::Task['sources:create_types'].invoke
    Rake::Task['data:update'].invoke
    Rake::Task['relics:all:create'].invoke
  end

  desc 'Updates all data'
  task update: :environment do
    puts 'Retrieving the latest game data from xiv-data'
    %x{cd #{Rails.root.join('vendor/xiv-data')} && git fetch && git checkout origin/main}

    Rake::Task['items:create'].invoke
    Rake::Task['instances:create'].invoke
    Rake::Task['quests:create'].invoke
    Rake::Task['achievements:create'].invoke
    Rake::Task['titles:create'].invoke
    Rake::Task['mounts:create'].invoke
    Rake::Task['minions:create'].invoke
    Rake::Task['orchestrions:create'].invoke
    Rake::Task['emotes:create'].invoke
    Rake::Task['bardings:create'].invoke
    Rake::Task['hairstyles:create'].invoke
    Rake::Task['armoires:create'].invoke
    Rake::Task['outfits:create'].invoke
    Rake::Task['armoires:find_outfits'].invoke
    Rake::Task['outfits:find_armoires'].invoke
    Rake::Task['spells:create'].invoke
    Rake::Task['fashions:create'].invoke
    Rake::Task['facewear:create'].invoke
    Rake::Task['field_records:create'].invoke
    Rake::Task['survey_records:create'].invoke
    Rake::Task['occult_records:create'].invoke
    Rake::Task['frames:create'].invoke
    Rake::Task['triad:cards:create'].invoke
    Rake::Task['triad:card_images:create'].invoke

    # Sources
    Rake::Task['items:set_unlocks'].invoke
    Rake::Task['items:set_extras'].invoke
    Rake::Task['sources:update'].invoke

    # Create NPCs after cards are linked to their items
    Rake::Task['triad:npcs:create'].invoke

    # Events
    Rake::Task['tomestones:latest:create'].invoke
  end
end

def log(message)
  puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}] #{message}"
end

def sanitize_name(name, locale: :en, capitalize: false, upcase_first_only: false)
  return '' if name.nil?

  # Clean up symbols, language tags, etc.
  name = name.gsub('[t]', 'der')
    .gsub('[a]', 'e')
    .gsub('[A]', 'er')
    .gsub('[p]', '')
    .gsub(/[\uE0BE\uE0BF]+ ?/, '') # Remove internal symbols
    .strip # Many achievements, items and quests have trailing spaces

  return name.upcase_first if upcase_first_only

  return name unless capitalize

  # Capitalize for EN and JA only (JA uses English names sometimes)
  if locale == :en || locale == :en
    name = name.split(' ')
      .map { |word| WORDS_TO_IGNORE.include?(word) ? word : word.upcase_first }
      .join(' ')
  end

  name.upcase_first # In case name starts with an ignored word
end

def sanitize_text(text, preserve_space: false)
  return '' if text.nil?

  unless preserve_space
    text = text.gsub("-\n", '-')
      .gsub("\n", ' ')
  end

  text.gsub(/[\uE0BE\uE0BF]+ ?/, '').strip
end

def without_custom(data)
  data.symbolize_keys.except(:name_en, :name_fr, :name_de, :name_ja, :patch)
end

def updated?(model, data)
  data.symbolize_keys!
  current = model.attributes.symbolize_keys.select { |k, _| data.keys.include?(k) }

  # Add associated IDs which are not part of the model's attributes. Sort them for proper comparison.
  data.each do |k, v|
    if v.is_a?(Array)
      current[k] = model.send(k).sort
      v.sort!
    end
  end

  # The XIVData values are all strings, so convert integers to strings for comparison
  current.each do |k, v|
    current[k] = v.to_s if v.is_a?(Integer)
  end

  if updated = data != current
    puts "  Found new data for #{model.name_en} (#{model.id}):"
    diff = data.map do |k, v|
      "#{k}: #{current[k]} → #{v}" if current[k] != v
    end
    puts "    #{diff.compact.join(', ')}"
  end

  updated
end

def maps_with_locations(ids)
  # Look up the maps for the given IDs and set the coordinate data
  maps = XIVData.sheet('Map').each_with_object({}) do |map, h|
    if ids.include?(map['#'])
      h[map['#']] = { region_id: map['PlaceNameRegion'], location_id: map['PlaceName'],
                      x_offset: map['OffsetX'].to_f, y_offset: map['OffsetY'].to_f,
                      size_factor: map['SizeFactor'].to_f }
    end
  end

  # Look up the locations associated with each map
  locations = ALL_LOCALES.each_with_object(Hash.new({})) do |locale, h|
    places = XIVData.sheet('PlaceName', locale: locale).map { |place| place['Name']}

    maps.values.each do |map|
      h[map[:location_id]] = h[map[:location_id]].merge(
        "name_#{locale}" => places[map[:location_id].to_i],
        "region_#{locale}" => places[map[:region_id].to_i],
      )
    end
  end

  # Create the locations
  locations.each do |id, data|
    data[:id] = id

    if existing = Location.find_by(id: id)
      existing.update!(data) if updated?(existing, data)
    else
      Location.create!(data)
    end
  end

  maps
end

def get_coordinate(value, map_offset, size_factor)
  scale = size_factor / 100.0
  offset = (value + map_offset) * scale
  (((40.9 / scale) * ((offset + 1024.0) / 2048.0)) + 1).round(1)
end
