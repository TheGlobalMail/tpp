margin = {t: 20, r: 80, b: 30, l: 110}
w = 960 - margin.l - margin.r
h = 760 - margin.t - margin.b
x = d3.scale.ordinal().rangeRoundBands([0, w])
y = d3.scale.ordinal().rangeRoundBands([h, 0])
colorScale = chroma.scale(['#F2F198', '#1C1C20']).mode('lch')
formatPercent = d3.format('%')
delayTime = 3

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

defs = svg.append('svg:defs')

defs.append('svg:pattern')
  .attr({
    id: 'diagonal',
    width: 5,
    height: 5,
    patternUnits: 'userSpaceOnUse'
  })
  .append('svg:image')
    .attr('width', 5)
    .attr('height', 5)
    .attr('xlink:href', '/images/pattern.png')

makeTooltipHtml = (d) ->
  '<p>Of <em>' + d.voting_country + '</em>\'s ' + d.baseline + ' proposals, <em>' +
  d.partner + '</em> acted with it on ' + d.sim_votes + ', or ' + formatPercent(d.sim_pct) + '</p>'

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

mouseOn = (self, d) ->
  tooltip.show(d)
  d3RectGroup = d3.select(self)
  thisRow = d3RectGroup.attr('data-row')
  thisWidth = d3RectGroup.select('.heatRect').attr('width')
  thisHeight = d3RectGroup.select('.heatRect').attr('height')

  d3.selectAll('.heatGroup').each(() ->
    rectGroup = d3.select(this)

    if rectGroup.attr('data-row') is thisRow
      rectGroup.select('.heatRect').style('stroke-dasharray', thisWidth + ' ' + thisHeight)
        .classed('heatRectActive', true)
    else
      rectGroup.select('.heatRect').style('stroke-dasharray', '0 0').classed('heatRectActive', false)
      rectGroup.select('.heatRectOverlay')
        .style('visibility', 'visible')
  )


mouseOff = () ->
  d3.selectAll('.heatRect')
    .style('stroke-dasharray', '0 0')
    .classed('heatRectActive', false)

  d3.selectAll('.heatRectOverlay')
    .style('visibility', null)


delay = (d, i) ->
  i*delayTime

reSort = () ->
  d3clickEl = d3.select(this)
  thisRow = d3clickEl.attr('data-row')

  d3.selectAll('.rowHilightRect').each(() ->
    rowHilight = d3.select(this)
    if rowHilight.attr('data-row') == thisRow
      rowHilight.classed('active', true)
    else
      rowHilight.classed('active', false)
  )

  rowVals = d3.selectAll('.heatGroup[data-row="' + thisRow + '"]').sort((a,b) -> b.sim_pct - a.sim_pct)
  rowVals = rowVals[0].map((d) -> d.__data__.partner)
  x.domain(rowVals)

  d3.selectAll('.heatGroup').transition().delay(delay).ease('quadratic')
    .attr('transform', (d) -> 'translate(' + [x(d.partner), y(d.voting_country)] + ')')

  d3.select('.x.axis').transition().delay(delayTime*144).call(xAxis)

svg.on 'mouseout', () ->
  tooltip.hide()
  mouseOff()

d3.csv '/data/csv/voting_similarity.csv', (csv) ->
  uniqCountries = csv.map((d) -> d.voting_country)
  x.domain(uniqCountries.sort(d3.ascending))
  y.domain(uniqCountries.sort(d3.descending))

  xAxisSvg.call(xAxis)
  yAxisSvg.call(yAxis)

  # click on a y label, re-sort the chart
  yAxisSvg.selectAll('text')
    .attr({
      'data-row': (d) -> d.replace(' ', '')
      'class': 'yAxisText'
      })
    .on('click', reSort)

  rowHilight = svg.selectAll('.rowHilight')
    .data(uniqCountries)
  .enter().insert('g', '.axis')
    .attr('class', 'rowHilight')
  
  rowHilight.append('rect')
    .attr({
      class: 'rowHilightRect'
      'data-row': (d) -> d.replace(' ', '')
      x: 20 - margin.l
      y: (d) -> y(d)
      width: w + margin.r
      height: y.rangeBand()
      })
    .on('click', reSort)

  heatGroups = svg.selectAll('.heatGroup')
    .data(csv)
  .enter().append('g')
    .attr({
      class: 'heatGroup'
      'data-column': (d) -> d.partner.replace(' ', '')
      'data-row': (d) -> d.voting_country.replace(' ', '')
      transform: (d) -> 'translate(' + [x(d.partner), y(d.voting_country)] + ')'
      })
    .on('mouseover', (d) -> if d.sim_pct < 1 then mouseOn(this, d) else null)
    .on('mouseout', mouseOff)

  heatGroups.append('rect')
    .attr({
      class: 'heatRect'
      width: x.rangeBand()
      height: y.rangeBand()
      fill: (d) -> if d.sim_pct < 1 then colorScale(d.sim_pct) else '#cfcfcf'
      })

  heatGroups.append('rect')
    .attr({
      class: 'heatRectOverlay'
      width: x.rangeBand()
      height: y.rangeBand()
      fill: 'url(#diagonal)'
      })
    

