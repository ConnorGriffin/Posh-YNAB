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
    [CmdletBinding(DefaultParameterSetName='NoAmount')]
    param(
        [Parameter(Position=0)]
        [Alias('Preset')]
        [String]$PresetName,

        [Parameter(Position=10)]
        [Alias('Budget')]
        [String]$BudgetName,

        [Parameter(Position=11,DontShow)]
        [String]$BudgetID,

        [Parameter(Position=20)]
        [Alias('Account')]
        [String]$AccountName,

        [Parameter(Position=21,DontShow)]
        [String]$AccountID,

        [Parameter(Position=30)]
        [Alias('Payee')]
        [String]$PayeeName,

        [Parameter(Position=31,DontShow)]
        [String]$PayeeID,

        [Parameter(Position=40)]
        [Alias('Category')]
        [String]$CategoryName,

        [Parameter(Position=41,DontShow)]
        [String]$CategoryID,

        [Parameter(Position=50)]
        [String]$Memo,

        [Parameter(Mandatory=$true,Position=60,ParameterSetName='Outflow')]
        [Parameter(Mandatory=$false,Position=60,ParameterSetName='NoAmount')]
        [Double]$Outflow,

        [Parameter(Mandatory=$true,Position=61,ParameterSetName='Inflow')]
        [Parameter(Mandatory=$false,Position=61,ParameterSetName='NoAmount')]
        [Double]$Inflow,

        [Parameter(Mandatory=$true,Position=62,ParameterSetName='Amount')]
        [Parameter(Mandatory=$false,Position=62,ParameterSetName='NoAmount')]
        [Double]$Amount,

        [Parameter(Position=70)]
        [Datetime]$Date = (Get-Date),

        [Parameter(Position=80)]
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
