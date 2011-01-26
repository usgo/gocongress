// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/* Fire up the slideshow -Jared 11/30/10 */
$(document).ready(function(){
	$('#gallery-container').show();
	$('#gallery').galleria({
		autoplay: 5000
		, image_crop: true
		, transition: 'fade'
		, transition_speed: 1000
	});
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