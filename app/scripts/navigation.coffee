define ['jquery', './scroll'], ($, scroll) ->

  $('.chapter a').on 'click', (e)->
    e.preventDefault()
    target = $(this).attr('href')
    scroll(target)
