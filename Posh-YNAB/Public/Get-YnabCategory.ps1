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
                   ParameterSetName='Month')]
        [String[]]$Month,
		
		[Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName='Month')]
        [String[]]$CategoryID,
		
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

		if($Month){
			$categories = Invoke-RestMethod "$uri/budgets/$budgetId/months/$Month/categories/$CategoryID" -Headers $header
		}else{
			$categories = Invoke-RestMethod "$uri/budgets/$budgetId/categories" -Headers $header
		}

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
                # Return category details for a single category for a given month
                if ($categories) {
                    Get-ParsedCategoryJson $categories.data.category -IncludeHidden:$IncludeHidden -NoParse:$NoParse
                }
			}
        }
    }
}
