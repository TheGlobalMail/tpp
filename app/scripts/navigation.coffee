define ['jquery', 'scrollTo'], ($) ->

  $('.chapter a').on 'click', (e)->
    e.preventDefault()
    target = $(this).attr('href')
    $.scrollTo(target, 1000, {offset: -150)} )
