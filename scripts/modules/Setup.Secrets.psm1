# Setup.Secrets.psm1
# Password generation and secret management

function New-Password {
    <#
    .SYNOPSIS
    Generates a cryptographically secure random password
    
    .PARAMETER Length
    Length of the password to generate (default: 32)
    
    .EXAMPLE
    New-Password -Length 64
    #>
    param([int]$Length = 32)
    
    # Try OpenSSL first (more secure and faster)
    try {
        $openssl = Get-Command openssl -ErrorAction Stop
        $bytes = [math]::Ceiling($Length * 4 / 3)
        $raw = & $openssl.Source rand -base64 $bytes
        if ($raw) {
            $clean = ($raw -replace '[=+/]', '').Substring(0, [Math]::Min($Length, $raw.Length))
            if ($clean.Length -eq $Length) { return $clean }
        }
    } catch {
        # Fallback to PowerShell RNG
    }
    
    # Fallback: Use PowerShell's Get-Random
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_'
    -join (0..($Length-1) | ForEach-Object { 
        $alphabet[(Get-Random -Maximum $alphabet.Length)] 
    })
}

function New-SecretSet {
    <#
    .SYNOPSIS
    Generates a complete set of secrets for an environment
    
    .DESCRIPTION
    Creates all required passwords for PostgreSQL roles, Redis users, and application secrets
    
    .EXAMPLE
    $secrets = New-SecretSet
    #>
    [OutputType([hashtable])]
    param()
    
    $set = [ordered]@{
        APP_SECRET                    = New-Password -Length 64
        POSTGRES_SUPERUSER_PASSWORD   = New-Password
        ADMIN_PASSWORD                = New-Password
        DEVELOPER_PASSWORD            = New-Password
        API_PASSWORD                  = New-Password
        READONLY_PASSWORD             = New-Password
        BACKUP_PASSWORD               = New-Password
        AUDITOR_PASSWORD              = New-Password
        REDIS_PASSWORD                = New-Password
        ADMIN_USER_REDIS_PASSWORD     = New-Password
        DEVELOPER_USER_REDIS_PASSWORD = New-Password
        API_USER_REDIS_PASSWORD       = New-Password
        READONLY_USER_REDIS_PASSWORD  = New-Password
        BACKUP_USER_REDIS_PASSWORD    = New-Password
        AUDITOR_USER_REDIS_PASSWORD   = New-Password
        ADMIN_USER_PASSWORD           = New-Password
        DEVELOPER_USER_PASSWORD       = New-Password
        API_USER_PASSWORD             = New-Password
        READONLY_USER_PASSWORD        = New-Password
        BACKUP_USER_PASSWORD          = New-Password
        AUDITOR_USER_PASSWORD         = New-Password
        REDIS_DEFAULT_USER_PASSWORD   = New-Password
    }
    
    return $set
}

function Read-EnvFileSecrets {
    <#
    .SYNOPSIS
    Reads secrets from an environment file
    
    .PARAMETER EnvFile
    Path to the .env file
    
    .EXAMPLE
    $secrets = Read-EnvFileSecrets -EnvFile '.env.dev'
    #>
    [OutputType([hashtable])]
    param([string]$EnvFile)
    
    if (-not (Test-Path $EnvFile)) {
        throw "Environment file '$EnvFile' not found."
    }
    
    $map = @{}
    foreach ($line in Get-Content $EnvFile) {
        if ($line -match '^(?<key>[A-Z0-9_]+)=(?<value>.*)$') {
            $map[$matches.key] = $matches.value
        }
    }
    
    return $map
}

function Show-SecretReport {
    <#
    .SYNOPSIS
    Displays all secrets for a given environment
    
    .PARAMETER Environment
    The environment name (dev, staging, prod)
    
    .PARAMETER RepoRoot
    Root directory of the repository
    
    .EXAMPLE
    Show-SecretReport -Environment 'dev' -RepoRoot $PSScriptRoot
    #>
    param(
        [string]$Environment,
        [string]$RepoRoot
    )
    
    Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
    
    $envFile = Join-Path $RepoRoot ".env.$Environment"
    $data = Read-EnvFileSecrets -EnvFile $envFile
    
    Write-Heading "Secrets for $Environment"
    foreach ($key in ($data.Keys | Sort-Object)) {
        Write-Host "$($PSStyle.Foreground.BrightBlack)$key$($PSStyle.Reset): $($data[$key])"
    }
}

# Export module members
Export-ModuleMember -Function @(
    'New-Password',
    'New-SecretSet',
    'Read-EnvFileSecrets',
    'Show-SecretReport'
)