# Get public and private function definition files.
$functions = Get-ChildItem -Path $PSScriptRoot\*\*.ps1 -ErrorAction SilentlyContinue

# Dot source the files
$functions.FullName.ForEach{
    try {. $_}
    catch {Write-Error -Message "Failed to import function $_"}
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
$allFunctions = ('Get-YNABBudget','Get-YNABAccount','Get-YNABCategory','Get-YNABUser','Set-YNABDefaults')
$budgetFunctions = @('Get-YNABBudget','Get-YNABAccount')
$tokenFunctions = @('Get-YNABBudget','Get-YNABAccount','Get-YNABUser')

# Import the config, if one has been set
if (Test-Path "$profilePath\Defaults.xml") {
    $defaults = Import-Clixml "$profilePath\Defaults.xml"
    $BudgetName= $defaults.GetEnumerator().Where{$_.Name -eq 'BudgetName'}.Value
    $BudgetID = $defaults.GetEnumerator().Where{$_.Name -eq 'BudgetID'}.Value
    $Token = $defaults.GetEnumerator().Where{$_.Name -eq 'Token'}.Value

    # Set module parameter defaults
    $allFunctions.ForEach{
        $parameters = (Get-Command $_).Parameters

        if ($BudgetName -and $parameters.BudgetName) {
            $global:PSDefaultParameterValues["${_}:BudgetName"] = $BudgetName
        }
        if ($BudgetID -and $parameters.BudgetID) {
            $global:PSDefaultParameterValues["${_}:BudgetID"] = $BudgetID
        }
        if ($Token -and $parameters.Token) {
            $global:PSDefaultParameterValues["${_}:Token"] = $Token
        }
    }
}
