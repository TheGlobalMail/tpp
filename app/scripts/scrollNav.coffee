define ['jquery'], ($) ->
  $nav = $('#navigation')
  nav_offset = $nav.offset().top

  scrollNav = () ->
    if $(window).scrollTop() > nav_offset + $('#chart').height()
      $nav.addClass('fixed')
    else
      $nav.removeClass('fixed')

  return {
    scrollNav: scrollNav
  }