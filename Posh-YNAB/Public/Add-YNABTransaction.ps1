function Add-YNABTransaction {
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
    [CmdletBinding(DefaultParameterSetName='Outflow')]
    param(
        [Parameter(Position=0)]
        [Alias('Preset')]
        [String]$PresetName,

        [Parameter(Position=10)]
        [Alias('Budget')]
        [String]$BudgetName,

        [Parameter(Position=10,DontShow)]
        [String]$BudgetID,

        [Parameter(Position=20)]
        [Alias('Account')]
        [String]$AccountName,

        [Parameter(Position=20,DontShow)]
        [String]$AccountID,

        [Parameter(Position=30)]
        [Alias('Payee')]
        [String]$PayeeName,

        [Parameter(Position=30,DontShow)]
        [String]$PayeeID,

        [Parameter(Position=40)]
        [Alias('Category')]
        [String]$CategoryName,

        [Parameter(Position=40,DontShow)]
        [String]$CategoryID,

        [Parameter(Position=50)]
        [String]$Memo,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Outflow')]
        [Double]$Outflow,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Inflow')]
        [Double]$Inflow,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Amount')]
        [Double]$Amount,

        [Parameter(Position=70)]
        [Datetime]$Date = (Get-Date),

        [Parameter(Position=80)]
        $Token,

        [Parameter(Position=90)]
        [ValidateSet('Red','Orange','Yellow','Green','Blue','Purple')]
        [String]$FlagColor,

        [Parameter(Position=100)]
        [Switch]$Cleared,

        [Parameter(Position=110)]
        [Bool]$Approved=$true,

        [Parameter(Position=120)]
        [String]$StoreAs
    )

    begin {
        Write-Verbose "Add-YNABTransaction.ParameterSetName: $($PsCmdlet.ParameterSetName)"

        # Set the default header value for Invoke-RestMethod
        if ($Token) {$header = Get-Header $Token}

        # Set Amount if Outflow or Inflow is provided
        if ($Outflow) {
            $Amount = -$Outflow
        } elseif ($Inflow) {
            $Amount = $Inflow
        }
    }

    process {
        # Load presets and perform a recursive run if a $Preset is specified
        if ($PresetName) {
            Write-Verbose "Using preset: $PresetName"
            $presetParams = (Get-YNABTransactionPreset $PresetName).Value

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
            }
            if ($Inflow) {
                $presetParams.Remove('Outflow')
                $presetParams.Remove('Amount')
                $presetParams.Inflow = $Inflow
            }
            if ($Amount) {
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

            Add-YNABTransaction @presetParams
        } else {
            # Get the budget IDs if the budget was specified by name
            if (!$BudgetID) {
                $budgets = Get-YNABBudget -List -Token $Token
                $BudgetID = $budgets.Where{$_.Budget -like $BudgetName}.BudgetID
                Write-Verbose "Using budget: $BudgetID"
            }

            # Get the account ID if the account was specified by name
            if (!$AccountID) {
                $accounts = Get-YNABAccount -List -BudgetID $BudgetID -Token $Token
                $AccountID = $accounts.Where{$_.Account -like $AccountName}.AccountID
                Write-Verbose "Using account: $AccountID"
            }

            # Get the category ID if the category was specified by name
            if (!$CategoryID) {
                $categories = (Get-YNABCategory -List -BudgetID $BudgetID -Token $Token).Categories
                $CategoryID = $categories.Where{$_.Category -like $CategoryName}.CategoryID
                Write-Verbose "Using category: $CategoryID"
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
            <#@{
                uri = "$uri/budgets/$BudgetID/transactions"
                headers = $header
                body = ($body | ConvertTo-Json)
                method = 'Post'
            }#>
            if ($response) {
                Get-ParsedTransactionJson $response.data.transaction
            }

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

                Add-YNABTransactionPreset -PresetName $StoreAs @params
            }
        }
    }
}
