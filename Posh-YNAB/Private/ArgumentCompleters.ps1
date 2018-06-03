# Tab completers
$budget = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'Budget'}.Function
    Parameter = 'Budget'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        } else {
            return
        }

        # Get a list of all budgets
        $budgets = Get-YnabBudget -Token $token -ListAll | Sort-Object Name

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

$account = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'Account'}.Function
    Parameter = 'Account'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        } else {
            return
        }

        # Get the budget name from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Budget) {
            $budget = $fakeBoundParameter.Budget
        } elseif ($global:PSDefaultParameterValues["${commandName}:Budget"]) {
            $budget = $global:PSDefaultParameterValues["${commandName}:Budget"]
        } else {
            return
        }

        # Get a list of all accounts
        $accounts = Get-YnabAccount -Budget $budget -Token $token | Sort-Object Name

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

$category = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'Category'}.Function
    Parameter = 'Category'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        } else {
            return
        }

        # Get the budget name from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Budget) {
            $budget = $fakeBoundParameter.Budget
        } elseif ($global:PSDefaultParameterValues["${commandName}:Budget"]) {
            $budget = $global:PSDefaultParameterValues["${commandName}:Budget"]
        } else {
            return
        }

        # Get a list of all accounts
        $categories = (Get-YnabCategory -Budget $budget -Token $token).Categories | Sort-Object Category

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

$payee = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'Payee'}.Function
    Parameter = 'Payee'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        # Get the token value from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Token) {
            $token = $fakeBoundParameter.Token
        } elseif ($global:PSDefaultParameterValues["${commandName}:Token"]) {
            $token = $global:PSDefaultParameterValues["${commandName}:Token"]
        } else {
            return
        }

        # Get the budget name from the pipeline or PSDefaultParamterValues
        if ($fakeBoundParameter.Budget) {
            $budget = $fakeBoundParameter.Budget
        } elseif ($global:PSDefaultParameterValues["${commandName}:Budget"]) {
            $budget = $global:PSDefaultParameterValues["${commandName}:Budget"]
        } else {
            return
        }

        # Get a list of all accounts
        $payees = (Get-YnabPayee -Budget $budget -Token $token) | Sort-Object Payee

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

$preset = @{
    CommandName = $paramsByFunction.Where{$_.Parameter -contains 'Preset'}.Function
    Parameter = 'Preset'
    ScriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        # Get a list of all accounts
        $presets = (Get-YnabTransactionPreset -List).GetEnumerator() | Sort-Object Name

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
Register-ArgumentCompleter @budget
Register-ArgumentCompleter @account
Register-ArgumentCompleter @category
Register-ArgumentCompleter @payee
#Register-ArgumentCompleter @preset
