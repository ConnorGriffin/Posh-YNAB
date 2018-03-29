function Get-YNABCategory {
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
    [CmdletBinding(DefaultParameterSetName='List:BudgetID')]
    param(
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetName,CategoryName')]
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetName,CategoryID')]
        [Parameter(ParameterSetName='List:BudgetName')]
        [String]$BudgetName,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetID,CategoryName')]
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory=$true,ParameterSetName='DetailByBudgetID,CategoryID')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [String]$BudgetID,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetName,CategoryName')]
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetID,CategoryName')]
        [String[]]$CategoryName,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetName,CategoryID')]
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='DetailByBudgetID,CategoryID')]
        [String[]]$CategoryID,

        [Parameter(Mandatory=$true)]
        [String]$Token,

        [Parameter(ParameterSetName='List:BudgetName')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [Switch]$List
    )

    begin {
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token`
        Write-Verbose "ParameterSetName: $($PsCmdlet.ParameterSetName)"
    }

    process {
        # Get the budget IDs if the budget was specified by name
        if ($BudgetName) {
            $budgets = Get-YNABBudget -List -Token $Token
            $BudgetID = $budgets.Where{$_.Name -like $BudgetName}.BudgetID
        }

        # Get the account ID if the account was specified by name
        if ($CategoryName) {
            $categories = Get-YNABCategory -List -BudgetID $BudgetID -Token $Token
            $CategoryID = $CategoryName.ForEach{
                $name = $_
                $categories.Where{$_.Name -like $name}.CategoryID
            }
        }

        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'List*' {
                $response = Invoke-RestMethod "$uri/budgets/$BudgetID/categories" -Headers $header
                if ($response) {
                    Get-ParsedCategoryJson $response.data.category_groups.categories
                }
            }
            'Detail*' {
                # Return account details for each AccountID specified
                $CategoryID.ForEach{
                    $response = Invoke-RestMethod "$uri/budgets/$BudgetID/categories/$_" -Headers $header
                    if ($response) {
                        Get-ParsedCategoryJson $response.data.category
                    }
                }
            }
        }
    }
}
