// The following files are provided by the jquery-rails gem.
// https://github.com/indirect/jquery-rails
// They must be included in this order:

//= require jquery
//= require jquery_ujs

/* To speed up page load, we are using a custom jquery-ui, which
only has autocomplete, datepicker, and dialog. -Jared 2012-07-09 */
//= require jquery-ui-1.10.1.custom.min.js

// The order is less importent for the other files:
//= require usgc.js

/* TODO: We only need the galleria stuff on the homepage. Hiding
this on other pages could improve page speed -Jared 2011.2.3 */
//= require galleria/galleria-1.2.8.min.js
