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
            $budgets = Get-YNABBudget -Token $token -List | Sort-Object Name

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $budgets.Where{$_.Budget -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.Budget)`"",
                    $_.Budget,
                    'ParameterValue',
                    $_.Budget
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
            $budgets = Get-YNABBudget -Token $token -List | Sort-Object BudgetID

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
            $accounts = Get-YNABAccount @params | Sort-Object Name

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $accounts.Where{$_.Account -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.Account)`"",
                    $_.Account,
                    'ParameterValue',
                    $_.Account
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
            $accounts = Get-YNABAccount @params | Sort-Object AccountID

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

$categoryName = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'CategoryName'}.Function
    Parameter = 'CategoryName'
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
            $categories = (Get-YNABCategory @params).Categories | Sort-Object Category

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $categories.Where{$_.Category -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.Category)`"",
                    $_.Category,
                    'ParameterValue',
                    $_.Category
                )
            }
        }
    }
}

$categoryId = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'CategoryID'}.Function
    Parameter = 'CategoryID'
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
            $categories = (Get-YNABCategory @params).Categories | Sort-Object Category

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $categories.Where{$_.CategoryID -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.CategoryID)`"",
                    $_.CategoryID,
                    'ParameterValue',
                    $_.CategoryID
                )
            }
        }
    }
}

$payeeName = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'PayeeName'}.Function
    Parameter = 'PayeeName'
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
            $payees = (Get-YNABPayee @params) | Sort-Object Payee

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $payees.Where{$_.Payee -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.Payee)`"",
                    $_.Payee,
                    'ParameterValue',
                    $_.Payee
                )
            }
        }
    }
}

$payeeId = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'PayeeID'}.Function
    Parameter = 'PayeeID'
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
            $payees = (Get-YNABPayee @params) | Sort-Object PayeeID

            # Trim quotes from the $wordToComplete
            $wordMatch = $wordToComplete.Trim("`"`'")

            # Add a CompletionResult for each budget name matching wordToComplete
            $payees.Where{$_.PayeeID -like "*$wordMatch*"}.ForEach{
                New-Object System.Management.Automation.CompletionResult (
                    "`"$($_.PayeeID)`"",
                    $_.PayeeID,
                    'ParameterValue',
                    $_.PayeeID
                )
            }
        }
    }
}

$presetName = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'PresetName'}.Function
    Parameter = 'PresetName'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        # Get a list of all accounts
        $presets = (Get-YNABTransactionPreset -List).GetEnumerator() | Sort-Object Name

        # Trim quotes from the $wordToComplete
        $wordMatch = $wordToComplete.Trim("`"`'")

        # Add a CompletionResult for each budget name matching wordToComplete
        $presets.Where{$_.Name -like "*$wordMatch*"}.ForEach{
            New-Object System.Management.Automation.CompletionResult (
                "`"$($_.Name)`"",
                $_.Name,
                'ParameterValue',
                $_.Name
            )
        }
    }
}

# Register the Argument Completers
Register-ArgumentCompleter @budgetName
Register-ArgumentCompleter @budgetId
Register-ArgumentCompleter @accountName
Register-ArgumentCompleter @accountId
Register-ArgumentCompleter @categoryName
Register-ArgumentCompleter @categoryId
Register-ArgumentCompleter @payeeName
Register-ArgumentCompleter @payeeID
Register-ArgumentCompleter @presetName
