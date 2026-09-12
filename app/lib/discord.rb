include ActionView::Helpers::DateHelper
include ActionView::Helpers::NumberHelper

module Discord
  ROOT_URL = 'https://ffxivcollect.com'.freeze

  extend self

  def embed_collectable(type, query)
    if type == 'card' || type == 'npc'
      # Add the /triad namespace for Cards and NPCs
      url = "#{ROOT_URL}/api/triad/#{type.pluralize}?#{query}"
    else
      url = "#{ROOT_URL}/api/#{type.pluralize}?#{query}"
    end

    response = RestClient::Request.execute(url: url, method: :get)
    results = JSON.parse(response, symbolize_names: true)[:results]
      .sort_by { |collectable| collectable[:name].size }
    collectable = results.first

    if collectable.nil?
      return { content: "#{type.titleize} not found" }
    end

    embed = Discordrb::Webhooks::Embed.new(color: 0xdaa556)

    if type == 'spell'
      name = "#{collectable[:name]} (No. #{collectable[:order]})"
    elsif type == 'title'
      if collectable[:name] == collectable[:female_name]
        name = collectable[:name]
      else
        name = "#{collectable[:name]} / #{collectable[:female_name]}"
      end
    elsif type == 'field_record'
      name = "#{collectable[:id].to_s.rjust(2, '0')}. #{collectable[:name]}"
    elsif type == 'card'
      name = "#{collectable[:name]} (#{collectable[:number]})"
    else
      name = collectable[:name]
    end

    if type == 'spell'
      embed.description = collectable[:description]
    elsif type == 'title'
      embed.description = collectable.dig(:achievement, :description)
    elsif type == 'field_record'
      embed.description = collectable[:description].split("\n\n").first(2).join("\n\n")
    else
      embed.description = collectable[:enhanced_description] || collectable[:description]
    end

    embed.image = Discordrb::Webhooks::EmbedImage.new(url: collectable[:image]) unless type == 'field_record'
    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: collectable[:icon])
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: name, url: collectable_url(type, collectable))

    if results.size > 1
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: additional_results(results))
    end

    if type == 'card'
      embed.add_field(name: 'Rarity', value: stars(collectable[:stars]), inline: true)
    end

    if type == 'spell'
      embed.add_field(name: 'Type', value: collectable.dig(:type, :name), inline: true)
      embed.add_field(name: 'Aspect', value: collectable.dig(:aspect, :name), inline: true)
      embed.add_field(name: 'Rank', value: "\u2605" * collectable[:rank], inline: true)
    elsif type == 'npc'
      location = "#{collectable[:location][:name]} (#{collectable[:location].values_at(:x, :y).join(', ')})"
      embed.add_field(name: 'Location', value: location)

      if collectable[:rules].present?
        embed.add_field(name: 'Rules', value: collectable[:rules].join("\n"), inline: true)
      end

      embed.add_field(name: 'Difficulty', value: stars(collectable[:difficulty].to_f.ceil), inline: true)
      embed.add_field(name: 'Patch', value: collectable[:patch], inline: true)

      if collectable[:quest].present?
        embed.add_field(name: 'Required Quest',
                        value: "[#{collectable.dig(:quest, :name)}](#{collectable.dig(:quest, :link)})")
      end

      rewards = collectable[:rewards].map { |card| link_card(card) }.join("\n")
      embed.add_field(name: 'Rewards', value: rewards)
    else
      embed.add_field(name: 'Owned', value: collectable[:owned], inline: true)
    end

    if type != 'npc'
      embed.add_field(name: 'Patch', value: collectable[:patch], inline: true)
    end

    if collectable[:sources].present?
      embed.add_field(name: 'Source', value: format_sources(collectable))
    end

    { embeds: [embed.to_hash] }
  end

  def embed_character(user)
    url = "#{ROOT_URL}/api/users/#{user}"
    response = RestClient::Request.execute(url: url, method: :get)
    character = JSON.parse(response, symbolize_names: true)

    embed = Discordrb::Webhooks::Embed.new(color: 0xdaa556)

    embed.description = "Last updated <t:#{DateTime.parse(character[:last_parsed]).to_i}:R>."
    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: character[:avatar])
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{character[:name]} (#{character[:server]})",
                                                        url: "#{ROOT_URL}/characters/#{character[:id]}")

    if character[:achievements][:public]
      count, total, points, points_total =
        character[:achievements].values_at(:count, :total, :points, :points_total).map { |value| number_with_delimiter(value) }

      embed.add_field(name: "#{category_title('achievements')}#{star(count, total)}", inline: true,
                      value: "#{count} of #{total} complete\n#{points} of #{points_total} points")
    else
      embed.add_field(name: 'Achievements', inline: true, value: 'Set to private.')
    end

    %i(mounts minions hairstyles emotes orchestrions frames spells beasts bardings fashions facewear outfits armoires field_records survey_records occult_records).each do |category|
      next unless character[category].present? && character[category][:count] > 0

      count, total = character[category].values_at(:count, :total)
      value = "#{count}/#{total} (#{((count / total.to_f) * 100).to_i}%)"
      embed.add_field(name: "#{category_title(category.to_s)}#{star(count, total)}",
                      value: value, inline: true)
    end

    relics = category_counts(character[:relics].slice(:weapons, :ultimate, :armor, :tools), 'Relics')
    embed.add_field(**relics) if relics.present?

    triple_triad = category_counts(character.slice(:cards, :npcs), 'Triple Triad')
    embed.add_field(**triple_triad) if triple_triad.present?

    leves = category_counts(character[:leves].slice(:battlecraft, :tradecraft, :fieldcraft), 'Levequests')
    embed.add_field(**leves) if leves.present?

    { embeds: [embed.to_hash] }
  end

  private
  def collectable_url(type, collectable)
    if type == 'title'
      "#{ROOT_URL}/achievements/#{collectable.dig(:achievement, :id)}"
    else
      "#{ROOT_URL}/#{type.pluralize}/#{collectable[:id]}"
    end
  end

  def format_sources(collectable)
    collectable[:sources].map { |source| source[:text] }.join("\n")
  end

  def additional_results(results)
    names = results[1..10].map { |collectable| collectable[:name] }
    names << '...' if results.size > 11
    "Also available: #{names.join(', ')}"
  end

  def category_counts(data, title)
    return nil unless data.values.any? { |category| category[:count] > 0 }

    count = data.values.sum { |category| category[:count] }
    total = data.values.sum { |category| category[:count] > 0 ? category[:total] : 0 }
    values = data.filter_map do |category, values|
      if values[:count] > 0
        "#{values[:count]} of #{values[:total]} #{category.to_s.titleize}"
      end
    end

    { name: "#{title}#{star(count, total)}", value: values.join("\n"), inline: true }
  end

  def category_title(category)
    case category
    when 'orchestrions' then 'Orchestrion'
    when 'spells' then 'Blue Magic'
    when 'frames' then "Framer's Kits"
    else category.titleize
    end
  end

  def link_card(card)
    link = "[#{card[:name]}](#{card[:link]})"
    "#{link} #{stars(card[:stars])}"
  end

  def star(count, total)
    " \u2605" if count == total
  end

  def stars(count)
    "\u2605" * count
  end
end
