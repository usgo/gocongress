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
    counter.className = "textarea-maxlength-counter";
    elem.parentNode.appendChild(counter);

    elem.addEventListener("keydown", (event) => {
      updateCounter(elem, counter);
    });
    elem.addEventListener("keyup", (event) => {
      updateCounter(elem, counter);
    });
  });

  function updateCounter(elem, counter) {
    counter.innerHTML = `Characters left: ${elem.maxLength - elem.value.length}`;
  }
});

// Add a separator control for email lists
$(function () {
  document.querySelectorAll('[data-email-list]').forEach(elem => {
    var separator = document.createElement('div');
    var glueLabel = document.createElement('span');
    var glueInput = document.createElement('input');

    glueLabel.innerHTML = 'Separator:';
    separator.classList.add('list-separator');
    glueInput.classList.add('glue');
    glueInput.value = elem.dataset.glue || ';';

    separator.appendChild(glueLabel);
    separator.appendChild(glueInput);
    elem.parentNode.insertBefore(separator, elem);

    // Select all on focus
    glueInput.addEventListener('focus', function (event) {
      event.target.setSelectionRange(0, this.value.length)
    });

    // Update the email list whenever the value changes
    glueInput.addEventListener('keyup', function (event) {
      var char = event.target.value;
      var json = elem.dataset.json;

      elem.value = JSON.parse(elem.dataset.json).map(
        attendee => `"${attendee.name}" <${attendee.email}>`
      ).join(char + ' ');
    });
  });
});


/*
 * List Filter
 */
$(function () {
  document.querySelectorAll('list-filter').forEach(function (elem) {
    var input = document.createElement('input');
    var clear = document.createElement('button');
    clear.innerHTML = "Clear";
    elem.appendChild(input);
    elem.appendChild(clear);

    var list = document.querySelector(elem.dataset.list);
    var items = list.querySelectorAll(elem.dataset.item);

    input.addEventListener('keyup', function (event) {
      search(input.value);
    });

    clear.addEventListener('click', function (event) {
      // TODO: Add keyup trigger
      input.value = '';
      search('');
    });

    function search(text) {
      items.forEach(function (item) {
        var value = item.querySelector(elem.dataset.value);

        // TODO: Replace with fuzzy search
        var HIDDEN = 'hidden-by-filter';
        if (value.innerHTML.toLowerCase().search(text.toLowerCase()) === -1) {
          item.classList.add(HIDDEN);
        } else {
          item.classList.remove(HIDDEN);
        }
      });
    }
  });
});
