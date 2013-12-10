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
  highlightedCountries = null
  filterActive = false
  filterIndex = null
  $filterResults = $('#filter-results')
  $searchIndex = $filterResults.find('[data-role="search-index"]')
  $searchTotal = $filterResults.find('[data-role="search-total"]')

  scrollToFilterIndex = ->
    $.scrollTo('#' + $(highlightedSnippets[filterIndex]).attr('id'), 1000, {offset: -100})

  $('#clear-search-result').on 'click', (e) ->
    e.preventDefault()
    filterIndex = null
    $filterResults.removeClass('active')
    $.scrollTo(0, 1000)
    highlightedParagraphs.removeClass('highlighted') if highlightedParagraphs
    highlightedCountries.removeClass('highlighted') if highlightedCountries
    highlightedSnippets.removeClass('highlighted') if highlightedSnippets

  $('#prev-search-result').on 'click', (e) ->
    e.preventDefault()
    if highlightedSnippets
      filterIndex -= 1
      if filterIndex < 0
        filterIndex = highlightedSnippets.length - 1
      scrollToFilterIndex()

  $('#next-search-result').on 'click', (e) ->
    e.preventDefault()
    if highlightedSnippets
      filterIndex += 1
      if filterIndex >= highlightedSnippets.length
        filterIndex = 0
      $searchIndex.text(filterIndex + 1)
      scrollToFilterIndex()

  window.filterTranscripts = (voter, partner) ->
    return if voter is partner
    filterActive = true
    filterIndex = 0
    abbrevs = [abbrev[voter], abbrev[partner]]
    combo = abbrevs.sort().join('')
    covotersTitleEl.innerHTML = "Proposals where #{voter} voted with #{partner}"
    highlightedSnippets.removeClass('highlighted') if highlightedSnippets
    highlightedSnippets = $("span[data-#{combo}=\"true\"]").addClass('highlighted')
    highlightedParagraphs.removeClass('highlighted') if highlightedParagraphs
    highlightedParagraphs = $("p[data-#{combo}=\"true\"]").addClass('highlighted')
    highlightedCountries.removeClass('highlighted') if highlightedCountries
    highlightedCountries = $("strong[data-country=\"#{abbrevs[0]}\"],strong[data-country=\"#{abbrevs[1]}\"]").addClass('highlighted')
    $searchIndex.text(filterIndex + 1)
    $searchTotal.text(highlightedSnippets.length)
    $filterResults.addClass('active')
    scrollToFilterIndex()
