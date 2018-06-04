# ALl JSON parsing functions should live here.

function Get-ParsedAccountJson {
    <#
    .SYNOPSIS
        Converts the account API data to a consistent format for use within the Posh-YNAB module.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [Object[]]$Account,
        
        [Switch]$NoParse
    )

    begin {
        $parsedData = @()
        $sortProp = @(
            @{
                Expression = 'OnBudget'
                Descending = $true
            },
            @{Expression = 'Closed'},
            @{Expression = 'Account'}
        )
    }

    process {
        $parsedData += $Account.ForEach{
            if (!$NoParse) {
                $object = [PSCustomObject]@{
                    Account = $_.name
                    Balance = ([double]$_.balance / 1000)
                    Type = $_.type
                    OnBudget = $_.on_budget
                    Closed = $_.closed
                    Note = $_.note
                    ClearedBalance = ([double]$_.cleared_balance / 1000)
                    UnclearedBalance = ([double]$_.uncleared_balance / 1000)
                    AccountID = $_.id
                }
                $object.PSObject.TypeNames.Insert(0,'Ynab.Account')
                $object
            } else {
                $_
            }
        } 
    }

    end {
        $parsedData | Sort-Object $sortProp
    }
}

function Get-ParsedPayeeJson {
    <#
    .SYNOPSIS
        Converts the payee API data to a consistent format for use within the Posh-YNAB module.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [Object[]]$Payee,

        [Object[]]$PayeeLocation,

        [Switch]$IncludeLocation,

        [Switch]$NoParse
    )

    begin {
        $parsedData = @()
    }

    process {
        $parsedData += $Payee.ForEach{
            $payeeId = $_.id

            # Build an object of longitude/latidude data for the current payee
            if ($IncludeLocation) {
                $location = $PayeeLocation.Where{$_.payee_id -eq $payeeId}.ForEach{
                    [PSCustomObject]@{
                        Latitude = $_.latitude
                        Longitude = $_.longitude
                        Maps = "https://maps.google.com/maps?q=$($_.latitude),$($_.longitude)"
                    }
                }
                $format = 'Ynab.PayeeWithLocation'
            } else {
                $format = 'Ynab.Payee'
            }
            if (!$NoParse) {
                $object = [PSCustomObject]@{
                    Payee = $_.name
                    Location = $location
                    TransferAccountID = $_.transfer_account_id
                    PayeeID = $payeeId
                }
                $object.PSObject.TypeNames.Insert(0,$format)
                $object
            } else {
                $_
            }
        }
    }

    end {
        $parsedData | Sort-Object Payee
    }
}

function Get-ParsedTransactionJson {
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
    [CmdletBinding(DefaultParameterSetName='TransactionResponse')]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline,ParameterSetName='TransactionResponse')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='Detail')]
        [Object[]]$Transaction,

        [Parameter(Position=1,ParameterSetName='Detail')]
        [Object[]]$Subtransaction,

        [Parameter(Position=2,ParameterSetName='Detail')]
        [Object[]]$Payee,

        [Parameter(Position=3,ParameterSetName='Detail')]
        [Object[]]$PayeeLocation,

        [Parameter(Position=4,ParameterSetName='Detail')]
        [Object[]]$ParsedPayee
    )

    begin {
        $parsedData = @()
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Detail' {
                # If no ParsedPayee data is provided, generate it
                if (!$ParsedPayee -and $Payee) {
                    $ParsedPayee = Get-ParsedPayeeJson $Payee $PayeeLocation
                }

                $parsedData += $Transaction.ForEach{
                    $transId = $_.id
                    $payeeId = $_.payee_id
                    $payee = $ParsedPayee.Where{$_.PayeeId -eq $payeeId}

                    # Build an object of longitude/latidude data for the current payee
                    $subtrans = $Subtransaction.Where{$_.transaction_id -eq $transId}.ForEach{
                        $payeeId = $_.payee_id
                        $subPayee = $ParsedPayee.Where{$_.PayeeId -eq $payeeId}

                        [PSCustomObject]@{
                            Amount = ([double]$_.amount / 1000)
                            Memo = $_.memo
                            Payee = $subPayee.Name
                            #Category
                            PayeeID = $subPayee.PayeeId
                            #CategoryID
                        }
                    }
                    $subtrans.PSObject.TypeNames.Insert(0,'Ynab.Transaction')

                    # Return the formatted transaction data
                    $object = [PSCustomObject]@{
                        Date = [datetime]::ParseExact($_.date,'yyyy-MM-dd',$null)
                        Amount = ([double]$_.amount / 1000)
                        Memo = $_.memo
                        Cleared = $_.cleared
                        Approved = $_.approved
                        #account
                        Payee = $payee.Name
                        #Category
                        Subtransactions = $subtrans
                        PayeeID = $payee.PayeeId
                        #CategoryID
                    }
                    $object.PSObject.TypeNames.Insert(0,'Ynab.Transaction')
                    $object
                }
            }
            'TransactionResponse' {
                $parsedData += $Transaction.ForEach{
                    # Build an object of longitude/latidude data for the current payee
                    $subtrans = $_.subtransaction.ForEach{
                        [PSCustomObject]@{
                            Amount = ([double]$_.amount / 1000)
                            Memo = $_.memo
                            Payee = $_.payee_name
                            Category = $_.category_name
                            Account = $_.account_name
                            PayeeID = $_.payee_id
                            CategoryID = $_.category_id
                            AccountID = $_.account_id
                        }
                    }
                    $subtrans.PSObject.TypeNames.Insert(0,'Ynab.Transaction')

                    # Return the formatted transaction data
                    $object = [PSCustomObject]@{
                        Date = [datetime]::ParseExact($_.date,'yyyy-MM-dd',$null)
                        Amount = ([double]$_.amount / 1000)
                        Memo = $_.memo
                        Cleared = $_.cleared
                        Approved = $_.approved
                        FlagColor = (Get-Culture).TextInfo.ToTitleCase($_.flag_color)
                        Payee = $_.payee_name
                        Category = $_.category_name
                        Account = $_.account_name
                        Subtransactions = $subtrans
                        PayeeID = $_.payee_id
                        CategoryID = $_.category_id
                        AccountID = $_.account_id
                    }
                    $object.PSObject.TypeNames.Insert(0,'Ynab.Transaction')
                    $object
                }
            }
        }
    }

    end {
        $parsedData.PSObject.TypeNames.Insert(0,'Ynab.Transaction')
        $parsedData
    }
}

function Get-ParsedCategoryJson {
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [Object[]]$Category,
        [Switch]$List,
        [Switch]$IncludeHidden,
        [Switch]$NoParse
    )

    begin {
        $parsedData = @()
    }

    process {
        if ($List) {
            # Get rid of hidden category groups unless $IncludeHidden is $true
            $includedCategories = $Category.Where{
                if (!$IncludeHidden) {
                    $_.hidden -ne $true -and $_.name -ne 'Internal Master Category'
                } else {
                    $_.name -ne 'Internal Master Category'
                }
            }
            
            if (!$NoParse) {
                # Parse the data if -NoParse is not specified
                $parsedData += $includedCategories.ForEach{
                    # Build an object of subcategories for each group
                    $categories = $_.categories.Where{
                        # Get rid of hidden categories unless $IncludeHidden is $true
                        if (!$IncludeHidden) {
                            $_.hidden -ne $true
                        } else {$true}
                    }.ForEach{
                        [PSCustomObject]@{
                            Category = $_.name
                            Note = $_.note
                            Budgeted = ([double]$_.budgeted / 1000)
                            Activity = ([double]$_.activity / 1000)
                            Balance = ([double]$_.balance / 1000)
                            Hidden = $_.hidden
                            CategoryID = $_.id
                        }
                    } | Sort-Object Category

                    # Don't return the category group if there aren't any categories
                    if ($categories) {
                        [PSCustomObject]@{
                            CategoryGroup = $_.name
                            Hidden = $_.hidden
                            Categories = $categories
                            CategoryGroupID = $_.id
                        }
                    }
                } | Sort-Object CategoryGroup
            } else {
                # Return unparsed data if -NoParse is specified
                $parsedData += $includedCategories.ForEach{$_}
            }
        } else {
            # If list isn't specified, parse as a single category
            if (!$NoParse) {
                $parsedData += $Category.ForEach{
                    # Return the formatted data
                    [PSCustomObject]@{
                        Category = $_.name
                        Note = $_.note
                        Budgeted = ([double]$_.budgeted / 1000)
                        Activity = ([double]$_.activity / 1000)
                        Balance = ([double]$_.balance / 1000)
                        Hidden = $_.hidden
                        CategoryID = $_.id
                    }
                } | Sort-Object Category
            } else {
                # Return unparsed data
                $parsedData += $Category.ForEach{$_}
            }
        }
    }

    end {
        $parsedData
    }
}
