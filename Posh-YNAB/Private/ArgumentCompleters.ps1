# Profile Name tab completion
$budgetName = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'BudgetName'}.Function
    Parameter = 'BudgetName'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        }

        # Only continue trying to complete if a token was provided
        if ($token) {
            # Get a list of all budgets
            $budgets = Get-YNABBudget -Token $token -List | Sort Name

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $budgets.Where{$_.Name -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.Name)`"",
                    $_.Name,
                    'ParameterValue',
                    $_.Name
                )
            }
        }
    }
}

Register-ArgumentCompleter @budgetName
