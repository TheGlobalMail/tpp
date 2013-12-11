define ['jquery', 'scrollTo'], ($) ->
  chartOffset = document.getElementById('chart').getBoundingClientRect().top

  $('.chapter a').on 'click', (e)->
    e.preventDefault()
    target = $(this).attr('href')
    target = chartOffset if target is '#chart'
    $.scrollTo(target, 1000, {offset: (if target is '#chart' then 0 else -150)} )
