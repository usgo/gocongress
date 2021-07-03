document.addEventListener("DOMContentLoaded", function () {
  // Find any elements marked with the "email-list" class and add standard email
  // list controls to them
  const emailLists = document.querySelectorAll(".email-list");
  emailLists.forEach(setUpEmailList);
});

function setUpEmailList(list) {
  const textarea = list.querySelector("textarea");

  // Create the necessary DOM elements
  const controls = document.createElement("div");
  controls.classList.add("controls");

  const separatorControl = document.createElement("label");
  separatorControl.classList.add("separator-control");
  separatorControl.innerText = "Separator: ";

  const separatorInput = document.createElement("input");
  separatorInput.type = "text";
  separatorInput.value = ", ";
  separatorControl.appendChild(separatorInput);

  // When the separator input value changes, substitute the separator in the
  // list of emails so that clients that have different requirements (such as
  // semi-colons) can easily adjust their list
  separatorInput.addEventListener("keyup", () => {
    textarea.value = textarea.dataset.emails.replace(
      /, /g,
      // The "replace" unescapes the newline separator so that \n can be used to
      // put emails on their own lines
      separatorInput.value.replace(/\\n/g, "\n")
    );
  });

  const copyButton = document.createElement("button");
  copyButton.innerText = "Copy";
  copyButton.classList.add("copy");

  // Copy the email list to the clipboard when this button is clicked
  copyButton.addEventListener("click", async (event) => {
    const button = event.currentTarget;
    button.classList.remove("copied");
    await navigator.clipboard.writeText(textarea.value);
    button.innerText = "Copied";
    button.classList.add("copied");
  });

  controls.appendChild(separatorControl);
  controls.appendChild(copyButton);

  const helpText = document.createElement("div");
  helpText.classList.add("help-text");
  helpText.innerHTML =
    "Use the separator to control how the list is formatted; email clients differ in what they need. You can also use <code>\\n</code> to separate each email with a new line.";

  list.appendChild(controls);
  list.appendChild(helpText);
}
