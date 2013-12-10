define ['jquery'], ($) ->
  $nav = $('#navigation')
  nav_offset = $nav.offset().top

  scrollNav = (svgHeight) ->
    if $(window).scrollTop() > nav_offset + svgHeight
      $nav.addClass('fixed')
    else
      $nav.removeClass('fixed')

  return {
    scrollNav: scrollNav
  }