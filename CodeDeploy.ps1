[cmdletBinding()]
param(
    [String]$Phase='Build',
    [Switch]$WhatIf
)

Switch ($Phase) {
    'Build' {
        Publish-Module -Path ./Posh-YNAB/ -NugetApiKey $ENV:PSGalleryAPIKey -WhatIf:$WhatIf
    }
}
