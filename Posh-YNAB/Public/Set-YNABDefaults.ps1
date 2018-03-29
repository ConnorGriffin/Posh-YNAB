function Set-YNABDefaults {
    <#
    .SYNOPSIS
    Describe the function here
    .DESCRIPTION
    Describe the function in more detail
    .EXAMPLE
    Give an example of how to use it
    .EXAMPLE
    Give another example of how to use it
    .PARAMETER computername
    The computer name to query. Just one.
    .PARAMETER logname
    The name of a file to write failed computer names to. Defaults to errors.txt.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByName')]
        [String]$BudgetName,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByID')]
        [String]$BudgetID,

        [String]$Token
    )

    begin {}

    process {
        # Set module parameter defaults. This is also done on module import once this command has been run once.
        if ($BudgetName) {
            $budgetFunctions.ForEach{
                $global:PSDefaultParameterValues["${_}:BudgetName"] = $BudgetName
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

        # Export the provided parameters for the module import to read them later
        $MyInvocation.BoundParameters | Export-Clixml "$profilePath\Defaults.xml"
    }
}
