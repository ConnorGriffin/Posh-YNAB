function Get-YnabBudget {
    [CmdletBinding(DefaultParameterSetName='List')]
    param(
        # Return details for a specific budget or list of budgets by name.
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Detail')]
        [String[]]$Budget,

        # Return a list of budgets rather than details for a specific budget.
        [Parameter(ParameterSetName='List')]
        [Switch]$ListAll,

        # YNAB API token.
        [Parameter(Mandatory,
                   Position=1)]
        $Token
    )

    begin {
        Write-Verbose "Get-YnabBudget.ParameterSetName: $($PsCmdlet.ParameterSetName)"
        
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token

        # Get all budgets here so we don't repeat it for each $Budget 
        if ($PsCmdlet.ParameterSetName -eq 'Detail') {
            $budgets = Get-YnabBudget -ListAll -Token $Token
        }
    }

    process {
        # Perform a recursive lookup, filtering by name and then looking up by ID
        switch ($PsCmdlet.ParameterSetName) {
            'List' {
                # Return a list of budgets if no ID is specified or if ListAvailable is supplied
                $response = Invoke-RestMethod "$uri/budgets" -Headers $header
                if ($response) {
                    $response.data.budgets.ForEach{
                        [PSCustomObject]@{
                            Budget = $_.name
                            LastModified = [datetime]::ParseExact($_.last_modified_on, $dateFormat, $null).ToLocalTime()
                            FirstMonth = [datetime]::ParseExact($_.first_month,'yyyy-MM-dd',$null)
                            LastMonth = [datetime]::ParseExact($_.last_month,'yyyy-MM-dd',$null)
                            DateFormat = $_.date_format.format
                            CurrencyFormat = [Ordered]@{
                                ISOCode = $_.currency_format.iso_code
                                ExampleFormat = $_.currency_format.example_format
                                DecimalDigits = $_.currency_format.decimal_digits
                                DecimalSeparator = $_.currency_format.decimal_separator
                                SymbolFirst = $_.currency_format.symbol_first
                                GroupSeparator = $_.currency_format.group_separator
                                CurrencySymbol = $_.currency_format.currency_symbol
                                DisplaySymbol = $_.currency_format.display_symbol
                            }
                            BudgetID = $_.id
                        }
                    }
                }
            }
            'Detail' {
                # Return details of each provided Budget
                foreach ($budgetName in $Budget) {
                    $budgetId = $budgets.Where{$_.Budget -eq $budgetName}.BudgetID
                    $response = Invoke-RestMethod "$uri/budgets/$budgetId" -Headers $header
                    if ($response) {
                        $budgetData = $response.data.budget
                        $accounts = Get-ParsedAccountJson $budgetData.accounts
                        $payees = Get-ParsedPayeeJson $budgetData.payees $budgetData.payee_locations
                        $transactions = Get-ParsedTransactionJson $budgetData.transactions $budgetData.subtransactions -ParsedPayee $payees
                        [PSCustomObject]@{
                            Budget = $budgetData.name
                            LastModified = [datetime]::ParseExact($budgetData.last_modified_on, $dateFormat, $null).ToLocalTime()
                            FirstMonth = [datetime]::ParseExact($budgetData.first_month,'yyyy-MM-dd',$null)
                            LastMonth = [datetime]::ParseExact($budgetData.last_month,'yyyy-MM-dd',$null)
                            DateFormat = $budgetData.date_format.format
                            CurrencyFormat = [PSCustomObject]@{
                                ISOCode = $budgetData.currency_format.iso_code
                                ExampleFormat = $budgetData.currency_format.example_format
                                DecimalDigits = $budgetData.currency_format.decimal_digits
                                DecimalSeparator = $budgetData.currency_format.decimal_separator
                                SymbolFirst = $budgetData.currency_format.symbol_first
                                GroupSeparator = $budgetData.currency_format.group_separator
                                CurrencySymbol = $budgetData.currency_format.currency_symbol
                                DisplaySymbol = $budgetData.currency_format.display_symbol
                            }
                            Accounts = $accounts
                            Payees = $payees
                            Transactions = $transactions
                            BudgetID = $budgetData.id
                            <# TODO: Implement:
                            Categories =
                            'Category Groups' =
                            Months =
                            'Scheduled Transactions' = (scheduled subtransactions under this)
                            #>
                        }
                    }
                }
            }
        }
    }
}
