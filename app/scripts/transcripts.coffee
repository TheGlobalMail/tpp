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

window.filterTranscripts = (voter, partner) ->
  combo = [abbrev[voter], abbrev[partner]].sort().join('')
  console.error('got:')
  console.error(combo)
  covotersTitleEl.innerHTML = " where #{voter} voted with #{partner}"
  highligtedSnippets.classed('highlighted', false) if highligtedSnippets
  highligtedSnippets = d3.selectAll("[data-#{combo}=\"true\"]").classed('highlighted', true)
