document.querySelectorAll('.dismiss-button-form').forEach(element => {
  element.addEventListener("ajax:success", function(event) {
    const tr = event.target.parentElement.parentElement;
    const loadId = this.dataset.loadId;
    tr.remove();

    if (!loadId) return;

    document.dispatchEvent(new Event(`load:${loadId}:delete`));
  });
});
document.querySelectorAll('.shortlist-button-form').forEach(element => {
  element.addEventListener("ajax:success", function(event) {
    element.classList.add('hidden');
    element.parentElement.querySelectorAll('.unshortlist-button-form').forEach(e => e.classList.remove('hidden'));
  });
});
document.querySelectorAll('.unshortlist-button-form').forEach(element => {
  element.addEventListener("ajax:success", function(event) {
    element.classList.add('hidden');
    element.parentElement.querySelectorAll('.shortlist-button-form').forEach(e => e.classList.remove('hidden'));
  });
});
