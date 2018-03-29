# Posh-YNAB
[YNAB API](https://api.youneedabudget.com/) Implementation in PowerShell

## Goals

* Implement functionality for all API endpoints
* Add AccountName and BudgetName parameters to Get-YNABAccount and Set-YNABDefaults
* BudgetName is set to be accepted from pipeline, but nothing outputs it, so... gotta work on that
* Add comment-based help for all functions
* Publish to PSGallery
* Add Pester tests

## Endpoint Progress

Attempting to implement functionality for all endpoints listed [here](https://api.youneedabudget.com/v1#/).

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
- [GET] /budgets/{budget_id}/categories
- [GET] /budgets/{budget_id}/categories/{category_id}

### Payees
The Payees for a budget.
- [GET] /budgets/{budget_id}/payees
- [GET] /budgets/{budget_id}/payees/{payee_id}

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
- **[POST] /budgets/{budget_id}/transactions**
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
