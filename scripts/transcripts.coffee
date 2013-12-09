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

highligtedSnippets = null

window.filterSnippets = (voter, partner) ->
  combo = [abbrev[voter], abbrev[partner]].sort().join('')
  covotersTitleEl.innerHTML = " where #{voter} voted with #{partner}"
  highligtedSnippets.classed('highlighted', false) if highligtedSnippets
  highligtedSnippets = d3.selectAll("[data-#{combo}=\"true\"]").classed('highlighted', true)
