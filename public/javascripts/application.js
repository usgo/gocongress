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