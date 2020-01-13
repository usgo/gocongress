$(document).ready(function() {
  // Initialize any dialogs present
  $(".dialog").dialog({
    autoOpen: false,
    modal: true,
    width: 450
  });

  /* Fire up the slideshow -Jared 11/30/10 */
  $("#gallery-container").show();
  if ($("#gallery").length == 1) {
    Galleria.loadTheme(
      "/assets/galleria/themes/classic/galleria.classic.min.js"
    );
    $("#gallery").galleria({
      autoplay: 5000,
      image_crop: true,
      show_info: true,
      thumbnails: false,
      transition: "fade",
      transition_speed: 1000
    });
  }
});
