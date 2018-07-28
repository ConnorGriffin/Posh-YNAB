function Get-YnabTransaction {
    <#
    .SYNOPSIS
    List YNAB transactions.
    .DESCRIPTION
    List YNAB transactions.
    .EXAMPLE
    Get-YnabTransaction -Budget 'TestBudget'
    Lists all transactions for TestBudget.
    .EXAMPLE
    Get-YnabTransaction -Budget 'TestBudget' -Type unapproved -SinceDate 2018-04-15
    Lists all unapproved transactions for TestBudget since April 4 2018.
    .EXAMPLE
    GetYnabTransaction -Budget 'TestBudget' -Account 'Checking','Cash' -Category 'Dining'
    Lists all Dining transactions made from the Checking or Cash accounts for TestBudget.
    #>

    [CmdletBinding(DefaultParameterSetName='Unfiltered')]
    param(
        # The budget to list transactions from.
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Budget,

        # The account or accounts to select transactions from.
        [Parameter(Position=1,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Filtered')]
        [string[]]$Account,

        # The category or categories to select transactions from.
        [Parameter(Position=2,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Filtered')]
        [string[]]$Category,

        # The payee or payees to select transactions from.
        [Parameter(Position=3,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Filtered')]
        [string[]]$Payee,

        # Only return transactions of a certain type (‘uncategorized’ and ‘unapproved’ are currently supported)
        [Parameter(ParameterSetName='Filtered')]
        [Parameter(ParameterSetName='Unfiltered')]
        [ValidateSet('uncategorized', 'unapproved')]
        [string]$Type,

        # Only return transactions on or after this date.
        [Parameter(ParameterSetName='Filtered')]
        [Parameter(ParameterSetName='Unfiltered')]
        [datetime]$SinceDate,

        # Return details for a transaction or list of transactions by ID.
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='TransactionID')]
        [string[]]$TransactionID,

        # Return the raw JSON data from the YNAB API. Only query parameters will be applied.
        [Parameter(DontShow,
                   ParameterSetName='Unfiltered')]
        [switch]$NoParse,

        # YNAB API token.
        [Parameter(Mandatory,
                   Position=1,
                   ValueFromPipelineByPropertyName)]
        $Token
    )

    begin {
        if ($Token) {$header = Get-Header $Token}
    }

    process {
        # Get the budget ID from the name
        $budgets = [Array](Get-YnabBudget -ListAll -Token $Token)
        $budgetId = ([Array]$budgets).Where{$_.Budget -like $Budget}.BudgetID

        # Build the URL query from the query parameters (only on supported parameter sets)
        if ($SinceDate -or $Type -and $PSCmdlet.ParameterSetName -ne 'TransactionID') {
            $queryItems = @()
            if ($SinceDate) {
                $queryItems += "since_date=$($SinceDate.ToString('yyyy-MM-dd'))"
            }
            if ($Type) {
                $queryItems += "type=$type"
            }
            $query = "?$($queryItems -join '&')"
        }

        # Perform the query based on parameter set
        switch ($PSCmdlet.ParameterSetName) {
            'Unfiltered' {
                # Get the transactions
                $response = Invoke-RestMethod -Uri "$uri/budgets/$budgetId/transactions$query" -Headers $header -Method Get
                $transactions = $response.data.transactions
            }
            'Filtered' {
                # Get the transactions for each account specified
                if ($Account) {
                    $transactions = foreach ($accountName in $Account) {
                        $accounts = [Array](Get-YnabAccount -Budget $Budget -Token $Token)
                        $accountId = $accounts.Where{$_.Account -eq $accountName}.AccountID
                        $response = Invoke-RestMethod -Uri "$uri/budgets/$budgetId/accounts/$accountId/transactions$query" -Headers $header -Method Get
                        $response.data.transactions
                    }

                    # Flag that we've attempted to pull transactions
                    $attempted = $true
                }

                # Get the transactions for each category unless another transaction pull already ran and returned no results
                if ($Category) {
                    if ($attempted -and $transactions) {
                        # If we've already pulled results from the API, just compare to those to avoid extra API calls
                        $transactions = $transactions.Where{$_.category_name -in $Category}
                    } elseif (!$attempted) {
                        # If we haven't made any API calls yet, pull the transactions
                        $transactions = foreach ($categoryName in $Category) {
                            $categories = [Array]((Get-YnabCategory -Budget $Budget -Token $Token).Categories)
                            $categoryId = $categories.Where{$_.Category -eq $categoryName}.CategoryID
                            $response = Invoke-RestMethod -Uri "$uri/budgets/$budgetId/categories/$categoryId/transactions$query" -Headers $header -Method Get
                            $response.data.transactions
                        }
                    }

                    # Flag that we've attempted to pull transactions
                    $attempted = $true
                }

                # Get the transactions for each payee unless another transaction pull already ran and returned no results
                if ($Payee) {
                    if ($attempted -and $transactions) {
                        # If we've already pulled results from the API, just compare to those to avoid extra API calls
                        $transactions = $transactions.Where{$_.payee_name -in $Payee}
                    } elseif (!$attempted) {
                        # If we haven't made any API calls yet, pull the transactions
                        $transactions = foreach ($payeeName in $Payee) {
                            $payees = [Array](Get-YnabPayee -Budget $Budget -Token $Token)
                            $payeeId = $payees.Where{$_.Payee -eq $payeeName}.PayeeID
                            $response = Invoke-RestMethod -Uri "$uri/budgets/$budgetId/payees/$payeeId/transactions$query" -Headers $header -Method Get
                            $response.data.transactions
                        }
                    }
                }

                Remove-Variable 'attempted'

            }
            'TransactionID' {
                foreach ($id in $TransactionID) {
                    # Get the transactions
                    $response = Invoke-RestMethod -Uri "$uri/budgets/$budgetId/transactions/$id" -Headers $header -Method Get
                    $transactions = $response.data.transaction
                }
            }
        }

        # Return the transaction details
        if ($transactions) {
            if (!$NoParse) {
                Get-ParsedTransactionJson $transactions
            } else {
                $transactions
            }
        }
    }
}
