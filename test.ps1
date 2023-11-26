# Define the parameters as global variables
param (
    [string]$bypass,
    [string]$export
)

# Define an array of hashtables with parameter, description, validation, and error message (if any)
$paramDescriptions = @(
    @{Name='theme'; Description='Please set your theme:'; Validation='^(Light|Dark|1|0)$'; ErrorMessage='Invalid choice: "Light, Dark"'},
    @{Name='computerName'; Description='Set a computer name [Leave blank to skip]:'},
    @{Name='wallpaper'; Description='Please enter a valid Wallpaper URL:'; Validation='^https?://[\S]+$'; ErrorMessage='Invalid Wallpaper URL format'},
    @{Name='wallpaperStyle'; Description='Please specify the wallpaper style:'; Validation='^(Fill|Fit|Stretch|Tile|Center|Span)$'; ErrorMessage='Invalid option, choose between Fill, Fit, Stretch, Tile, Centre or Span'},
    @{Name='settings'; Description='Please enter a valid Settings URL:'; Validation='^https?://[\S]+$'; ErrorMessage='Invalid Settings URL format'},
    @{Name='apps'; Description='Please enter a valid Apps URL:'; Validation='^https?://[\S]+$'; ErrorMessage='Invalid Apps URL format'},
    @{Name='activate'; Description='Please activate (Y/N/Yes/No):'; Validation='^(Y|N|Yes|No)$'; ErrorMessage='Invalid choice: "Yes or No"'}
)

# Function to display error message
function Show-ErrorMessage {
    param (
        [string]$ErrorMessage
    )
    Write-Host "Error: $ErrorMessage" -ForegroundColor Red
}

# Dynamically create parameters based on the entries in $paramDescriptions
foreach ($param in $paramDescriptions) {
    $paramName = $param.Name
    $paramValidation = $param.Validation
    $paramErrorMessage = $param.ErrorMessage

    # Dynamically create parameters
    Invoke-Expression "param([string]`$$paramName)"
    
    # Check if the parameter is null
    if (-not (Get-Variable -Name $paramName -ValueOnly)) {
        # Prompt the user for input
        do {
            Clear-Host
            $userInput = Read-Host $param.Description
            Set-Variable -Name $paramName -Value $userInput -Scope Global

            if ($paramValidation -and $userInput -notmatch $paramValidation -and $userInput -ne "") {
                Show-ErrorMessage -ErrorMessage $paramErrorMessage
                Pause
            }

            if ($userInput -eq "") {
                Write-Host "$paramName skipped..." -ForegroundColor Yellow
                Start-Sleep 2
            }
            else {
                # Output the value
                Write-Host ""$paramName": $($global:$paramName)"
            }
        } while ($paramValidation -and $userInput -notmatch $paramValidation -and $userInput -ne "")
    }
}

# Output the values (optional)
foreach ($param in $paramDescriptions) {
    $paramName = $param.Name
    Write-Host "$paramName: $($global:$($paramName))" -ForegroundColor White
}
Pause