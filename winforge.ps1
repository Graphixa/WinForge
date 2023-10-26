# Winforge PowerShell Configuration Script

param (
    [int]$theme,
    [string]$background,
    [string]$settings,
    [string]$computerName,
    [string]$apps
)

# You can call your winforge.ps1 script with the parameters as follows:
# . .\winforge.ps1 -theme 0 -background '#555555' -computerName "Bob's PC" -apps "www.list.com/myapplist.json"


# Example usage of the parameters
Write-Host "Theme: $theme"
Write-Host "Background: $background"
Write-Host "Computer Name: $computerName"
Write-Host "Apps: $apps"


# SET REGISTRY ENTRIES FUNCTION
# Example usage: Set-RegistryProperty -Path 'HKCU:\Software\Example' -Name 'SampleValue' -Value 'NewValue' -PropertyType 'String'
function Set-RegistryProperty {

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
    } else {
        # Registry entry doesn't exist, create it
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType
        Write-Host "Registry entry '$Name' created with value '$Value'."
    }
}



    # Function to install registry settings
    function Install-RegistrySettings {
        # Add your registry settings installation logic here
        Write-Host "Installing registry settings..."
    }
    
    # Function to set computer name
    function Set-ComputerName {
        # Add your computer name setting logic here
        Write-Host "Setting computer name..."
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
    function Deploy-Everything {
        Install-RegistrySettings
        Set-ComputerName
        Install-Apps
        Set-DesktopBackground
        Set-TaskbarColors
        Write-Host "Everything has been deployed."
    }
    
    # Main menu loop
    while ($true) {
        Clear-Host
        Show-SplashScreen
        Write-Host "Main Menu"
        Write-Host "1. Install Registry Settings"
        Write-Host "2. Set Computer Name"
        Write-Host "3. Install Applications"
        Write-Host "4. Set Desktop Background"
        Write-Host "5. Set Windows Taskbar Colors"
        Write-Host "6. Deploy Everything"
        Write-Host "0. Exit"
    
        $choice = Read-Host "Enter your choice:"
    
        switch ($choice) {
            "1" { Install-RegistrySettings }
            "2" { Set-ComputerName }
            "3" { Install-Apps }
            "4" { Set-DesktopBackground }
            "5" { Set-TaskbarColors }
            "6" { Deploy-Everything }
            "0" { break }
            Default { Write-Host "Invalid choice. Please try again." }
        }
    }