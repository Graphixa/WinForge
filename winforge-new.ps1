#Requires -RunAsAdministrator


param (
    [switch]$bypass,
    [string]$theme,
    [string]$checkpoint,
    [string]$computerName,
    [string]$wallpaper,
    [string]$wallpaperStyle,
    [string]$settings,
    [string]$apps,
    [string]$appDefaults,
    [string]$activate
)

<#
.DESCRIPTION
You can call your winforge.ps1 script with the parameters as follows:
. .\winforge.ps1 -theme 0 -wallpaper '#555555' -wallpaperStyle 'fill' -settings "www.list.com/settings.json" -computerName "Bob-PC" -apps "www.list.com/myapplist.json"

.EXAMPLE
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge.ps1))) -checkpoint "Yes" -theme light -wallpaper "https://images.pexels.com/photos/2478248/pexels-photo-2478248.jpeg" -wallpaperStyle 'fill' -computerName "TestPC" -settings "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -apps "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json -appDefaults "https://raw.githubusercontent.com/Graphixa/WinForge/main/defaultapps.xml" -activate yes"
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge.ps1))) -checkpoint "No" -theme dark -wallpaper "https://images.pexels.com/photos/3075993/pexels-photo-3075993.jpeg" -wallpaperStyle 'fill' -computerName "Winforge-1" -settings "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -apps "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json -appDefaults "https://raw.githubusercontent.com/Graphixa/WinForge/main/defaultapps.xml" -activate no" 
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge-new.ps1))) -checkpoint "Yes" -theme dark -wallpaper "https://images.pexels.com/photos/2478248/pexels-photo-2478248.jpeg" -wallpaperStyle 'fill' -computerName "WinForgePC" -settings "https://raw.githubusercontent.com/Graphixa/WinForge/main/ooshutup10.cfg" -apps "https://raw.githubusercontent.com/Graphixa/WinForge/main/applist.json -appDefaults "https://raw.githubusercontent.com/Graphixa/WinForge/main/defaultapps.xml" -activate yes"
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Graphixa/WinForge/main/winforge-new.ps1))) -checkpoint "Yes" -theme dark -wallpaper "https://images.pexels.com/photos/2478248/pexels-photo-2478248.jpeg" -wallpaperStyle 'fill' -computerName "WinForgePC" -bypass

.PARAMETER -bypass
    The -bypass switch parameter allows you to run the script without any user prompts or checks. 

    When included, it allows for a streamlined execution, bypassing all parameter prompts and enabling the script to run without requiring additional user input. 
    This functionality is particularly useful for advanced users aiming to automate specific aspects of the script while excluding others. 
    
    Example: Users might choose to utilize -checkpoint, -apps, and -theme options while avoiding other modifications and this can be done by including -bypass in the scriptblock.
    Exercise caution and use this option only if you are confident in the script's content, having thoroughly reviewed its functionality.

.PARAMETER -theme
    The theme parameter allows you to specify the desired color theme.
    Options: light, dark, 1, or 2. (1 = light theme, 2 = dark theme)

.PARAMETER -wallpaper
    The wallpaper parameter allows you to set the background image from a remote URL or imagehost.
    Example: https://imageurl.com/mywallpaper.jpg or leave blank to skip.

.PARAMETER -wallpaperStyle
    Provide the wallpaper style for your desktop background (Required if you include the -wallpaper parameter)
    Options: Fill, Fit, Stretch, Tile, Center, or Span.

.PARAMETER -computerName
    The computerName parameter sets the computer name.
    Example: "Paul PC".

    Always use quotes, especially when using spaces in your PC name. Alternatively, use the -bypass switch to avoid prompting for an input.
    Please note that Windows does not support certain characters in computer names. To avoid errors, refrain from using the following characters: ' < > : " / \ | ? *'

.PARAMETER -settings
    The settings parameter allows you to provide a URL to your O&O ShutUp configuration file.
    Feel free to use the default one or use the -bypass switch to avoid prompting for an input.

.PARAMETER -apps
    The apps parameter allows you to specify a URL to your Winget import file (JSON format).
    Check GitHub for the layout of the JSON file. Alternatively, use the -bypass switch to avoid prompting for an input.

.PARAMETER -appDefaults
    The appDefaults parameter allows you to specify a URL to an XML file containing default app associations. 
    Use the predefined associations file from WinForge or provide a custom DISM export file in XML format. 
    
    For more information on the required XML schema, refer to:
    https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/export-or-import-default-application-associations

.PARAMETER -checkpoint
    The checkpoint parameter allows you to create a system restore point.
    Options: Yes, No, Y, or N. Enter Yes to create a system restore point (Highly recommended) or No to skip.

.PARAMETER -activate
    The activate parameter allows you to activate Windows using massgrave's Mass Activation Scripts (MAS).
    Options: Yes, No, Y, or N. Enter Yes or No to select whether you want to activate Windows using MAS.
#>

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

=========================================

    _ _ _ _     _____                 
   | | | |_|___|   __|___ ___ ___ ___ 
   | | | | |   |   __| . |  _| . | -_|
   |_____|_|_|_|__|  |___|_| |_  |___|
                             |___|

=========================================
     Get Ready to Forge Your System!
=========================================
     

"@

    Pause
}

function Set-Checkpoint {

    if ($checkpoint.ToLower() -eq "yes") {
        $checkpoint = "Y"
    }
    
    if ($checkpoint.ToLower() -eq "no") {
        $checkpoint = "N"
    }

    if ([string]::IsNullOrEmpty($checkpoint)) {

        if ($bypass) {
            Return
        }

        do {
            Clear-Host
            Write-Host "Do you want to create a system restore point?" -ForegroundColor Yellow
            Write-Host "[Not required, but advisable]" -ForegroundColor Gray
            Write-Host ""
            Write-Host "[Y] Yes"
            Write-Host "[N] No"
            Write-Host ""
            $checkpoint = Read-Host "Enter your choice (Y/N)"
            $checkpoint = $checkpoint.ToUpper()  # Convert to uppercase for case-insensitive comparison
            if ($checkpoint -ne "Y" -and $checkpoint -ne "N") {
                Clear-Host
                Write-Host "Invalid choice. Please select a valid option (Y/N)." -ForegroundColor Red
                Start-Sleep 2
            }
        } while ($checkpoint -ne "Y" -and $checkpoint -ne "N")

    }
    
    if ([string]::IsNullOrEmpty($checkpoint) -or ($checkpoint -eq "N")) {
        # The user entered nothing, so skip setting the computer name.
        Clear-Host
        Write-Host "Creation of system restore point skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Return
    }

    if ($checkpoint -eq "Y") {
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
}

function Set-ComputerName {
    
    if ([string]::IsNullOrEmpty($computerName)) {
        
        if ($bypass) {
            Return
        }

        Clear-Host
        Write-Host "Set a computer name [Leave blank to skip]"
        $computerName = Read-Host "Computer Name:"

    }

    if ([string]::IsNullOrEmpty($computerName)) {
        # The user entered nothing, so skip setting the computer name.
        Clear-Host
        Write-Host "Set computer name skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Return
    }
    
    if (-not [string]::IsNullOrEmpty($computerName)) {
        try {
            Clear-Host
            Write-Host "Setting computer name now..."
            Rename-Computer -NewName $computerName -Force
            Start-Sleep 2
        }
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }

        Clear-Host
        Write-Host "Computer name set to: " -NoNewline -ForegroundColor Yellow
        Write-Host $computerName -NoNewline -ForegroundColor White
        Start-Sleep 2
    }
}

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

    if ($theme -eq "Light") {
        $theme = 1  # Light Mode
    }
    if ($theme -eq "Dark") {
        $theme = 0  # Dark Mode
    }

    if ([string]::IsNullOrEmpty($theme)) {

        if ($bypass) {
            Return
        }
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
                    $theme = "1"  # Light Mode
                }
                "2" {
                    $theme = "0"  # Dark Mode
                }
                Default {
                    Clear-Host
                    Write-Host "Invalid choice. Please select a valid number (1-2)." -ForegroundColor Red
                    Start-Sleep 3
                }
            }
        } while ($choice -ne "1" -and $choice -ne "2")
    } 

    if ([string]::IsNullOrEmpty($theme)){
        # The user entered nothing, so skip setting the computer name.
        Clear-Host
        Write-Host "Theme setting skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Return
    }

    if (-not [string]::IsNullOrEmpty($theme)) {
    
        try {
            Clear-Host
            Write-Host "Setting theme..." -ForegroundColor Yellow
            Start-Sleep 2
            Set-RegistryProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value $theme -PropertyType 'Dword' | Out-Null
            Stop-Process -Name explorer -Force
            Start-Process explorer

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
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
    }
 
}

function Set-WallPaper {

    <#

    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER wallpaper
    Provide the exact path to the image
 
    .PARAMETER wallpaperStyle
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
  
#>


    if ([string]::IsNullOrEmpty($wallpaper) -or -not ($wallpaper -match '^https?://')) {
    
        if ($bypass) {
            Return
        }

        do {
            Clear-Host
            Write-Host "Paste a URL for your wallpaper or press [Enter] to skip:" -ForegroundColor Yellow
            Write-Host "Example: https://images.pexels.com/photos/2246476/pexels-photo-2246476.jpeg" -ForegroundColor Gray
            Write-Host ""
            $wallpaper = Read-Host "Wallpaper URL" 
    
            if (-not [string]::IsNullOrEmpty($wallpaper) -and $wallpaper -match '^https?://') {
                break  # Exit the loop if a valid URL is provided
            }
            else {
                Write-Host "Invalid URL. Please enter a valid URL." -ForegroundColor Red
                Start-Sleep -Seconds 2  # Sleep for 2 seconds before looping again
            }
        } while ($true)
    }

    # 2nd Check of $wallpaper variable - if still empty, skips the function entirely.
    if ([string]::IsNullOrEmpty($wallpaper)) {
    
        # The user entered nothing, so skip setting the wallpaper.
        Clear-Host
        Write-Host "Wallpaper import skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Return      
    }

    if ([string]::IsNullOrEmpty($wallpaperStyle) -or $wallpaperStyle.ToLower() -notin @('fit', 'fill', 'stretch', 'tile', 'centre', 'span')) {

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
                "1" { $wallpaperStyle = "fit" }
                "2" { $wallpaperStyle = "fill" }
                "3" { $wallpaperStyle = "stretch" }
                "4" { $wallpaperStyle = "tile" }
                "5" { $wallpaperStyle = "centre" }
                "6" { $wallpaperStyle = "span" }
                Default {
                    Clear-Host
                    Write-Host "Invalid choice. Please select a valid number (1-6)." -ForegroundColor Red
                    Start-Sleep 3
                    $StyleChoice = $null
                }
            }
        } while (-not $StyleChoice)
    
        Clear-Host
        Write-Host "Wallpaper Style: " -NoNewline -ForegroundColor Yellow
        Write-Host $wallpaperStyle.ToUpper() -ForegroundColor White
        Start-Sleep 2
    }

    if (-not [string]::IsNullOrEmpty($wallpaper) -and $wallpaper -match '^https?://') {
    
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
  
            "fill" { "10" }
            "fit" { "6" }
            "stretch" { "2" }
            "tile" { "0" }
            "center" { "0" }
            "span" { "22" }
  
        }
 
        if ($Style -eq "Tile") {
 
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $style -Force | Out-Null
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force | Out-Null
 
        }
        else {
 
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $style -Force | Out-Null
            New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force | Out-Null
 
        }
 
        try {
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

        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
        
    }

       
}

function Install-Apps {

    if ([string]::IsNullOrEmpty($apps) -or -not ($apps -match '^https?://')) {
        $choiceMade = $false

        if ($bypass) {
            Return
        }

        while (-not $choiceMade) {
            Clear-Host
            Write-Host "Do you want to install apps on the system?" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "[1] - Use WinForge default app list " -NoNewline
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
                    $choiceMade = $true
                }
                default {
                    Write-Host "Invalid choice. Please choose 1, 2, or 3." -ForegroundColor Red
                    Pause
                }
            }
        }
    }

    if ([string]::IsNullOrEmpty($apps)){
        # The user entered nothing, so skip installing apps.
        Clear-Host
        Write-Host "Apps installation skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Return
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

}

function Import-DefaultAppSettings {

    if ([string]::IsNullOrEmpty($appDefaults) -or -not ($appDefaults -match '^https?://')) {
        $choiceMade = $false

        if ($bypass) {
            Return
        }

        while (-not $choiceMade) {
            Clear-Host
            Write-Host "Do you want change the default app associations?" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "[1] - Use WinForge default app associations " -NoNewline
            Write-Host "| https://raw.githubusercontent.com/Graphixa/WinForge/main/defaultapps.xml" -ForegroundColor Gray
            Write-Host "[2] - Specify your own URL " -NoNewline
            Write-Host "| Must be a DISM export file in XML format" -ForegroundColor Gray
            Write-Host "[3] - Skip " -NoNewline
            Write-Host "| Skip changing default app associations" -ForegroundColor Gray
            Write-Host ""
            $choice = Read-Host "Choose an option [1-3]"

            switch ($choice) {
                1 {
                    $appDefaults = "https://raw.githubusercontent.com/Graphixa/WinForge/main/defaultapps.xml"
                    $choiceMade = $true
                }
                2 {
                    Clear-Host
                    $customUrl = Read-Host "Enter the URL to your custom JSON file"
                    if ($customUrl -match "\.xml$") {
                        $appDefaults = $customUrl
                        $choiceMade = $true
                    }
                    else {
                        Write-Host "The URL must point to a XML file with the proper windows associations schema." -ForegroundColor Red
                        Write-Host "More info: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/export-or-import-default-application-associations" -ForegroundColor Red
                        Pause
                    }
                }
                3 {
                    $choiceMade = $true
                }
                default {
                    Write-Host "Invalid choice. Please choose 1, 2, or 3." -ForegroundColor Red
                    Pause
                }
            }
        }
    }

    if ([string]::IsNullOrEmpty($appDefaults)){
        # The user entered nothing, so skip installing apps.
        Clear-Host
        Write-Host "Setting of default app associations skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Return
    }

    # 2nd Check of $apps variable - if still empty, skips the function entirely.
    if (-not [string]::IsNullOrEmpty($appDefaults)) {
       
        try {
            # Download Applist file from remote URL
            $TempDownloadPath = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $appDefaults -Leaf)
            
            # Use Invoke-RestMethod to fetch the file contents
            Invoke-RestMethod -Uri $appDefaults -OutFile $TempDownloadPath

            Clear-Host
            Write-Host "Setting default app associations..." -ForegroundColor Yellow
            
            Powershell.exe -executionpolicy remotesigned -Command dism /online /Import-DefaultAppAssociations:"$TempDownloadPath\defaultassociations.xml" -Wait -PassThru | Out-Null
        }

        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Pause
        }
    }

}

function Import-Settings {

    if ([string]::IsNullOrEmpty($settings) -or -not ($settings -match '^https?://')) {
        $choiceMade = $false
        
        if ($bypass) {
            Return
        }

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
    if ([string]::IsNullOrEmpty($settings)) {
        # The user entered nothing, so skip calling your script.
        Clear-Host
        Write-Host "Settings import skipped." -ForegroundColor Yellow
        Start-Sleep 2
        Return
    }

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
}

function Import-RegistrySettings {

    # CURRENTLY UNUSED

    if ([string]::IsNullOrEmpty($RegistrySettings) -or -not ($RegistrySettings -match '^https?://')) {

        if ($bypass) {
            Return
        }
        Clear-Host
        Write-Host "URL to your registry settings file (JSON format) or leave blank to skip"
        Write-Host "Check Github for the registry settings file layout example" -ForegroundColor Gray
        Write-Host
        $RegistrySettings = Read-Host "URL"
    }
    
    if ([string]::IsNullOrEmpty($RegistrySettings)){
      # The user entered nothing, so skip calling your script.
      Clear-Host
      Write-Host "Settings import skipped."
      Start-Sleep 2
      Return
    }
    
    if (-not [string]::IsNullOrEmpty($registrysettings)) {
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
}

function Install-MAS {

    if ($activate -eq "yes") {
        $activate = "Y"
    }
    if ($activate -eq "no") {
        $activate = "N"
    }

    if ([string]::IsNullOrEmpty($activate)) {

        if ($bypass) {
            Return
        }

        do {
            Clear-Host
            Write-Host "Do you want to activate Windows using Microsoft Activation Scripts (MAS)?" -ForegroundColor Yellow
            Write-Host "[Maintained by massgrave: https://github.com/massgravel/Microsoft-Activation-Scripts]" -ForegroundColor Gray
            Write-Host ""
            Write-Host "[Y] Yes"
            Write-Host "[N] No"
            Write-Host ""
            $activate = Read-Host "Enter your choice (Y/N)"
            $activate = $activate.ToUpper()  # Convert to uppercase for case-insensitive comparison
            if ($activate -ne "Y" -and $activate -ne "N") {
                Clear-Host
                Write-Host "Invalid choice. Please select a valid option (Y/N)." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        } while ($activate -ne "Y" -and $activate -ne "N")
    }

    if (([string]::IsNullOrEmpty($activate)) -or ($activate -eq "N")) {      
        Write-Host "Activation Scripts skipped."
        Start-Sleep 2
        Return
    }
    
    if ($activate -eq "Y") {
        

        try {
            irm https://massgrave.dev/get | iex
        }
    
        catch {
            Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
            Write-Host ""
            Write-host "There was a problem executing the Mass Activation Scripts"
            Write-host "Goto https://massgrave.dev/ for more information and troubleshooting"
            Pause
            Return
        }
   
    }
}

function DeployAll {
    Show-ASCIIArt
    Set-Checkpoint
    Set-ComputerName
    Set-Theme
    Set-WallPaper
    Install-MAS
    Import-Settings
    Install-Apps
    Import-DefaultAppSettings
    
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