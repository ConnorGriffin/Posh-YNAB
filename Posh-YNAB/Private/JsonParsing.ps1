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
                'On Budget' = $_.on_budget
                Closed = $_.closed
                Note = $_.note
                Balance = ([double]$_.balance / 1000)
                'Cleared Balance' = ([double]$_.cleared_balance / 1000)
                'Uncleared Balance' = ([double]$_.uncleared_balance / 1000)
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
                'Transfer AccountID' = $_.transfer_account_id
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [Object[]]$Transaction,

        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [Object[]]$Subtransaction,

        [Parameter(Mandatory=$false,ValueFromPipeline)]
        [Object[]]$Payee,

        [Parameter(Mandatory=$false,ValueFromPipeline)]
        [Object[]]$PayeeLocation,


        [Parameter(Mandatory=$false,ValueFromPipeline)]
        [Object[]]$ParsedPayee
    )

    begin {}

    process {
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
}
