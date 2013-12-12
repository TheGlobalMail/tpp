define ['jquery', 'lodash'], ($, _) ->
  $nav = $('#navigation')
  navWrapper = document.getElementById('nav-wrapper')

  scrollNav = () ->
    navOffset = navWrapper.getBoundingClientRect().top
    if navOffset <= 50
      $nav.addClass('fixed')
    else
      $nav.removeClass('fixed')

  $(window.document).bind('scroll', _.throttle(scrollNav, 50) )
