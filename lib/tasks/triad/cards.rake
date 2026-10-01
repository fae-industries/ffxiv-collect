require 'xiv_data'

namespace :triad do
  namespace :cards do
    desc 'Create the cards'
    task create: :environment do
      PaperTrail.enabled = false

      puts 'Creating cards'
      count = Card.count

      # Load the base cards
      cards = XIVData.sheet('TripleTriadCard', locale: 'en').each_with_object({}) do |card, h|
        next unless card['#'] != '0' && card['Name'].present?

        h[card['#']] = { id: card['#'], name_en: sanitize_name(card['Name']),
                         description_en: sanitize_text(card['Description'], preserve_space: true) }
      end

      OTHER_LOCALES.each do |locale|
        XIVData.sheet('TripleTriadCard', locale: locale).each do |card|
          next unless card['#'] != '0' && card['Name'].present?

          cards[card['#']].merge!("name_#{locale}" => sanitize_name(card['Name'], locale: locale, upcase_first_only: locale == :fr),
                                  "description_#{locale}" => sanitize_text(card['Description'], preserve_space: true))
        end
      end

      # Add their various stats
      XIVData.sheet('TripleTriadCardResident').each do |card|
        next unless cards[card['#']].present?

        stars = card['TripleTriadCardRarity'].scan(/\d$/).first
        formatted_number = card['UIPriority'] == '0' ? "No. #{card['Order']}" : "Ex. #{card['Order']}"

        cards[card['#']].merge!(top: card['Top'], bottom: card['Bottom'], left: card['Left'], right: card['Right'],
                                stars: stars, card_type_id: card['TripleTriadCardType'], sell_price: card['SaleValue'],
                                deck_order: card['SortKey'], order_group: card['UIPriority'],
                                order: card['Order'], formatted_number: formatted_number,
                                image_url: XIVData.image_url(88000 + card['#'].to_i))
      end

      # Then create or update them
      cards.each do |id, data|
        if card = Card.find_by(id: data[:id])
          card.update!(data) if updated?(card, data)
        else
          card = Card.create!(data) if data[:name_en].present?
        end
      end

      puts "Created #{Card.count - count} new cards"
    end
  end
end
