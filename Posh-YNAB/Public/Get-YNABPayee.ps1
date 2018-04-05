function Get-YNABPayee {
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
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,PayeeName')]
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,PayeeID')]
        [Parameter(Mandatory=$true,ParameterSetName='List:BudgetName')]
        [String]$BudgetName,

        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,PayeeName')]
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,PayeeID')]
        [Parameter(Mandatory=$true,ParameterSetName='List:BudgetID')]
        [String]$BudgetID,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,PayeeName')]
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,PayeeName')]
        [String[]]$PayeeName,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,PayeeID')]
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,PayeeID')]
        [String[]]$PayeeID,

        [Parameter(ParameterSetName='List:BudgetName')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [Switch]$List,

        [Switch]$Location,

        [Parameter(Mandatory=$true)]
        $Token
    )

    begin {
        Write-Verbose "Get-YNABPayee.ParameterSetName: $($PsCmdlet.ParameterSetName)"

        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token

        # Exclude Location in the data return if $Location is not used
        if (!$Location) {$exclude = 'Location'}
    }

    process {
        # Get the budget IDs if the budget was specified by name
        if ($BudgetName) {
            $budgets = Get-YNABBudget -List -Token $Token
            $BudgetID = $budgets.Where{$_.Budget -like $BudgetName}.BudgetID
        }

        # Get the account ID if the account was specified by name
        if ($PayeeName) {
            $payees = (Get-YNABPayee -List -BudgetID $BudgetID -Token $Token)
            $PayeeID = $PayeeName.ForEach{
                $name = $_
                $payees.Where{$_.Payee -like $name}.PayeeID
            }
        }

        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'List*' {
                $response = Invoke-RestMethod "$uri/budgets/$BudgetID/payees" -Headers $header
                if ($response) {
                    # Perform a payee location lookup if -Location is provided
                    if ($Location) {
                        $locations = Invoke-RestMethod "$uri/budgets/$BudgetID/payee_locations" -Headers $header
                    }
                    Get-ParsedPayeeJson $response.data.payees $locations.data.payee_locations | Select-Object * -ExcludeProperty $exclude
                }
            }
            'Detail*' {
                # Return account details for each AccountID specified
                $PayeeID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$BudgetID/payees/$_" -Headers $header
                    if ($response) {
                        # Perform a payee location lookup if -Location is provided
                        if ($Location) {
                            $locations = Invoke-RestMethod "$uri/budgets/$BudgetID/payees/$_/payee_locations" -Headers $header
                        }
                        Get-ParsedPayeeJson $response.data.payee $locations.data.payee_locations | Select-Object * -ExcludeProperty $exclude
                    }
                }
            }
        }
    }
}
