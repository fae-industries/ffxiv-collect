module Lodestone
  class PrivateProfileError < StandardError; end
  class HiddenProfileError < StandardError; end

  LODESTONE_URL = 'https://na.finalfantasyxiv.com/lodestone'.freeze
  PROXY_URL = Rails.application.credentials.dig(:proxy, :url).freeze
  DESKTOP_USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) ' \
    'Chrome/104.0.0.0 Safari/537.36'
  MOBILE_USER_AGENT = 'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) ' \
    'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36'.freeze

  extend self

  def character(character_id)
    character = profile(character_id)

    set_achievements!(character)
    set_mounts!(character)
    set_minions!(character)
    set_facewear!(character)
    set_emotes!(character)

    character
  end

  def free_company(free_company_id)
    url = "#{LODESTONE_URL}/freecompany/#{free_company_id}"

    doc = Nokogiri::HTML.parse(request(url))
    {
      id: free_company_id,
      name: doc.at_css('.freecompany__text__name').text,
      tag: doc.at_css('p.freecompany__text__tag').text[/[\w\s]+/]
    }
  end

  def free_company_members(free_company_id, page: 1)
    url = "#{LODESTONE_URL}/freecompany/#{free_company_id}/member?page=#{page}"

    doc = Nokogiri::HTML.parse(request(url))
    members = doc.css('.entry__bg').map { |entry| element_id(entry) }

    # If there are additional pages, recursively continue fetching members
    if doc.at_css('.btn__pager__next:not(.btn__pager__no)').present?
      members += free_company_members(free_company_id, page: page + 1)
    end

    members
  end

  def profile_link(character)
    case locale = I18n.locale.to_s
    when 'en'
      locale = character.region == 'na' ? 'na' : 'eu'
    when 'ja'
      locale = 'jp'
    end

    "#{LODESTONE_URL}/character/#{character.id}".sub('na', locale)
  end

  def search(name:, server:, data_center:)
    if server.present?
      worldname = server
    elsif data_center.present?
      worldname = "_dc_#{data_center}"
    end

    doc = character_document(params: {
      q: name,
      worldname: worldname,
      order: 3
    })

    doc.css('.entry__chara__link').map do |character|
      {
        id: element_id(character),
        name: character.at_css('.entry__name').text,
        avatar: character.at_css('.entry__chara__face > img').attributes['src'].value,
        server: character.at_css('.entry__world').text.split(' ').first
      }
    end
  end

  def verified?(character_id, code)
    doc = character_document(character_id: character_id)

    # Profile must be public to verify the code
    raise PrivateProfileError unless doc.at_css('.character__profile').present?

    doc.css('.character__character_profile').text.include?(code)
  end

  private
  def profile(character_id)
    begin
      doc = character_document(character_id: character_id)
    rescue RestClient::Forbidden
      raise PrivateProfileError
    end

    # Check if the user has opted out of tracking via their Lodestone profile
    if doc.css('.character__character_profile').text.include?('ffxivcollect:hidden')
      raise HiddenProfileError
    end

    character = {
      id: character_id,
      name: doc.at_css('.frame__chara__name').text,
      server: doc.at_css('.frame__chara__world').text[/^\w+/],
      data_center: doc.at_css('.frame__chara__world').text.gsub(/.*\[(\w+)\]/, '\1'),
      avatar: doc.at_css('.frame__chara__face > img').attributes['src'].value,
      last_parsed: Time.now,
      public_profile: true,
    }

    # Assign remaining attributes based on whether the profile is public
    if doc.at_css('.character__profile').present?
      character.merge!(
        gender: doc.at_css('.character-block__profile').text.match?('♂') ? 'male' : 'female',
        portrait: doc.at_css('.character__detail__image > a > img').attributes['src'].value,
      )
    else
      character.merge!(
        gender: nil,
        portrait: nil,
      )
    end

    # If the character has a free company, create/update it and add it to the profile
    free_company = doc.at_css('.entry__freecompany')

    if free_company.present? && !free_company.attributes['href'].value.match?('pvp')
      free_company_id = element_id(free_company)
      name = doc.at_css('.character__freecompany__name > h4').text
      character[:free_company_id] = free_company_id

      if free_company = FreeCompany.find_by(id: free_company_id)
        free_company.update!(name: name)
      else
        FreeCompany.create!(id: free_company_id, name: name)
      end
    else
      character[:free_company_id] = nil
    end

    character
  end

  def set_mounts!(data)
    begin
      doc = character_document(endpoint: 'mount', character_id: data[:id])
      mounts = doc.css('.mount__name')

      if mounts.empty?
        data[:mounts] = []
        data[:public_mounts] = false
      else
        data[:mounts] = Mount.where(name_en: mounts.map(&:text)).pluck(:id)
        data[:public_mounts] = true
      end
    rescue RestClient::NotFound
      data[:mounts] = []
      data[:public_mounts] = true
    end
  end

  def set_minions!(data)
    begin
      doc = character_document(endpoint: 'minion', character_id: data[:id])
      minions = doc.css('.minion__name')

      if minions.empty?
        data[:minions] = []
        data[:public_minions] = false
      else
        data[:minions] = Minion.summonable.where(name_en: minions.map(&:text)).pluck(:id)
        data[:public_minions] = true
      end
    rescue RestClient::NotFound
      data[:minions] = []
      data[:public_minions] = true
    end
  end

  def set_facewear!(data)
    begin
      doc = character_document(endpoint: 'faceaccessory', character_id: data[:id])
      facewear = doc.css('.faceaccessory__name')

      data[:facewear] = Facewear.where(lodestone_name: facewear.map(&:text)).pluck(:id)
      data[:public_facewear] = true
    rescue RestClient::NotFound
      data[:facewear] = []
      data[:public_facewear] = true
    rescue RestClient::Forbidden
      data[:facewear] = []
      data[:public_facewear] = false
    end
  end

  def set_emotes!(data)
    begin
      doc = character_document(endpoint: 'emote', character_id: data[:id])
      emotes = doc.css('.emote__name')

      data[:emotes] = Emote.where(name_en: emotes.map(&:text)).pluck(:id)
      data[:public_emotes] = true
    rescue RestClient::NotFound
      data[:emotes] = []
      data[:public_emotes] = true
    rescue RestClient::Forbidden
      data[:emotes] = []
      data[:public_emotes] = false
    end
  end

  def set_achievements!(data)
    begin
      doc = character_document(endpoint: 'achievement', character_id: data[:id])
    rescue RestClient::Forbidden
      data[:achievements] = []
      data[:public_achievements] = false
    end

    return unless doc.present?
    data[:public_achievements] = true

    # If the character exists, grab their recent achievements from the overview page
    if character = Character.find_by(id: data[:id])
      recent = doc.css('.entry__achievement').map { |achievement| parse_achievement(achievement) }
      owned = character.achievement_ids
      new_achievements = recent.reject { |achievement| owned.include?(achievement[:id]) }

      # If the character's recent achievements do not fill the whole page, return them
      if new_achievements.size < recent.size
        data[:achievements] = new_achievements
        return
      end
    end

    # If the character does not exist, or their achievements filled the whole page,
    # collect them from each of the achievement type pages
    data[:achievements] = AchievementType.pluck(:id).flat_map do |type|
      begin
        doc = character_document(endpoint: "achievement/kind/#{type}", character_id: data[:id])
        doc.css('.entry__achievement--complete').map { |achievement| parse_achievement(achievement) }
      rescue RestClient::NotFound
        []
      end
    end
  end

  def parse_achievement(achievement)
    { id: element_id(achievement), date: element_time(achievement) }
  end

  def character_document(endpoint: nil, character_id: nil, params: {})
    url = [LODESTONE_URL, 'character', character_id, endpoint].compact.join('/')
    url += "?#{params.to_query}" if params.present?

    Nokogiri::HTML.parse(request(url, mobile: true))
  end

  def element_id(element)
    element.attributes['href'].value.match(/(\d+)\/$/)[1].to_i
  end

  def element_time(element)
    time = element.at_css('.entry__activity__time').text.match(/ldst_strftime\((\d+)/)[1]
    Time.at(time.to_i).to_formatted_s(:db)
  end

  def request(url, mobile: nil)
    if Rails.env.production? && PROXY_URL.present?
      params = { url: url, mobile: mobile }.compact
      RestClient.get(PROXY_URL, params: params)
    else
      RestClient.get(url, user_agent: mobile ? MOBILE_USER_AGENT : DESKTOP_USER_AGENT)
    end
  end
end
