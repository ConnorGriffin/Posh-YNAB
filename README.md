# Posh-YNAB
[YNAB API](https://api.youneedabudget.com/) Implementation in PowerShell

## To Do

* Implement functionality for all API endpoints
* Change tab complete for Category Name to use "CategoryGroup: CategoryName" rather than just "CategoryName" (-CategoryName parameters should support either as valid input)
* Due to ParameterSet restrictions, add custom required parameter prompting for required parameters that have an ID or Name type. Alternatively accept ID in the Name field, but this would mess with tab complete.  
* ~~Add AccountName and BudgetName parameters to Get-YNABAccount and Set-YNABDefaults~~
* ~~Add transaction presets~~
* Add ValueFromPipelineByPropertyName for all applicable parameters
* Build ArgumentCompleters for all applicable parameters
* Add comment-based help for all functions
* ~~Publish to PSGallery, integrate with some kind of CI/CD (look into [this](https://github.com/LawrenceHwang/powershell-ci-pipeline-with-aws))~~
* Add Pester tests
* Automatically update FunctionsToExport and AliasesToExport on build
* Merge all functions into a single .psm1 file on build

## Endpoint Progress

Attempting to implement functionality for all endpoints listed [here](https://api.youneedabudget.com/v1#/), as of 2018-04-04.

### User
- ~~[GET] /user~~

### Budgets
- ~~[GET] /budgets~~
- [GET] /budgets/{budget_id}

### Accounts
The Accounts for a budget.
- ~~[GET] /budgets/{budget_id}/accounts~~
- ~~[GET] /budgets/{budget_id}/accounts/{account_id}~~

### Categories
The Categories for a budget.
- ~~[GET] /budgets/{budget_id}/categories~~
- ~~[GET] /budgets/{budget_id}/categories/{category_id}~~

### Payees
The Payees for a budget.
- ~~[GET] /budgets/{budget_id}/payees~~
- ~~[GET] /budgets/{budget_id}/payees/{payee_id}~~

### Payee Locations
When you enter a transaction and specify a payee on the YNAB mobile apps, the GPS coordinates for that location are stored, with your permission, so that the next time you are in the same place (like the Grocery store) we can pre-populate nearby payees for you! It’s handy and saves you time. This resource makes these locations available. Locations will not be available for all payees.
- [GET] /budgets/{budget_id}/payee_locations
- [GET] /budgets/{budget_id}/payee_locations/{payee_location_id}
- [GET] /budgets/{budget_id}/payees/{payee_id}/payee_locations

### Months
Each budget contains one or more months, which is where To be Budgeted, Age of Money and Category (budgeted / activity / balances) amounts are available.
- [GET] /budgets/{budget_id}/months
- [GET] /budgets/{budget_id}/months/{month}

### Transactions
The Transactions for a budget.
- [GET] /budgets/{budget_id}/transactions  
- ~~**[POST] /budgets/{budget_id}/transactions**~~
- [POST] /budgets/{budget_id}/transactions/bulk
- [GET] /budgets/{budget_id}/accounts/{account_id}/transactions
- [GET] /budgets/{budget_id}/categories/{category_id}/transactions
- [GET] /budgets/{budget_id}/payees/{payee_id}/transactions
- [GET] /budgets/{budget_id}/transactions/{transaction_id}
- **[PUT] /budgets/{budget_id}/transactions/{transaction_id}**

### Scheduled Transactions
The Scheduled Transactions for a budget.
- [GET] /budgets/{budget_id}/scheduled_transactions
- [GET] /budgets/{budget_id}/scheduled_transactions/{scheduled_transaction_id}
