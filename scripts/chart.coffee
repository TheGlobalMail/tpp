margin = {t: 20, r: 20, b: 30, l: 110}
w = 960 - margin.l - margin.r
h = 760 - margin.t - margin.b
x = d3.scale.ordinal().rangeRoundBands([0, w])
y = d3.scale.ordinal().rangeRoundBands([h, 0])
colorScale = d3.scale.linear().range(['white', 'turquoise'])

svg = d3.select('#chart').append('svg')
  .attr({
    width: w + margin.l + margin.r
    height: h + margin.t + margin.b
  })
.append('g')
  .attr({
    class: 'heatmapG'
    transform: 'translate(' + [margin.l, margin.t] + ')'
  })

xAxis = d3.svg.axis()
  .scale(x)
  .orient('bottom')

yAxis = d3.svg.axis()
  .scale(y)
  .orient('left')

xAxisSvg = svg.append('g')
  .attr({
    class: 'x axis'
    transform: 'translate(0,' + h + ')'
  })

yAxisSvg = svg.append('g')
  .attr({
    class: 'y axis'
  })

makeTooltipHtml = (d) ->
  '<p>Of ' + d.voting_country + '\'s ' + d.baseline + ' proposals, ' +
  d.partner + ' was involved in ' + d.sim_votes + '</p>'


tooltip = d3.tip().attr('class', 'tooltip')
  .direction('n')
  .html(makeTooltipHtml)

svg.call(tooltip)

d3.csv '/data/csv/voting_similarity.csv', (csv) ->
  console.log csv

  uniqCountries = csv.map((d) -> d.voting_country)
  x.domain(uniqCountries)
  y.domain(uniqCountries.sort((a, b) -> b - a))

  xAxisSvg.call(xAxis)
  yAxisSvg.call(yAxis)

  heatGroups = svg.selectAll('.heatGroup')
    .data(csv)
  .enter().append('g')
    .attr('class', 'heatGroup')

  heatGroups.append('rect')
    .attr({
      width: x.rangeBand()
      height: y.rangeBand()
      x: (d) -> x(d.partner)
      y: (d) -> y(d.voting_country)
      fill: (d) -> colorScale(d.sim_pct)
    })
    .on('mouseover', tooltip.show)
    .on('mouseout', tooltip.show)