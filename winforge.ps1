#Requires -RunAsAdministrator

param (
    [int]$theme,
    [string]$computerName,
    [string]$wallpaper,
    [string]$wallpaperStyle,
    [string]$settings,
    [string]$apps
)

# You can call your winforge.ps1 script with the parameters as follows:
# . .\winforge.ps1 -theme 0 -wallpaper '#555555' -wallpaperStyle 'fill' -settings "www.list.com/settings.json" -computerName "Bob's PC" -apps "www.list.com/myapplist.json"

# Parameter Options
# ------------------
# theme: - 1 for light theme, 2 for dark theme
# wallpaper: https://imageurl.com/mywallpaper.jpg or leave blank to skip
# computerName: "Bob's PC" always use "" especially when using a space in your pc name, alternatively leave blank to skip
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

# ----------------------------------

function Set-Checkpoint {

    do {
        $choice = Read-Host "Would you like to create a system restore point? [Advisable]"
    } while ($choice -ne "Y" -and $choice -ne "N")

    if ($choice -eq "Y") {
        Write-Host "Creating a system restore point..."
  
        try {
            Enable-ComputerRestore -Drive "$env:systemdrive"
            Checkpoint-Computer -Description "Winforge Customisation" -RestorePointType "MODIFY_SETTINGS" -Verbose
        }
    
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
            Return
        }
    
        Write-Host "System checkpoint created..."
        Start-Sleep 1
    }
  
}

function Set-ComputerName {
    if (-not $computerName) {
        $computerName = Read-Host "Set your Computer Name:"

    }
    Write-Host "Setting computer name now..."
    
    try {
        Rename-Computer -NewName $computerName -Force
        Start-Sleep 1
    }
    catch {
        Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Pause
    }
    Write-Host "Computer name set to: $computerName"
    Start-Sleep 1
    Clear-Host
}

function Set-Theme {
    # Prompt for the theme preferencee if it's not provided as a parameter [1 - Use Light Theme | 0 - Use Dark Theme]
    do {
        $theme = Read-Host "Select your theme: 0 = Dark Theme | 1 = Light Theme"
    } while ($theme -ne "0" -and $theme -ne "1")

    Write-Host "Setting computer theme..."
    Set-RegistryProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value $theme -PropertyType 'Dword'
    Stop-Process -Name explorer -Force
    Start-Process explorer
}

Function Set-WallPaper {
 
<#
 
    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER Image
    Provide the exact path to the image
 
    .PARAMETER Style
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
    .EXAMPLE
    Set-WallPaper wallpaper "C:\Wallpaper\Default.jpg"
    Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
  
#>

 
param (
    [string]$wallpaper,
    # Provide wallpaper style that you would like applied
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$wallpaperStyle
)

if (-not $wallpaper) {
    $wallpaper = Read-Host "Image URL for your desktop background?"
    
}
if (-not [string]::IsNullOrEmpty($wallpaper)) {

    try {
        # Use Invoke-RestMethod to fetch the file contents
        $wallpaperPath = Invoke-RestMethod -Uri $wallpaper -OutFile "$HOME\Pictures\wallpaper.jpg"
    }
    catch {
        Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Pause
    }

 
$Style = Switch ($WallpaperStyle) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $style -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $style -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
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
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaper, $fWinIni)
}
else {
    # The user entered nothing, so skip setting the wallpaper.
    Write-Host "Wallpaper import skipped."
}
    
}

function Set-TaskbarColors {

    Write-Host "Setting Windows taskbar colors..."

}

function Install-Apps {
    param (
        [string]$apps
    )

    if (-not $apps) {
        do {
            Write-Host "What would you like to do?"
            Write-Host "1. Use Default App List - Pack: https://winstall.app/packs/hEZLyyrSB"
            Write-Host "2. Specify your own URL (must be a JSON file with the proper winget import schema)"
            Write-Host "3. Skip (Don't install apps)"
            
            $choice = Read-Host "Enter the number of your choice (1/2/3):"

            switch ($choice) {
                1 {
                    $apps = "https://winstall.app/packs/hEZLyyrSB"
                }
                2 {
                    $customUrl = Read-Host "Enter the URL to your custom JSON file:"
                    if ($customUrl -match "\.json$") {
                        $apps = $customUrl
                    }
                    else {
                        Write-Host "The URL must point to a JSON file with the proper winget import schema." -ForegroundColor Red
                    }
                }
                3 {
                    Write-Host "Skipping app installation."
                }
                default {
                    Write-Host "Invalid choice. Please choose 1, 2, or 3." -ForegroundColor Red
                }
            }
        } while ($choice -ne "1" -and $choice -ne "2" -and $choice -ne "3")
    }

    if (-not [string]::IsNullOrEmpty($apps)) {
        try {
            Write-Host "Installing applications..."
            echo Y | winget list | Out-Null
            winget import --import-file $apps
        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
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
        
    if (-not [string]::IsNullOrEmpty($apps)) {
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

function Import-OOShutupSettings {
    # Example usage:
    # Import-RegistrySettings -settings "https://raw.githubusercontent.com/graphixa/winforge/main/config.cfg"

    param (
        [string]$settings
    )
    if (-not $settings) {
        $settings = Read-Host "URL to your settings file:"
    }
        
    if (-not [string]::IsNullOrEmpty($settings)) {
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
        Start-Sleep 1
    }
}

function DeployAll {
    Set-Checkpoint
    Set-Theme
    Set-TaskbarColors
    Set-ComputerName
    Import-Settings
    Install-Apps
    Set-Desktopwallpaper
    
    Write-Host "Everything has been deployed."
    Pause
}