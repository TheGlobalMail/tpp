define ['d3', 'chroma', 'd3-tip'], (d3, chroma) ->

  init = () ->

    margin = {t: 20, r: 110, b: 80, l: 110}
    x = d3.scale.ordinal()
    y = d3.scale.ordinal()
    colorScale = chroma.scale(['#F2F198', '#1C1C20']).mode('lch').domain([0, 1])
    formatPercent = d3.format('%')
    legendRectHeight = 20
    legendStops = [0, 0.2, 0.4, 0.6, 0.8]
    legendX = d3.scale.ordinal().domain(legendStops)
    webkit = navigator.userAgent.match(/(iPod|iPhone|iPad)/)

    # how much to delay between rect transitions
    delayTime = 3

    # will be used later
    uniqCountriesX = null
    uniqCountriesY = null
    rectHeight = null
    rectWidth = null
    h = null

    svg = d3.select('#chart').append('svg')
      .attr({
        class: 'wrapperSvg'
      })
    .append('g')
      .attr({
        class: 'heatmapG'
        transform: 'translate(' + [margin.l, margin.t] + ')'
      })

    # used for drawing the diagonal-line pattern on inactive rects
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

    # tooltips and their content
    makeTooltipHtml = (d) ->
      '<p>Of <em>' + d.voting_country + '</em>\'s ' + d.baseline + ' stances, <em>' +
      d.partner + '</em> acted with it on ' + d.sim_votes + ', or ' + formatPercent(d.sim_pct) + '</p>'

    tooltip = d3.tip().attr('class', 'tooltip')
      .direction('n')
      .offset([-10, 0])
      .html(makeTooltipHtml)

    xAxis = d3.svg.axis()
      .tickSize(4, 0, 0)
      .orient('bottom')

    yAxis = d3.svg.axis()
      .tickSize(4, 0, 0)
      .orient('left')

    xAxisSvg = svg.append('g')
      .attr({
        class: 'x axis'
      })

    yAxisSvg = svg.append('g')
      .attr({
        class: 'y axis'
      })

    legend = svg.append('g')
      .attr({
        class: 'legend'
      })

    legend.append('text')
      .attr('class', 'legendLabel')
      .text('How often countries agree:')

    legendTitleOffset = 6

    legend.append('text')
      .attr('class', 'legendSource')
      .text('Source: Wikileaks')

    legendAxis = d3.svg.axis()
      # .scale(legendX)
      .orient('bottom')
      .tickFormat(formatPercent)

    legendAxisSvg = legend.append('g')
      .attr({
        class: 'legend axis'
        transform: 'translate(' + [0, legendRectHeight + legendTitleOffset] + ')'
      })

    # legendAxisSvg.call(legendAxis)

    # align ticks to left of rects

    legendGroups = legend.selectAll('.legendGroup')
      .data(legendStops)
    .enter().append('g')
      .attr('class', 'legendGroup')
      .attr('transform', 'translate(' + [0, legendTitleOffset] + ')')

    legendGroups.append('rect')
      .attr({
        class: 'legendRect'
        # x: (d) -> legendX(d)
        y: 0
        # width: legendX.rangeBand()
        height: legendRectHeight
        fill: (d) -> colorScale(d)
        })


    # interaction
    mouseOn = (self, d) ->
      d3selection = d3.select(self)
      # only show tooltip if it is a tile, not the axis label
      if d3selection.attr('class') is 'heatGroup'
        if not webkit
          tooltip.show(d)
        else
          tooltip.show(d)
          d3tooltip = d3.select('.tooltip')
          offsetTop = +d3tooltip.style('top').slice(0, -2) - document.body.scrollTop
          d3tooltip.style('top', offsetTop + 'px')

      thisRow = d3selection.attr('data-row')

      d3.selectAll('.heatGroup').each () ->
        rectGroup = d3.select(this)

        if rectGroup.attr('data-row') is thisRow
          rectGroup.select('.heatRect').classed('heatRectActive', true)
        else
          rectGroup.select('.heatRect').classed('heatRectActive', false)
          rectGroup.select('.heatRectOverlay')
            .style('visibility', 'visible')

    # disable everything
    mouseOff = () ->
      d3.selectAll('.heatRect')
        .style('stroke-dasharray', '0 0')
        .classed('heatRectActive', false)

      d3.selectAll('.heatRectOverlay')
        .style('visibility', null)

    delay = (d, i) ->
      i*delayTime

    # re-sort the tiles on clicking y-axis labels
    reSort = () ->
      d3clickEl = d3.select(this)

      if not d3clickEl.classed('active')
        thisRow = d3clickEl.attr('data-row')
        d3.selectAll('.rowHilightRect').each () ->
          rowHilight = d3.select(this)
          if rowHilight.attr('data-row') is thisRow
            rowHilight.classed('active', true)
          else
            rowHilight.classed('active', false)
        rowVals = d3.selectAll('.heatGroup[data-row="' + thisRow + '"]').sort((a,b) -> b.sim_pct - a.sim_pct)
        rowVals = rowVals[0].map((d) -> d.__data__.partner)
      else
        d3clickEl.classed('active', false)
        rowVals = uniqCountriesX

      x.domain(rowVals)

      d3.selectAll('.heatGroup').transition().delay(delay).ease('quadratic')
        .attr('transform', (d) -> 'translate(' + [x(d.partner), y(d.voting_country)] + ')')


      d3.select('.x.axis').transition().delay(delayTime*144).call(xAxis)

      xAxisSvg.selectAll("text").style("text-anchor", "end")

    svg.on 'mouseout', () ->
      tooltip.hide()
      mouseOff()

    resize = () ->
      width = Math.max(450, Math.min(window.innerWidth, 1020))
      w = width - margin.l - margin.r
      h = w
      heatMapHeight = h - margin.b
      x.rangeRoundBands([0, w])
      y.rangeRoundBands([heatMapHeight, 0])
      legendWidth = w / 2

      d3.select('.wrapperSvg')
        .attr({
          width: w + margin.l + margin.r
          height: h + margin.t + margin.b
          })
          .call(tooltip)
      
      d3.select('#chart').style('width', width + 'px')

      xAxis.scale(x)
      yAxis.scale(y)

      xAxisSvg.attr('transform', 'translate(0,' + heatMapHeight + ')')
        
      xAxisSvg.call(xAxis)
      yAxisSvg.call(yAxis)

      legendX.rangeRoundBands([0, legendWidth])
      legendAxis.scale(legendX)
      legendAxisSvg.call(legendAxis)

      legendGroups.selectAll('rect')
        .attr({
          x: (d) -> legendX(d)
          width: legendX.rangeBand()
          })

      legend.attr('transform', 'translate(0,' + (h - 10) + ')')
      legend.select('.legendSource').attr('transform', 'translate(' + [w - margin.r, 25] + ')')
      legendAxisSvg.selectAll('.tick')
        .attr('transform', (d) -> 'translate(' + [legendX(d), 0] + ')')
        
      xAxisSvg.selectAll("text")
        .style("text-anchor", "end")
        .attr("dx", "0.15em")
        .attr("dy", ".55em")
        .attr("transform", (d) -> "rotate(-35)")

      rectWidth = x.rangeBand()
      rectHeight = y.rangeBand()

      d3.selectAll('.rowHilightRect')
        .attr({
          y: (d) -> y(d)
          width: w + margin.r
          height: rectHeight
        })

      d3.selectAll('.heatGroup')
        .attr({
          transform: (d) -> 'translate(' + [x(d.partner), y(d.voting_country)] + ')'
        })

      d3.selectAll('.heatRect, .heatRectOverlay')
        .attr({
          width: rectWidth
          height: rectHeight
        })


    # bring in data and render
    render = () ->
      d3.csv '/data/voting_similarity.csv', (csv) ->
        uniqCountries = csv.map((d) -> d.voting_country)
        uniqCountriesX = uniqCountries.slice(0).sort(d3.ascending)
        uniqCountriesY = uniqCountries.slice(0).sort(d3.descending)

        x.domain(uniqCountriesX)
        y.domain(uniqCountriesY)

        rowHilight = svg.selectAll('.rowHilight')
          .data(uniqCountries)
        .enter().insert('g', '.axis')
          .attr('class', 'rowHilight')
        
        rowHilight.append('rect')
          .attr({
            class: 'rowHilightRect'
            'data-row': (d) -> d.replace(' ', '')
            x: 15 - margin.l
            })
          .on('click', reSort)
          .on('mouseover', (d) -> mouseOn(this, d))

        heatGroups = svg.selectAll('.heatGroup')
          .data(csv)
        .enter().append('g')
          .attr({
            class: 'heatGroup'
            'data-column': (d) -> d.partner.replace(' ', '')
            'data-row': (d) -> d.voting_country.replace(' ', '')
            })
          .on('mouseover', (d) -> if d.sim_pct < 1 then mouseOn(this, d) else null)
          .on('click', ((d) -> window.filterTranscripts(d.voting_country, d.partner)))
          .on('mouseout', mouseOff)

        heatGroups.append('rect')
          .attr({
            class: 'heatRect'
            fill: (d) -> if d.sim_pct < 1 then colorScale(d.sim_pct) else '#cfcfcf'
            })

        heatGroups.append('rect')
          .attr({
            class: 'heatRectOverlay'
            fill: 'url(#diagonal)'
            })
        
        resize()

    debouncer = (func, timeout) ->
      # Delays calling `func` until `timeout` has expired,
      # successive calls reset timeout and enforce the wait

      timeout = timeout || 200
      timeoutID = null

      return ->
        scope = this
        args = arguments

        clearTimeout(timeoutID)
        timeoutID = setTimeout(
          ->
            func.apply(
              scope,
              Array.prototype.slice.call(args)
            )
          timeout
        )

    _resize = debouncer(resize, 75)

    d3.select(window).on('resize', () ->
      _resize()
    )
          
    render()

    $('.loader').fadeOut('slow')
    $('#chart,#nav-wrapper,#transcripts').removeClass('loading')

  return {
    init: init
  }
