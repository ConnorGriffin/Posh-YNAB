function Add-YnabTransactionPreset {
    <#
    .SYNOPSIS
    Add a transaction preset to be used in Add-YnabTransaction.
    .DESCRIPTION
    Add a transaction preset to be used in Add-YnabTransaction.
    Presets are stored in $ENV:AppData\PSModules\Posh-YNAB\Presets.xml
    .EXAMPLE
    Add-YnabTransactionPreset -PresetName 'Coffee' -BudgetName 'TestBudget' -AccountName 'Checking' -CategoryName 'Food' -Memo 'Coffee' -Outflow 3.50
    Adds a transaction preset called Coffee that can be used in Add-YnabTransaction with Add-YnabTransaction -PresetName 'Coffee'
    #>
    [CmdletBinding(DefaultParameterSetName='Preset')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='API key are provided as plaintext (See -NuGetApiKey for Publish-Module), so this is actually improving security by storing the keys as a SecureString. AWS has CLI tools that store API keys in plaintext files in a ~\.aws\ folder, for example. See also: https://github.com/PowerShell/PSScriptAnalyzer/issues/574')]
    param(
        # The name to save the preset with (see: Add-YnabTransactionPreset).
        [Parameter(Mandatory,
                   Position=0,
                   ValueFromPipelineByPropertyName)]
        [Alias('Name','PresetName')]
        [String]$Preset,

        # The name of the budget to add the transaction to.
        [Parameter(Position=1,
                   ValueFromPipelineByPropertyName)]
        [String]$Budget,

        # The name of the account to add the transaction to.
        [Parameter(Position=2,
                   ValueFromPipelineByPropertyName)]
        [String]$Account,

        # The name of the payee to add the transaction to.
        [Parameter(Position=3,
                   ValueFromPipelineByPropertyName)]
        [String]$Payee,

        # The name of the category to add the transaction to.
        [Parameter(Position=4,
                   ValueFromPipelineByPropertyName)]
        [String]$Category,

        # Memo for the transaction.
        [Parameter(Position=5,
                   ValueFromPipelineByPropertyName)]
        [String]$Memo,

        # Outflow amount for the transaction.
        # Uses absolute value, so a positive or negative number can be provided.
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Outflow')]
        [Double]$Outflow,

        # Inflow amount for the transaction.
        # Uses absolute value, so a positive or negative number can be provided.
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Inflow')]
        [Double]$Inflow,

        # Amount for the transaction. Negative = Outflow, Positive = Inflow
        [Parameter(Mandatory,
                   Position=6,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Preset,Amount')]
        [Double]$Amount,

        # Date for the trarnsaction.
        # Defaults to today.
        [Parameter(Position=7,
                   ValueFromPipelineByPropertyName)]
        [Datetime]$Date,

        # YNAB API token.
        [Parameter(Position=8,
                   ValueFromPipelineByPropertyName)]
        $Token,

        # Flag color for the transaction.
        [Parameter(Position=9,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Red','Orange','Yellow','Green','Blue','Purple','')]
        [String]$FlagColor,

        # If specified the transaction will be marked as CLeared.
        [Parameter(Position=10)]
        [Switch]$Cleared,

        # If specified the transaction will be marked as Approved.
        # Defaults to $true.
        [Parameter(Position=11,
                   ValueFromPipelineByPropertyName)]
        [Bool]$Approved=$true
    )

    begin {
        # Encrypt the token if it is of type String, replace $PSBoundParameters.Token with the SecureString version
        $data = $PSBoundParameters
        if ($Token.GetType().Name -eq 'String') {
            $data.Token = $Token | ConvertTo-SecureString -AsPlainText -Force
        }

        # Import the preset file if one exists
        $presetFile = Join-Path $profilePath Presets.xml
        if (Test-Path $presetFile) {
            $presets = Import-Clixml $presetFile
        } else {
            $presets = @{}
        }
    }

    process {
        # Remove the preset from the hashtable (does nothing if it does not exist)
        $presets.Remove($Preset)

        # Add all of the parameter values to a hashtable. Can't use $PSBoundParameters because it breaks pipeline support :(
        $data = @{
            Budget = $Budget
            Account = $Account
            Payee = $Payee
            Category = $Category
            Memo = $Memo
            Outflow = $Outflow
            Inflow = $Inflow
            Amount = $Amount
            Date = $Date
            Token = $Token
            FlagColor = $FlagColor
            Cleared = $Cleared
            Approved = $Approved
        }

        # Determine null entries to remove (easier than only adding non-null to $data with a ton of ifs)
        $remove = $data.GetEnumerator().ForEach{
            if (!$_.Value) {
                $_.Key
            }
        }

        # Actually remove the values (can't modify $data during a foreach)
        $remove.ForEach{
            $data.Remove($_)
        }

        # Add the preset data to the presets hashtable, then export to $presetFile
        $presets += @{$Preset = $data}
    }

    end {
        $presets | Export-Clixml $presetFile
    }
}
