function Get-YnabTransactionPreset {
    <#
    .SYNOPSIS
    List transaction presets.
    .DESCRIPTION
    List transaction presets from the preset file.
    .EXAMPLE
    Get-YnabTransactionPreset -PresetName 'Coffee'
    Get the Coffee preset.
    .EXAMPLE
    Get-YnabTransactionPreset -PresetName 'Coffee','Soda'
    Get the Coffee and Soda presets.
    .EXAMPLE
    Get-YnabTransactionPreset -PresetName '*'
    Get all presets
    .PARAMETER Preset
    The name of the preset to list, accepts a string or array of strings. Supports wildcards.
    .PARAMETER List
    Returns a list of all presets
    #>
    [CmdletBinding(DefaultParameterSetName='List')]
    param(
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='LoadPreset')]
        [String[]]$Preset,

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
                    $Preset.ForEach{
                        $name = $_
                        $presets.GetEnumerator().Where{$_.Name -like $name}
                    }
                }
                'List' {
                    $presets
                }
            }
        }
    }
}
