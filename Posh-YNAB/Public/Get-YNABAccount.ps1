function Get-YNABAccount {
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
    [CmdletBinding(DefaultParameterSetName='List')]
    param(
        [Parameter(Mandatory=$true)]
        [String]$Token,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true)]
        [String[]]$BudgetID,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='Detail')]
        [String[]]$AccountID,

        [Parameter(ParameterSetName='List')]
        [Switch]$ListAll
    )

    begin {
        # Set the default header value for Invoke-RestMethod
        $header =  Get-Header $Token
        $dateFormat = 'yyyy-MM-ddTHH:mm:ss+00:00'
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'List' {
                # Return a list of accounts in each budget
                $BudgetID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$_/accounts" -Headers $header
                    $response
                }
            }
            'Detail' {
                # Return account details for each account in each budget
                $BudgetID.ForEach{
                    $budget = $_
                    $AccountID.ForEach{
                        $response = Invoke-RestMethod "$uri/budgets/$budget/$_" -Headers $header
                        $response
                    }
                }
            }
        }
    }
}
