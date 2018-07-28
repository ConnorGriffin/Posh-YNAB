# Posh-YNAB
[![Build status](https://ci.appveyor.com/api/projects/status/32r7s2skrgm9ubva?svg=true)](https://ci.appveyor.com/project/ConnorGriffin/posh-ynab)
[![PSG Version](https://img.shields.io/powershellgallery/v/Posh-YNAB.svg)](https://www.powershellgallery.com/packages/Posh-YNAB)
[![PSG Downloads](https://img.shields.io/powershellgallery/dt/Posh-YNAB.svg)](https://www.powershellgallery.com/packages/Posh-YNAB)

[YNAB API](https://api.youneedabudget.com/) Implementation in PowerShell.

This module is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/Posh-YNAB).

## Initial setup

### Installing and loading the module
```powershell
# Install the module (if you have PowerShell 5, or the PowerShellGet module).
Install-Module Posh-YNAB -Scope CurrentUser

# Import the module.
Import-Module Posh-YNAB

# Get commands in the module
Get-Command -Module Posh-YNAB

# Get help for a specific command
Get-Help Add-YnabTransaction -Full
```

### Getting your YNAB API Token

Head on over to YNAB's [Personal Access Tokens](https://api.youneedabudget.com/#personal-access-tokens) page for instructions on generating a token.

### Configuring defaults

Your budget name and API token can be stored as defaults that load when the module loads, so you do not need to specify these every time. The API token is stored
as a SecureString, which can only be decrypted by the user and computer that encrypted it. The Token cannot be decrypted by any other user on your computer, or any user
(including yourself) on any other computer.

```powershell
# Set your default Budget and Token (example token generated randomly)
Set-YnabDefault -Budget "Test Budget" -Token 'c63d41ca37bc03e4837d2e7cacc60ee9ac63432f3bbf2f3deced75449afb5185'

# Test the defaults by getting a list of categories from your budget without actually providing the -Budget or -Token parameters
Get-YnabCategory
```

## Usage
Some things to note:
- Most parameters that validate against data from YNAB (Accounts, Categories, etc.) support tab completion.
- Each tab complete attempt does perform 1 API call, so take your rate limits and network bandwidth into consideration.
- I have probably designed some things inefficently or just plain poorly. I welcome all contributions.
- This module is IN PROGRESS and does not support all API features, though it does support a good amount.

### Posting a transaction
```powershell
# Add a transaction
Add-YnabTransaction -Budget 'Test Budget' -Account 'Checking' -Payee 'School' -Category 'Education' -Memo 'Enrollment Fee' -Outflow 500

Date                 Amount Memo           Cleared   Approved FlagColor Payee  Category  Account
----                 ------ ----           -------   -------- --------- -----  --------  -------
6/4/2018 12:00:00 AM -500   Enrollment Fee uncleared True               School Education Checking
```

## Current Progress

### To Do
* Move this to a public Trello page or a github project
* Change tab complete for Category Name to use "CategoryGroup: CategoryName" rather than just "CategoryName" (-CategoryName parameters should support either as valid input)
* Add comment-based help for all functions
* Automatically update FunctionsToExport and AliasesToExport on build
* Merge all functions into a single .psm1 file on build
* Add aliases for all functions (remove YNAB piece, so Get-YnabBudget is just Get-Budget)
* Add support for transfer transactions
* Add about_helptopic (https://msdn.microsoft.com/en-us/library/dd878343(v=vs.85).aspx)
* Support inflow (To Be Budgeted) transaction

### In Progress

* Implement functionality for all API endpoints
* Add ValueFromPipelineByPropertyName for all applicable parameters
* Add Pester tests
* Custom formats for all data outputs (list and table!)
* Add -NoParse to all data parsers
* Add comment-based help for all functions

### Done

* Due to ParameterSet restrictions, add custom required parameter prompting for required parameters that have an ID or Name type. Alternatively accept ID in the Name field, but this would mess with tab complete.
* Add AccountName and BudgetName parameters to Get-YnabAccount and Set-YnabDefaults
* Add transaction presets
* Build ArgumentCompleters for all applicable parameters
* Publish to PSGallery, integrate with some kind of CI/CD (look into [this](https://github.com/LawrenceHwang/powershell-ci-pipeline-with-aws))
* Change all *ID and *Name parameters to just the rootname (CategoryID is deleted, CategoryName becomes Category)
* Add badges based on tests
* Test all pull requests
* Get-YnabTransaction, implement a filter, or maybe Find-YnabTransaction
* Pipeline idea/goal - store an already posted transaction as a preset: Get-YnabTransaction <transaction criteria> | Add-YnabTransactionPreset
* Add testing to the build process, don't publish if tests fail

### Endpoint Progress

Attempting to implement functionality for all endpoints listed [here](https://api.youneedabudget.com/v1#/), as of 2018-04-04.

#### User
- ~~[GET] /user~~ Get-YnabUser

#### Budgets
- ~~[GET] /budgets~~ Get-YnabBudget
- [GET] /budgets/{budget_id} Get-YnabBudget -Budget <budget_name>

#### Accounts
The Accounts for a budget.
- ~~[GET] /budgets/{budget_id}/accounts~~ Get-YnabAccount
- ~~[GET] /budgets/{budget_id}/accounts/{account_id}~~ Get-YnabAccount -Account <account_name>

#### Categories
The Categories for a budget.
- ~~[GET] /budgets/{budget_id}/categories~~ Get-YnabCategory
- ~~[GET] /budgets/{budget_id}/categories/{category_id}~~ Get-YnabCategory -Category <category_name>

#### Payees
The Payees for a budget.
- ~~[GET] /budgets/{budget_id}/payees~~ Get-YnabPayee
- ~~[GET] /budgets/{budget_id}/payees/{payee_id}~~ Get-YnabPayee -Payee <payee_name>

#### Payee Locations
When you enter a transaction and specify a payee on the YNAB mobile apps, the GPS coordinates for that location are stored, with your permission, so that the next time you are in the same place (like the Grocery store) we can pre-populate nearby payees for you! It’s handy and saves you time. This resource makes these locations available. Locations will not be available for all payees.
- ~~[GET] /budgets/{budget_id}/payee_locations~~ Get-YnabPayee -Location
- [GET] /budgets/{budget_id}/payee_locations/{payee_location_id}
- ~~[GET] /budgets/{budget_id}/payees/{payee_id}/payee_locations~~ Get-YnabPayee -Payee <payee_name> -Location

#### Months
Each budget contains one or more months, which is where To be Budgeted, Age of Money and Category (budgeted / activity / balances) amounts are available.
- [GET] /budgets/{budget_id}/months
- [GET] /budgets/{budget_id}/months/{month}

#### Transactions
The Transactions for a budget.
- [GET] /budgets/{budget_id}/transactions
- ~~**[POST] /budgets/{budget_id}/transactions**~~ Add-YnabTransaction -Budget <budget_name> -Account <account_name> etc..
- [POST] /budgets/{budget_id}/transactions/bulk
- ~~[GET] /budgets/{budget_id}/accounts/{account_id}/transactions~~ Get-YnabTransaction
- ~~[GET] /budgets/{budget_id}/categories/{category_id}/transactions~~
- ~~[GET] /budgets/{budget_id}/payees/{payee_id}/transactions~~
- ~~[GET] /budgets/{budget_id}/transactions/{transaction_id}~~
- **[PUT] /budgets/{budget_id}/transactions/{transaction_id}**

#### Scheduled Transactions
The Scheduled Transactions for a budget.
- [GET] /budgets/{budget_id}/scheduled_transactions
- [GET] /budgets/{budget_id}/scheduled_transactions/{scheduled_transaction_id}
