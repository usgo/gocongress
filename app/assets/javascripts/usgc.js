$(document).ready(function(){

  // Initialize any dialogs present
  $( ".dialog" ).dialog({
    autoOpen: false,
    modal: true,
    width: 450
  });

  /* Fire up the slideshow -Jared 11/30/10 */
  $('#gallery-container').show();
  if ($('#gallery').length == 1) {
    Galleria.loadTheme('assets/galleria/themes/classic/galleria.classic.min.js');
    $('#gallery').galleria({
      autoplay: 5000
      , image_crop: true
      , show_info: true
      , thumbnails: false
      , transition: 'fade'
      , transition_speed: 1000
    });
  }
});

function add_round (link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $('.rounds-container').append( content.replace(regexp, new_id) );
}

function remove_round (elm) {
  /* Mark the hidden _destroy field for this round -Jared 1/25/11 */
  var hiddenField = $(elm).siblings('.tournament-round-destroy');
  if (hiddenField.length != 1) { throw 'Unable to find exactly one hidden field'; }
  hiddenField.val(1);

  /* Hide the set of inputs for this round -Jared 1/25/11 */
  var round = $(elm).parent('.tournament-round');
  if (round.length != 1) { throw 'Unable to find exactly one round'; }
  round.hide();
}
