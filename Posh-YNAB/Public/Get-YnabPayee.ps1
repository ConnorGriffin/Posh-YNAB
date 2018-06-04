function Get-YnabPayee {
    [CmdletBinding(DefaultParameterSetName='List')]
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [String]$Budget,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Detail')]
        [String[]]$Payee,

        [Parameter(ParameterSetName='List')]
        [Switch]$ListAll,

        [Switch]$IncludeLocation,

        # Return the raw JSON data from the YNAB API.
        [Parameter(DontShow)]
        [Switch]$NoParse,

        [Parameter(Mandatory)]
        $Token
    )

    begin {
        Write-Verbose "Get-YnabPayee.ParameterSetName: $($PsCmdlet.ParameterSetName)"
        $header = Get-Header $Token
    }

    process {
        # Get the IDs of the budget and all payees
        $budgets = [Array](Get-YnabBudget -ListAll -Token $Token)
        $budgetId = $budgets.Where{$_.Budget -eq $Budget}.BudgetID
        $payees = Invoke-RestMethod "$uri/budgets/$BudgetID/payees" -Headers $header

        if ($payees) {
            switch ($PsCmdlet.ParameterSetName) {
                'List' {
                    # Perform a payee location lookup if -Location is provided
                    if ($IncludeLocation) {
                        $locations = Invoke-RestMethod "$uri/budgets/$budgetId/payee_locations" -Headers $header
                    }
                    Get-ParsedPayeeJson $payees.data.payees $locations.data.payee_locations -IncludeLocation:$IncludeLocation -NoParse:$NoParse
                }
                'Detail' {
                    foreach ($payeeName in $Payee) {
                        $payeeData = $payees.data.payees.Where{$_.Name -eq $payeeName}
                        # Perform a payee location lookup if -IncludeLocation is provided
                        if ($IncludeLocation) {
                            $locations = Invoke-RestMethod "$uri/budgets/$budgetId/payees/$_/payee_locations" -Headers $header
                        }
                        Get-ParsedPayeeJson $payeeData $locations.data.payee_locations -IncludeLocation:$IncludeLocation -NoParse:$NoParse
                    }
                }
            }
        }
    }
}
