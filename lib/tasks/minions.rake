namespace :minions do
  desc 'Create the minions'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating minions'

    behaviors = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('CompanionMove', locale: locale).each do |behavior|
        next unless behavior['Name'].present?

        data = h[behavior['#']] || { id: behavior['#'] }
        data["name_#{locale}"] = behavior ['Name']
        h[data[:id]] = data
      end
    end

    behaviors.values.each do |behavior|
      if existing = MinionBehavior.find_by(id: behavior[:id])
        existing.update!(behavior) if updated?(existing, behavior)
      else
        MinionBehavior.create!(behavior)
      end
    end

    races = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('MinionRace', locale: locale).each do |race|
        next unless race['Name'].present?

        data = h[race['#']] || { id: race['#'] }
        data["name_#{locale}"] = race ['Name']
        h[data[:id]] = data
      end
    end

    races.values.each do |race|
      if existing = MinionRace.find_by(id: race[:id])
        existing.update!(race) if updated?(existing, race)
      else
        MinionRace.create!(race)
      end
    end

    skill_types = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('MinionSkillType', locale: locale).each do |type|
        next unless type['Name'].present?

        data = h[type['#']] || { id: type['#'] }
        data["name_#{locale}"] = type ['Name']
        h[data[:id]] = data
      end
    end

    skill_types.values.each do |type|
      if existing = MinionSkillType.find_by(id: type[:id])
        existing.update!(type) if updated?(existing, type)
      else
        MinionSkillType.create!(type)
      end
    end

    count = Minion.count
    minions = ALL_LOCALES.each_with_object({}) do |locale, h|
      XIVData.sheet('Companion', locale: locale).each do |minion|
        next if minion['Order'] == '0'

        data = h[minion['#']] || { id: minion['#'], order: minion['Order'], hp: minion['HP'], cost: minion['Cost'],
                                   skill_angle: minion['SkillAngle'], skill_cost: minion['SkillCost'],
                                   image_url: XIVData.image_url(minion['Icon']),
                                   behavior_id: minion['Behavior'], race_id:  minion['MinionRace'] }

        data["name_#{locale}"] = sanitize_name(minion['Singular'], locale: locale, capitalize: true)
        h[data[:id]] = data
      end
    end

    # Add the remaining data from the transient sheet
    ALL_LOCALES.each do |locale, h|
      XIVData.sheet('CompanionTransient', locale: locale).each do |minion|
        next unless minions.has_key?(minion['#']) && minion['Description'].present?

        data = minions[minion['#']]
        data.merge!("description_#{locale}" => sanitize_text(minion['Description']),
                    "enhanced_description_#{locale}" => sanitize_text(minion['DescriptionEnhanced']),
                    "tooltip_#{locale}" => sanitize_text(minion['Tooltip']),
                    "skill_#{locale}" => sanitize_name(minion['SpecialActionName'], locale: locale),
                    "skill_description_#{locale}" => sanitize_text(minion['SpecialActionDescription'], preserve_space: true),
                    attack: minion['Attack'], defense: minion['Defense'], speed: minion['Speed'],
                    area_attack: minion['HasAreaAttack'] == 'True', gate: minion['StrengthGate'] == 'True',
                    eye: minion['StrengthEye'] == 'True', shield: minion['StrengthShield'] == 'True',
                    arcana: minion['StrengthArcana'] == 'True', skill_type_id: minion['MinionSkillType'])
      end
    end

    minions.values.each do |minion|
      next unless minion['name_en'].present?

      minion[:large_image_url] = minion[:image_url].gsub(/004(\d{3})/, '068\1')
      minion[:footprint_image_url] = minion[:image_url].gsub(/004(\d{3})/, '069\1')

      if existing = Minion.find_by(id: minion[:id])
        existing.update!(minion) if updated?(existing, minion)
      else
        Minion.create!(minion)
      end
    end

    puts "Created #{Minion.count - count} new minions"
  end
end
