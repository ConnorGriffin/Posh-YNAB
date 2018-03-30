# Tab completers
$budgetName = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'BudgetName'}.Function
    Parameter = 'BudgetName'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
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

$budgetId = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'BudgetID'}.Function
    Parameter = 'BudgetID'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        }

        # Only continue trying to complete if a token was provided
        if ($token) {
            # Get a list of all budgets
            $budgets = Get-YNABBudget -Token $token -List | Sort BudgetID

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $budgets.Where{$_.BudgetID -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.BudgetID)`"",
                    $_.BudgetID,
                    'ParameterValue',
                    $_.BudgetID
                )
            }
        }
    }
}

$accountName = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'AccountName'}.Function
    Parameter = 'AccountName'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        }

        # Get the budget ID or name from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.BudgetName -or $fakeBoundParameter.BudgetID) {
            $budgetName = $fakeBoundParameter.BudgetName
            $budgetId = $fakeBoundParameter.BudgetID
        } elseif ($global:PSDefaultParameterValues["${commandName}:BudgetName"] -or $global:PSDefaultParameterValues["${commandName}:BudgetID"]) {
            $budgetName = $global:PSDefaultParameterValues["${commandName}:BudgetName"]
            $budgetId = $global:PSDefaultParameterValues["${commandName}:BudgetID"]
        }

        # Build a parameter object for splatting
        $params = @{List = $true}
        if ($token) {$params.Token = $token}
        # Prioritize ID over name, only include one
        if ($budgetId) {$params.BudgetID = $budgetId}
        elseif ($budgetName) {$params.BudgetName = $budgetName}

        # Only continue trying to complete if a token was provided
        if ($token -and ($budgetId -or $budgetName)) {
            # Get a list of all accounts
            $accounts = Get-YNABAccount @params | Sort Name

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $accounts.Where{$_.Name -like "*$wordMatch*"}.ForEach{
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

$accountId = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'AccountID'}.Function
    Parameter = 'AccountID'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        }

        # Get the budget ID or name from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.BudgetName -or $fakeBoundParameter.BudgetID) {
            $budgetName = $fakeBoundParameter.BudgetName
            $budgetId = $fakeBoundParameter.BudgetID
        } elseif ($global:PSDefaultParameterValues["${commandName}:BudgetName"] -or $global:PSDefaultParameterValues["${commandName}:BudgetID"]) {
            $budgetName = $global:PSDefaultParameterValues["${commandName}:BudgetName"]
            $budgetId = $global:PSDefaultParameterValues["${commandName}:BudgetID"]
        }

        # Build a parameter object for splatting
        $params = @{List = $true}
        if ($token) {$params.Token = $token}
        # Prioritize ID over name, only include one
        if ($budgetId) {$params.BudgetID = $budgetId}
        elseif ($budgetName) {$params.BudgetName = $budgetName}

        # Only continue trying to complete if a token was provided
        if ($token -and ($budgetId -or $budgetName)) {
            # Get a list of all accounts
            $accounts = Get-YNABAccount @params | Sort AccountID

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $accounts.Where{$_.AccountID -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.AccountID)`"",
                    $_.AccountID,
                    'ParameterValue',
                    $_.AccountID
                )
            }
        }
    }
}

# Register the Argument Completers
Register-ArgumentCompleter @budgetName
Register-ArgumentCompleter @budgetId
Register-ArgumentCompleter @accountName
Register-ArgumentCompleter @accountId
