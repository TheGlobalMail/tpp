snippetsEl = document.getElementById('snippets')

abbrev =
  'United States': 'US'
  'Japan': 'JP'
  'Mexico': 'MX'
  'Canada': 'CA'
  'Australia': 'AU'
  'Malaysia': 'MY'
  'Chile': 'CL'
  'Singapore': 'Sg'
  'Peru': 'PE'
  'Vietnam': 'VN'
  'New Zealand': 'NZ'
  'Brunei': 'BN'

window.filterSnippets = (voter, partner) ->
  combo = [abbrev[voter], abbrev[partner]].sort().join('')
  snippets = _.select(window.tppData, (snippet) -> snippet.combos[combo])
  title = '<h2>' + voter + ' vs ' + partner + '</h2>'
  snippetsEl.innerHTML = title + _.map(snippets, (snippet) -> '<p>' + snippet.html + '</p>').join('\n')
