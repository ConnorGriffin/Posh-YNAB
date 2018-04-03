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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,CategoryName')]
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,CategoryID')]
        [Parameter(Mandatory=$true,ParameterSetName='List:BudgetName')]
        [String]$BudgetName,

        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,CategoryName')]
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,CategoryID')]
        [Parameter(Mandatory=$true,ParameterSetName='List:BudgetID')]
        [String]$BudgetID,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,CategoryName')]
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,CategoryName')]
        [String[]]$CategoryName,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetName,CategoryID')]
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName='Detail:BudgetID,CategoryID')]
        [String[]]$CategoryID,

        [Parameter(ParameterSetName='List:BudgetName')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [Switch]$List,

        [Parameter(ParameterSetName='List:BudgetName')]
        [Parameter(ParameterSetName='List:BudgetID')]
        [Switch]$IncludeHidden,

        [Parameter(Mandatory=$true)]
        [String]$Token
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
                $categories.Categories.Where{$_.Category -like $name}.CategoryID
            }
        }

        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'List*' {
                $response = Invoke-RestMethod "$uri/budgets/$BudgetID/categories" -Headers $header
                if ($response) {
                    Get-ParsedCategoryJson $response.data.category_groups -List -IncludeHidden:$IncludeHidden
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
