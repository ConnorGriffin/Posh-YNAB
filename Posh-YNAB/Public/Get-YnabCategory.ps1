function Get-YnabCategory {
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
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [String]$Budget,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Detail')]
        [String[]]$Category,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName='List')]
        [Switch]$ListAll,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName='List')]
        [Switch]$IncludeHidden,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        $Token
    )

    begin {
        $header = Get-Header $Token
    }

    process {
        # Get the budget and category data
        $budgets = [Array](Get-YnabBudget -ListAll -Token $Token)
        $budgetId = $budgets.Where{$_.Budget -like $Budget}.BudgetID

        switch ($PsCmdlet.ParameterSetName) {
            'List' {
                $categories = Invoke-RestMethod "$uri/budgets/$budgetId/categories" -Headers $header
                # Return the full list of categories by group
                if ($categories) {
                    Get-ParsedCategoryJson $categories.data.category_groups -List -IncludeHidden:$IncludeHidden
                }
            }
            'Detail' {
                $categories = [Array]((Get-YnabCategory -Budget $Budget -ListAll -IncludeHidden:$IncludeHidden -Token $Token).Categories)
                # Return category details for each category specified
                foreach ($categoryName in $Category) {
                    $categoryId = $categories.Where{$_.Category -like $categoryName}.CategoryID
                    $response = Invoke-RestMethod "$uri/budgets/$budgetId/categories/$categoryId" -Headers $header
                    Get-ParsedCategoryJson $response.data.category
                }
            }
        }
    }
}
