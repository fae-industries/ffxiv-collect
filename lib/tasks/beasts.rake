namespace :beasts do
  desc 'Create the Beastmaster beasts'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating Beastmaster beasts'
    count = Beast.count

    pets = %w(en de fr ja tc).each_with_object({}) do |locale, h|
      XIVData.sheet('Pet', locale: locale).each do |pet|
        # All Beastmaster pets share this ability
        next unless pet['Abilities[2]'] == '44934'

        data = h[pet['#']] || {
          trick_id: pet['Abilities[0]'],
          tempered_release_id: pet['Abilities[1]'],
        }

        data["name_#{locale}"] = sanitize_name(pet['Name'], locale: locale, capitalize: true)

        h[pet['#']] = data
      end
    end

    actions = {}

    beasts = %w(en de fr ja tc).each_with_object({}) do |locale, h|
      XIVData.sheet('XBMPet', locale: locale).each do |beast|
        pet = pets[beast['Pet']]
        next unless pet.present?

        data = h[beast['#']]

        unless data.present?
          data = {
            id: beast['#'],
            image_url: XIVData.image_url(beast['Icon']),
            **pets[beast['Pet']],
          }

          actions[data[:trick_id]] = { id: data[:trick_id] }
          actions[data[:tempered_release_id]] = { id: data[:tempered_release_id] }
        end

        description_key = "description_#{locale}"
        data[description_key] = sanitize_text(beast['Description'])
        actions[data[:trick_id]][description_key] = sanitize_text(beast['TrickDescription'])
        actions[data[:tempered_release_id]][description_key] = sanitize_text(beast['TemperedDescription'])

        h[data[:id]] = data
      end
    end

    %w(en de fr ja tc).each do |locale|
      XIVData.sheet('Action', locale: locale).each do |action|
        next unless actions.has_key?(action['#']) && action['Name'].present?

        actions[action['#']].merge!(
          "name_#{locale}" => sanitize_name(action['Name'], locale: locale),
          image_url: XIVData.image_url(action['Icon']),
        )
      end
    end

    actions.values.each do |action|
      if existing = BeastAction.find_by(id: action[:id])
        existing.update!(action) if updated?(existing, action)
      else
        BeastAction.create!(action)
      end
    end

    beasts.values.each do |beast|
      if existing = Beast.find_by(id: beast[:id])
        existing.update!(beast) if updated?(existing, beast)
      else
        Beast.create!(beast)
      end
    end

    puts "Created #{Beast.count - count} new beasts"
  end
end
