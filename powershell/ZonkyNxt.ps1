Add-Type -AssemblyName System.Web
$uri = 'https://app.zonky.cz/api/oauth/authorize?client_id=mujrobot&redirect_uri=https://app.zonky.cz/api/oauth/code&response_type=code&scope=SCOPE_APP_BASIC_INFO+SCOPE_INVESTMENT_READ&state=opaque'
$ie = New-Object -ComObject InternetExplorer.Application
$ie.Visible=$false
$ie.Navigate($uri)
while ($ie.ReadyState -ne 4) {Start-Sleep -m 100}
$ie.document.getElementById("email").value = ""
$ie.document.getElementById("password").value =""
$ie.Document.getElementById("login-form").submit()
while ($ie.ReadyState -ne 4) {Start-Sleep -m 100}
$uri_code = [uri]$ie.LocationURL
$code=[System.Web.HttpUtility]::ParseQueryString(($uri_code).Query)['code']
$ie.Stop()
$ie.Quit()

$code

class Crdential{
    [string]$access_token = ''
    [string]$token_type = ''
    [string]$refresh_token = ''
    [string]$expires_in = ''
    [string]$scope = 'SCOPE_APP_BASIC_INFO SCOPE_INVESTMENT_READ'
    [string]$username = 'mujrobot'
    [string]$password = 'mujrobot'
    [string]$code = 'mujrobot'
    [string]$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username`:$password"))
}

class ZonkyNxt {
    class Credential {
    }
}

function login()
{
    $auth_code = '6OC7YE'
    $auth = 'mujrobot:mujrobot' 
    $auth_b64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$auth"))
    $scope = 'SCOPE_APP_BASIC_INFO SCOPE_INVESTMENT_READ'
    $redirect_uri = 'https://app.zonky.cz/api/oauth/code'

    $Headers = @{
        'Content-Type'='application/x-www-form-urlencoded'
        'Authorization'="Basic $auth_b64"
    }

    $body = "scope=$scope&grant_type=authorization_code&code=$auth_code&redirect_uri=$redirect_uri"
    $uri = "https://api.zonky.cz/oauth/token"
    try {
        $auth = Invoke-RestMethod -Method POST -Uri $URI -Headers $Headers -Body $Body  -UseBasicParsing
    } catch {
        $ex = $_
        Write-Host $ex.Exception.Message
    }
}

function Get-ActiveInvestments() {
    $Headers = @{
        'Content-Type'  = 'application/x-www-form-urlencoded'
        'Authorization' = "$($res.token_type) $($res.access_token)"
        'User-Agent' = 'zonkyNXT/1.0 (https://github.com/MilanNXT/ZonkyNxt)'
    }
    #/users/me/investments?loan.status__in=%5B%22ACTIVE%22,%22PAID_OFF%22%5D&status__eq=ACTIVE
    $uri = "https://api.zonky.cz/users/me/investments?loan.status__in=[ACTIVE,PAID_OFF]&status__eq=ACTIVE"
    $res = Invoke-RestMethod -Method Get -Uri $URI -Headers $Headers -UseBasicParsing
    return $res
}

function Get-MarketPlace([string]$bearer, [int]$page, [int]$size) {
    $Headers = @{
        'Content-Type'  = 'application/x-www-form-urlencoded'
        'Authorization' = "$($res.token_type) $($res.access_token)"
        'X-Page'        = "$page"
        'X-Size'        = "$size"
    }
    #/users/me/investments?loan.status__in=%5B%22ACTIVE%22,%22PAID_OFF%22%5D&status__eq=ACTIVE
    $uri = "https://api.zonky.cz/loans/marketplace?nonReservedRemainingInvestment__gt=0"
    $res = Invoke-RestMethod -Method Get -Uri $URI -Headers $Headers  -UseBasicParsing
    return $res
}

