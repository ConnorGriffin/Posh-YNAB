function Get-Header {
    param($Token)
    @{
        Authorization = "Bearer $Token"
        'Content-Type' = 'application/json; charset=utf-8'
    }
}
