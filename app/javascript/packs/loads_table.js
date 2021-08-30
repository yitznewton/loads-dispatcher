document.querySelectorAll('.dismiss-button-form').forEach(element => {
  element.addEventListener("ajax:success", (event) => {
    const tr = event.target.parentElement.parentElement;
    tr.remove();
  });
});
