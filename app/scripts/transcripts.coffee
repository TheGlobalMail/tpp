define ['d3', 'jquery', 'scrollTo'], (d3, $) ->
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
  highlightedParagraphs = null
  filterActive = false
  filterIndex = null
  $filterResults = $('#filter-results')

  scrollToFilterIndex = ->
    $.scrollTo('#' + $(highlightedParagraphs[filterIndex]).attr('id'), 1000, {offset: -100})

  $('#clear-search-result').on 'click', (e) ->
    e.preventDefault()
    filterIndex = null
    $filterResults.removeClass('active')
    $.scrollTo(0, 1000)

  $('#prev-search-result').on 'click', (e) ->
    e.preventDefault()
    if highlightedParagraphs
      filterIndex -= 1
      if filterIndex < 0
        filterIndex = highlightedParagraphs.length - 1
      scrollToFilterIndex()

  $('#next-search-result').on 'click', (e) ->
    e.preventDefault()
    if highlightedParagraphs
      filterIndex += 1
      if filterIndex >= highlightedParagraphs.length
        filterIndex = 0
      scrollToFilterIndex()

  window.filterTranscripts = (voter, partner) ->
    filterActive = true
    filterIndex = 0
    $filterResults.addClass('active')
    combo = [abbrev[voter], abbrev[partner]].sort().join('')
    covotersTitleEl.innerHTML = " where #{voter} voted with #{partner}"
    highlightedSnippets.removeClass('highlighted') if highlightedSnippets
    highlightedSnippets = $("span[data-#{combo}=\"true\"]").addClass('highlighted')
    highlightedParagraphs.removeClass('highlighted') if highlightedParagraphs
    highlightedParagraphs = $("p[data-#{combo}=\"true\"]").addClass('highlighted')
