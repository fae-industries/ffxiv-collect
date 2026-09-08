module CollectionsHelper
  def collectable_classes(collectable)
    "collectable#{' tradeable' if collectable.tradeable?}"
  end

  def collectable_name_link(collectable)
    link_to(collectable.name, polymorphic_path(collectable), class: 'name')
  end

  def small_image(collectable)
    safe_image_tag(collectable.image_url, loading: 'lazy', class: 'image-small drop-shadow')
  end

  def medium_image(collectable)
    safe_image_tag(collectable.image_url, loading: 'lazy', class: 'image-medium')
  end

  def large_image(collectable)
    safe_image_tag(collectable.large_image_url, class: 'image-large')
  end

  def collectable_image_link(collectable)
    link_to(polymorphic_path(collectable)) do
      small_image(collectable)
    end
  end

  def collectable_icon(collectable)
    # Handle as both a string and an instance of a model
    case (collectable.is_a?(String) ? collectable : collectable.class.to_s)
    when 'Mount'
      fa_icon('horse')
    when 'Minion'
      fa_icon('paw')
    when 'Orchestrion'
      fa_icon('music')
    when 'Hairstyle'
      fa_icon('cut')
    when 'Emote'
      fa_icon('smile')
    when 'Barding'
      fa_icon('chess-knight')
    when 'Armoire'
      fa_icon('socks')
    when 'Outfit'
      fa_icon('tshirt')
    when 'Fashion'
      fa_icon('umbrella')
    when 'Facewear'
      fa_icon('glasses')
    when 'Frame'
      fa_icon('portrait')
    when 'Card'
      fa_icon('id-badge')
    when 'Spell'
      fa_icon('magic')
    when 'Beast'
      fa_icon('dog')
    when 'FieldRecord'
      fa_icon('file-alt')
    when 'SurveyRecord'
      fa_icon('book-open')
    when 'OccultRecord'
      fa_icon('moon')
    end
  end

  def collectable_type(collectable)
    collectable.class.to_s.downcase.pluralize.to_sym
  end

  def format_text(text)
    text.gsub(/\s{2,}-/, "<br>&nbsp;&nbsp;&nbsp;-")
      .gsub(/\*\*(.*?)\*\*/, '<b>\1</b>')
      .gsub(/\*(.*?)\*/, '<i>\1</i>')
      .html_safe
  end

  def format_text_long(text)
    format_text(
      text.gsub(/\u203B/, "<br>\u203B")
      .gsub("\n", '<br>')
    )
  end

  def format_tooltip(tooltip)
    tooltip
      .gsub(/(?<=\n)(.*?):/, '<b>\1:</b>')
      .gsub("\n", '<br>')
      .html_safe
  end

  def format_skill_description(description)
    format_text(description.gsub("\n", '<br>'))
  end

  def character_selected?
    @character.present?
  end

  def collection_progress(collection, ids)
    if collection.length > 0
      render 'shared/progress', value: (collection.map(&:id) & ids).size, min: 0, max: collection.length
    end
  end

  def ownership_options(selected = nil)
    options_for_select([[t('show_all'), 'all'], [t('only.owned'), 'owned'], [t('only.missing'), 'missing']], selected)
  end

  def gender_filter_options(selected = nil)
    options_for_select([[t('all.genders'), 'all'], [t('hide.male'), 'male'], [t('hide.female'), 'female'],
                        [t('characters.usable'), 'character']], selected)
  end

  def tradeable_options(selected = nil)
    options_for_select([[t('any_tradeable'), 'all'], [t('only.tradeable'), 'tradeable'],
                        [t('only.untradeable'), 'untradeable']], selected)
  end

  def category_row_classes(collectable, categories: [])
    category_id = collectable[:category_id] || categories.index(collectable.category)

    "#{collectable_classes(collectable)} category-row category-#{category_id}"
  end

  def rarity(collectable, numeric: false, percent: false, owned: nil)
    # Ownership is provided by the Collection concern, but data provided directly will override this
    ownership = owned || @owned

    # Set the count and percentage from the full ownership dataset if we have it,
    # otherwise fetch the values from Redis for the given collectable.
    if ownership.present?
      count = ownership.dig(:count, collectable.id.to_s).to_i
      percentage = ownership.dig(:percentage, collectable.id.to_s) || '0%'
    else
      key = collectable.class.name.underscore.pluralize
      count = Redis.current.hget("#{key}-count", collectable.id).to_i
      percentage = Redis.current.hget(key, collectable.id) || '0%'
    end

    if numeric
      count
    elsif percent
      percentage.delete('%')
    else
      content_tag(:span, percentage, data: { toggle: 'tooltip' },
                  title: "#{number_with_delimiter(count)} #{t('character', count: count)}")
    end
  end

  def owned?(id)
    @collection_ids.include?(id)
  end

  def ownership(character, collectable)
    if character.present?
      owned = collectable.characters.include?(character)

      content_tag(:span, data: { toggle: 'tooltip' }, title: t(owned ? 'characters.owned' : 'characters.not_owned')) do
        fa_check(owned, false)
      end
    end
  end

  def td_owned(collectable)
    id = "#{collectable.class.to_s.underscore}-#{collectable.id}"

    content_tag(:td, class: 'text-center check-ownership', data: { id: id, value: 0 }) do
      if collectable.class.automatic_collection?
        fa_icon('times')
      else
        check_box_tag(collectable.id, nil, class: 'own', data: { path: polymorphic_path(collectable, action: :add) })
      end
    end
  end

  def tradeable(collectable)
    if collectable.tradeable?
      data_center = @character&.data_center&.downcase || 'primal'
      price = Redis.current.hget("prices-#{data_center}", collectable.item_id)

      link_to(universalis_url(collectable[:item_id]), class: 'name', target: '_blank',
              data: { toggle: 'tooltip', html: true }, title: price_tooltip(collectable, price)) do
        fa_check(true)
      end
    else
      fa_check(false)
    end
  end

  def sort_value(collectable)
    patch = collectable.patch || '2.0'
    order = collectable[:order] || collectable[:id]
    "#{patch.ljust(4, '0')}#{order}"
  end

  def price_sort_value(collectable)
    if collectable.tradeable?
      @prices.dig(collectable.item_id, 'price') || '9999999998'
    else
      '9999999999'
    end
  end

  def achievement_link(source)
    if source.related_id.present?
      link_to(source.related.name, achievement_path(source.related_id), title: source.related.description,
              data: { toggle: 'tooltip' })
    else
      source.text
    end
  end

  def market_link(collectable)
    if collectable.tradeable?
      link_to(fa_icon('dollar-sign'), universalis_url(collectable.item_id), target: '_blank',
              data: { toggle: 'tooltip', html: true }, title: price_tooltip(collectable))
    end
  end

  def materiel_container(collectable)
    return nil unless collectable.tradeable?

    case collectable.patch
    when /^[23]/ then '3.0'
    when /^4/ then '4.0'
    else nil
    end
  end

  def materiel_sort_value(collectable)
    collectable.patch if materiel_container(collectable).present?
  end

  def materiel_icon(collectable)
    if number = materiel_container(collectable)
      content_tag(:span, fa_icon('box'), data: { toggle: 'tooltip' }, title: t("materiel.#{number[0]}"))
    end
  end

  def database_link(type, text, id = nil, &block)
    return text unless id.present?

    path = database_link_path(type: type, id: id)

    if block_given?
      link_to(path, target: '_blank') do
        block.call
      end
    else
      link_to(text, path, target: '_blank')
    end
  end

  def triple_triad_card_link(name)
    link_to(name, "https://triad.raelys.com/cards/#{name.sub(/Card\z/, '')}", target: '_blank')
  end

  def source_sort_value(collectable)
    if collectable.class == Achievement
      "Achievement #{collectable.description}"
    else
      source = collectable.sources&.first
      "#{source&.type&.name} #{source&.text}"
    end
  end

  def sources(collectable, list: false, limit: nil)
    sources = collectable.sources.flat_map.filter_map do |source|
      case type = source.type.name_en
      when 'Achievement'
        content = achievement_link(source)
      when *ContentType.instance_type_names
        content = database_link(:instance, format_text(source.related&.name || source.text || ''), source.related&.content_id)
      when 'Crafting', 'Gathering'
        content = database_link(:item, source.text, collectable.item_id)
      when 'NPC'
        if npc = source.related
          link = link_to(npc.name, npc_path(npc))
          content = "#{link}&nbsp;-&nbsp;#{location(npc.location, npc.x, npc.y, inline: true)}"
        else
          content = source.text
        end
      when 'Quest', 'Event'
        content = database_link(:quest, source.related&.name || source.text, source.related_id)
      when 'Voyages'
        content = voyage_source(source.text, list: list)
      else
        content = source.text
      end

      next if content.nil?

      if source.limited?
        content = "#{content}&nbsp;#{far_icon('clock', data: { toggle: 'tooltip' }, title: t('tooltips.time_limited'))}"
      end

      { type: type, content: content.html_safe }
    end

    content_tag(:div, class: 'sources') do
      # Apply the limit after collecting the sources since a SQL limit doesn't work with eager loading
      amount = limit || sources.size

      sources.first(amount).each do |source|
        concat(content_tag(:span, source[:content], class: "source source-#{source[:type].parameterize(separator: '-')}"))
      end
    end
  end

  def voyage_source(text, list: false)
    return text unless text.match?(' - ')

    voyage_type, sites_list = text.split(' - ')
    sites = sites_list.split(', ')

    if list
      sites.map { |site| "#{voyage_type} - #{site}" }.join('<br>')
    else
      if sites.size > 3
        "#{voyage_type} - #{sites.first(3).join(', ')}...&nbsp;" +
          fa_icon('question-circle', data: { toggle: 'tooltip', html: true }, title: sites.join('<br>'))
      else
        text
      end
    end
  end

  def active_filters
    available_filters.each_with_object({}) do |filter, h|
      value = cookies[filter]

      unless value.nil? || value == 'show' || value == 'all'
        h[filter] = value
      end
    end
  end

  def available_filters
    # If the controller/action are passed in from the filter form submission, use those.
    # Otherwise, use the current controller/action.
    filter_controller = params[:filter_controller] || controller_name
    filter_action = params[:filter_action] || action_name

    # Non-standard filters are set here
    filters =
      case filter_controller
      when 'achievements'
        if action_name == 'index'
          %i(limited)
        else
          %i(owned limited ranked_pvp)
        end
      when 'groups', 'free_companies'
        %i(premium limited ranked_pvp unknown)
      when 'search'
        %i(owned tradeable gender premium limited ranked_pvp armoire unknown)
      when 'tomestones'
        %i(owned)
      when 'tools'
        case filter_action
        when 'gemstones'
          %i(owned tradeable)
        else
          %i(owned)
        end
      when 'packs'
        %i(owned)
      else
        # Otherwise, filters are provided by the model
        filter_controller.classify.constantize.available_filters
      end

    filters.delete(:owned) unless @character.present? || params[:character_id].present?
    filters
  end

  def filter_icon(filter, value)
    icon = case filter
           when :owned
             case value
             when 'owned' then 'check'
             when 'missing' then 'times'
             end
           when :tradeable
             'dollar-sign'
           when :gender
             if value == 'character'
               case @character&.gender
               when 'male' then 'mars'
               when 'female' then 'venus'
               end
             else
               case value
               when 'male' then 'venus'
               when 'female' then 'mars'
               end
             end
           when :premium
             'money-bill-alt'
           when :limited
             'clock'
           when :ranked_pvp
             'medal'
           when :armoire
             return collectable_icon('Armoire')
           when :outfit
             return collectable_icon('Outfit')
           when :unknown
             'question'
           end

    fa_icon(icon) if icon.present?
  end

  def patch_options_for_select(patches, selected, expansions: false, all: true)
    # Collect all of the patch numbers and add the Patch text to the display values
    options = patches.map do |patch|
      ["#{t('patch')} #{patch}", patch]
    end

    # Add special options for searching by expansion
    if expansions
      t('expansions').each do |value, expansion|
        options << [expansion, value]
      end
    end

    # Sort the patches in reverse chronological order
    options.sort_by! { |patch| [-patch[1].to_f, patch[1].is_a?(Integer) ? 1 : 0] }

    # Add an All Patches option to the start of the list
    if all
      options.unshift([t('all.patches'), 'all'])
    end

    options_for_select(options, selected)
  end

  def location(location, x, y, inline: false)
    "#{location.name}#{inline ? ' ' : '<br>'}(#{x}, #{y})".html_safe
  end

  def tooltip_path(collectable)
    polymorphic_path([collectable, :tooltip])
  end

  private
  def price_tooltip(collectable, data = nil)
    begin
      if data.present?
        # Use explicitly provided price data if available
        price = JSON.parse(data)
      else
        # Otherwise, it should be available from a hash
        price = @prices[collectable.item_id]
      end

      # Do not render tooltips for items without listings
      return unless price['price'].present?

      "<b>#{t('prices.price')}:</b> #{number_with_delimiter(price['price'])} Gil<br>" \
        "<b>#{t('prices.world')}:</b> #{price['world']}<br>" \
        "<b>#{t('prices.updated')}:</b> #{price['last_updated']}"
    rescue
    end
  end
end
