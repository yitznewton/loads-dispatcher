const setRate = (loadId, rate) => {
  const data = {
    load: {
      rate: parseInt(rate.replace(/[^0-9.]/g, ''), 10) * 100
    }
  }

  const headers = {
    'Content-Type': 'application/json'
  };

  fetch(`/loads/${loadId}.json`, { body: JSON.stringify(data), method: 'PATCH', headers: headers })
};

for (const element of document.getElementsByClassName('selectable-for-rate')) {
  let selectedText;

  element.addEventListener('mouseup', function() {
    const currentlySelectedText = window.getSelection().toString();

    if (selectedText !== currentlySelectedText) {
      selectedText = currentlySelectedText;

      if (selectedText.length === 0) {
        return;
      }

      const result = window.confirm(`Change rate to ${selectedText}?`);

      if (result) {
        setRate(this.dataset.loadId, selectedText);
      }
    }
  });
}
