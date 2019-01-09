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
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Month')]
        [String[]]$Category,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName='Month')]
        [Datetime[]]$Month,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName='List')]
        [Switch]$ListAll,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName='List')]
        [Switch]$IncludeHidden,

        # Return the raw JSON data from the YNAB API.
        [Parameter(DontShow)]
        [Switch]$NoParse,

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
        $categories = Invoke-RestMethod "$uri/budgets/$budgetId/categories" -Headers $header

        switch ($PsCmdlet.ParameterSetName) {
            'List' {
                # Return the full list of categories by group
                if ($categories) {
                    Get-ParsedCategoryJson $categories.data.category_groups -List -IncludeHidden:$IncludeHidden -NoParse:$NoParse
                }
            }
            'Detail' {
                # Return category details for each category specified
                foreach ($categoryName in $Category) {
                    $data = ([Array]$categories.data.category_groups.categories).Where{$_.Name -eq $categoryName}
                    Get-ParsedCategoryJson $data -NoParse:$NoParse
                }
            }
            'Month' {
                # Return category details for a each given category and month
                foreach ($categoryName in $Category) {
                    $categoryId = ([Array]$categories.data.category_groups.categories).Where{$_.Name -eq $categoryName}.id
                    
                    # Convert dates as entered into a unique list of months (ex: 2018-01-01 and 2018-01-04 are merged)
                    $dates = $Month | ForEach-Object {
                        Get-Date $_ -Day 1 -Format 'yyyy-MM-dd'
                    } | Sort-Object -Unique

                    # Return the category details for each specified month
                    foreach ($date in $dates) {
                        $categoryData = Invoke-RestMethod "$uri/budgets/$budgetId/months/$date/categories/$categoryId" -Headers $header
                        Get-ParsedCategoryJson $categoryData.data.category -NoParse:$NoParse | Select-Object @{N='Month'; E={$date}}, *
                    }
                }
			}
        }
    }
}
