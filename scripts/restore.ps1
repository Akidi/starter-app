#!/usr/bin/env pwsh
#Requires -Version 7.2

<#
.SYNOPSIS
    Restore script for PostgreSQL and Redis

.DESCRIPTION
    Restores PostgreSQL database and Redis data from backup files.
    WARNING: This will overwrite existing data!

.PARAMETER Environment
    Environment to restore to (dev, staging, prod)

.PARAMETER PostgresBackup
    Path to PostgreSQL backup file (.sql or .sql.gz)

.PARAMETER RedisBackup
    Path to Redis backup file (.rdb or .rdb.gz)

.PARAMETER Force
    Skip confirmation prompt

.EXAMPLE
    pwsh restore.ps1 -Environment dev -PostgresBackup backups/myapp_postgres_dev_20250102_120000.sql

.EXAMPLE
    pwsh restore.ps1 -Environment prod -PostgresBackup backups/db.sql.gz -RedisBackup backups/dump.rdb.gz -Force
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('dev', 'staging', 'prod')]
    [string]$Environment,

    [Parameter()]
    [string]$PostgresBackup,

    [Parameter()]
    [string]$RedisBackup,

    [Parameter()]
    [switch]$Force
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

function Write-Header {
    param([string]$Text)
    Write-Host "`n${Bold}${Blue}━━━ $Text ━━━${Reset}`n"
}

function Write-Success {
    param([string]$Text)
    Write-Host "  ${Green}✓${Reset} $Text"
}

function Write-Failure {
    param([string]$Text)
    Write-Host "  ${Red}✗${Reset} $Text"
}

function Write-Warning {
    param([string]$Text)
    Write-Host "  ${Yellow}⚠${Reset} $Text"
}

function Write-Info {
    param([string]$Text)
    Write-Host "  ${Blue}ℹ${Reset} $Text"
}

# Get root directory
$RootDir = Split-Path -Parent $PSScriptRoot
Push-Location $RootDir

try {
    Write-Host "${Bold}${Red}"
    Write-Host "╔════════════════════════════════════════════════════════╗"
    Write-Host "║   RESTORE SCRIPT - WARNING                            ║"
    Write-Host "║   This will OVERWRITE existing data!                  ║"
    Write-Host "║   Environment: $($Environment.PadRight(38)) ║"
    Write-Host "╚════════════════════════════════════════════════════════╝"
    Write-Host "${Reset}"

    # Validate inputs
    if (-not $PostgresBackup -and -not $RedisBackup) {
        Write-Failure "No backup files specified. Use -PostgresBackup or -RedisBackup"
        exit 1
    }

    # Docker compose file
    $composeFile = "docker-compose.$Environment.yml"
    if (-not (Test-Path $composeFile)) {
        Write-Failure "Docker Compose file not found: $composeFile"
        exit 1
    }

    # Confirmation
    if (-not $Force) {
        Write-Warning "This will replace existing data in the $Environment environment!"
        if ($PostgresBackup) {
            Write-Host "  PostgreSQL: $PostgresBackup"
        }
        if ($RedisBackup) {
            Write-Host "  Redis: $RedisBackup"
        }
        Write-Host ""
        $confirm = Read-Host "Type 'yes' to continue, or anything else to cancel"

        if ($confirm -ne 'yes') {
            Write-Info "Restore cancelled"
            exit 0
        }
    }

    # Load environment variables
    $envFile = ".env.$Environment"
    if (-not (Test-Path $envFile)) {
        Write-Failure "Environment file not found: $envFile"
        exit 1
    }

    # Parse .env file
    $envVars = @{}
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            $envVars[$matches[1].Trim()] = $matches[2].Trim()
        }
    }

    $appName = $envVars['APP_NAME']
    if (-not $appName) {
        Write-Failure "APP_NAME not found in $envFile"
        exit 1
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # PostgreSQL Restore
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if ($PostgresBackup) {
        Write-Header "PostgreSQL Restore"

        if (-not (Test-Path $PostgresBackup)) {
            Write-Failure "PostgreSQL backup file not found: $PostgresBackup"
            exit 1
        }

        Write-Info "Restoring from: $PostgresBackup"

        try {
            # Check if file is gzipped
            $isGzipped = $PostgresBackup -like "*.gz"

            if ($isGzipped) {
                Write-Info "Decompressing and restoring..."
                $restoreCmd = "gunzip -c '$PostgresBackup' | docker compose -f $composeFile exec -T db psql -U archon $appName"
            }
            else {
                $restoreCmd = "docker compose -f $composeFile exec -T db psql -U archon $appName < '$PostgresBackup'"
            }

            & bash -c $restoreCmd 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Success "PostgreSQL restore completed"
            }
            else {
                Write-Failure "PostgreSQL restore failed (exit code: $LASTEXITCODE)"
            }
        }
        catch {
            Write-Failure "PostgreSQL restore error: $_"
        }
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Redis Restore
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if ($RedisBackup) {
        Write-Header "Redis Restore"

        if (-not (Test-Path $RedisBackup)) {
            Write-Failure "Redis backup file not found: $RedisBackup"
            exit 1
        }

        Write-Info "Restoring from: $RedisBackup"

        try {
            # Decompress if needed
            $tempFile = $null
            $isGzipped = $RedisBackup -like "*.gz"

            if ($isGzipped) {
                Write-Info "Decompressing backup..."
                $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "dump_restore_$((Get-Date).Ticks).rdb"
                & gunzip -c $RedisBackup > $tempFile
                $rdbFile = $tempFile
            }
            else {
                $rdbFile = $RedisBackup
            }

            # Stop Redis
            Write-Info "Stopping Redis..."
            docker compose -f $composeFile stop redis | Out-Null

            # Copy dump.rdb to container volume
            Write-Info "Copying backup to Redis container..."
            docker compose -f $composeFile cp $rdbFile redis:/data/dump.rdb 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                # Start Redis
                Write-Info "Starting Redis..."
                docker compose -f $composeFile start redis | Out-Null

                # Wait for Redis to be ready
                Start-Sleep -Seconds 2

                Write-Success "Redis restore completed"
            }
            else {
                Write-Failure "Redis restore failed: Could not copy dump.rdb"
            }

            # Cleanup temp file
            if ($tempFile -and (Test-Path $tempFile)) {
                Remove-Item $tempFile
            }
        }
        catch {
            Write-Failure "Redis restore error: $_"
        }
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Summary
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Write-Header "Restore Summary"

    Write-Success "Restore operation completed!"
    Write-Info "Verify your data and test the application"
    Write-Host ""
}
finally {
    Pop-Location
}
