document.querySelectorAll('.shortlist-button-form').forEach((element) => {
  /* eslint-disable no-param-reassign */
  const buttons = Array.from(element.getElementsByClassName('shortlist-button'));

  element.addEventListener('ajax:before', () => (buttons.forEach((button) => button.disabled = true)));
  element.addEventListener('ajax:success', () => {
    element.classList.add('hidden');
    element.parentElement.querySelectorAll('.unshortlist-button-form').forEach((e) => e.classList.remove('hidden'));
  });
  element.addEventListener('ajax:complete', () => (buttons.forEach((button) => button.disabled = false)));
});
document.querySelectorAll('.unshortlist-button-form').forEach((element) => {
  /* eslint-disable no-param-reassign */
  const buttons = Array.from(element.getElementsByClassName('unshortlist-button'));

  element.addEventListener('ajax:before', () => (buttons.forEach((button) => button.disabled = true)));
  element.addEventListener('ajax:success', () => {
    element.classList.add('hidden');
    element.parentElement.querySelectorAll('.shortlist-button-form').forEach((e) => e.classList.remove('hidden'));
  });
  element.addEventListener('ajax:complete', () => (buttons.forEach((button) => button.disabled = false)));
});
