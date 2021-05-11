alert("YAY!");
document.addEventListener("DOMContentLoaded", function () {
  const markdownPreviewAreas = document.querySelectorAll(".markdown-preview");

  if (markdownPreviewAreas.length) {
    markdownPreviewAreas.forEach((elem) => buildPreview(elem));
  }
});

const buildPreview = (elem) => {
  const markdownEditors = elem.querySelectorAll(".markdown");

  markdownEditors.forEach((markdown) => {
    const preview = document.createElement("div");
    const previewPanel = document.createElement("div");
    preview.classList.add("preview");
    preview.appendChild(previewPanel);
    previewPanel.classList.add("preview-panel");
    markdown.after(preview);

    const textarea = markdown.querySelector("textarea");
    textarea.addEventListener("keyup", (event) => {
      displayPreview(event.target.value, previewPanel);
    });

    displayPreview(textarea.value, previewPanel);
  });
};

const displayPreview = async (text, elem) => {
  const response = await fetch("/api/markdown", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ markdown: text }),
  });

  const json = await response.json();
  elem.innerHTML = json.html;
};
