snippetsEl = document.getElementById('snippets')
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

wrapInParagraphs = (snippet) -> "<p>#{snippet.html}</p>"

highligtedSnippets = null

window.filterSnippets = (voter, partner) ->
  combo = [abbrev[voter], abbrev[partner]].sort().join('')
  snippets = _.select(window.tppData, (snippet) -> snippet.combos[combo])
  snippetsEl.innerHTML = _.map(snippets, wrapInParagraphs).join('\n')
  covotersTitleEl.innerHTML = " where #{voter} voted with #{partner}"
  highligtedSnippets.classed('highlighted', false) if highligtedSnippets
  highligtedSnippets = d3.selectAll("mark[data-#{combo}=\"true\"]").classed('highlighted', true)
