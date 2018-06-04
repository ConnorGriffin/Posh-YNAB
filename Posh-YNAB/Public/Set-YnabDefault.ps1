function Set-YnabDefault {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
                                                        Justification='API key are often provided as plaintext (See -NuGetApiKey for Publish-Module), 
                                                                       so this is actually improving security by storing the keys as a SecureString. 
                                                                       AWS has CLI tools that store API keys in plaintext files in a ~\.aws\ folder, for example. 
                                                                       See also: https://github.com/PowerShell/PSScriptAnalyzer/issues/574')]
    Param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [String]$Budget,

        [Parameter(ValueFromPipelineByPropertyName)]
        $Token
    )

    begin {}
    
    process {
        # Encrypt the token if it is of type String
        if ($Token.GetType().Name -eq 'String') {
            $Token = $Token | ConvertTo-SecureString -AsPlainText -Force
        }

        $data = @{
            Budget = $Budget
            Token = $Token
        }

        # Export the provided parameters for the module import to read them later
        $data | Export-Clixml "$profilePath\Defaults.xml"

        # Re-import the module to reload the defaults
        Import-Module "$moduleRoot\$moduleName.psm1" -Global -Force
    }

    end {}
}
