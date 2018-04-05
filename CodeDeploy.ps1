param($Phase)

Switch ($Phase) {
    'Install' {
    }
    'Build' {
        Write-Host $env:PSModulePath
    }
}
