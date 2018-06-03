function Remove-YnabTransactionPreset {
    <#
    .SYNOPSIS
    Remove transaction presets.
    .DESCRIPTION
    Remove transaction presets from the preset file.
    .EXAMPLE
    Remove-YnabTransactionPreset -PresetName 'Coffee'
    Remove the Coffee preset.
    .EXAMPLE
    Remove-YnabTransactionPreset -PresetName 'Coffee','Soda'
    Remove the Coffee and Soda presets.
    .EXAMPLE
    Remove-YnabTransactionPreset -PresetName '*'
    Remove all presets.
    .PARAMETER PresetName
    The name of the preset to remove, accepts a string or array of strings. Supports wildcards.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Preset')]
        [String[]]$PresetName
    )

    begin {}

    process {
        # Import the preset file if one exists
        $presetFile = "$profilePath\Presets.xml"
        if (Test-Path $presetFile) {
            $presets = Import-Clixml $presetFile

            # Iterate through the provided PresetNames
            $PresetName.ForEach{
                $name = $_

                # Get presets that match the provided name
                $presetNames = $presets.GetEnumerator().Where{$_.Name -like $name}.Name

                # Iterate through the matches, remove the object from the hashtable
                $presetNames.ForEach{
                    $presets.Remove($_)
                }
            }
        }
        # Export the presets
        $presets | Export-Clixml $presetFile
    }
}
