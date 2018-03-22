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

//= require svgxuse.js

/* TODO: We only need the galleria stuff on the homepage. Hiding
this on other pages could improve page speed -Jared 2011.2.3 */
//= require galleria/galleria-1.2.8.min.js


// check for text areas with a maxlength prop
$(function () {
  document.querySelectorAll("textarea[maxlength]").forEach(elem => {
    if (!elem.getAttribute("maxLength")) {
      return;
    }

    const counter = document.createElement("div");
    elem.parentNode.appendChild(counter);

    elem.addEventListener("keydown", (event) => {
      updateCounter(elem, counter);
    });
    elem.addEventListener("keyup", (event) => {
      updateCounter(elem, counter);
    });
  })
});

function updateCounter(elem, counter) {
  counter.innerHTML = `Characters left: ${elem.maxLength - elem.value.length}`;
}

// create a element to show chars left

// update element of textarea value change
