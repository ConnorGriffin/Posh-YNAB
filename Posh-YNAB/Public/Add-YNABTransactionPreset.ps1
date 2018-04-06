function Add-YNABTransactionPreset {
    <#
    .SYNOPSIS
    Add a transaction preset to be used in Add-YNABTransaction.
    .DESCRIPTION
    Add a transaction preset to be used in Add-YNABTransaction.
    Presets are stored in $ENV:AppData\PSModules\Posh-YNAB\Presets.xml
    .EXAMPLE
    Add-YNABTransactionPreset -PresetName 'Coffee' -BudgetName 'TestBudget' -AccountName 'Checking' -CategoryName 'Food' -Memo 'Coffee' -Outflow 3.50
    Adds a transaction preset called Coffee that can be used in Add-YNABTransaction with Add-YNABTransaction -PresetName 'Coffee'
    .PARAMETER PresetName
    The name of the preset to remove, accepts a string or array of strings. Supports wildcards.
    .PARAMETER BudgetName
    The name of the budget to add the transaction to.
    .PARAMETER BudgetID
    The ID of the budget to add the transaction to.
    Takes priority over BudgetName if both are provided.
    .PARAMETER AccountName
    The name of the account to add the transaction to.
    .PARAMETER AccountID
    The ID of the account to add the transaction to.
    Takes priority over AccountName if both are provided.
    .PARAMETER PayeeName
    The name of the payee to add the transaction to.
    .PARAMETER PayeeID
    The ID of the payee to add the transaction to.
    Takes priority over PayeeName if both are provided.
    .PARAMETER CategoryName
    The name of the category to add the transaction to.
    .PARAMETER CategoryID
    The ID of the category to add the transaction to.
    Takes priority over CategoryName if both are provided.
    .PARAMETER Memo
    Memo for the transaction.
    .PARAMETER Outflow
    Outflow amount for the transaction.
    Uses absolute value, so a positive or negative number can be provided.
    .PARAMETER Inflow
    Inflow amount for the transaction.
    Uses absolute value, so a positive or negative number can be provided.
    .PARAMETER Amount
    Amount for the transaction.
    Negative = Outflow, Positive = Inflow
    .PARAMETER Date
    Date for the trarnsaction.
    Defaults to today.
    .PARAMETER Token
    API token used to post the transaction.
    .PARAMETER FlagColor
    Flag color for the transaction.
    .PARAMETER Cleared
    If specified the transaction will be marked as CLeared.
    .PARAMETER Approved
    If specified the transaction will be marked as Approved.
    Defaults to $true.
    #>
    [CmdletBinding(DefaultParameterSetName='NoAmount')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='API key are provided as plaintext (See -NuGetApiKey for Publish-Module), so this is actually improving security by storing the keys as a SecureString. AWS has CLI tools that store API keys in plaintext files in a ~\.aws\ folder, for example. See also: https://github.com/PowerShell/PSScriptAnalyzer/issues/574')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
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
