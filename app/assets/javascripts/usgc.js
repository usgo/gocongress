/* Fire up the slideshow -Jared 11/30/10 */
$(document).ready(function(){	
	$('#gallery-container').show();
	
	// After struggling to get galleria into the vendor dir, I have settled
	// with the public dir.  Galleria really wants to live at the webroot.
	Galleria.loadTheme('galleria/themes/classic/galleria.classic.min.js');
  $('#gallery').galleria({
		autoplay: 5000
		, image_crop: true
		, transition: 'fade'
		, transition_speed: 1000
	});
	
	$('.expand_attendee').live('click', function() {
		var attendee_id = $(this).attr('id').split('_')[2];
		var drawer = $('#attendee_drawer_' + attendee_id);
		if (drawer.length != 1) { throw "Unable to find attendee drawer"; }
		if (drawer.is(':hidden')) { drawer.show('blind'); } 
		else { drawer.hide('blind'); }
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
