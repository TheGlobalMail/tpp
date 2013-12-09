define ['d3', 'chroma', 'd3-tip'], (d3, chroma) ->

  init = () ->

    margin = {t: 20, r: 80, b: 30, l: 110}
    #w = 1060 - margin.l - margin.r
    #h = 760 - margin.t - margin.b
    x = d3.scale.ordinal()
    y = d3.scale.ordinal()
    colorScale = chroma.scale(['#F2F198', '#1C1C20']).mode('lch')
    formatPercent = d3.format('%')

    # how much to delay between rect transitions
    delayTime = 3

    # will be used later
    uniqCountriesX = null
    uniqCountriesY = null
    rectHeight = null
    rectWidth = null

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
      '<p>Of <em>' + d.voting_country + '</em>\'s ' + d.baseline + ' proposals, <em>' +
      d.partner + '</em> acted with it on ' + d.sim_votes + ', or ' + formatPercent(d.sim_pct) + '</p>'

    tooltip = d3.tip().attr('class', 'tooltip')
      .direction('n')
      .offset([-10, 0])
      .html(makeTooltipHtml)

    svg.call(tooltip)

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

    # interaction
    mouseOn = (self, d) ->
      d3selection = d3.select(self)
      # only show tooltip if it is a tile, not the axis label
      if d3selection.attr('class') is 'heatGroup'
        tooltip.show(d)

      thisRow = d3selection.attr('data-row')

      d3.selectAll('.heatGroup').each () ->
        rectGroup = d3.select(this)

        if rectGroup.attr('data-row') is thisRow
          rectGroup.select('.heatRect').style('stroke-dasharray', rectWidth + ' ' + rectHeight)
            .classed('heatRectActive', true)
        else
          rectGroup.select('.heatRect').style('stroke-dasharray', '0 0').classed('heatRectActive', false)
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

    svg.on 'mouseout', () ->
      tooltip.hide()
      mouseOff()

    resize = () ->
      width = Math.max(600, Math.min(window.innerWidth, 1020))
      w = width - margin.l - margin.r
      h = w - margin.t - margin.b
      x.rangeRoundBands([0, w])
      y.rangeRoundBands([h, 0])

      d3.select('.wrapperSvg')
        .attr({
          width: w + margin.l + margin.r
          height: h + margin.t + margin.b
          })
      
      d3.select('#chart').style('width', width + 'px')

      xAxis.scale(x)
      yAxis.scale(y)

      xAxisSvg.attr('transform', 'translate(0,' + h + ')')
        
      xAxisSvg.call(xAxis)
      yAxisSvg.call(yAxis)

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

        #xAxisSvg.call(xAxis)
        #yAxisSvg.call(yAxis)

        #rectWidth = x.rangeBand()
        #rectHeight = y.rangeBand()

        rowHilight = svg.selectAll('.rowHilight')
          .data(uniqCountries)
        .enter().insert('g', '.axis')
          .attr('class', 'rowHilight')
        
        rowHilight.append('rect')
          .attr({
            class: 'rowHilightRect'
            'data-row': (d) -> d.replace(' ', '')
            x: 15 - margin.l
            #y: (d) -> y(d)
            #width: w + margin.r
            #height: rectHeight
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
            #transform: (d) -> 'translate(' + [x(d.partner), y(d.voting_country)] + ')'
            })
          .on('mouseover', (d) -> if d.sim_pct < 1 then mouseOn(this, d) else null)
          .on('click', ((d) -> window.filterTranscripts(d.voting_country, d.partner)))
          .on('mouseout', mouseOff)

        heatGroups.append('rect')
          .attr({
            class: 'heatRect'
            #width: rectWidth
            #height: rectHeight
            fill: (d) -> if d.sim_pct < 1 then colorScale(d.sim_pct) else '#cfcfcf'
            })

        heatGroups.append('rect')
          .attr({
            class: 'heatRectOverlay'
            #width: rectWidth
            #height: rectHeight
            fill: 'url(#diagonal)'
            })
        
        resize()


    debouncer = (func, timeout) ->
      # Delays calling `func` until `timeout` has expired,
      # successive calls reset timeout and enforce the wait

      timeout = timeout || 200;
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


  return {
    init: init
  }
