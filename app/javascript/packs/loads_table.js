document.querySelectorAll('.dismiss-button-form').forEach((element) => {
  element.addEventListener('ajax:success', function (event) {
    const tr = event.target.parentElement.parentElement;
    const { loadId } = this.dataset;
    tr.remove();

    if (!loadId) return;

    document.dispatchEvent(new Event(`load:${loadId}:delete`));
  });
});
