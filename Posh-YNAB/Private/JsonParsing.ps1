# ALl JSON parsing functions should live here.

function Get-ParsedAccountJson {
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
        [Object[]]$Account
    )

    begin {}

    process {
        $Account.ForEach{
            [PSCustomObject]@{
                AccountID = $_.id
                Name = $_.name
                Type = $_.type
                OnBudget = $_.on_budget
                Closed = $_.closed
                Note = $_.note
                Balance = ([double]$_.balance / 1000)
                ClearedBalance = ([double]$_.cleared_balance / 1000)
                UnclearedBalance = ([double]$_.uncleared_balance / 1000)
            }
        }
    }
}

function Get-ParsedPayeeJson {
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
        [Object[]]$Payee,

        [Parameter(ValueFromPipeline)]
        [Object[]]$PayeeLocation
    )

    begin {}

    process {
        $Payee.ForEach{
            $payeeId = $_.id

            # Build an object of longitude/latidude data for the current payee
            $location = $PayeeLocation.Where{$_.payee_id -eq $payeeId}.ForEach{
                [PSCustomObject]@{
                    Latitude = $_.latitude
                    Longitude = $_.longitude
                    Maps = "https://maps.google.com/maps?q=$($_.latitude),$($_.longitude)"
                }
            }

            # Return the formatted payee data
            [PSCustomObject]@{
                PayeeID = $payeeId
                Name = $_.name
                TransferAccountID = $_.transfer_account_id
                Location = $location
            }
        }
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
        Write-Verbose "ParameterSetName: $($PsCmdlet.ParameterSetName)"
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Detail' {
                # If no ParsedPayee data is provided, generate it
                if (!$ParsedPayee -and $Payee) {
                    $ParsedPayee = Get-ParsedPayeeJson $Payee $PayeeLocation
                }

                $Transaction.ForEach{
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

                    # Return the formatted transaction data
                    [PSCustomObject]@{
                        Date = [datetime]::ParseExact($_.date,'yyyy-MM-dd',$null)
                        Amount = ([double]$_.amount / 1000)
                        Memo = $_.memo
                        Cleared = $_.cleared
                        Approved = $_.approved
                        #account
                        Payee = $payee.Name
                        #Category
                        PayeeID = $payee.PayeeId
                        #CategoryID
                        Subtransactions = $subtrans
                    }
                }
            }
            'TransactionResponse' {
                $Transaction.ForEach{
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

                    # Return the formatted transaction data
                    [PSCustomObject]@{
                        Date = [datetime]::ParseExact($_.date,'yyyy-MM-dd',$null)
                        Amount = ([double]$_.amount / 1000)
                        Memo = $_.memo
                        Cleared = $_.cleared
                        Approved = $_.approved
                        FlagColor = $_.flag_color
                        Payee = $_.payee_name
                        Category = $_.category_name
                        Account = $_.account_name
                        PayeeID = $_.payee_id
                        CategoryID = $_.category_id
                        AccountID = $_.account_id
                        Subtransactions = $subtrans
                    }
                }
            }
        }
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
        [Object[]]$Category
    )

    begin {}

    process {
        $Category.ForEach{
            $categoryId = $_.id

            # Return the formatted data
            [PSCustomObject]@{
                CategoryID = $categoryId
                Name = $_.name
            }
        }
    }
}
