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
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='BudgetName')]
        [String]$BudgetName,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='BudgetID')]
        [String]$BudgetID,

        $Token
    )

    begin {
        Write-Verbose "Set-YNABDefaults.ParameterSetName: $($PsCmdlet.ParameterSetName)"

        # Encrypt the token if it is of type String
        if ($Token.GetType().Name -eq 'String') {
            $Token = $Token | ConvertTo-SecureString -AsPlainText -Force
        }

        $data = $PSBoundParameters
        $data.Token = $Token
    }

    process {
        # Export the provided parameters for the module import to read them later
        $data | Export-Clixml "$profilePath\Defaults.xml"

        # Re-import the module to reload the defaults
        Import-Module "$moduleRoot\$moduleName.psm1" -Global -Force
    }
}
