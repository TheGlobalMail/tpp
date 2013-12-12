define ['jquery', 'scrollTo'], ($, scrollTo) ->

  webkit = navigator.userAgent.match(/(iPod|iPhone|iPad|Android)/)
  $navAndHeader = $('nav,header')
  $header = $('header')
  $nav = $('nav')

  reappear = ->
    if webkit
      $header.show()
      $nav.slideDown('fast')
  
  (target, offset = -150) ->
    $navAndHeader.hide() if webkit
    $.scrollTo(target, 1000, {offset: offset, onAfter: reappear, axis: 'y'})
