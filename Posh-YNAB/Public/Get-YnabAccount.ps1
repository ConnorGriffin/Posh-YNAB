function Get-YnabAccount {
    <#
    .SYNOPSIS
        Returns the accounts for a budget.
    .DESCRIPTION
        Returns a single account or list of accounts for a given budget.
    #>
    [CmdletBinding(DefaultParameterSetName='List')]
    param(
        # Name of the budget where the accounts exist.
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipelineByPropertyName)]
        [String]$Budget,

        # Account or list of accounts to get details of. 
        [Parameter(Mandatory,
                   Position=1,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Detail')]
        [String[]]$Account,

        # Include closed accounts in the returned data. 
        [Parameter(ParameterSetName='List')]
        [Switch]$IncludeClosed,

        # Return the raw JSON data from the YNAB API.
        [Parameter(DontShow)]
        [Switch]$NoParse,
        
        # YNAB API token.
        [Parameter(Mandatory,
                   Position=2)]
        $Token
    )

    begin {
        Write-Verbose "Get-YnabAccount.ParameterSetName: $($PsCmdlet.ParameterSetName)"
        
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token
    }

    process {
        # Get the budget and account data
        $budgets = [Array](Get-YNABBudget -ListAll -Token $Token)
        $budgetId = $budgets.Where{$_.Budget -like $Budget}.BudgetID
        $accounts = Invoke-RestMethod "$uri/budgets/$budgetId/accounts" -Headers $header

        switch ($PsCmdlet.ParameterSetName) {
            'List' {
                # Return the full list of accounts
                if ($accounts) {
                    # By default only include open accounts, return closed accounts if -IncludeClosed is specified
                    $data = $accounts.data.accounts.Where{
                        if (!$IncludeClosed) {$_.closed -ne $true}
                        else {$_}
                    }
                    Get-ParsedAccountJson $data -NoParse:$NoParse
                }
            }
            'Detail' {
                # Return account details for each account specified
                foreach ($accountName in $Account) {
                    $data = ([Array]$accounts.data.accounts).Where{$_.Name -eq $accountName}
                    if ($data) {
                        Get-ParsedAccountJson $data -NoParse:$NoParse
                    }
                }
            }
        }
    }
}
