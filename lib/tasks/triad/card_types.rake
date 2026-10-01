require 'xiv_data'

namespace :triad do
  namespace :card_types do
    desc 'Create the card types'
    task create: :environment do
      PaperTrail.enabled = false

      puts 'Creating card types'
      count = CardType.count

      # Typeless cards reference ID 0, so create it
      CardType.find_or_create_by!(id: 0, name_en: 'Normal', name_de: 'Normal', name_fr: 'Normal', name_ja: 'ノーマル')

      types = ALL_LOCALES.map do |locale|
        XIVData.sheet('TripleTriadCardType', locale: locale).filter_map do |type|
          type['Name']
        end
      end

      types.transpose.each_with_index do |type, i|
        data = { id: (i + 1).to_s }

        ALL_LOCALES.each_with_index do |locale, i|
          data["name_#{locale}"] = type[i]
        end

        if existing = CardType.find_by(id: data[:id])
          existing.update!(data) if updated?(existing, data)
        else
          CardType.create!(data)
        end
      end

      puts "Created #{CardType.count - count} new card types"
    end
  end
end
