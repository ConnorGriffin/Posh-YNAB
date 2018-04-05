param($Phase)

Switch ($Phase) {
    'Install' {
        Install-Module PSDeploy -Force
    }
    'Build' {
        Invoke-PSDeploy -Tags Remote -Force
    }
}
