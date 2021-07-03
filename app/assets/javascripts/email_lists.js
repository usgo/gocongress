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
      separatorInput.value
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

  list.appendChild(controls);
}
