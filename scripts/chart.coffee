# TODO
# resort x axis on click?

margin = {t: 20, r: 20, b: 30, l: 110}
w = 960 - margin.l - margin.r
h = 760 - margin.t - margin.b
x = d3.scale.ordinal().rangeRoundBands([0, w])
y = d3.scale.ordinal().rangeRoundBands([h, 0])
colorScale = chroma.scale(['#F2F198', '#1C1C20']).mode('lch')
formatPercent = d3.format('%')

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

makeTooltipHtml = (d) ->
  '<p>Of ' + d.voting_country + '\'s ' + d.baseline + ' proposals, ' +
  d.partner + ' acted with it on ' + d.sim_votes + ', or ' + formatPercent(d.sim_pct) + '</p>'

tooltip = d3.tip().attr('class', 'tooltip')
  .direction('n')
  .offset([-10, 0])
  .html(makeTooltipHtml)

svg.call(tooltip)

xAxis = d3.svg.axis()
  .tickSize(4, 0, 0)
  .scale(x)
  .orient('bottom')

yAxis = d3.svg.axis()
  .tickSize(4, 0, 0)
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

mouseOn = (d) ->
  tooltip.show(d)
  d3Rect = d3.select(this)
  thisRow = d3Rect.attr('data-row')
  thisWidth = d3Rect.attr('width')
  thisHeight = d3Rect.attr('height')

  d3.selectAll('.heatRect')
    .style('stroke-dasharray', '0 0')
    .classed('heatRectActive', false)

  d3.selectAll('[data-row="' + thisRow + '"]')
    .style('stroke-dasharray', thisWidth + ' ' + thisHeight)
    .classed('heatRectActive', true)

mouseOff = () ->
  d3.selectAll('.heatRect')
    .style('stroke-dasharray', '0 0')
    .classed('heatRectActive', false)

svg.on('mouseout', () ->
  tooltip.hide()
  mouseOff()
)

d3.csv '/data/csv/voting_similarity.csv', (csv) ->
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
      class: 'heatRect'
      width: x.rangeBand()
      height: y.rangeBand()
      x: (d) -> x(d.partner)
      y: (d) -> y(d.voting_country)
      'data-column': (d) -> d.partner.replace(' ', '')
      'data-row': (d) -> d.voting_country.replace(' ', '')
      fill: (d) -> if d.sim_pct < 1 then colorScale(d.sim_pct) else '#cfcfcf'
    })
    .on('mouseover', mouseOn)
    .on('mouseout', mouseOff)
