$ ->
  return unless $('.collection').length || $('#filters').length

  #region Update cached table data with dynamic content
  data = $('#collection-data').data()

  if data?.characterSelected
    owned_ids = new Set(data.collectionIds.split(',').filter(Boolean))

    # Mark collectables as owned based on the character's collection IDs
    $('table.collection td[data-id]').each ->
      return unless owned_ids.has(this.dataset.id)

      td = $(this)
      td.attr('data-value', 1)
      td.parent().addClass('owned')

      # Manual collection checkbox
      checkbox = td.find('input[type="checkbox"]')
      if checkbox.length
        checkbox.prop('checked', true)
        checkbox.data('path', checkbox.data('path').replace('add', 'remove'))

      # Automatic collection icon
      icon = td.find('i')
      if icon.length
        icon.removeClass('fa-times').addClass('fa-check')

    # Triple Triad

    ## Card rewards
    $('.card-toggle').each ->
      return unless owned_ids.has(this.dataset.id)

      card = $(this)
      card.addClass('owned')
      card.data('path', card.data('path').replace('add', 'remove'))

    ## NPCs
    $('.npc-row').each ->
      npc = $(this)

      if npc.find('input[type="checkbox"]').prop('checked')
        npc.addClass('defeated')

      # cardList.find('.owned').length == cardList.children().length
      card_list = npc.find('.card-list')
      if card_list.children().length == card_list.children('.owned').length
        npc.addClass('completed')

    if !data?.characterVerified
      # Replace manual checkboxes with icons if the selected character is not verified
      $('table.collection input:checked').replaceWith('<i class="fas fa-check"></i>')
      $('table.collection input:not(:checked)').replaceWith('<i class="fas fa-times"></i>')

      # And disable card toggling
      $('.card-toggle').removeClass('card-toggle')

  if !data?.characterSelected
    # Hide checkbox column if no character is selected
    $('.check-ownership').hide()
    $('.card-toggle').removeClass('card-toggle')

  # Hide collectables of the specified types
  hidden_types = Cookies.get('hidden_types')?.split(',') || []
  for type in hidden_types
    $("tr[data-type='#{type}']").addClass('hidden')


  # Reveal the page
  $('.collection-spinner').hide()
  $('.collection-wrapper').show()

  #endregion

  #region Restripe table (performed after adding, removing, or filtering)
  restripe = ->
    # Skip restripe for Orchestrion Quick Select
    return if $('.quick-select').length || $('.npcs').length

    $('.collectable:not(.hidden)').show()

    if Cookies.get('owned') == 'owned'
      # Only show owned collectables
      $('.collection').addClass('only-owned')
      $('.collectable:not(.owned)').hide()
    else if Cookies.get('owned') == 'missing'
      # Only show missing collectables
      $('.collection').removeClass('only-owned')
      $('.collectable.owned').hide()
    else
      # Show all collectables
      $('.collection').removeClass('only-owned')

    # Only show/hide tradeables if the filter is available
    if $('#tradeable').length
      if Cookies.get('tradeable') == 'tradeable'
        $('.collectable:not(.tradeable)').hide()
      else if Cookies.get('tradeable') == 'untradeable'
        $('.collectable.tradeable').hide()

    $('tr.collectable:visible').each (index) ->
      $(@).css('background-color', if index % 2 == 0 then 'rgba(0, 0, 0, 0.1)' else 'rgba(0, 0, 0, 0.2)')

    # Update the collection progress bar based on visible collectables, with the exception of special pages
    unless $('.materiel').length
      progress_bar = $('.progress:first .progress-bar')
      progress_label = $('.progress:first .progress-label')
      current = $('.owned:not(.hidden)').length
      max = $('tr.collectable:not(.hidden)').length

      if max > 0
        completion = (current / max) * 100
        progress_bar.attr('aria-valuenow', current)
        progress_bar.attr('style', "width: #{completion}%")
        progress_label.text("#{current}/#{max} (#{parseInt(completion)}%)")

    # Update the alternate progress bar based on the *values* of visible collectables
    if $('tr.collectable').data('value')
      progress_bar = $('.progress:eq(1) .progress-bar')
      progress_label = $('.progress:eq(1) .progress-label')
      current = max = 0

      $('tr.collectable:not(.hidden)').each (_, collectable) ->
        value = $(collectable).data('value')
        current += value if $(collectable).hasClass('owned')
        max += value

      if max > 0
        completion = (current / max) * 100
        progress_bar.attr('aria-valuenow', current)
        progress_bar.attr('style', "width: #{completion}%")

        text = progress_label.text()
        text = text.replace(/[\d\s,.]+\s/, "#{current.toLocaleString()} ")
        text = text.replace(/(\D+) [\d\s,.]+/, "$1 #{max.toLocaleString()} ")
        progress_label.text(text)

  restripe()
  #endregion

  #region Add/remove a collectable from a player's collection
  updateCollection = (collectable) ->
    $.ajax({
      type: 'POST',
      url: collectable.data('path'),
      data: { authenticity_token: window._token },
      error: ->
        alert(I18n.t('alerts.problem_updating'))
        location.reload()
    })


  #endregion

  #region Manual collection ownership toggle
  $('td input.own').change ->
    collectable = $(this)
    updateCollection(collectable)

    if !this.checked
      path = collectable.data('path').replace('remove', 'add')
      collectable.closest('tr').removeClass('owned')
      collectable.closest('td').attr('data-value', 0)
    else
      path = collectable.data('path').replace('add', 'remove')
      collectable.closest('tr').addClass('owned')
      collectable.closest('td').attr('data-value', 1)
      collectable.closest('td').tooltip('enable')

    collectable.data('path', path)
    restripe()
  #endregion

  #region Manual generic item ownership toggle
  $('.item.own').click ->
    collectable = $(this)
    updateCollection(collectable)

    if collectable.hasClass('owned')
      path = collectable.data('path').replace('remove', 'add')
      collectable.removeClass('owned')
    else
      path = collectable.data('path').replace('add', 'remove')
      collectable.addClass('owned')

    collectable.data('path', path)

    count = collectable.closest('.collapse').find('.owned').length
    header = collectable.closest('.card').find('.card-header > h6')
    header.text(header.text().replace(/\d+/, count))

    if count == collectable.closest('.collapse').find('.item').length
      header.addClass('complete')
    else
      header.removeClass('complete')
  #endregion

  #region Orchestrion quick select
  $('.orchestrion-select input.own').change ->
    collectable = $(this)

    if !this.checked
      updateCollection(collectable)
      path = collectable.data('path').replace('remove', 'add')
      collectable.closest('.collectable').removeClass('owned')
    else
      updateCollection(collectable)
      path = collectable.data('path').replace('add', 'remove')
      collectable.closest('.collectable').addClass('owned')

    collectable.data('path', path)
  #endregion

  #region Category Buttons
  categories = $('.category-buttons button')
  categories.click ->
    category = $(@).attr('id').match(/\d+$/)[0]
    categories.removeClass('active')
    $(@).addClass('active')

    # Set the category in the form so it is retained on search
    $('#category').val(category)

    if category == '0'
      $('.collectable').removeClass('hidden')
      $('.all-hide').addClass('hidden')
    else
      $('.collectable').addClass('hidden')
      $(".collectable.category-#{category}").removeClass('hidden')
      $('.all-hide').removeClass('hidden')

    restripe()
  #endregion

  #region Type Buttons
  types = $('.type-buttons button:not("#reset")')

  types.click ->
    $(@).toggleClass('active')
    type = $(@).data('value')
    $(".collectable[data-type='#{type}']").toggleClass('hidden')

    restripe()
    hidden_types = $('.type-buttons button:not(".active")').map ->
      $(@).data('value')
    Cookies.set('hidden_types', hidden_types.get().join(','), { expires: 7300, sameSite: 'Lax' })

  $('.type-buttons button#reset').click ->
    $('.type-buttons button').addClass('active')
    $('.collectable').removeClass('hidden')
    Cookies.remove('hidden_types')
    restripe()
  #endregion

  #region Filters
  checkboxValue = (checkbox) ->
    if $(checkbox).prop('checked') then 'hide' else 'show'

  $('#filters-form').submit ->
    premium = $(@).find('#premium')
    limited = $(@).find('#limited')
    ranked_pvp = $(@).find('#ranked_pvp')
    armoire = $(@).find('#armoire')
    outfit = $(@).find('#outfit')
    unknown = $(@).find('#unknown')
    gender = $(@).find('#gender')

    refresh = (premium.length && Cookies.get('premium') != checkboxValue(premium)) ||
      (limited.length && Cookies.get('limited') != checkboxValue(limited)) ||
      (ranked_pvp.length && Cookies.get('ranked_pvp') != checkboxValue(ranked_pvp)) ||
      (armoire.length && Cookies.get('armoire') != checkboxValue(armoire)) ||
      (outfit.length && Cookies.get('outfit') != checkboxValue(outfit)) ||
      (unknown.length && Cookies.get('unknown') != checkboxValue(unknown)) ||
      (gender.length && Cookies.get('gender') != gender.val())

    $(@).find('input[type="checkbox"]').each (_, option) ->
      Cookies.set("#{$(option).attr('id')}", checkboxValue(option), { expires: 7300, sameSite: 'Lax' })

    $(@).find('select').each (_, option) ->
      Cookies.set("#{$(option).attr('id')}", $(option).val(), { expires: 7300, sameSite: 'Lax' })

    $('#filters').modal('hide')

    if refresh
      location.reload()
      false
    else
      restripe()

  $('#filters-reset').click ->
    $('#filters-form select option').prop('selected', false)
    $('#filters-form input[type=checkbox]').prop('checked', false)
    $(@).blur()
    false
  #endregion

  #region Miscellaneous

  # Restripe on table sort
  $('.sortable').on 'sorted', ->
    restripe()

  # Remove focus from modal toggle button after showing
  $('.modal').on 'shown.bs.modal', ->
    $('.modal-toggle').one 'focus', ->
      $(@).blur()

  #endregion
