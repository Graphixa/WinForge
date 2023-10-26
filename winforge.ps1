# Winforge PowerShell Configuration Script

param (
    [int]$theme,
    [string]$background,
    [string]$settings,
    [string]$computerName,
    [string]$apps
)

# You can call your winforge.ps1 script with the parameters as follows:
# . .\winforge.ps1 -theme 0 -background '#555555' -settings "www.list.com/settings.json" -computerName "Bob's PC" -apps "www.list.com/myapplist.json"


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

function Import-RegistrySettingsFromFile {
    if (-not $settings) {
        $settings = Read-Host "Path to settings file URL (Enter nothing to skip)"

        if (-not [string]::IsNullOrEmpty($settings)) {

            # The user entered a path, so proceed with calling your script.
            Get-Content $settings | ForEach-Object {
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
            Pause 3
            
        }
        else {
            # The user entered nothing, so skip calling your script.
            Write-Host "Script skipped."
        }

    }
}

function Import-Settings {
    # Example usage:
    # Import-RegistrySettings -settings "https://raw.githubusercontent.com/graphixa/winforge/main/config.cfg"

    param (
        [string]$settings
    )

    if (-not [string]::IsNullOrEmpty($settings)) {
        try {
            # Use Invoke-RestMethod to fetch the file contents
            $settingsContent = Invoke-RestMethod -Uri $settings

            # Process the contents of the configuration file
            $settingsContent | ForEach-Object {
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
            Pause 3
        }
        catch {
            Write-Host "An error occurred while fetching or processing the configuration file: $_"
        }
    }
    else {
        # The user entered nothing, so skip calling your script.
        Write-Host "Script skipped."
    }
}




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

# Function to set theme [ Light / Dark Mode ]
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

# Function to set computer name
function Set-ComputerName {
    if (-not $computerName) {
        $computerName = Read-Host "Set your Computer Name:"

    }
    Write-Host "Setting computer name..."
    
    try {
        Rename-Computer -NewName $computerName -Force
    }
    catch {
        Write-Host "Error:" $_.Exception.Message -ForegroundColor Red
    }
    
}
    
# Function to install applications
function Install-Apps {
    # Add your application installation logic here
    Write-Host "Installing applications..."
}
    
# Function to set desktop background
function Set-DesktopBackground {
    # Add your desktop background setting logic here
    Write-Host "Setting desktop background..."
}
    
# Function to set Windows taskbar colors
function Set-TaskbarColors {
    # Add your taskbar color setting logic here
    Write-Host "Setting Windows taskbar colors..."

}
    
# Function to deploy everything
function DeployAll {
    Set-Checkpoint
    Set-Theme
    Set-ComputerName
    Import-RegistrySettings
    Install-Apps
    Set-DesktopBackground
    Set-TaskbarColors
    Write-Host "Everything has been deployed."
}