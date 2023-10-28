#Requires -RunAsAdministrator

param (
    [string]$theme,
    [string]$computerName,
    [string]$wallpaper,
    [string]$wallpaperStyle,
    [string]$settings,
    [string]$apps
)


# You can call your winforge.ps1 script with the parameters as follows:
# . .\winforge.ps1 -theme 0 -wallpaper '#555555' -wallpaperStyle 'fill' -settings "www.list.com/settings.json" -computerName "Bob's PC" -apps "www.list.com/myapplist.json"

#REMOTE USAGE
# & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge.ps1))) -theme light -wallpaper "https://images.pexels.com/photos/2478248/pexels-photo-2478248.jpeg" -wallpaperStyle 'fill' -computerName "JeecfefC" -settings "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -apps "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json"
# & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge.ps1))) -theme dark -wallpaper "https://images.pexels.com/photos/3075993/pexels-photo-3075993.jpeg" -wallpaperStyle 'fill' -computerName "Piggy1" -settings "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -apps "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json"

# Parameter Options
# ------------------
# theme: - 1 for light theme, 2 for dark theme
# wallpaper: https://imageurl.com/mywallpaper.jpg or leave blank to skip
# computerName: "Bob PC" always use "" especially when using a space in your pc name, alternatively leave blank to skip
# settings: Add a url to your O&O shutup configuration file, feel free to use the default one or alternatively leave blank to skip
# apps: Add a url to your JSON file, check GitHub for layout of JSON file, alternatively leave blank to skip

function Set-RegistryProperty {
    # Example usage: Set-RegistryProperty -Path 'HKCU:\Software\Example' -Name 'SampleValue' -Value 'NewValue' -PropertyType 'String'

    param (
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [string]$PropertyType = "String"
    )

    if (Test-Path $Path) {
        # Registry entry exists, so set its value
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $PropertyType
        Write-Host "Registry entry '$Name' updated with value '$Value'."
    }
    else {
        # Registry entry doesn't exist, create it
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType
        Write-Host "Registry entry '$Name' created with value '$Value'."
    }
}

function Show-ASCIIArt {
    @"

------------------------------------

 _ _ _ _     _____                 
| | | |_|___|   __|___ ___ ___ ___ 
| | | | |   |   __| . |  _| . | -_|
|_____|_|_|_|__|  |___|_| |_  |___|
                          |___|

------------------------------------
      Forge Your Own System!
------------------------------------                          
     
"@

    Pause
}

function Set-Checkpoint {
    do {
        Clear-Host
        Write-Host "Do you want to create a system restore point?" -ForegroundColor Yellow
        Write-Host "[Not required, but advisable]" -ForegroundColor Gray
        Write-Host ""
        Write-Host "[Y] Yes"
        Write-Host "[N] No"
        Write-Host ""
        $choice = Read-Host "Enter your choice (Y/N)"
        $choice = $choice.ToUpper()  # Convert to uppercase for case-insensitive comparison
        if ($choice -ne "Y" -and $choice -ne "N") {
            Clear-Host
            Write-Host "Invalid choice. Please select a valid option (Y/N)." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } while ($choice -ne "Y" -and $choice -ne "N")

    if ($choice -eq "Y") {
        Clear-Host
        Write-Host "Creating a system restore point..."
  
        try {
            Enable-ComputerRestore -Drive "$env:systemdrive"
            Checkpoint-Computer -Description "Winforge Customization" -RestorePointType "MODIFY_SETTINGS" -Verbose
            Clear-Host
            Write-Host "System checkpoint created..." -ForegroundColor Yellow
            Start-Sleep 2
           
        }
    
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
            Return
        }
        
    }
    elseif ($choice -eq "N") {
        Clear-Host
        Write-Host "System restore point creation skipped." -ForegroundColor Yellow
        Start-Sleep 2
    }
}

function Set-ComputerName {
    if ([string]::IsNullOrEmpty($computerName)) {
        $computerName = Read-Host "Set your Computer Name:"

    }
    Write-Host ""
    Write-Host "Setting computer name now..."
    
    try {
        Rename-Computer -NewName $computerName -Force
        Start-Sleep 3
    }
    catch {
        Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Pause
    }
    Clear-Host
    Write-Host "Computer name set to: " -NoNewline -ForegroundColor Yellow
    Write-Host $computerName -NoNewline -ForegroundColor White
    Start-Sleep 4
}

## DONE >>
function Set-Theme {
    <#
.SYNOPSIS
Sets the theme (Light Mode or Dark Mode) for the current user in Windows.

.DESCRIPTION
This function allows you to set the theme for the current user in Windows. You can choose between Light Mode and Dark Mode.

.PARAMETER theme
Specify the theme to set. You can use "Light" for Light Mode or "Dark" for Dark Mode. If not provided, the function will prompt you to choose a theme interactively.

.EXAMPLE
# Set the theme to Light Mode
Set-Theme -theme "Light" or Set-Theme Light

# Set the theme to Dark Mode
Set-Theme -theme "Dark" or Set-Theme Dark
#>

    # [CmdletBinding()]
    # param (
    #     [string]$theme
    # )

    if ($theme -eq "Light") {
        $theme = 1  # Light Mode
    }
    elseif ($theme -eq "Dark") {
        $theme = 0  # Dark Mode
    }
    else {
        if (([string]::IsNullOrEmpty($theme)) -or ($theme -ne "Dark") -or ($theme -ne "Light")) {
            do {
                Clear-Host
                Write-Host "Choose a theme option:" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "[1] Light Mode"
                Write-Host "[2] Dark Mode"
                Write-Host ""
                $choice = Read-Host "Enter the number corresponding to your choice (1-2)"

                switch ($choice) {
                    "1" {
                        $theme = 1  # Light Mode
                    }
                    "2" {
                        $theme = 0  # Dark Mode
                    }
                    Default {
                        Clear-Host
                        Write-Host "Invalid choice. Please select a valid number (1-2)." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                    }
                }
            } while ($choice -ne "1" -and $choice -ne "2")
        }
    }
    
    Clear-Host
    Write-Host "Setting theme..." -ForegroundColor Yellow
    Start-Sleep 2
    Set-RegistryProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value $theme -PropertyType 'Dword'
    Stop-Process -Name explorer -Force
    Start-Process -Name explorer

    $themeChoice = if ($theme -eq 1) {
        "Light Mode"
    }
    else {
        "Dark Mode"
    }
    Clear-Host
    Write-Host "Theme Setting: " -NoNewline -ForegroundColor Yellow
    Write-Host $themeChoice -NoNewline -ForegroundColor White
    Start-Sleep 2
}

Function Set-WallPaper {
 
<#

    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER wallpaper
    Provide the exact path to the image
 
    .PARAMETER wallpaperStyle
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
  
#>

    if ([string]::IsNullOrEmpty($wallpaper)) {

        Clear-Host
        Write-Host "Paste a URL for your wallpaper or press [Enter] to skip:" -ForegroundColor Yellow
        Write-Host "Example: https://images.pexels.com/photos/2246476/pexels-photo-2246476.jpeg" -ForegroundColor Gray
        Write-Host ""
        $wallpaper = Read-Host "Wallpaper URL" 
    }

    # 2nd Check of $wallpaper variable - if still empty, skips the function entirely.
    if (-not [string]::IsNullOrEmpty($wallpaper)) {

        if ([string]::IsNullOrEmpty($wallpaperStyle)) {

            do {
                Clear-Host
                Write-Host "Choose your wallpaper style (1-6):"
                Write-Host "[1] - Fit"
                Write-Host "[2] - Fill"
                Write-Host "[3] - Stretch"
                Write-Host "[4] - Tile"
                Write-Host "[5] - Centre"
                Write-Host "[6] - Span"
                Write-Host ""
                $StyleChoice = Read-Host "Enter the number corresponding to your choice"
                
                switch ($StyleChoice) {
                    "1" { $wallpaperStyle = "Fit" }
                    "2" { $wallpaperStyle = "Fill" }
                    "3" { $wallpaperStyle = "Stretch" }
                    "4" { $wallpaperStyle = "Tile" }
                    "5" { $wallpaperStyle = "Centre" }
                    "6" { $wallpaperStyle = "Span" }
                    Default {
                        Clear-Host
                        Write-Host "Invalid choice. Please select a valid number (1-6)." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                        $StyleChoice = $null
                    }
                }
            } while (-not $StyleChoice)
                
            Clear-Host
            Write-Host "Wallpaper Style: " -NoNewline -ForegroundColor Yellow
            Write-Host $wallpaperStyle -ForegroundColor White
            Start-Sleep 2
        }

        # Download Wallpaper from URL
        try {
            
            Clear-Host
            Write-Host "Importing wallpaper..." -ForegroundColor Yellow
            Write-Host ""
            Start-Sleep 2

            $WallpaperFolder = "$HOME\Pictures\Wallpapers"

            # Check if the folder exists, and if not, create it
            if (-not (Test-Path $WallpaperFolder)) {
                New-Item -Path $WallpaperFolder -ItemType Directory -Force | Out-Null
            }
            
            $WallpaperDownloadPath = Join-Path -Path $WallpaperFolder -ChildPath (Split-Path -Path $wallpaper -Leaf)
                        
            # Use Invoke-RestMethod to fetch the file contents
            Invoke-RestMethod -Uri $wallpaper -OutFile $wallpaperDownloadPath
            
        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }

        $Style = Switch ($WallpaperStyle) {
  
            "Fill" { "10" }
            "Fit" { "6" }
            "Stretch" { "2" }
            "Tile" { "0" }
            "Center" { "0" }
            "Span" { "22" }
  
        }
 
        If ($Style -eq "Tile") {
 
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $style -Force | Out-Null
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force | Out-Null
 
        }
        Else {
 
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $style -Force | Out-Null
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force | Out-Null
 
        }
 
        Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
        $SPI_SETDESKWALLPAPER = 0x0014
        $UpdateIniFile = 0x01
        $SendChangeEvent = 0x02
  
        $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
        $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperDownloadPath, $fWinIni)

        Clear-Host
        Write-Host "Wallpaper import complete..." -ForegroundColor Yellow
        Start-Sleep 2
    }
    else {
        # The user entered nothing, so skip setting the wallpaper.
        Clear-Host
        Write-Host "Wallpaper import skipped..." -ForegroundColor Yellow
        Start-Sleep 2
    }
}        

function Install-Apps {

    if ([string]::IsNullOrEmpty($apps)) {
        $choiceMade = $false

        while (-not $choiceMade) {
            Clear-Host
            Write-Host "Do you want to install apps on the system?" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "[1] - Use default app list " -NoNewline
            Write-Host "| https://winstall.app/packs/hEZLyyrSB" -ForegroundColor Gray
            Write-Host "[2] - Specify your own URL " -NoNewline
            Write-Host "| Must be a winget import file in JSON format" -ForegroundColor Gray
            Write-Host "[3] - Skip " -NoNewline
            Write-Host  -NoNewline
            Write-Host "| Don't install any apps" -ForegroundColor Gray
            Write-Host ""
            $choice = Read-Host "Choose an option [1-3]"

            switch ($choice) {
                1 {
                    $apps = "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json"
                    $choiceMade = $true
                }
                2 {
                    Clear-Host
                    $customUrl = Read-Host "Enter the URL to your custom JSON file"
                    if ($customUrl -match "\.json$") {
                        $apps = $customUrl
                        $choiceMade = $true
                    }
                    else {
                        Write-Host "The URL must point to a JSON file with the proper winget import schema." -ForegroundColor Red
                        Pause
                    }
                }
                3 {
                    Write-Host "Skipping app installation."
                    $choiceMade = $true
                }
                default {
                    Write-Host "Invalid choice. Please choose 1, 2, or 3." -ForegroundColor Red
                    Pause
                }
            }
        }
    }

    # 2nd Check of $apps variable - if still empty, skips the function entirely.
    if (-not [string]::IsNullOrEmpty($apps)) {
        try {
            # Download Applist file from remote URL
            $TempDownloadPath = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $apps -Leaf)
            
            # Use Invoke-RestMethod to fetch the file contents
            Invoke-RestMethod -Uri $apps -OutFile $TempDownloadPath

            Clear-Host
            Write-Host "Installing applications..." -ForegroundColor Yellow
            
            #echo Y | winget list | Out-Null  # uses old Alias 'echo' removed for future compatability
            Write-Output Y | winget list | Out-Null
            winget import --import-file $TempDownloadPath --ignore-versions --no-upgrade --accept-package-agreements --accept-source-agreements --disable-interactivity
        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
    }
    else {
        # The user entered nothing, so skip installing apps.
        Clear-Host
        Write-Host "Apps installation skipped..." -ForegroundColor Yellow
        Start-Sleep 2
    }
}

<# Old Version that didn't use Winget Import
function Install-Apps {
    param (
        [string]$apps
    )

    if (-not $apps) {
        $apps = Read-Host "Specify the URL to your JSON file containing the list of apps:"
    }
        
    if ([string]::IsNullOrEmpty($apps)) {
        try {

            # Fetch the list of apps from GitHub
            $jsonContent = Invoke-RestMethod -Uri $apps

            # Create the $wingetapps array
            $wingetapps = @()

            # Add the apps from the JSON file to the array
            $wingetapps += $jsonContent

            # Output the $wingetapps array for verification
            $wingetapps

            Write-Host "Installing applications..."

          # We need to interact with winget and accept the source agreements
          # before we're able to actually use it. So, just a random search
          # command will work.
          # winget search Microsoft.WindowsTerminal --accept-source-agreements
            echo Y | winget list | Out-Null

            foreach ($wingetapp in $wingetapps) {
                winget install -e --accept-source-agreements --accept-package-agreements --id $wingetapp
            }
        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
    }
}
#>

function Import-Settings {
    # Example usage:
    # Import-RegistrySettings -settings "https://raw.githubusercontent.com/graphixa/winforge/main/config.cfg"

    if ([string]::IsNullOrEmpty($settings)) {
        $choiceMade = $false

        while (-not $choiceMade) {
            Clear-Host
            Write-Host "Do you want to import O&OShutup10 Configuration?" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "[1] - Use default configuration " -NoNewline
            Write-Host "| https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -ForegroundColor Gray
            Write-Host "[2] - Specify your own URL " -NoNewline
            Write-Host "| Must be a O&OShutup Configuration file in CFG format" -ForegroundColor Gray
            Write-Host "[3] - Skip " -NoNewline
            Write-Host  -NoNewline
            Write-Host "| Don't import any settings configuration file" -ForegroundColor Gray
            Write-Host ""
            $choice = Read-Host "Choose an option [1-3]"

            switch ($choice) {
                1 {
                    $settings = "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg"
                    $choiceMade = $true
                }
                2 {
                    Clear-Host
                    $customUrl = Read-Host "Enter the URL to your custom O&OShutup10 Configuration (.cfg) file"
                    if ($customUrl -match "\.cfg$") {
                        $settings = $customUrl
                        $choiceMade = $true
                    }
                    else {
                        Write-Host "The URL must point to a (.cfg) file with the proper O&OShutup10 configuration layout." -ForegroundColor Red
                        Pause
                    }
                }
                3 {
                    Clear-Host
                    Write-Host "Skipping settings configuration import."
                    Start-Sleep 2
                    $choiceMade = $true
                }
                default {
                    Write-Host "Invalid choice. Please choose 1, 2, or 3." -ForegroundColor Red
                    Pause
                }
            }
        }
    }

    # 2nd Check of $settings variable - if still empty, skips the function entirely.
    if (-not [string]::IsNullOrEmpty($settings)) {
        try {
            
            # Download O&OShutUp10
            $url = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
            $fallbackURL = "https://github.com/Graphixa/WinForge/raw/main/OOSU10.exe"
            
            $downloadPath = "$env:TEMP\OOSU10.exe"
        
            try {
                Clear-Host
                Write-Host "Downloading O&O ShutUp10 from the official website..."
                
                try {
                    Invoke-WebRequest -Uri $url -OutFile $downloadPath -UseBasicParsing
                    Clear-Host
                    Write-Host "Download complete..." -ForegroundColor Yellow
                    Start-Sleep 2
                }
                catch {
                    Clear-Host
                    Write-Host "Unable to download from offical website."
                    Write-Host "Attempting to download from Github "
                    Write-Host ""
                    Start-Sleep 2
                    Invoke-WebRequest -Uri $fallbackURL -OutFile $downloadPath -UseBasicParsing
                    Clear-Host
                    Write-Host "Download complete..." -ForegroundColor Yellow
                    Start-Sleep 2
                }             
            }
            catch {
                Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            }


            # Set Configuration Download Path
            $OOShutup10Config = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $settings -Leaf)
            
            # Use Invoke-RestMethod to fetch the file contents
            Invoke-RestMethod -Uri $settings -OutFile $OOShutup10Config

            Clear-Host
            Write-Host "Configuring settings now..." -ForegroundColor Yellow
            Start-Sleep 2
            
            # Define the installation command with silent options and install
            $installArguments = "$OOShutup10Config /quiet /nosrp"  
            Start-Process -FilePath $downloadPath -ArgumentList $installArguments -Wait
                    
            Write-Host "Setting configuration import complete."

        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
    }
    else {
        # The user entered nothing, so skip calling your script.
        Clear-Host
        Write-Host "Settings import skipped." -ForegroundColor Yellow
        Start-Sleep 2
    }
}

function Import-RegistrySettingsOLD {
    # Example usage:
    # Import-RegistrySettings -settings "https://raw.githubusercontent.com/graphixa/winforge/main/config.cfg"

    param (
        [string]$settings
    )
    if (-not $settings) {
        $settings = Read-Host "URL to your settings file:"
    }
        
    if ([string]::IsNullOrEmpty($settings)) {
        try {
            
            # Use Invoke-RestMethod to fetch the file contents
            $settingsContent = Invoke-RestMethod -Uri $settings

            # The user entered a path, so proceed with calling your script.
            Get-Content $settingsContent | ForEach-Object {
                $line = $_.Trim()
                if ($line -ne "" -and $line -match '^"([^"]+)" -Name "([^"]+)" -Value (.+)$') {
                    $path = $matches[1]
                    $name = $matches[2]
                    $value = $matches[3]

                    if (-not (Test-Path $path)) {
                        # Create the registry key (folder) if it doesn't exist
                        New-Item -Path $path
                    }

                    Set-ItemProperty -Path $path -Name $name -Value $value
                    Write-Host "Updated: $path\$name"
                }
            }
            Write-Host "Registry settings have been updated."
            Start-Sleep 2
        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
    }
    else {
        # The user entered nothing, so skip calling your script.
        Write-Host "Settings import skipped."
        Start-Sleep 2
    }
}

function DeployAll {
    Show-ASCIIArt
    Set-Checkpoint
    Set-Theme
    Set-WallPaper
    Set-ComputerName
    Install-Apps
    Import-Settings  
}

DeployAll

Clear-Host
Write-Host @"

        =======================
           WINFORGE COMPLETE  
        =======================

⠀⠀⠀⠀⠀⠀⠀⢰⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡄⠀⠀⠀⠀⠀
⠀⠹⣿⣿⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢠⣄⡀⠀⠀
⠀⠀⠙⢿⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⣿⡶⠀
⠀⠀⠀⠀⠉⠛⠇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠸⠟⠋⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣶⣶⣶⣶⣶⣶⣶⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣀⣀⣈⣉⣉⣉⣉⣉⣉⣉⣉⣉⣉⣉⣉⣉⣉⣁⣀⣀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀

           Thanks for Using

               -------

          Github.com/graphixa

"@
Write-Host ""
Pause