#!/usr/bin/env pwsh
#Requires -Version 7.2

<#
.SYNOPSIS
    Backup script for PostgreSQL and Redis

.DESCRIPTION
    Creates backups of PostgreSQL database and Redis data.
    Backups are stored in the backups/ directory with timestamps.
    Supports automatic cleanup of old backups.

.PARAMETER Environment
    Environment to backup (dev, staging, prod)

.PARAMETER BackupDir
    Directory to store backups (default: ./backups)

.PARAMETER RetentionDays
    Number of days to retain backups (default: 30)

.PARAMETER SkipPostgres
    Skip PostgreSQL backup

.PARAMETER SkipRedis
    Skip Redis backup

.PARAMETER Compress
    Compress backups with gzip

.EXAMPLE
    pwsh backup.ps1 -Environment prod

.EXAMPLE
    pwsh backup.ps1 -Environment prod -RetentionDays 7 -Compress
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('dev', 'staging', 'prod')]
    [string]$Environment,

    [Parameter()]
    [string]$BackupDir = './backups',

    [Parameter()]
    [int]$RetentionDays = 30,

    [Parameter()]
    [switch]$SkipPostgres,

    [Parameter()]
    [switch]$SkipRedis,

    [Parameter()]
    [switch]$Compress
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

function Write-Info {
    param([string]$Text)
    Write-Host "  ${Blue}ℹ${Reset} $Text"
}

# Get root directory
$RootDir = Split-Path -Parent $PSScriptRoot
Push-Location $RootDir

try {
    Write-Host "${Bold}${Blue}"
    Write-Host "╔════════════════════════════════════════════════════════╗"
    Write-Host "║   Backup Script                                       ║"
    Write-Host "║   Environment: $($Environment.PadRight(38)) ║"
    Write-Host "╚════════════════════════════════════════════════════════╝"
    Write-Host "${Reset}"

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

    # Get app name from env file
    $appName = $envVars['APP_NAME']
    if (-not $appName) {
        Write-Failure "APP_NAME not found in $envFile"
        exit 1
    }

    # Create backup directory
    $backupPath = Join-Path $RootDir $BackupDir
    if (-not (Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath | Out-Null
        Write-Info "Created backup directory: $backupPath"
    }

    # Timestamp for backup files
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    # Docker compose file
    $composeFile = "docker-compose.$Environment.yml"
    if (-not (Test-Path $composeFile)) {
        Write-Failure "Docker Compose file not found: $composeFile"
        exit 1
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # PostgreSQL Backup
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if (-not $SkipPostgres) {
        Write-Header "PostgreSQL Backup"

        $pgBackupFile = Join-Path $backupPath "${appName}_postgres_${Environment}_${timestamp}.sql"

        Write-Info "Starting PostgreSQL backup..."

        try {
            # Use pg_dump via docker exec
            $pgDumpCmd = "docker compose -f $composeFile exec -T db pg_dump -U archon --clean --if-exists --create $appName"

            if ($Compress) {
                $pgBackupFile += ".gz"
                & bash -c "$pgDumpCmd | gzip > '$pgBackupFile'"
            }
            else {
                & bash -c "$pgDumpCmd > '$pgBackupFile'"
            }

            if ($LASTEXITCODE -eq 0) {
                $fileSize = (Get-Item $pgBackupFile).Length
                $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
                Write-Success "PostgreSQL backup created: $pgBackupFile ($fileSizeMB MB)"
            }
            else {
                Write-Failure "PostgreSQL backup failed"
            }
        }
        catch {
            Write-Failure "PostgreSQL backup error: $_"
        }
    }
    else {
        Write-Info "Skipping PostgreSQL backup"
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Redis Backup
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if (-not $SkipRedis) {
        Write-Header "Redis Backup"

        $redisBackupFile = Join-Path $backupPath "${appName}_redis_${Environment}_${timestamp}.rdb"

        Write-Info "Starting Redis backup..."

        try {
            # Get Redis archon password
            $redisPassword = $envVars['ADMIN_USER_REDIS_PASSWORD']

            # Trigger BGSAVE
            $saveResult = docker compose -f $composeFile exec -T redis redis-cli --user archon --pass $redisPassword BGSAVE 2>&1

            if ($saveResult -match 'Background saving started') {
                Write-Info "Background save initiated, waiting..."

                # Wait for save to complete
                $maxWait = 30
                $waited = 0
                $saveComplete = $false

                while ($waited -lt $maxWait) {
                    Start-Sleep -Seconds 1
                    $waited++

                    $lastSave = docker compose -f $composeFile exec -T redis redis-cli --user archon --pass $redisPassword LASTSAVE 2>&1

                    # Check if save is complete by comparing LASTSAVE timestamps
                    if ($lastSave -match '\d+') {
                        $saveComplete = $true
                        break
                    }
                }

                if ($saveComplete) {
                    # Copy dump.rdb from container
                    docker compose -f $composeFile cp redis:/data/dump.rdb $redisBackupFile 2>&1 | Out-Null

                    if ($LASTEXITCODE -eq 0) {
                        if ($Compress) {
                            $compressedFile = "$redisBackupFile.gz"
                            & gzip -c $redisBackupFile > $compressedFile
                            Remove-Item $redisBackupFile
                            $redisBackupFile = $compressedFile
                        }

                        $fileSize = (Get-Item $redisBackupFile).Length
                        $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
                        Write-Success "Redis backup created: $redisBackupFile ($fileSizeKB KB)"
                    }
                    else {
                        Write-Failure "Redis backup failed: Could not copy dump.rdb"
                    }
                }
                else {
                    Write-Failure "Redis backup timed out after ${maxWait}s"
                }
            }
            else {
                Write-Failure "Redis BGSAVE failed: $saveResult"
            }
        }
        catch {
            Write-Failure "Redis backup error: $_"
        }
    }
    else {
        Write-Info "Skipping Redis backup"
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Cleanup Old Backups
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Write-Header "Backup Cleanup"

    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    $oldBackups = Get-ChildItem -Path $backupPath -File | Where-Object {
        $_.LastWriteTime -lt $cutoffDate -and
        ($_.Name -like "*_postgres_*.sql*" -or $_.Name -like "*_redis_*.rdb*")
    }

    if ($oldBackups) {
        Write-Info "Found $($oldBackups.Count) backup(s) older than $RetentionDays days"
        foreach ($backup in $oldBackups) {
            Remove-Item $backup.FullName
            Write-Info "Deleted: $($backup.Name)"
        }
        Write-Success "Cleanup completed"
    }
    else {
        Write-Info "No old backups to clean up"
    }

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Summary
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Write-Header "Backup Summary"

    $allBackups = Get-ChildItem -Path $backupPath -File | Where-Object {
        $_.Name -like "${appName}_*_${Environment}_*"
    } | Sort-Object LastWriteTime -Descending | Select-Object -First 5

    if ($allBackups) {
        Write-Info "Recent backups (latest 5):"
        foreach ($backup in $allBackups) {
            $size = [math]::Round($backup.Length / 1MB, 2)
            Write-Host "    • $($backup.Name) ($size MB) - $($backup.LastWriteTime)"
        }
    }

    Write-Host ""
    Write-Success "Backup completed successfully!"
    Write-Host ""
}
finally {
    Pop-Location
}
