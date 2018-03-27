function Set-DefaultBudget {
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
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String]$ID
    )

    begin {}

    process {
        # Output the budget ID
        $ID | Out-File "$profilePath\DefaultBudget.txt" -Force

        # Set default parameters for the rest of the script functions
        $global:PSDefaultParameterValues.Remove('Get-Budget:ID')
        $global:PSDefaultParameterValues += @{
            'Get-Budget:ID' = $ID
        }
    }
}
