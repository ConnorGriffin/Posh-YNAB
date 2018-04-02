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

        [String]$BudgetName,


        [String]$BudgetID,


        [String]$AccountName,

        [String]$AccountID,

        [Datetime]$Date = (Get-Date),

        [Double]$Amount,

        [Double]$Outflow,

        [Double]$Inflow,

        [String]$PayeeName,

        #[Parameter(Mandatory=$true)]
        # Remove PayeeID, need to just use Payee, autocomplete for PayeeName, idk?
        # Maybe use aliases. Apply for all *ID and *Name parameters
        [String]$PayeeID,

        #[Parameter(Mandatory=$true)]
        [String]$CategoryName,

        #[Parameter(Mandatory=$true)]
        [String]$CategoryID,

        [String]$Memo,

        [Switch]$Cleared,

        [Bool]$Approved=$true,

        # Validate list here
        [String]$FlagColor,

        [Parameter(Mandatory=$true)]
        [String]$Token
    )

    begin {
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token`
        Write-Verbose "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Verbose $Date
    }

    process {
        # Get the budget IDs if the budget was specified by name
        if ($BudgetName) {
            $budgets = Get-YNABBudget -List -Token $Token
            $BudgetID = $budgets.Where{$_.Name -like $BudgetName}.BudgetID
        }

        # Get the account ID if the account was specified by name
        if ($AccountName) {
            $accounts = Get-YNABAccount -List -BudgetID $BudgetID -Token $Token
            $AccountID = $accounts.Where{$_.Name -like $AccountName}.AccountID
        }

        # Get the category ID if the category was specified by name
        if ($CategoryName) {
            $categories = Get-YNABCategory -List -BudgetID $BudgetID -Token $Token
            $CategoryID = $categories.Where{$_.Name -like $CategoryName}.CategoryID
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
