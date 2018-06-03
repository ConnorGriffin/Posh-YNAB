function Add-YnabTransaction {
    <#
    .SYNOPSIS
    Adds a transaction to YNAB.
    .DESCRIPTION
    Adds a transaction to YNAB.
    .EXAMPLE
    Add-YnabTransaction -BudgetName 'TestBudget' -AccountName 'Checking' -CategoryName 'Food' -Memo 'Coffee' -Outflow 3.50 -Token $ynabToken
    Adds a transaction to TestBudget with the specified account, category, memo, and outflow.
    .EXAMPLE
    Add-YnabTransaction -BudgetName 'TestBudget' -AccountName 'Checking' -CategoryName 'Food' -Memo 'Coffee' -Outflow 3.50 -Token $ynabToken -StoreAs 'Coffee'
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
        [String]$Preset,

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
            $presetParams = (Get-YnabTransactionPreset $Preset).Value

            # Override preset data with values for any provided named parameters
            if ($BudgetName) {$presetParams.BudgetName = $BudgetName}
            if ($BudgetID) {$presetParams.BudgetID = $BudgetID}
            if ($AccountName) {$presetParams.AccountName = $AccountName}
            if ($AccountID) {$presetParams.AccountID = $AccountID}
            if ($PayeeName) {$presetParams.PayeeName = $PayeeName}
            if ($PayeeID) {$presetParams.PayeeID = $PayeeID}
            if ($CategoryName) {$presetParams.CategoryName = $CategoryName}
            if ($CategoryID) {$presetParams.CategoryID = $CategoryID}
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
        } else {
            # Get the budget IDs if the budget was specified by name
            if (!$BudgetID) {
                $budgets = Get-YnabBudget -List -Token $Token
                if (!$BudgetName) {
                    $BudgetName = Read-Host 'BudgetName'
                }
                $BudgetID = $budgets.Where{$_.Budget -like $BudgetName}.BudgetID
                Write-Verbose "Using budget: $BudgetID"
            }

            # Get the account ID if the account was specified by name
            if (!$AccountID) {
                $accounts = Get-YnabAccount -List -BudgetID $BudgetID -Token $Token
                if (!$AccountName) {
                    $AccountName = Read-Host 'AccountName'
                }
                $AccountID = $accounts.Where{$_.Account -like $AccountName}.AccountID
                Write-Verbose "Using account: $AccountID"
            }

            # Get the category ID if the category was specified by name
            if (!$CategoryID) {
                $categories = (Get-YnabCategory -List -BudgetID $BudgetID -Token $Token).Categories
                if (!$CategoryName) {
                    $CategoryName = Read-Host 'CategoryName'
                }
                $CategoryID = $categories.Where{$_.Category -like $CategoryName}.CategoryID
                Write-Verbose "Using category: $CategoryID"
            }

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
                    account_id = $AccountID
                    date = $Date.ToString('yyyy-MM-dd')
                    amount = $Amount * 1000
                    category_id = $CategoryID
                    approved = $Approved
                }
            }

            # Add the optionbal parameters
            if ($PayeeID) {$body.transaction.payee_id = $PayeeID}
            elseif ($PayeeName) {$body.transaction.payee_name = $PayeeName}

            if ($Memo) {$body.transaction.memo = $Memo}
            if ($Cleared) {$body.transaction.cleared = 'cleared'}
            if ($FlagColor) {$body.transaction.flag_color = $FlagColor.ToLower()}

            $response = Invoke-RestMethod "$uri/budgets/$BudgetID/transactions" -Headers $header -Body ($body | ConvertTo-Json) -Method 'POST'

            # Return parsed details
            if ($response) {
                Get-ParsedTransactionJson $response.data.transaction
            }

            # Save the Preset if StoreAs is provided
            if ($StoreAs) {
                $params = $PSBoundParameters
                [Void]$params.Remove('StoreAs')

                # Replace *Name parameters with ID, which will speed up future calls
                [Void]$params.Remove('BudgetName')
                [Void]$params.Remove('AccountName')
                [Void]$params.Remove('CategoryName')
                $params.Add('BudgetID',$BudgetID)
                $params.Add('AccountID',$AccountID)
                $params.Add('CategoryID',$CategoryID)

                Add-YnabTransactionPreset -PresetName $StoreAs @params
            }
        }
    }
}
