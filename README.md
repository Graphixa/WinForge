## Overview
Winforge is a powerful PowerShell script designed to simplify and enhance the process of configuring Windows machines. It provides a straightforward and efficient way to manage and apply system settings, making it easier than ever to automate your perfect setup on a fresh install through a single command line.

## Features

- **Effortless Configuration:** Winforge offers a user-friendly approach to configuring Windows machines, reducing complexity and saving time.
- **Single-Line Deployment:** Customise parameters so you can deploy your system settings through a single line.
- **Automation:** Automate repetitive tasks and ensure consistency across your Windows infrastructure.
- **No-Download:** No need to download and install, just remote execute and include your own URL's to your own configuration files.
- **Open Source:** Winforge is open-source and available for you to use, modify, and contribute to.

## Getting Started

To get started with Winforge, ensure that you are able to run Powershell scripts on your system:

Open powershell as administrator and run the following command:

``set-executionpolicy bypass``

## Running the Script

You can execute the script remotely by running the following:

``irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge.ps1 | iex``

## Running the Script w/ Parameters

The best part about WinForge is you can design your own single-line command to run on any Windows machine. Simply replace any of the options in the parameters below with your own URL's or options [Parameter options listed below].

Refer to the **Paramater Options** and modify the parameter options to your own config files, urls, options and wallpaper.

Use the following format to run the script remotely:

``& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge.ps1))) -theme dark -wallpaper "https://images.pexels.com/photos/2478248/pexels-photo-2478248.jpeg" -wallpaperStyle 'fill' -computerName "WinForgePC" -settings "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -apps "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json -activate yes"``

### Parameter Options
- **theme:** (Options: light, dark, 1, 2) - 1 = light theme, 2 = dark theme - Choose an option to apply your preferred theme, or remove parameter to skip
- **wallpaper:** (Example: [https://imageurl.com/mywallpaper.jpg](https://imageurl.com/mywallpaper.jpg)) - Choose a URL to apply your wallpaper from, or remove parameter to skip
- **wallpaperStyle:** (Options: fill, fit, stretch, tile, center) - choose the style for displaying the wallpaper - must be selected if wallpaper parameter is used
- **computerName:** (Example: "WinForge PC" - use quotes for names with spaces, or remove parameter to skip
- **settings:** URL to O&O ShutUp configuration file - feel free to use the one listed, or remove parameter to skip
- **apps:** URL to Winget import file (JSON format) - refer to GitHub for layout, or don't use parameter to skip
- **activate:** (Options: Yes, No, Y, N) - Activate Windows with Mass Activation Scripts (MAS), or remove parameter to skip

## Creating Your Own Apps Configuration

To create your own apps configuration do the following:
- Goto [Winstall.app](https://winstall.app/), and create your own custom app list
- Export your applist as json file
- Upload to your JSON applist file to your own Github, Google Drive, Dropbox, or other cloud storage provider
- Share a public link and replace the URL in the **-apps* option 

## Creating your own Settings Configuration.

- Download [O&OShutu10](https://www.oo-software.com/en/shutup10)
- Change your settings to how you like your windows to be configured
- Export your configuration to the .CFG file
- Upload to your .CFG file to your own Github, Google Drive, Dropbox, or other cloud storage provider
- Share a public link and replace the URL in the **-settings* option with your own

## License
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

This project is licensed under the [MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.

## Fork It

Feel free to fork it and make it your own!

## Acknowledgments

- Special thanks to [MassGrave](https://github.com/massgravel) for their work on (MAS).

**Disclaimer:**

- This script incorporates no code from Mass Activation scripts; all code is remotely executed from the [Microsoft-Activation-Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts) GitHub repository.
- We expressly disclaim any responsibility for the code contained outside of this GitHub repository.
- The use of this script is at your sole risk. We assume zero liability for any legal consequences or implications arising from its use or the use of any scripts that are remotely executed by this script.


## More Information

For more information, visit our website: [Your Website](https://www.yourwebsite.com).

Enjoy configuring Windows with ease using Winforge!
