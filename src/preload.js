const { ipcRenderer } = require('electron');

// Listen for the output event from the main process
ipcRenderer.on('output', (event, output) => {
  // Render the output by updating the text content of an element with id "output"
  const outputElement = document.getElementById('output');
  outputElement.textContent = output;
});
