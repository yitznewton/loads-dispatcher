document.querySelectorAll('.shortlist-button-form').forEach((element) => {
  element.addEventListener('ajax:success', () => {
    element.classList.add('hidden');
    element.parentElement.querySelectorAll('.unshortlist-button-form').forEach((e) => e.classList.remove('hidden'));
  });
});
document.querySelectorAll('.unshortlist-button-form').forEach((element) => {
  element.addEventListener('ajax:success', () => {
    element.classList.add('hidden');
    element.parentElement.querySelectorAll('.shortlist-button-form').forEach((e) => e.classList.remove('hidden'));
  });
});
