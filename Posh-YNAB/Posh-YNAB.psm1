# Get public and private function definition files.
$functions  = Get-ChildItem -Path $PSScriptRoot\*\*.ps1 -ErrorAction SilentlyContinue

# Dot source the files
$functions.ForEach{
    try {. $_.FullName}
    catch {Write-Error -Message "Failed to import function $($_.FullName)"}
}

# Set module variables
$moduleRoot = $PSScriptRoot
$dateFormat = 'yyyy-MM-ddTHH:mm:ss+00:00'
$uri = 'https://api.youneedabudget.com/v1'

# Create Profiles path if it does not exist
$profilePath = "$ENV:APPDATA\PSModules\Posh-YNAB"
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -Type Directory | Out-Null
}

# These are referenced below and in Set-YNABDefaults
$budgetFunctions = @('Get-YNABBudget','Get-YNABAccount','Get-YNABUser')
$tokenFunctions = @('Get-YNABBudget','Get-YNABAccount','Get-YNABUser')

# Import the config, if one has been set
if (Test-Path "$profilePath\Defaults.xml") {
    $defaults = Import-Clixml "$profilePath\Defaults.xml"
    $BudgetID = $defaults.GetEnumerator().Where{$_.Name -eq 'BudgetID'}.Value
    $Token = $defaults.GetEnumerator().Where{$_.Name -eq 'Token'}.Value

    # Set module parameter defaults
    if ($BudgetName) {
        $budgetFunctions.ForEach{
            $global:PSDefaultParameterValues["${_}:BudgetID"] = $BudgetName
        }
    }
    
    if ($BudgetID) {
        $budgetFunctions.ForEach{
            $global:PSDefaultParameterValues["${_}:BudgetID"] = $BudgetID
        }
    }

    if ($Token) {
        $tokenFunctions.ForEach{
            $global:PSDefaultParameterValues["${_}:Token"] = $Token
        }
    }
}
