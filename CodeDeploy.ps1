[cmdletBinding()]
param($Phase)

Switch ($Phase) {
    'Install' {
    }
    'Build' {
        Publish-Module -Path ./Posh-YNAB/ -NugetApiKey $ENV:PSGalleryAPIKey
    }
}
