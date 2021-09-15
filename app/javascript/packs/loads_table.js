document.querySelectorAll('.dismiss-button-form').forEach((element) => {
  /* eslint-disable no-param-reassign */
  const buttons = Array.from(element.getElementsByClassName('dismiss-button'));

  element.addEventListener('ajax:before', () => (buttons.forEach((button) => button.disabled = true)));
  element.addEventListener('ajax:success', (event) => {
    const tr = event.target.parentElement.parentElement;
    const { loadId } = element.dataset;
    tr.remove();

    if (!loadId) return;

    document.dispatchEvent(new Event(`load:${loadId}:delete`));
  });
  element.addEventListener('ajax:complete', () => (buttons.forEach((button) => button.disabled = false)));
});
