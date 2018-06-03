function Get-YnabBudget {
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
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName')]
        [String[]]$BudgetName,

        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID')]
        [String[]]$BudgetID,

        [Parameter(ParameterSetName='List')]
        [Switch]$List,

        [Parameter(Mandatory=$true)]
        $Token
    )

    begin {
        Write-Verbose "Get-YnabBudget.ParameterSetName: $($PsCmdlet.ParameterSetName)"
        
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token
    }

    process {
        # If a name is provided, perform a recursive lookup, filtering by name and then looking up by ID
        if ($BudgetName) {
            $budgets = Get-YnabBudget -Token $Token -List
            $budgetId = $budgets.Where{$_.Budget -eq $BudgetName}.BudgetID
        }

        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'List' {
                # Return a list of budgets if no ID is specified or if ListAvailable is supplied
                $response = Invoke-RestMethod "$uri/budgets" -Headers $header
                if ($response) {
                    $budgets = $response.data.budgets
                    $budgets.ForEach{
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
            'Detail*' {
                # Return details of each provided BudgetID
                $BudgetID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$_" -Headers $header
                    if ($response) {
                        $budget = $response.data.budget
                        $accounts = Get-ParsedAccountJson $budget.accounts
                        $payees = Get-ParsedPayeeJson $budget.payees $budget.payee_locations
                        $transactions = Get-ParsedTransactionJson $budget.transactions $budget.subtransactions -ParsedPayee $payees
                        [PSCustomObject]@{
                            Budget = $budget.budget
                            LastModified = [datetime]::ParseExact($budget.last_modified_on, $dateFormat, $null).ToLocalTime()
                            FirstMonth = [datetime]::ParseExact($budget.first_month,'yyyy-MM-dd',$null)
                            LastMonth = [datetime]::ParseExact($budget.last_month,'yyyy-MM-dd',$null)
                            DateFormat = $budget.date_format.format
                            CurrencyFormat = [PSCustomObject]@{
                                ISOCode = $budget.currency_format.iso_code
                                ExampleFormat = $budget.currency_format.example_format
                                DecimalDigits = $budget.currency_format.decimal_digits
                                DecimalSeparator = $budget.currency_format.decimal_separator
                                SymbolFirst = $budget.currency_format.symbol_first
                                GroupSeparator = $budget.currency_format.group_separator
                                CurrencySymbol = $budget.currency_format.currency_symbol
                                DisplaySymbol = $budget.currency_format.display_symbol
                            }
                            Accounts = $accounts
                            Payees = $payees
                            Transactions = $transactions
                            BudgetID = $budget.id
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
