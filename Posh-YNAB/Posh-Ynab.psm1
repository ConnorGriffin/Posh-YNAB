# Set module-scoped variables used by the module in other places
$parameters = @('Budget','Account','Category','Payee','Preset','Token')
$moduleRoot = $PSScriptRoot
$moduleName = 'Posh-YNAB'
$dateFormat = 'yyyy-MM-ddTHH:mm:ss+00:00'
$uri = 'https://api.youneedabudget.com/v1'

# Define our custom Set-FunctionDefaults function, which sets default parameters and outputs function data to be used elsewhere
function Set-FunctionDefault {
    Param(
        $File,
        $Parameters,
        $Defaults
    )

    $params = @()

    # Add the function to the parameter arrays based on its accepted parameters
    $functionParams = (Get-Command $File.BaseName).Parameters

    # Iterate through the supplied $Parameters
    foreach ($paramName in $Parameters) {
        if ($functionParams.$paramName) {
            # If the parameter is accepted by the function, add it to an array
            $params += $paramName

            # Set the default value for the function:parameter pair if Defaults contains one
            if ($Defaults) {
                $default = $Defaults.GetEnumerator().Where{$_.Name -eq $paramName}.Value
                if ($default) {
                    $global:PSDefaultParameterValues["$($File.BaseName):$paramName"] = $default
                }
            }
        }
    }

    # Return an object with the function and its accepted parameters. This is used by ArgumentCompleters
    [PSCustomObject]@{
        Function = $File.BaseName
        Parameter = $params
    }
}

# Create Profiles path if it does not exist, if it does, try importing the config
$profilePath = "$ENV:APPDATA\PSModules\Posh-YNAB"
if (Test-Path $profilePath) {
    # Import the config, if one has been set
    try {$defaults = Import-Clixml "$profilePath\Defaults.xml"}
    catch {Write-Error "Failed to import $profilePath\Defaults.xml"}
} else {
    New-Item -Path $profilePath -Type Directory | Out-Null
}

# Import public functions first, we'll import private ones later
$publicFunctions = (Get-ChildItem "$PSScriptRoot\Public\*.ps1")
$paramsByFunction = $publicFunctions.ForEach{
    . $_.Fullname
    Set-FunctionDefault $_ $parameters $defaults
    #Export-ModuleMember -Function $_.BaseName
}

# Import private functions, nothing fancy needed here
(Get-ChildItem "$PSScriptRoot\Private\*.ps1").ForEach{
    . $_.FullName
}
