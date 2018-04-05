param($Phase)

Switch ($Phase) {
    'Install' {
    }
    'Build' {
        $localModPath = $env:PSModulePath.Split(':')[0]
        Copy-Item -Recurse ./Posh-YNAB/ $localModPath
        Publish-Module -Name 'Posh-YNAB' -NugetApiKey $ENV:PSGalleryAPIKey -ErrorAction Stop
    }
}
