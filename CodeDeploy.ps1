[cmdletBinding()]
param($Phase)

Switch ($Phase) {
    'Install' {
    }
    'Build' {
        Test-ModuleManifest -Path ./Posh-YNAB/Posh-YNAB.psd1 -Verbose
        Publish-Module -Path ./Posh-YNAB/ -NugetApiKey $ENV:PSGalleryAPIKey
    }
}
