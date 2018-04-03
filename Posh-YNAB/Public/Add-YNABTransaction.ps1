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
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [String]$Preset,

        [Parameter(Mandatory=$true,Position=10,ParameterSetName='Amount:Name')]
        [Parameter(Mandatory=$true,Position=10,ParameterSetName='Inflow:Name')]
        [Parameter(Mandatory=$true,Position=10,ParameterSetName='Outflow:Name')]
        [Alias('Budget')]
        [String]$BudgetName,

        [Parameter(Mandatory=$true,Position=10,ParameterSetName='Amount:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=10,ParameterSetName='Inflow:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=10,ParameterSetName='Outflow:ID',DontShow)]
        [String]$BudgetID,

        [Parameter(Mandatory=$true,Position=20,ParameterSetName='Amount:Name')]
        [Parameter(Mandatory=$true,Position=20,ParameterSetName='Inflow:Name')]
        [Parameter(Mandatory=$true,Position=20,ParameterSetName='Outflow:Name')]
        [Alias('Account')]
        [String]$AccountName,

        [Parameter(Mandatory=$true,Position=20,ParameterSetName='Amount:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=20,ParameterSetName='Inflow:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=20,ParameterSetName='Outflow:ID',DontShow)]
        [String]$AccountID,

        [Parameter(Mandatory=$true,Position=30,ParameterSetName='Amount:Name')]
        [Parameter(Mandatory=$true,Position=30,ParameterSetName='Inflow:Name')]
        [Parameter(Mandatory=$true,Position=30,ParameterSetName='Outflow:Name')]
        [Alias('Payee')]
        [String]$PayeeName,

        [Parameter(Mandatory=$true,Position=30,ParameterSetName='Amount:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=30,ParameterSetName='Inflow:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=30,ParameterSetName='Outflow:ID',DontShow)]
        [String]$PayeeID,

        [Parameter(Mandatory=$true,Position=40,ParameterSetName='Amount:Name')]
        [Parameter(Mandatory=$true,Position=40,ParameterSetName='Inflow:Name')]
        [Parameter(Mandatory=$true,Position=40,ParameterSetName='Outflow:Name')]
        [Alias('Category')]
        [String]$CategoryName,

        [Parameter(Mandatory=$true,Position=40,ParameterSetName='Amount:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=40,ParameterSetName='Inflow:ID',DontShow)]
        [Parameter(Mandatory=$true,Position=40,ParameterSetName='Outflow:ID',DontShow)]
        [String]$CategoryID,

        [Parameter(Position=50)]
        [String]$Memo,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Outflow:Name')]
        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Outflow:ID')]
        [Double]$Outflow,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Inflow:Name')]
        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Inflow:ID')]
        [Double]$Inflow,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Amount:Name')]
        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Amount:ID')]
        [Double]$Amount,

        [Parameter(Position=70)]
        [Datetime]$Date = (Get-Date),

        [Parameter(Mandatory=$true,Position=80)]
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
        $header = Get-Header $Token
    }

    process {
        # Get the budget IDs if the budget was specified by name
        if ($BudgetName) {
            $budgets = Get-YNABBudget -List -Token $Token
            $BudgetID = $budgets.Where{$_.Budget -like $BudgetName}.BudgetID
            Write-Verbose "Using budget: $BudgetID"
        }

        # Get the account ID if the account was specified by name
        if ($AccountName) {
            $accounts = Get-YNABAccount -List -BudgetID $BudgetID -Token $Token
            $AccountID = $accounts.Where{$_.Account -like $AccountName}.AccountID
            Write-Verbose "Using account: $AccountID"
        }

        # Get the category ID if the category was specified by name
        if ($CategoryName) {
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
        if ($FlagColor) {$body.transaction.approved = $FlagColor}

        $response = Invoke-RestMethod "$uri/budgets/$BudgetID/transactions" -Headers $header -Body ($body | ConvertTo-Json) -Method 'POST'
        if ($response) {
            Get-ParsedTransactionJson $response.data.transaction
        }
    }
}
