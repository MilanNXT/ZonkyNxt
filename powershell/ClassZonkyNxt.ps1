#Requires -Version 5
Add-Type -AssemblyName System.Web

class zCredential {
    [string]$email
    [securestring]$password

    zCredential() {}
    zCredential([string]$Email,[securestring]$Password){
        $this.email=$Email
        $this.password=$Password
    } 
    [string] get_plain_password() {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.password))
    }
}

class zApi {
    [string[]]$scope = @('SCOPE_APP_BASIC_INFO','SCOPE_INVESTMENT_READ')
    [string]$redirect_uri = 'https://app.zonky.cz/api/oauth/code'
    [string]$user_agent = 'zonkyNXT/1.0 (https://github.com/MilanNXT/ZonkyNxt)'    
    [string]$authorization_code
    [string]$client_id
    [string]$name
    [string]$password
    [System.Management.Automation.PSCustomObject]$oauth
    [System.Collections.Hashtable]$token = @{
        'access' = ''
        'type' = ''
        'refresh' = ''
        'expires_in' = ''
    }

    zApi([string]$ApiClientId,[string]$ApiName,[string]$ApiPassword) {
        $this.client_id = $ApiClientId
        $this.name = $ApiName
        $this.password = $ApiPassword
    }
    [string] get_scope([char]$JoinChar=' ') {
        return $this.scope -join $JoinChar
    } 
    [string] get_credential() {
        return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($this.name):$($this.password)"))
    }
    [void] get_access_token()
    {
        $Headers = @{
            'Content-Type'='application/x-www-form-urlencoded'
            'Authorization'="Basic $($this.get_credential())"
            'User-Agent' = $this.user_agent
        }
        $body = "scope=$($this.get_scope())&grant_type=authorization_code&code=$($this.authorization_code)&redirect_uri=$($this.redirect_uri)"
        $uri = "https://api.zonky.cz/oauth/token"
        try {
            $tkn = Invoke-RestMethod -Method POST -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
            
        } catch {
            $ex = $_
            Write-Host $ex.Exception.Message
        }    
    }
}

class zLogin {
    hidden [string]$pwd_file
    [zCredential]$credential
    [zApi]$api = [zApi]::new('mujrobot','mujrobot','mujrobot')
    hidden [string]$login_uri = "https://app.zonky.cz/api/oauth/authorize?client_id=$($this.api.client_id)&redirect_uri=$($this.api.redirect_uri)&response_type=code&scope=$($this.api.get_scope('+'))&state=opaque"

    hidden init() {
        $this.init('ZonkyNxt.pwd')
    }
    hidden init([string]$PwdFile){
        if (Test-Path -Path $PwdFile) {
            $this.pwd_file=$PwdFile
        } else {
            $this.pwd_file='ZonkyNxt.pwd'
        }
        $tmp_cred = Get-Content -Path $this.pwd_file | ConvertFrom-Json
        $this.init($tmp_cred.email,(ConvertTo-SecureString -String $tmp_cred.password -AsPlainText -Force))
    }
    hidden init([string]$Email,[securestring]$Password) {
        $this.credential = [zCredential]::new($Email,$Password)
    }
    zLogin() {
        $this.init()
    }
    zLogin([string]$PwdFile) {
        $this.init($PwdFile)
    }
    zLogin([string]$Email,[securestring]$Password) {
        $this.init($Email,$Password)
    }
    zLogin([string]$Email,[string]$PlainPassword) {
        $this.init($Email,(ConvertTo-SecureString -String $PlainPassword -AsPlainText -Force))
    }
    [void] login() {
        $ie = New-Object -ComObject InternetExplorer.Application
        try{
            $ie.Visible=$true
            $ie.Navigate($this.login_uri)
            while ($ie.ReadyState -ne 4) {Start-Sleep -m 100}
            if ($ie.document.getElementById("email")) {
                $ie.document.getElementById("email").value = $this.credential.email
                $ie.document.getElementById("password").value = $this.credential.get_plain_password()
                $ie.Document.getElementById("login-form").submit()
                while ($ie.ReadyState -ne 4) {Start-Sleep -m 100}
            }
            if ($ie.LocationURL) {
                $uri_code = [uri]$ie.LocationURL
                $this.api.authorization_code=[System.Web.HttpUtility]::ParseQueryString(($uri_code).Query)['code']
            }
        } catch {
            $ex = $_
            Write-Host "Unable to precess Login..."
            Write-Host $ex.Exception.Message

        } finally {
            $ie.Stop()
            $ie.Quit()        
        }
    }
}

class ZonkyNxt {
    hidden [zLogin]$connection = [zLogin]::new()

    ZonkyNxt() {}
    [void] connect() {
        $this.connection.login()
        $this.connection.api.get_access_token()
    }
    hidden [string] get_authorization() {
        return "$($this.connection.api.token['type']) $($this.connection.api.token['access'])"
    }
    hidden [string] get_user_agent() {
        return "$($this.connection.api.user_agent)"
    }
    [void] get_active_investments() {
        $Headers = @{
            'Content-Type'  = 'application/x-www-form-urlencoded'
            'Authorization' = $this.get_authorization()
            'User-Agent' = $this.get_user_agent()
        }
        #/users/me/investments?loan.status__in=%5B%22ACTIVE%22,%22PAID_OFF%22%5D&status__eq=ACTIVE
        $uri = "https://api.zonky.cz/users/me/investments?loan.status__in=[ACTIVE,PAID_OFF]&status__eq=ACTIVE"
        $res = Invoke-RestMethod -Method Get -Uri $URI -Headers $Headers -UseBasicParsing
    }
    [void] get_marketplace([string]$bearer, [int]$page, [int]$size) {
        $Headers = @{
            'Content-Type'  = 'application/x-www-form-urlencoded'
            'Authorization' = $this.get_authorization()
            'User-Agent' = $this.get_user_agent()
            'X-Page'        = "$page"
            'X-Size'        = "$size"
        }
        #/users/me/investments?loan.status__in=%5B%22ACTIVE%22,%22PAID_OFF%22%5D&status__eq=ACTIVE
        $uri = "https://api.zonky.cz/loans/marketplace?nonReservedRemainingInvestment__gt=0"
        $res = Invoke-RestMethod -Method Get -Uri $URI -Headers $Headers  -UseBasicParsing
    }       
}
