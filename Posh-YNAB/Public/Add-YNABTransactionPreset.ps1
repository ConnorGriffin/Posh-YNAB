function Add-YNABTransactionPreset {
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
    [CmdletBinding(DefaultParameterSetName='Outflow')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$PresetName,

        [Parameter(Position=10,ParameterSetName='Amount')]
        [Parameter(Position=10,ParameterSetName='Inflow')]
        [Parameter(Position=10,ParameterSetName='Outflow')]
        [Alias('Budget')]
        [String]$BudgetName,

        [Parameter(Position=10,DontShow)]
        [String]$BudgetID,

        [Parameter(Position=20,ParameterSetName='Amount')]
        [Parameter(Position=20,ParameterSetName='Inflow')]
        [Parameter(Position=20,ParameterSetName='Outflow')]
        [Alias('Account')]
        [String]$AccountName,

        [Parameter(Position=20,DontShow)]
        [String]$AccountID,

        [Parameter(Position=30,ParameterSetName='Amount')]
        [Parameter(Position=30,ParameterSetName='Inflow')]
        [Parameter(Position=30,ParameterSetName='Outflow')]
        [Alias('Payee')]
        [String]$PayeeName,

        [Parameter(Position=30,DontShow)]
        [String]$PayeeID,

        [Parameter(Position=40,ParameterSetName='Amount')]
        [Parameter(Position=40,ParameterSetName='Inflow')]
        [Parameter(Position=40,ParameterSetName='Outflow')]
        [Alias('Category')]
        [String]$CategoryName,

        [Parameter(Position=40,DontShow)]
        [String]$CategoryID,

        [Parameter(Position=50)]
        [String]$Memo,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Outflow')]
        [Double]$Outflow,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Inflow')]
        [Double]$Inflow,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Amount')]
        [Double]$Amount,

        [Parameter(Position=70)]
        [Datetime]$Date = (Get-Date),

        [Parameter(Mandatory=$true,Position=80)]
        $Token,

        [Parameter(Position=90)]
        [ValidateSet('Red','Orange','Yellow','Green','Blue','Purple')]
        [String]$FlagColor,

        [Parameter(Position=100)]
        [Switch]$Cleared,

        [Parameter(Position=110)]
        [Bool]$Approved=$true
    )

    begin {
        Write-Verbose "New-YNABTransactionPreset.ParameterSetName: $($PsCmdlet.ParameterSetName)"

        # Encrypt the token if it is of type String, replace $PSBoundParameters.Token with the SecureString version
        $data = $PSBoundParameters
        if ($Token.GetType().Name -eq 'String') {
            $data.Token = $Token | ConvertTo-SecureString -AsPlainText -Force
        }

        # Import the preset file if one exists
        $presetFile = "$profilePath\Presets.xml"
        if (Test-Path $presetFile) {
            $presets = Import-Clixml $presetFile
        } else {
            $presets = @{}
        }
    }

    process {
        # Get the preset name and then remove it from the parameters array
        $name = $data.PresetName
        [Void]$data.Remove('PresetName')

        # Remove the preset from the hashtable (does nothing if it does not exist)
        $presets.Remove($name)

        # Add the preset data to the presets hashtable, then export to $presetFile
        $presets += @{$name = $data}
        $presets | Export-Clixml $presetFile
    }
}
