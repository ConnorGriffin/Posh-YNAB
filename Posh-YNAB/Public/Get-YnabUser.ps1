function Get-YnabUser {
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
        [Parameter(Mandatory=$true)]
        $Token
    )

    begin {
        # Set the default header value for Invoke-RestMethod
        $header = Get-Header $Token
    }

    process {
        $response = Invoke-RestMethod "$uri/user" -Headers $header

        if ($response) {
            [PSCustomObject] @{
                UserID = $response.data.user.id
            }
        }
    }
}
