define ['d3', 'jquery', 'lodash', './scroll'], (d3, $, _, scroll) ->
  covotersTitleEl = document.getElementById('covoters-title')

  abbrev =
    'United States': 'US'
    'Japan': 'JP'
    'Mexico': 'MX'
    'Canada': 'CA'
    'Australia': 'AU'
    'Malaysia': 'MY'
    'Chile': 'CL'
    'Singapore': 'SG'
    'Peru': 'PE'
    'Vietnam': 'VN'
    'New Zealand': 'NZ'
    'Brunei': 'BN'

  highlightedSnippets = null
  highlightedSnippetsOffsets = null
  highlightedCountries = null
  filterActive = false
  filterIndex = null
  inScroll = false
  inScrollTimer = null
  $filterResults = $('#filter-results')
  $filterControls = $('.filter-controls') 
  $searchIndex = $filterControls.find('[data-role="search-index"]')
  $searchTotal = $filterControls.find('[data-role="search-total"]')
  $currentlyhighlightedSnippet = null

  correctOffset = ->
    $('header').height() + $('#navigation').height() + 100

  scrollToFilterIndex = ->
    clearTimeout(inScrollTimer) if inScrollTimer
    inScroll = true
    scroll('#' + $(highlightedSnippets[filterIndex]).attr('id'), -50 - correctOffset())
    setTimeout (-> inScroll = false), 1202

  updateFilterIndex = ()->
    $currentlyhighlightedSnippet.removeClass('current-index') if $currentlyhighlightedSnippet
    $currentlyhighlightedSnippet = $(highlightedSnippets[filterIndex])
    $currentlyhighlightedSnippet.addClass('current-index')
    $searchIndex.text(filterIndex + 1)

  $window = $(window)

  # Recaculate offsets
  $window.on 'resize', () ->
    highlightedSnippetsOffsets = _.map highlightedSnippets, (snippet) -> $(snippet).offset().top - headerHeight

  # Adjust search counter as results scroll offscreen
  $window.on 'scroll', (e) ->
    e.preventDefault()
    return if not highlightedSnippets or inScroll
    newOffset = $window.scrollTop()
    topHighlightIndex = -1
    _.detect highlightedSnippetsOffsets, (offset) ->
      topHighlightIndex++
      offset > newOffset
    if topHighlightIndex > 0 and topHighlightIndex isnt filterIndex
      filterIndex = topHighlightIndex
      updateFilterIndex()

  $('#clear-search-result').on 'click', (e) ->
    $(highlightedSnippets[filterIndex]).removeClass('current-index')
    $filterResults.removeClass('active')
    $filterControls.removeClass('active')
    filterIndex = null
    scroll('#chart')
    highlightedCountries.removeClass('highlighted') if highlightedCountries
    highlightedSnippets.removeClass('highlighted') if highlightedSnippets
    highlightedSnippets = null
    highlightedSnippetsOffsets = null
    highlightedCountries = null

  $('#prev-search-result').on 'click', (e) ->
    e.preventDefault()
    return if inScroll
    if highlightedSnippets
      filterIndex -= 1
      if filterIndex < 0
        filterIndex = highlightedSnippets.length - 1
      updateFilterIndex()
      scrollToFilterIndex()

  $('#next-search-result').on 'click', (e) ->
    e.preventDefault()
    return if inScroll
    if highlightedSnippets
      filterIndex += 1
      if filterIndex >= highlightedSnippets.length
        filterIndex = 0
      updateFilterIndex()
      scrollToFilterIndex()

  window.filterTranscripts = (voter, partner) ->
    return if voter is partner
    filterActive = true
    filterIndex = 0
    abbrevs = [abbrev[voter], abbrev[partner]]
    combo = abbrevs.sort().join('')
    covotersTitleEl.innerHTML = "#{voter} <span class='country-abbrev'>(" + abbrev[voter] + ")</span> and #{partner} <span class='country-abbrev'>(" + abbrev[partner] + ")</span><br /><small class='follow'>Follow the text to see where they agree</small>"
    highlightedSnippets.removeClass('highlighted') if highlightedSnippets
    highlightedSnippets = $("span[data-#{combo}=\"true\"]").addClass('highlighted')
    highlightedCountries.removeClass('highlighted') if highlightedCountries
    highlightedCountries = $("strong[data-country=\"#{abbrevs[0]}\"],strong[data-country=\"#{abbrevs[1]}\"]").addClass('highlighted')
    headerHeight = correctOffset()
    highlightedSnippetsOffsets = _.map highlightedSnippets, (snippet) -> $(snippet).offset().top - headerHeight
    updateFilterIndex()
    $searchTotal.text(highlightedSnippets.length)
    $filterResults.addClass('active')
    $filterControls.addClass('active')
    scrollToFilterIndex()
