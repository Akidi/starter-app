#!/usr/bin/env pwsh
#Requires -Version 7.2

<#
.SYNOPSIS
    Production Deployment Validation Script

.DESCRIPTION
    Validates that the production environment is properly configured and ready for deployment.
    Checks:
    - Required files exist
    - Docker and Docker Compose are installed
    - Environment variables are set correctly
    - Secrets are not weak or default
    - Services are healthy
    - SSL certificates (if configured)
    - Domain resolution (if configured)

.PARAMETER Environment
    Environment to validate (default: prod)

.PARAMETER Domain
    Domain name to check (optional)

.PARAMETER SkipDocker
    Skip Docker-related checks

.PARAMETER SkipSSL
    Skip SSL certificate checks

.EXAMPLE
    pwsh validate-production.ps1 -Environment prod

.EXAMPLE
    pwsh validate-production.ps1 -Environment prod -Domain "app.example.com"
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('dev', 'staging', 'prod')]
    [string]$Environment = 'prod',

    [Parameter()]
    [string]$Domain,

    [Parameter()]
    [switch]$SkipDocker,

    [Parameter()]
    [switch]$SkipSSL
)

# Error handling
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Colors
$Reset = "`e[0m"
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Bold = "`e[1m"

# Validation results
$script:FailCount = 0
$script:WarnCount = 0
$script:PassCount = 0

function Write-Header {
    param([string]$Text)
    Write-Host "`n${Bold}${Blue}━━━ $Text ━━━${Reset}`n"
}

function Write-Success {
    param([string]$Text)
    Write-Host "  ${Green}✓${Reset} $Text"
    $script:PassCount++
}

function Write-Failure {
    param([string]$Text)
    Write-Host "  ${Red}✗${Reset} $Text"
    $script:FailCount++
}

function Write-Warning {
    param([string]$Text)
    Write-Host "  ${Yellow}⚠${Reset} $Text"
    $script:WarnCount++
}

function Write-Info {
    param([string]$Text)
    Write-Host "  ${Blue}ℹ${Reset} $Text"
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-WeakPassword {
    param([string]$Password)

    if ([string]::IsNullOrWhiteSpace($Password)) {
        return $true
    }

    # Check minimum length
    if ($Password.Length -lt 16) {
        return $true
    }

    # Check for common weak passwords
    $weakPasswords = @('password', 'admin', '123456', 'changeme', 'secret', 'test')
    foreach ($weak in $weakPasswords) {
        if ($Password -like "*$weak*") {
            return $true
        }
    }

    return $false
}

# Get root directory
$RootDir = Split-Path -Parent $PSScriptRoot

Write-Host "${Bold}${Blue}"
Write-Host "╔════════════════════════════════════════════════════════╗"
Write-Host "║   Production Deployment Validation                    ║"
Write-Host "║   Environment: $($Environment.PadRight(38)) ║"
Write-Host "╚════════════════════════════════════════════════════════╝"
Write-Host "${Reset}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. Required Files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Header "Required Files"

$requiredFiles = @(
    @{ Path = ".env.$Environment"; Description = "Environment variables" }
    @{ Path = "docker-compose.$Environment.yml"; Description = "Docker Compose config" }
    @{ Path = "db/init.$Environment.sql"; Description = "Database initialization script" }
    @{ Path = "redis.$Environment.conf"; Description = "Redis configuration" }
    @{ Path = "redis.$Environment.acl"; Description = "Redis ACL" }
    @{ Path = "app/Dockerfile"; Description = "Application Dockerfile" }
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $RootDir $file.Path
    if (Test-Path $fullPath) {
        Write-Success "$($file.Description) exists: $($file.Path)"
    }
    else {
        Write-Failure "$($file.Description) missing: $($file.Path)"
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. System Dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Header "System Dependencies"

if (-not $SkipDocker) {
    # Docker
    if (Test-Command 'docker') {
        $dockerVersion = (docker --version) -replace 'Docker version ([0-9.]+).*', '$1'
        Write-Success "Docker installed: $dockerVersion"

        # Check Docker is running
        try {
            $null = docker ps 2>&1
            Write-Success "Docker daemon is running"
        }
        catch {
            Write-Failure "Docker daemon is not running or not accessible"
        }
    }
    else {
        Write-Failure "Docker is not installed"
    }

    # Docker Compose
    if (Test-Command 'docker') {
        try {
            $composeVersion = (docker compose version) -replace '.*version ([0-9.]+).*', '$1'
            Write-Success "Docker Compose installed: $composeVersion"
        }
        catch {
            Write-Failure "Docker Compose (plugin) is not installed"
        }
    }
}
else {
    Write-Info "Skipping Docker checks"
}

# PowerShell version
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 7) {
    Write-Success "PowerShell version: $($psVersion.ToString())"
}
else {
    Write-Failure "PowerShell 7.2+ required, found: $($psVersion.ToString())"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. Environment Variables
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Header "Environment Variables"

$envFile = Join-Path $RootDir ".env.$Environment"
if (Test-Path $envFile) {
    $envVars = @{}
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            $envVars[$matches[1].Trim()] = $matches[2].Trim()
        }
    }

    # Required environment variables
    $requiredVars = @(
        'APP_SECRET',
        'POSTGRES_PASSWORD',
        'DATABASE_URL',
        'REDIS_URL',
        'ORIGIN'
    )

    foreach ($varName in $requiredVars) {
        if ($envVars.ContainsKey($varName) -and -not [string]::IsNullOrWhiteSpace($envVars[$varName])) {
            Write-Success "$varName is set"
        }
        else {
            Write-Failure "$varName is not set or empty"
        }
    }

    # Check ORIGIN for production
    if ($Environment -eq 'prod' -and $envVars.ContainsKey('ORIGIN')) {
        $origin = $envVars['ORIGIN']
        if ($origin -like '*localhost*' -or $origin -like '*127.0.0.1*') {
            Write-Warning "ORIGIN is set to localhost in production: $origin"
        }
        elseif ($origin -like 'https://*') {
            Write-Success "ORIGIN uses HTTPS: $origin"
        }
        elseif ($origin -like 'http://*') {
            Write-Warning "ORIGIN uses HTTP (should be HTTPS in production): $origin"
        }
    }

    # Check NODE_ENV
    if ($envVars.ContainsKey('NODE_ENV')) {
        $nodeEnv = $envVars['NODE_ENV']
        if ($Environment -eq 'prod' -and $nodeEnv -ne 'production') {
            Write-Warning "NODE_ENV should be 'production' in prod environment, found: $nodeEnv"
        }
        else {
            Write-Success "NODE_ENV is set to: $nodeEnv"
        }
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. Secret Strength
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Header "Secret Strength"

$secretVars = @(
    'APP_SECRET',
    'POSTGRES_PASSWORD',
    'ADMIN_PASSWORD',
    'API_PASSWORD'
)

foreach ($varName in $secretVars) {
    if ($envVars.ContainsKey($varName)) {
        $value = $envVars[$varName]
        if (Test-WeakPassword $value) {
            Write-Failure "$varName appears to be weak (too short or common pattern)"
        }
        else {
            Write-Success "$varName appears to be strong"
        }
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. Docker Services (if running)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if (-not $SkipDocker) {
    Write-Header "Docker Services"

    Push-Location $RootDir
    try {
        $composeFile = "docker-compose.$Environment.yml"
        if (Test-Path $composeFile) {
            try {
                $services = docker compose -f $composeFile ps --format json 2>&1 | ConvertFrom-Json
                if ($services) {
                    foreach ($service in $services) {
                        $name = $service.Service
                        $state = $service.State
                        $health = $service.Health

                        if ($state -eq 'running') {
                            if ($health -eq 'healthy' -or [string]::IsNullOrEmpty($health)) {
                                Write-Success "$name is running and healthy"
                            }
                            elseif ($health -eq 'starting') {
                                Write-Warning "$name is starting (health check in progress)"
                            }
                            else {
                                Write-Warning "$name is running but health check failed: $health"
                            }
                        }
                        else {
                            Write-Warning "$name is not running (state: $state)"
                        }
                    }
                }
                else {
                    Write-Info "No services are currently running (this is OK if not yet started)"
                }
            }
            catch {
                Write-Info "Services not yet started (run 'docker compose up -d' to start)"
            }
        }
    }
    finally {
        Pop-Location
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. Domain Resolution (if Domain specified)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ($Domain) {
    Write-Header "Domain Resolution"

    if (Test-Command 'nslookup') {
        try {
            $result = nslookup $Domain 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Domain $Domain resolves successfully"
            }
            else {
                Write-Failure "Domain $Domain does not resolve"
            }
        }
        catch {
            Write-Warning "Could not check domain resolution: $_"
        }
    }
    else {
        Write-Info "nslookup not available, skipping DNS check"
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7. SSL Certificate (if Domain specified and not skipped)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ($Domain -and -not $SkipSSL) {
    Write-Header "SSL Certificate"

    if (Test-Command 'openssl') {
        try {
            $certInfo = echo | openssl s_client -servername $Domain -connect "${Domain}:443" 2>&1
            if ($certInfo -match 'Verify return code: 0') {
                Write-Success "SSL certificate is valid for $Domain"
            }
            elseif ($certInfo -match 'connect: Connection refused') {
                Write-Info "Cannot connect to $Domain on port 443 (SSL not configured yet?)"
            }
            else {
                Write-Warning "SSL certificate validation failed for $Domain"
            }
        }
        catch {
            Write-Info "Could not check SSL certificate: $_"
        }
    }
    else {
        Write-Info "openssl not available, skipping SSL check"
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 8. Production-Specific Checks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ($Environment -eq 'prod') {
    Write-Header "Production-Specific Checks"

    # Check if .env.prod is in .gitignore
    $gitignorePath = Join-Path $RootDir ".gitignore"
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath -Raw
        if ($gitignoreContent -match '\.env\.\w+' -or $gitignoreContent -match '\.env\.prod') {
            Write-Success ".env files are in .gitignore"
        }
        else {
            Write-Warning ".env files may not be in .gitignore (security risk!)"
        }
    }

    # Check if running as root (bad practice in production)
    if ($IsLinux -or $IsMacOS) {
        $currentUser = whoami
        if ($currentUser -eq 'root') {
            Write-Warning "Running as root user (should use non-root user in production)"
        }
        else {
            Write-Success "Not running as root user"
        }
    }

    # Check disk space
    if ($IsLinux -or $IsMacOS) {
        $diskSpace = df -h . | Select-Object -Last 1
        Write-Info "Disk space: $diskSpace"
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Host "`n${Bold}${Blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}`n"

Write-Host "  ${Green}✓${Reset} Passed:  ${Bold}$script:PassCount${Reset}"
Write-Host "  ${Yellow}⚠${Reset} Warnings: ${Bold}$script:WarnCount${Reset}"
Write-Host "  ${Red}✗${Reset} Failed:  ${Bold}$script:FailCount${Reset}"

Write-Host "`n${Bold}${Blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}`n"

if ($script:FailCount -eq 0 -and $script:WarnCount -eq 0) {
    Write-Host "${Green}${Bold}✓ All checks passed! Ready for deployment.${Reset}`n"
    exit 0
}
elseif ($script:FailCount -eq 0) {
    Write-Host "${Yellow}${Bold}⚠ Some warnings found. Review before deployment.${Reset}`n"
    exit 0
}
else {
    Write-Host "${Red}${Bold}✗ Critical issues found. Fix before deployment.${Reset}`n"
    exit 1
}
