function Get-Header {
    param($Token)

    # Decrypt the token if it is of type SecureString
    if ($Token.GetType().Name -eq 'SecureString') {
        $Token = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($Token))
    }

    @{
        Authorization = "Bearer $Token"
        'Content-Type' = 'application/json; charset=utf-8'
    }
}
