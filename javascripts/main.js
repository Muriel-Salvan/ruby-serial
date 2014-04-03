//STICKY NAV
jQuery(document).ready(function () {

  function getDefaultFontSize(parentElement)
  {
      parentElement = parentElement || document.body;
      var div = document.createElement('div');
      div.style.width = "1000em";
      parentElement.appendChild(div);
      var pixels = div.offsetWidth / 1000;
      parentElement.removeChild(div);
      return pixels;
  }

  var menuTopSpace = getDefaultFontSize(jQuery('#floating_menu')[0])*2;
  var top = jQuery('#floating_menu').offset().top - parseFloat(jQuery('#floating_menu').css('marginTop').replace(/auto/, 100));
  jQuery(window).scroll(function (event) {
    // what the y position of the scroll is
    var y = jQuery(this).scrollTop();

    // whether that's below the form
    if (y >= top - menuTopSpace) {
      // if so, ad the fixed class
      jQuery('#floating_menu').addClass('fixed');
    } else {
      // otherwise remove it
      jQuery('#floating_menu').removeClass('fixed');
    }
  });
});
