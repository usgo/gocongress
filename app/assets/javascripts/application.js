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
//= require intlTelInput
//= require libphonenumber/utils

/* TODO: We only need the galleria stuff on the homepage. Hiding
this on other pages could improve page speed -Jared 2011.2.3 */
//= require galleria/galleria-1.2.8.min.js
function intlTelFunction() {
  var $phoneInputCollection = $(`[data-intl-phone="true"]`);

  $phoneInputCollection.each(function(i, item) {
    var $phoneInput = $(item),
      name = $phoneInput.attr("name"),
      hiddenInputName = name,
      $errorMsg = $("<span />")
        .addClass("error hide smalltext")
        .text("Invalid number"),
      $validMsg = $("<span />")
        .addClass("valid hide smalltext")
        .html('✓&nbsp;Valid');

    $phoneInput.attr("name", name + "_input");
    $phoneInput.after($validMsg);
    $phoneInput.after($errorMsg);

    $phoneInput.intlTelInput({
      initialCountry: "auto",
      geoIpLookup: function(callback) {
        var $this = $(this);

        $.get("https://ipinfo.io", function() {}, "jsonp").always(function(
          resp
        ) {
          var countryCode = resp && resp.country ? resp.country : "";

          // When we get the country code, loop through all of the phone inputs
          // and see if they have a current value, but not a country code
          $phoneInputCollection.each(function(i, item) {
            var $phoneInput = $(item);
            var currentNum = $phoneInput
              .intlTelInput('getNumber')
              .replace(/[\(\)\-\.\+]/g, '');

            var selectedCountry = $phoneInput.intlTelInput('getSelectedCountryData');

            if (currentNum) {
              // If it looks like a domestic number
              if (currentNum.length === 10) {
                if (!selectedCountry.length) {
                  $phoneInput.intlTelInput('setCountry', countryCode);
                }
                $phoneInput.intlTelInput('setNumber', currentNum);
              } else {
                $phoneInput.intlTelInput('setNumber', '+' + currentNum)
              }
              $phoneInput.trigger('blur');
            }
          });

          callback(countryCode);
        });
      },
      hiddenInput: hiddenInputName,
      nationalMode: true,
      formatOnDisplay: true,
      autoPlaceholder: 'polite'
    });

    var reset = function() {
      $errorMsg.addClass("hide");
      $validMsg.addClass("hide");
      $phoneInput.removeClass("error-border");
    };

    // on blur: validate
    $phoneInput.blur(function() {
      reset();
      if ($.trim($phoneInput.val())) {
        if ($phoneInput.intlTelInput("isValidNumber")) {
          $validMsg.removeClass("hide");
        } else {
          $phoneInput.addClass("error-border");
          $errorMsg.removeClass("hide");
        }
      }
    });

    // on keyup / change flag: reset
    $phoneInput.on("keyup change", reset);
  });
}

$(intlTelFunction);

// check for text areas with a maxlength prop
$(function() {
  document.querySelectorAll("textarea[maxlength]").forEach(elem => {
    if (!elem.getAttribute("maxLength")) {
      return;
    }

    const counter = document.createElement("div");
    counter.className = "textarea-maxlength-counter";
    elem.parentNode.appendChild(counter);

    elem.addEventListener("keydown", event => {
      updateCounter(elem, counter);
    });
    elem.addEventListener("keyup", event => {
      updateCounter(elem, counter);
    });
  });

  function updateCounter(elem, counter) {
    counter.innerHTML = `Characters left: ${elem.maxLength -
      elem.value.length}`;
  }
});

// Add a separator control for email lists
$(function() {
  document.querySelectorAll("[data-email-list]").forEach(elem => {
    var separator = document.createElement("div");
    var glueLabel = document.createElement("span");
    var glueInput = document.createElement("input");

    glueLabel.innerHTML = "Separator:";
    separator.classList.add("list-separator");
    glueInput.classList.add("glue");
    glueInput.value = elem.dataset.glue || ";";

    separator.appendChild(glueLabel);
    separator.appendChild(glueInput);
    elem.parentNode.insertBefore(separator, elem);

    // Select all on focus
    glueInput.addEventListener("focus", function(event) {
      event.target.setSelectionRange(0, this.value.length);
    });

    // Update the email list whenever the value changes
    glueInput.addEventListener("keyup", function(event) {
      var char = event.target.value;
      var json = elem.dataset.json;

      elem.value = JSON.parse(elem.dataset.json)
        .map(attendee => `"${attendee.name}" <${attendee.email}>`)
        .join(char + " ");
    });
  });
});

/*
 * List Filter
 */
$(function() {
  document.querySelectorAll("list-filter").forEach(function(elem) {
    var input = document.createElement("input");
    var clear = document.createElement("button");
    clear.innerHTML = "Clear";
    elem.appendChild(input);
    elem.appendChild(clear);

    var list = document.querySelector(elem.dataset.list);
    var items = list.querySelectorAll(elem.dataset.item);

    input.addEventListener("keyup", function(event) {
      search(input.value);
    });

    clear.addEventListener("click", function(event) {
      // TODO: Add keyup trigger
      input.value = "";
      search("");
    });

    function search(text) {
      items.forEach(function(item) {
        var value = item.querySelector(elem.dataset.value);

        // TODO: Replace with fuzzy search
        var HIDDEN = "hidden-by-filter";
        if (value.innerHTML.toLowerCase().search(text.toLowerCase()) === -1) {
          item.classList.add(HIDDEN);
        } else {
          item.classList.remove(HIDDEN);
        }
      });
    }
  });
});

/*
 * Adaptive nav
 * @see https://css-tricks.com/container-adapting-tabs-with-more-button/
 */
$(function() {
  document.querySelectorAll(".adaptive-nav").forEach(function(container) {
    var primary = container.querySelector("ul:first-of-type");
    primary.classList.add("-primary");
    var primaryItems = container.querySelectorAll(
      "ul:first-of-type > li:not(.-more)"
    );

    container.classList.add("--jsified");

    // insert "more" button and duplicate the list
    primary.insertAdjacentHTML(
      "beforeend",
      `
      <li class="-more">
        <button type="button" aria-haspopup="true" aria-expanded="false">
          More <span>&darr;</span>
        </button>
        <ul class="-secondary">
          ${primary.innerHTML}
        </ul>
      </li>
    `
    );

    var secondary = container.querySelector(".-secondary");
    var secondaryItems = secondary.querySelectorAll("li");
    var allItems = container.querySelectorAll("li");
    var moreLi = primary.querySelector(".-more");
    var moreBtn = moreLi.querySelector("button");

    moreBtn.addEventListener("click", event => {
      event.preventDefault();
      container.classList.toggle("--show-secondary");
      moreBtn.setAttribute(
        "aria-expanded",
        container.classList.contains("--show-secondary")
      );
    });

    function doAdapt() {
      // reveal all items for the calculation
      allItems.forEach(function(item) {
        item.classList.remove("--hidden");
      });

      // hide items that won't fit in the Primary
      var stopWidth = moreBtn.offsetWidth;
      var hiddenItems = [];
      var primaryWidth = primary.offsetWidth;

      primaryItems.forEach(function(item, i) {
        if (primaryWidth >= stopWidth + item.offsetWidth) {
          stopWidth += item.offsetWidth;
        } else {
          item.classList.add("--hidden");
          hiddenItems.push(i);
        }
      });

      // toggle the visibility of More button and items in Secondary
      if (!hiddenItems.length) {
        moreLi.classList.add("--hidden");
        container.classList.remove("--show-secondary");
        moreBtn.setAttribute("aria-expanded", false);
      } else {
        secondaryItems.forEach(function(item, i) {
          if (!hiddenItems.includes(i)) {
            item.classList.add("--hidden");
          }
        });
      }
    }

    // adapt immediately on load
    doAdapt();
    window.addEventListener("load", doAdapt);

    // adapt on window resize
    window.addEventListener("resize", doAdapt);

    // hide Secondary on the outside click
    document.addEventListener("click", function(e) {
      var el = e.target;
      while (el) {
        if (el === secondary || el === moreBtn) {
          return;
        }
        el = el.parentNode;
      }
      container.classList.remove("--show-secondary");
      moreBtn.setAttribute("aria-expanded", false);
    });
  });
});
