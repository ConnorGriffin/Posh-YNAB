function Get-YNABTransactionPreset {
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
    [CmdletBinding(DefaultParameterSetName='List')]
    param(
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='LoadPreset')]
        [String[]]$PresetName,

        [Parameter(ParameterSetName='List')]
        [Switch]$List
    )

    begin {}

    process {
        # Import the preset file if one exists
        $presetFile = "$profilePath\Presets.xml"
        if (Test-Path $presetFile) {
            $presets = Import-Clixml $presetFile

            switch ($PsCmdlet.ParameterSetName) {
                'LoadPreset' {
                    $PresetName.ForEach{
                        $name = $_
                        $presets.GetEnumerator().Where{$_.Name -eq $name}
                    }
                }
                'List' {
                    $presets
                }
            }
        }
    }
}
