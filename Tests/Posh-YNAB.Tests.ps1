Import-Module .\Posh-YNAB\Posh-YNAB.psd1 -Force

$testPreset = 'Test Preset'
$testBudget = 'Test Budget'
$testAccount = 'Test Account'
$testPayee = 'Test Payee'
$testCategory = 'Test Category'
$testMemo = 'Test Memo'
$testOutflow = 10.25
$testToken = 'Test Token'
$testFlagColor = 'Red'

$transactionObject = [PSCustomObject]@{
    Budget = $testBudget
    Account = $testAccount
    Payee = $testPayee
    Category = $testCategory
    Memo = $testMemo
    Outflow = $testOutflow
    Token = $testToken
    FlagColor = $testFlagColor
}

$transactionHashtable = @{
    Budget = $testBudget
    Account = $testAccount
    Payee = $testPayee
    Category = $testCategory
    Memo = $testMemo
    Token = $testToken
    FlagColor = $testFlagColor
}

# Disable default parameter values during testing
$defaultParam = $PSDefaultParameterValues["Disabled"]
$PSDefaultParameterValues["Disabled"] = $true


Describe 'Public functions exports' {
    $files = Get-ChildItem -Path .\Posh-YNAB\Public\*.ps1
    $exportedFunctions = (Get-Module -Name Posh-YNAB).ExportedFunctions.Values.Name
    
    Context 'File names match the function they export' {
        $files.ForEach{
            It "$($_.Name) exports $($_.BaseName)" {
                $content = Get-Content $_.FullName 
                $function = $content[0].Split(' ')[1]
                $function | Should -Be $_.BaseName
            }
        }
    }

    Context 'All public files correspond to an exported function' {
        $files.ForEach{
            It "$($_.BaseName) is in exported functions" {
                $_.BaseName | Should -BeIn $exportedFunctions
            }
        }
    }

    Context 'All exported functions correspond to a public file' {
        $exportedFunctions.ForEach{
            It "$_.ps1 is in Public" {
                ".\Posh-YNAB\Public\$_.ps1" | Should -Exist
            }
        }
    }
}

Describe 'Add-YnabTransaction' {
    # Force 
    InModuleScope Posh-YNAB {
        $script:profilePath = $PSScriptRoot
    }

    Mock -ModuleName Posh-YNAB -CommandName Invoke-RestMethod {
        @{
            data = @{
                transaction = @{
                    account_id = $accountId
                    date = $Date.ToString('yyyy-MM-dd')
                    amount = ($Amount * 1000)
                    payee_id =  $payeeId
                    payee_name = $Payee
                    category_id = $categoryId
                    memo = $Memo
                    cleared = 'uncleared'
                    approved = $Approved
                    flag_color = $FlagColor
                    import_id = $null
                }
            }
        }
    }
    
    Mock -ModuleName Posh-YNAB -CommandName Get-YnabBudget {
        [PSCustomObject]@{
            Budget = $testBudget
            ID = '1'
        }
    }

    Mock -ModuleName Posh-YNAB -CommandName Get-YnabAccount {
        [PSCustomObject]@{
            Account = $testAccount
            ID = '1'
        }
    }

    Mock -ModuleName Posh-YNAB -CommandName Get-YnabCategory {
        [PSCustomObject]@{
            Category = $testCategory
            ID = '1'
        }
    }

    Context 'Supports all expected parameter combinations' {
        It 'Supports transactions with Outflow' {
            $response = Add-YnabTransaction @transactionHashtable -Outflow 10.25
            
            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.25
        }

        It 'Supports transactions with Inflow' {
            $response = Add-YnabTransaction @transactionHashtable -Inflow 10.25
            
            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be 10.25
        }

        It 'Supports transactions with Amount' {
            $response = Add-YnabTransaction @transactionHashtable -Amount -10.25

            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.25
        }
        
        It 'Supports transactions with Preset only' {
            $response = Add-YnabTransaction -Preset $testPreset

            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.25
        }

        It 'Supports transactions with an array of presets' {
            $response = Add-YnabTransaction -Preset @($testPreset,$testPreset)

            $response.Count | Should -Be 2
            $response[0].Amount | Should -Be -10.25
            $response[1].Amount | Should -Be -10.25
        }

        It 'Supports transactions with Preset and Outflow' {
            $response = Add-YnabTransaction -Preset $testPreset -Outflow 10.55

            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.55
        }

        It 'Supports transactions with Preset and Inflow' {
            $response = Add-YnabTransaction -Preset $testPreset -Inflow 10.55

            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be 10.55
        }

        It 'Supports transactions with Preset and Amount' {
            $response = Add-YnabTransaction -Preset $testPreset -Amount -10.55

            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.55
        }

        It 'Supports transactions with Preset and other (non-amount) variables' {
            $response = Add-YnabTransaction -Preset $testPreset -Payee 'Test Payee2' -Memo 'Test Memo2' 

            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.25
            $response.Memo | Should -Be 'Test Memo2' 
            $response.Payee | Should -Be 'Test Payee2'
        }
    }

    Context 'Supports pipeline' {
        It 'Supports pipeline input by property name for a single object' {
            $response = $transactionObject | Add-YnabTransaction
            
            ([Array]$response).Count | Should -Be 1
        }
    
        It 'Supports pipeline input by property name for an array of objects' {
            $response = @($transactionObject,$transactionObject) | Add-YnabTransaction
            
            $response.Count | Should -Be 2
        }
    
        It 'Supports pipeline input of a single preset by name' {
            $response = $testPreset | Add-YnabTransaction
            
            ([Array]$response).Count | Should -Be 1
            $response.Amount | Should -Be -10.25
        }
    
        It 'Supports pipeline input of an array of presets by name' {
            $response = @($testPreset,$testPreset) | Add-YnabTransaction
            
            $response.Count | Should -Be 2
            $response[0].Amount | Should -Be -10.25
            $response[1].Amount | Should -Be -10.25
        }
    }
}

# Restore the original default parameter values state after testing
$PSDefaultParameterValues["Disabled"] = $defaultParam