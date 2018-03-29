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

    begin {
        Write-Verbose "ParameterSetName: $($PsCmdlet.ParameterSetName)"
    }

    process {
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

        # Export the provided parameters for the module import to read them later
        $MyInvocation.BoundParameters | Export-Clixml "$profilePath\Defaults.xml"
    }
}
