$script:moduleName = 'Posh-YNAB'
# Get the PSD1 data for this module
$psd1 = Import-LocalizedData -BaseDirectory $PSScriptRoot\$moduleName -FileName (Get-ChildItem -Path $PSScriptRoot\$moduleName\*.psd1).Name

$moduleVersion = $psd1.ModuleVersion
$localModPath = $env:PSModulePath.Split(';') | Where-Object {$_ -match 'Documents'}

Deploy Module {
    By PSGalleryModule {
        FromSource "$PSScriptRoot\$moduleName"
        To "PSGallery"
        Tagged Remote
        WithOptions @{
            ApiKey = $ENV:PSGalleryAPIKey
        }
    }
    By FileSystem {
        FromSource "$PSScriptRoot\$moduleName"
        To "$localModPath\$moduleName\$moduleVersion"
        Tagged Local
        WithPostScript {
            Import-Module $moduleName -Force -Global
        }
    }
}
