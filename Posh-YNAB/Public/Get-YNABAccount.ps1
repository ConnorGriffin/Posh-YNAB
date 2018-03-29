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

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetName,AccountName')]
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetName,AccountID')]
        [String]$BudgetName,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetID,AccountName')]
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetID,AccountID')]
        [String]$BudgetID,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetName,AccountName')]
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetID,AccountName')]
        [String[]]$AccountName,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetName,AccountID')]
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetID,AccountID')]
        [String[]]$AccountID,

        [Parameter(ParameterSetName='List')]
        [Switch]$ListAll
    )

    begin {
        # Set the default header value for Invoke-RestMethod
        $header =  Get-Header $Token
    }

    process {
        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'List' {
                # Return a list of accounts in each budget
                $BudgetID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$_/accounts" -Headers $header
                    if ($response) {
                        Get-ParsedAccountJson $response.data.accounts
                    }
                }
            }
            'Detail*' {
                # Set the paramaters based on the provided values, using parametersets to make sure we don't get conflicting variables
                $params = @{}
                if ($BudgetName) {$params.BudgetName = $BudgetName}
                elseif ($BudgetID) {$params.BudgetID = $BudgetID}
                if ($AccountName) {$params.AccountName = $AccountName}
                elseif ($AccountID) {$params.AccountID = $AccountID}

                # Return account details for each AccountID specified
                $AccountID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$budget/accounts/$_" -Headers $header
                    if ($response) {
                        Get-ParsedAccountJson $response.data.account
                    }
                }
            }
        }
    }
}
