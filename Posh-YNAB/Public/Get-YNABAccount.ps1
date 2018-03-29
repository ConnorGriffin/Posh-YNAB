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
    [CmdletBinding(DefaultParameterSetName='List:BudgetID')]
    param(
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetName,AccountName')]
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetName,AccountID')]
        [Parameter(ParameterSetName='List:BudgetName')]
        [String]$BudgetName,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetID,AccountName')]
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetID,AccountID')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [String]$BudgetID,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetName,AccountName')]
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetID,AccountName')]
        [String[]]$AccountName,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetName,AccountID')]
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetID,AccountID')]
        [String[]]$AccountID,

        [Parameter(Mandatory=$true)]
        [String]$Token,

        [Parameter(ParameterSetName='List:BudgetName')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [Switch]$List
    )

    begin {
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token`
        Write-Verbose "Get-YNABAccount ParameterSetName: $($PsCmdlet.ParameterSetName)"
    }

    process {
        # Get the budget IDs if the budget was specified by name
        if ($BudgetName) {
            Write-Verbose "Performing budget lookup to get BudgetID for $BudgetName"
            $budgets = Get-YNABBudget -List -Token $Token
            $BudgetID = $budgets.Where{$_.Name -like $BudgetName}.BudgetID
            Write-Verbose "Using BudgetID: $BudgetID"
        }

        # Get the account ID if the account was specified by name
        if ($AccountName) {
            $accounts = Get-YNABAccount -List -BudgetID $BudgetID -Token $Token
            $AccountID = $AccountName.ForEach{
                $name = $_
                $accounts.Where{$_.Name -like $name}.AccountID
            }
            Write-Verbose "Using AccountID: $($AccountID -join ', ')"
        }

        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'List*' {
                $response = Invoke-RestMethod "$uri/budgets/$BudgetID/accounts" -Headers $header
                if ($response) {
                    Get-ParsedAccountJson $response.data.accounts
                }
            }
            'Detail*' {
                # Return account details for each AccountID specified
                $AccountID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$BudgetID/accounts/$_" -Headers $header
                    if ($response) {
                        Get-ParsedAccountJson $response.data.account
                    }
                }
            }
        }
    }
}
