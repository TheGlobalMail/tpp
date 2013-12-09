define ['jquery', 'scrollTo'], ($) ->

  $('#chapters a').on 'click', (e)->
    e.preventDefault()
    target = $(this).attr('href')
    target = 0 if target is '#main'
    $.scrollTo(target, 1000, {offset: (target is '#main' ? 0 : -100)} )
