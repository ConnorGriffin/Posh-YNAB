# Get public and private function definition files.
$functions  = Get-ChildItem -Path $PSScriptRoot\*\*.ps1 -ErrorAction SilentlyContinue

# Dot source the files
$functions.ForEach{
    try {. $_.FullName}
    catch {Write-Error -Message "Failed to import function $($_.FullName)"}
}

# Set module variables
$moduleRoot = $PSScriptRoot
$uri = 'https://api.youneedabudget.com/v1'

# Create Profiles path if it does not exist
$profilePath = "$ENV:APPDATA\PSModules\Posh-YNAB"
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -Type Directory | Out-Null
}

# Import the config, if one has been set
if (Test-Path "$profilePath\DefaultBudget.txt") {
    $defaultBudget = Get-Content "$profilePath\DefaultBudget.txt"

    # Set default parameters for the rest of the script functions
    $global:PSDefaultParameterValues.Remove('Get-Budget:ID')
    $global:PSDefaultParameterValues += @{
        'Get-Budget:ID' = $defaultBudget
    }
}
