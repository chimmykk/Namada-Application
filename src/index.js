const { app, BrowserWindow, ipcMain, remote } = require('electron');
const { spawn } = require('node-pty');
const { exec } = require('child_process');
const path = require('path');
const os = require('os');
const fixPath = require('fix-path');

const fs = require('fs');

// Get the path to the desktop directory
const desktopPath = (app || remote.app).getPath('desktop');

// Specify the directory name

const dir = path.join(desktopPath, 'memodata');

function createDirectory(directoryPath) {
  // Check if the directory doesn't exist
  if (!fs.existsSync(directoryPath)) {
    try {
      // Create the directory with full permissions
      fs.mkdirSync(directoryPath, { recursive: true, mode: '0777' });
      console.log('Directory created successfully.');
    } catch (error) {
      console.error('Error creating directory:', error);
    }
  } else {
    console.log('Directory already exists.');
  }
}



// Call fixPath() to set the correct PATH environment variable
fixPath();

let mainWindow;
let pty;

// Determine the shell based on the operating system's platform
const shell = os.platform() === 'win32' ? 'powershell.exe' : 'bash';

app.on('ready', () => {
  // Initialize the pseudo-terminal with node-pty
  try {
    pty = spawn(shell, [], {
      name: 'xterm-color',
      cols: 80,
      rows: 30,
      cwd: process.env.HOME,
      env: process.env
    });
  } catch (error) {
    console.error("Error spawning terminal:", error);
  }

  // Create the main window
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    show: false,
    icon: path.join(__dirname, './icons/namadalogo.png'), // Set the icon path
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true
    },
  });

  // Load the HTML file
  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  // Event handlers for communication between terminal and renderer process
  if (pty) {
    pty.onData((data) => {
      mainWindow.webContents.send('terminalData', data);
    });

    ipcMain.on('toTerminal', (event, data) => {
      pty.write(data);
    });

    ipcMain.on('executeInteractiveCommand', (event, command) => {
      // Write command to node-pty process
      pty.write(`${command}\n`);
    });

    pty.onData((data) => {
      mainWindow.webContents.send('interactiveCommandOutput', data);
    });
  } else {
    console.error("Terminal initialization failed.");
  }
  const executeWalletList = () => {
    exec('namada wallet list', (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        return;
      }
      mainWindow.webContents.send('walletList', stdout);
    });
  };
  ipcMain.on('executeWalletList', executeWalletList);
  const executeTerminalCommand = (command) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        return;
      }
      console.log(stdout);
      mainWindow.webContents.send('terminalCommandOutput', stdout);
    });
  };
  ipcMain.on('executeTerminalCommand', (event, command) => {
    createDirectory(dir);
    executeTerminalCommand(command);
  });
  ipcMain.on('generateWallet', (event, alias) => {
    const command = `namada gen wallet --alias "${alias}"`;
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        return;
      }
      console.log(stdout);
    });
  });
  ipcMain.on('executeInteractiveCommand', (event, command) => {
    // Write command to node-pty process
    pty.write(`${command}\n`);
  });



  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});