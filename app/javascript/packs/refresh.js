window.addEventListener('load', () => {
  const formElement = document.getElementById('refresh-form');
  const resultElement = document.getElementById('form-result');

  formElement.addEventListener('ajax:success', () => {
    resultElement.textContent = 'Refresh queued';
  });
  formElement.addEventListener('ajax:error', () => {
    resultElement.textContent = 'Refresh failed';
  });
});
