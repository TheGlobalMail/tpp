define ['jquery', 'scrollTo'], ($) ->

  $('.chapter a').on 'click', (e)->
    e.preventDefault()
    target = $(this).attr('href')
    target = 0 if target is '#main'
    $.scrollTo(target, 1000, {offset: (if target is '#main' then 0 else -150)} )
