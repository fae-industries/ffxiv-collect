SPELL_STATS_REGEX = /.+\*([\w★]+)/.freeze

namespace :spells do
  desc 'Create the Blue Magic spells'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating Blue Magic spells'

    # Create spell types
    SpellType.find_or_create_by!(name_en: 'Magic', name_de: 'Magie', name_fr: 'Magique', name_ja: '魔法')
    SpellType.find_or_create_by!(name_en: 'Physical', name_de: 'Physisch', name_fr: 'Physique', name_ja: '物理')

    count = Spell.count
    spells = XIVData.sheet('AozAction').each_with_object({}) do |spell, h|
      next if spell['Action'] == '0'
      h[spell['Action']] = { id: spell['#'], aspects: {} }
    end

    ALL_LOCALES.each do |locale|
      XIVData.sheet('Action', locale: locale).each do |action|
        next unless spells.has_key?(action['#'])
        spells[action['#']]["name_#{locale}"] = sanitize_name(action['Name'], locale: locale, upcase_first_only: true)
      end
    end

    ALL_LOCALES.each do |locale|
      XIVData.sheet('ActionTransient', locale: locale).each do |action|
        next unless spells.has_key?(action['#'])
        spells[action['#']]["description_#{locale}"] = sanitize_text(action['Description'])
      end
    end

    ALL_LOCALES.each do |locale|
      XIVData.sheet('AozActionTransient', locale: locale).each do |spell|
        data = spells.values.find { |s| s[:id] == spell['#'] }
        next unless data.present?

        data[:order] ||= spell['Number']
        data[:image_url] ||= XIVData.image_url(spell['Icon'])
        data["location_#{locale}"] ||= sanitize_name(spell['Location'], locale: locale) if spell['Location'].present?
        data["tooltip_#{locale}"] = sanitize_text(spell['Description'])

        type, aspect, rank = spell['Stats'].gsub(/\*\*.+\*\*/, '').split

        data[:type_id] ||= SpellType.find_by(name_en: type).id.to_s
        data[:aspects]["name_#{locale}"] = aspect
        data[:rank] ||= rank.count('★').to_s
      end
    end

    other_type = SourceType.find_by(name_en: 'Other').id

    spells.values.each do |spell|
      aspect = SpellAspect.find_or_create_by!(spell.delete(:aspects))
      spell[:aspect_id] = aspect.id.to_s
      data = spell.except(Spell.locale_columns(:location))

      if existing = Spell.find_by(id: spell[:id])
        existing.update!(data) if updated?(existing, data)
      else
        spell = Spell.create!(data)

        # Create a stub source based on the location provided by the spellbook for new spells
        next unless spell['location_en'].present?

        texts = ALL_LOCALES.each_with_object({}) do |locale, h|
          location = spell["location_#{locale}"]
          h["text_#{locale}"] = I18n.t('sources.unreported', location: location, locale: locale)
        end

        spell.sources.create!(**texts, type_id: other_type)
      end
    end

    puts "Created #{Spell.count - count} new blue magic spells"
  end
end
