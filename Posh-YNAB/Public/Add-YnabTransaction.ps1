function Add-YnabTransaction {
    <#
    .SYNOPSIS
    Adds a transaction to YNAB.
    .DESCRIPTION
    Adds a transaction to YNAB.
    .EXAMPLE
    Add-YnabTransaction -Budget 'TestBudget' -Account 'Checking' -Category 'Food' -Memo 'Coffee' -Outflow 3.50 -Token $ynabToken
    Adds a transaction to TestBudget with the specified account, category, memo, and outflow.
    .EXAMPLE
    Add-YnabTransaction -Budget 'TestBudget' -Account 'Checking' -Category 'Food' -Memo 'Coffee' -Outflow 3.50 -Token $ynabToken -StoreAs 'Coffee'
    Adds a transaction to TestBudget with the specified account, category, memo, and outflow.
    Stores the transaction as a preset called 'Coffee' (see: Add-YnabTransactionPreset).
    .EXAMPLE
    Add-YnabTransaction -PresetName 'Coffee'
    Adds a transaction to YNAB using the settings from the 'Coffee' transaction preset (see: Get-YnabTransactionPreset).
    .EXAMPLE
    Add-YnabTransaction -PresetName 'Coffee' -Inflow 3.50 -Memo 'Refund' -StoreAs 'Coffee Refund'
    Adds a transaction to YNAB using the settings from the 'Coffee' transaction preset, but overrides the existing amount and memo, then stores the new details as 'Coffee Refund'.
    #>
    [CmdletBinding(DefaultParameterSetName='NoPreset,Outflow')]
    param(
        # The name of the preset to load (see: Add-YnabTransactionPreset).
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset')]
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Outflow')]
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Inflow')]
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Amount')]
        [String[]]$Preset,

        # The name of the budget to add the transaction to.
        [Parameter(Position=1,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset')]
        [Parameter(Mandatory,
                   Position=1,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Outflow')]
        [Parameter(Mandatory,
                   Position=1,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Inflow')]
        [Parameter(Mandatory,
                   Position=1,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Amount')]
        [String]$Budget,

        # The name of the account to add the transaction to.
        [Parameter(Position=2,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset')]
        [Parameter(Mandatory,
                   Position=2,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Outflow')]
        [Parameter(Mandatory,
                   Position=2,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Inflow')]
        [Parameter(Mandatory,
                   Position=2,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Amount')]
        [String]$Account,

        # The name of the payee to add the transaction to.
        [Parameter(Position=3,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset')]
        [Parameter(Mandatory,
                   Position=3,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Outflow')]
        [Parameter(Mandatory,
                   Position=3,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Inflow')]
        [Parameter(Mandatory,
                   Position=3,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Amount')]
        [String]$Payee,

        # The name of the category to add the transaction to.
        [Parameter(Position=4,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset')]
        [Parameter(Mandatory,
                   Position=4,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Outflow')]
        [Parameter(Mandatory,
                   Position=4,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Inflow')]
        [Parameter(Mandatory,
                   Position=4,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Amount')]
        [String]$Category,

        # Memo for the transaction.
        [Parameter(Position=5,
                   ValueFromPipelineByPropertyName)]
        [String]$Memo,

        # Outflow amount for the transaction.
        # Uses absolute value, so a positive or negative number can be provided.
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Outflow')]
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Outflow')]
        [Double]$Outflow,

        # Inflow amount for the transaction.
        # Uses absolute value, so a positive or negative number can be provided.
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Inflow')]
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Inflow')]
        [Double]$Inflow,

        # Amount for the transaction. Negative = Outflow, Positive = Inflow
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Amount')]
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='NoPreset,Amount')]
        [Double]$Amount,

        # Date for the trarnsaction. 
        # Defaults to today.
        [Parameter(Position=7,
                   ValueFromPipelineByPropertyName)]
        [Datetime]$Date = (Get-Date),

        # YNAB API token.
        [Parameter(Position=8,
                   ValueFromPipelineByPropertyName)]
        $Token,

        # Flag color for the transaction.
        [Parameter(Position=9,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Red','Orange','Yellow','Green','Blue','Purple')]
        [String]$FlagColor,

        # If specified the transaction will be marked as CLeared.
        [Parameter(Position=10,
                   ValueFromPipelineByPropertyName)]
        [Switch]$Cleared,

        # If specified the transaction will be marked as Approved.
        # Defaults to $true.
        [Parameter(Position=11,
                   ValueFromPipelineByPropertyName)]
        [Bool]$Approved=$true,

        # Preset name to save the transaction as, allowing the transaction details to be re-used with the Preset parameter (see: Add-YnabTransactionPreset).
        [Parameter(Position=12,
                   ValueFromPipelineByPropertyName)]
        [String]$StoreAs
    )

    begin {
        if ($Token) {$header = Get-Header $Token}
    }

    process {
        # Load presets and perform a recursive run if a $Preset is specified
        if ($Preset) {
            foreach ($presetName in $Preset) {
                $presetParams = (Get-YnabTransactionPreset $presetName).Value
                if (!$presetParams) {
                    Write-Error "Preset $presetName could not be found in $profilePath\Presets.xml"
                } else {
                    # Override preset data with values for any provided named parameters
                    if ($Budget) {$presetParams.Budget = $Budget}
                    if ($Account) {$presetParams.Account = $Account}
                    if ($Payee) {$presetParams.Payee = $Payee}
                    if ($Category) {$presetParams.Category = $Category}
                    if ($Memo) {$presetParams.Memo = $Memo}
                    if ($Outflow) {
                        $presetParams.Remove('Inflow')
                        $presetParams.Remove('Amount')
                        $presetParams.Outflow = $Outflow
                    } elseif ($Inflow) {
                        $presetParams.Remove('Outflow')
                        $presetParams.Remove('Amount')
                        $presetParams.Inflow = $Inflow
                    } elseif ($Amount) {
                        $presetParams.Remove('Inflow')
                        $presetParams.Remove('Outflow')
                        $presetParams.Amount = $Amount
                    }
                    if ($Date) {$presetParams.Date = $Date}
                    if ($Token) {$presetParams.Token = $Token}
                    if ($FlagColor) {$presetParams.FlagColor = $FlagColor}
                    if ($Cleared) {$presetParams.Cleared = $Cleared}
                    if ($Approved) {$presetParams.Approved = $Approved}
                    if ($StoreAs) {$presetParams.StoreAs = $StoreAs}

                    Add-YnabTransaction @presetParams
                }
            }
        } else {
            # Get the budget details
            if (!$Budget) {
                $Budget = Read-Host 'Budget'
            }
            $budgets = [Array](Get-YnabBudget -ListAll -Token $Token)
            $budgetId = ([Array]$budgets).Where{$_.Budget -like $Budget}.BudgetID

            # Get the account details
            if (!$Account) {
                $Account = Read-Host 'Account'
            }
            $accounts = [Array](Get-YnabAccount -Budget $Budget -Token $Token)
            $accountId = $accounts.Where{$_.Account -eq $Account}.AccountID

            # Get the category details
            if (!$Category) {
                $Category = Read-Host 'Category'
            }
            $categories = [Array]((Get-YnabCategory -List -Budget $Budget -Token $Token).Categories)
            $categoryId = $categories.Where{$_.Category -like $Category}.CategoryID

            # Set Amount if Outflow or Inflow is provided, use negative or positive absolute value respectively
            if ($Outflow) {
                $Amount = -[Math]::Abs($Outflow)
            } elseif ($Inflow) {
                $Amount = [Math]::Abs($Inflow)
            } elseif (!$Amount) {
                # If none are provided, prompt for an outflow amount
                $Amount = -[Math]::Abs((Read-Host 'Outflow'))
            }

            # Prompt for token if none has been provided
            if (!$Token) {
                $Token = Read-Host 'Token'
            }

            # Setup the POST body
            $body = @{
                transaction = @{
                    account_id = $accountId
                    date = $Date.ToString('yyyy-MM-dd')
                    amount = $Amount * 1000
                    category_id = $categoryId
                    approved = $Approved
                }
            }

            # Add the optionbal parameters
            if ($Payee) {$body.transaction.payee_name = $Payee}
            if ($Memo) {$body.transaction.memo = $Memo}
            if ($Cleared) {$body.transaction.cleared = 'cleared'}
            if ($FlagColor) {$body.transaction.flag_color = $FlagColor.ToLower()}

            $response = Invoke-RestMethod "$uri/budgets/$budgetId/transactions" -Headers $header -Body ($body | ConvertTo-Json) -Method 'POST'

            # Return parsed details
            if ($response) {
                Get-ParsedTransactionJson $response.data.transaction
            }

            # Save the Preset if StoreAs is provided
            if ($StoreAs) {
                $params = $PSBoundParameters
                [Void]$params.Remove('StoreAs')

                Add-YnabTransactionPreset -Preset $StoreAs @params
            }
        }
    }
}
