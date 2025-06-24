#!/usr/bin/env pwsh
#Requires -Version 7.0

# Colors for output
$Colors = @{
    Red = "`e[31m"
    Green = "`e[32m"
    Yellow = "`e[33m"
    Blue = "`e[34m"
    Magenta = "`e[35m"
    Cyan = "`e[36m"
    White = "`e[37m"
    Gray = "`e[90m"
    Reset = "`e[0m"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "$($Colors[$Color])$Message$($Colors.Reset)"
}

function Show-Banner {
    Clear-Host
    Write-ColorOutput "╔════════════════════════════════════════╗" "Cyan"
    Write-ColorOutput "║        SvelteKit Starter Setup        ║" "Cyan"
    Write-ColorOutput "║     Project Management & Utilities    ║" "Cyan"
    Write-ColorOutput "╚════════════════════════════════════════╝" "Cyan"
    Write-Host ""
}

function Show-MainMenu {
    Write-ColorOutput "🚀 Main Menu - What would you like to do?" "Yellow"
    Write-Host ""
    Write-ColorOutput "1. 🏗️  Full Project Setup (New Environment)" "Green"
    Write-ColorOutput "2. 🗄️  Add Database Schema" "Blue"
    Write-ColorOutput "3. 🔑 Show Generated Passwords" "Magenta"
    Write-ColorOutput "4. 📋 Project Status" "Cyan"
    Write-ColorOutput "5. 🧹 Clean & Reset Environment" "Red"
    Write-ColorOutput "6. ❓ Help & Documentation" "Gray"
    Write-ColorOutput "0. 🚪 Exit" "White"
    Write-Host ""
}

function Get-UserChoice {
    param([string]$Prompt = "Enter your choice")
    Write-ColorOutput "$Prompt`: " "Yellow" -NoNewline
    return Read-Host
}

function Get-AppName {
    do {
        $appName = Get-UserChoice "Enter application name (lowercase, letters/numbers/hyphens only)"
        if ($appName -match '^[a-z][a-z0-9-]*$' -and $appName.Length -le 20) {
            return $appName
        }
        Write-ColorOutput "❌ Invalid app name. Use lowercase letters, numbers, hyphens. Max 20 chars." "Red"
    } while ($true)
}

function Get-Environment {
    Write-ColorOutput "📦 Environment Selection:" "Yellow"
    Write-ColorOutput "1. dev (Development - Default)" "Green"
    Write-ColorOutput "2. staging (Staging)" "Blue"
    Write-ColorOutput "3. prod (Production)" "Red"
    Write-Host ""
    
    $choice = Get-UserChoice "Select environment (1-3, or press Enter for dev)"
    
    switch ($choice) {
        "1" { return "dev" }
        "2" { return "staging" }
        "3" { return "prod" }
        "" { return "dev" }
        default { 
            Write-ColorOutput "Invalid choice, defaulting to 'dev'" "Yellow"
            return "dev"
        }
    }
}

function Show-SetupOptions {
    param([string]$AppName, [string]$Env)
    
    Write-ColorOutput "⚙️ Setup Options:" "Yellow"
    Write-ColorOutput "1. Full setup with auto-start (recommended)" "Green"
    Write-ColorOutput "2. Generate files only (no Docker start)" "Blue"
    Write-ColorOutput "3. Full setup + show passwords" "Magenta"
    Write-ColorOutput "4. Generate files + show passwords" "Cyan"
    Write-Host ""
    
    $choice = Get-UserChoice "Select setup type (1-4)"
    
    $showPasswords = $false
    $noStart = $false
    
    switch ($choice) {
        "1" { 
            Write-ColorOutput "🚀 Starting full setup with auto-start..." "Green"
        }
        "2" {
            $noStart = $true
            Write-ColorOutput "📝 Generating files only..." "Blue"
        }
        "3" {
            $showPasswords = $true
            Write-ColorOutput "🚀 Starting full setup with passwords..." "Magenta"
        }
        "4" {
            $showPasswords = $true
            $noStart = $true
            Write-ColorOutput "📝 Generating files with passwords..." "Cyan"
        }
        default {
            Write-ColorOutput "Invalid choice, using full setup with auto-start" "Yellow"
        }
    }
    
    return @{
        ShowPasswords = $showPasswords
        NoStart = $noStart
    }
}

function Invoke-FullSetup {
    Write-ColorOutput "`n🏗️ Full Project Setup" "Green"
    Write-ColorOutput "═══════════════════════" "Green"
    
    $appName = Get-AppName
    $env = Get-Environment
    $options = Show-SetupOptions -AppName $appName -Env $env
    
    Write-ColorOutput "`n📋 Setup Summary:" "Cyan"
    Write-ColorOutput "App Name: $appName" "White"
    Write-ColorOutput "Environment: $env" "White"
    Write-ColorOutput "Show Passwords: $($options.ShowPasswords)" "White"
    Write-ColorOutput "Auto-start containers: $(-not $options.NoStart)" "White"
    Write-Host ""
    
    $confirm = Get-UserChoice "Proceed with setup? (y/N)"
    if ($confirm -notmatch '^y|yes$') {
        Write-ColorOutput "❌ Setup cancelled" "Red"
        return
    }
    
    # Build arguments for full-setup.ps1
    $arguments = @()
    $arguments += "-AppName"
    $arguments += $appName
    $arguments += "-Env" 
    $arguments += $env
    if ($options.ShowPasswords) {
        $arguments += "-ShowPasswords"
    }
    
    Write-ColorOutput "`n🔄 Running full setup..." "Yellow"
    Write-ColorOutput "Debug: AppName='$appName', Env='$env'" "Gray"
    
    if (Test-Path "./full-setup.ps1") {
        Write-ColorOutput "Executing: ./full-setup.ps1 -AppName '$appName' -Env '$env'$(if ($options.ShowPasswords) { ' -ShowPasswords' })" "Gray"
        
        # Alternative: Use direct parameter passing instead of splatting
        if ($options.ShowPasswords -and $options.NoStart) {
            & "./full-setup.ps1" -AppName $appName -Env $env -ShowPasswords -NoStart
        } elseif ($options.ShowPasswords) {
            & "./full-setup.ps1" -AppName $appName -Env $env -ShowPasswords
        } elseif ($options.NoStart) {
            & "./full-setup.ps1" -AppName $appName -Env $env -NoStart
        } else {
            & "./full-setup.ps1" -AppName $appName -Env $env
        }
    } else {
        Write-ColorOutput "❌ full-setup.ps1 not found!" "Red"
        Write-ColorOutput "Please ensure full-setup.ps1 is in the same directory." "Red"
    }
}

function Invoke-AddSchema {
    Write-ColorOutput "`n🗄️ Add Database Schema" "Blue"
    Write-ColorOutput "═══════════════════════" "Blue"
    
    do {
        $schemaName = Get-UserChoice "Enter schema name (lowercase, letters/numbers/underscores)"
        if ($schemaName -match '^[a-z_][a-z0-9_]*$') {
            break
        }
        Write-ColorOutput "❌ Invalid schema name. Use lowercase letters, numbers, underscores." "Red"
    } while ($true)
    
    $dryRun = Get-UserChoice "Preview changes first? (Y/n)"
    $dryRunFlag = if ($dryRun -notmatch '^n|no$') { "--dry-run" } else { "" }
    
    Write-ColorOutput "`n🔄 Adding schema '$schemaName'..." "Yellow"
    
    if (Test-Path "./add-schema.ps1") {
        if ($dryRunFlag) {
            & "./add-schema.ps1" $schemaName -DryRun
            Write-Host ""
            $proceed = Get-UserChoice "Apply changes? (y/N)"
            if ($proceed -match '^y|yes$') {
                & "./add-schema.ps1" $schemaName
            }
        } else {
            & "./add-schema.ps1" $schemaName
        }
    } else {
        Write-ColorOutput "❌ add-schema.ps1 not found!" "Red"
        Write-ColorOutput "Please ensure add-schema.ps1 is in the same directory." "Red"
    }
}

function Show-Passwords {
    Write-ColorOutput "`n🔑 Generated Passwords" "Magenta"
    Write-ColorOutput "═══════════════════════" "Magenta"
    
    $envFiles = Get-ChildItem -Filter ".env.*" | Where-Object { $_.Name -match '\.env\.(dev|staging|prod)$' }
    
    if ($envFiles.Count -eq 0) {
        Write-ColorOutput "❌ No environment files found. Run full setup first." "Red"
        return
    }
    
    foreach ($envFile in $envFiles) {
        $envName = ($envFile.Name -split '\.')[-1]
        Write-ColorOutput "`n📁 Environment: $envName" "Cyan"
        Write-ColorOutput "─────────────────────" "Gray"
        
        $content = Get-Content $envFile.FullName
        $passwords = $content | Where-Object { $_ -match '_PASSWORD=' }
        
        foreach ($line in $passwords) {
            if ($line -match '^([^=]+)=(.+)$') {
                $key = $matches[1]
                $value = $matches[2]
                Write-ColorOutput "$key`: " "Yellow" -NoNewline
                Write-ColorOutput $value "White"
            }
        }
    }
}

function Show-ProjectStatus {
    Write-ColorOutput "`n📋 Project Status" "Cyan"
    Write-ColorOutput "═══════════════════" "Cyan"
    
    # Check for key files
    $files = @(
        @{ Path = "docker-compose.dev.yml"; Name = "Dev Docker Compose" }
        @{ Path = "docker-compose.staging.yml"; Name = "Staging Docker Compose" }
        @{ Path = "docker-compose.prod.yml"; Name = "Production Docker Compose" }
        @{ Path = ".env.dev"; Name = "Dev Environment" }
        @{ Path = ".env.staging"; Name = "Staging Environment" }
        @{ Path = ".env.prod"; Name = "Production Environment" }
        @{ Path = "app/drizzle.config.ts"; Name = "Drizzle Config" }
        @{ Path = "templates/init.template.sql"; Name = "Database Template" }
        @{ Path = "db/init.dev.sql"; Name = "Dev Database Init" }
    )
    
    Write-ColorOutput "`n📁 Configuration Files:" "Yellow"
    foreach ($file in $files) {
        $status = if (Test-Path $file.Path) { "✅" } else { "❌" }
        $color = if (Test-Path $file.Path) { "Green" } else { "Red" }
        Write-ColorOutput "$status $($file.Name)" $color
    }
    
    # Check Docker/Podman status
    Write-ColorOutput "`n🐳 Container Status:" "Yellow"
    try {
        # Try podman first
        try {
            $containers = podman ps --format "table {{.Names}}\t{{.Status}}" 2>$null
            if ($containers) {
                Write-ColorOutput "Podman containers:" "White"
                Write-ColorOutput $containers "White"
            } else {
                Write-ColorOutput "No running Podman containers found" "Gray"
            }
        } catch {
            # Try docker
            try {
                $containers = docker ps --format "table {{.Names}}\t{{.Status}}" 2>$null
                if ($containers) {
                    Write-ColorOutput "Docker containers:" "White"
                    Write-ColorOutput $containers "White"
                } else {
                    Write-ColorOutput "No running Docker containers found" "Gray"
                }
            } catch {
                Write-ColorOutput "No container engine available or running" "Red"
            }
        }
    } catch {
        Write-ColorOutput "Container engine not available" "Red"
    }
}

function Invoke-CleanReset {
    Write-ColorOutput "`n🧹 Clean & Reset Environment" "Red"
    Write-ColorOutput "══════════════════════════" "Red"
    
    Write-ColorOutput "⚠️ This will:" "Yellow"
    Write-ColorOutput "  • Stop and remove all containers" "Red"
    Write-ColorOutput "  • Remove all volumes (DATABASE WILL BE LOST)" "Red"
    Write-ColorOutput "  • Remove generated environment files" "Red"
    Write-ColorOutput "  • Remove generated Docker Compose files" "Red"
    Write-Host ""
    
    $confirm = Get-UserChoice "Are you sure? Type 'RESET' to confirm"
    if ($confirm -ne "RESET") {
        Write-ColorOutput "❌ Reset cancelled" "Green"
        return
    }
    
    Write-ColorOutput "`n🔄 Cleaning environment..." "Yellow"
    
    # Stop containers (try both podman-compose and docker-compose)
    try {
        podman-compose -f docker-compose.dev.yml down -v 2>$null
        podman-compose -f docker-compose.staging.yml down -v 2>$null
        podman-compose -f docker-compose.prod.yml down -v 2>$null
    } catch {
        try {
            docker-compose -f docker-compose.dev.yml down -v 2>$null
            docker-compose -f docker-compose.staging.yml down -v 2>$null
            docker-compose -f docker-compose.prod.yml down -v 2>$null
        } catch {
            Write-ColorOutput "No containers to stop" "Gray"
        }
    }
    
    # Remove generated files
    $filesToRemove = @(
        ".env.dev", ".env.staging", ".env.prod",
        "docker-compose.dev.yml", "docker-compose.staging.yml", "docker-compose.prod.yml",
        "db/init.dev.sql", "db/init.staging.sql", "db/init.prod.sql",
        "redis.dev.conf", "redis.staging.conf", "redis.prod.conf",
        "redis.dev.acl", "redis.staging.acl", "redis.prod.acl"
    )
    
    foreach ($file in $filesToRemove) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-ColorOutput "🗑️ Removed $file" "Gray"
        }
    }
    
    Write-ColorOutput "✅ Environment cleaned successfully!" "Green"
}

function Show-Help {
    Write-ColorOutput "`n❓ Help & Documentation" "Gray"
    Write-ColorOutput "════════════════════════" "Gray"
    
    Write-ColorOutput "`n📖 Available Commands:" "Yellow"
    Write-ColorOutput "• Full Setup: Creates complete environment with containers" "White"
    Write-ColorOutput "• Add Schema: Adds new PostgreSQL schema to project" "White"
    Write-ColorOutput "• Show Passwords: Displays generated passwords from env files" "White"
    Write-ColorOutput "• Project Status: Shows current configuration and container status" "White"
    Write-ColorOutput "• Clean Reset: Removes all generated files and containers" "White"
    
    # Detect what's actually available
    Write-ColorOutput "`n🔧 Detected Requirements:" "Yellow"
    Write-ColorOutput "• PowerShell 7.0+" "White"
    
    # Check container engines
    try {
        podman --version | Out-Null
        Write-ColorOutput "• ✅ Podman detected" "Green"
        
        # Check for podman-compose (native) first
        try {
            podman-compose --version | Out-Null
            Write-ColorOutput "• ✅ podman-compose (native) detected" "Green"
        } catch {
            # Check for podman compose (external provider)
            try {
                podman compose --version | Out-Null
                Write-ColorOutput "• ✅ podman compose (external provider) detected" "Green"
                Write-ColorOutput "   Note: Uses external docker-compose.exe" "Gray"
            } catch {
                Write-ColorOutput "• ⚠️ No podman compose tool found" "Yellow"
                Write-ColorOutput "   Install: pip install podman-compose" "Gray"
            }
        }
    } catch {
        try {
            docker --version | Out-Null
            Write-ColorOutput "• ✅ Docker detected" "Green"
            
            # Check for docker compose (v2) vs docker-compose (v1)
            try {
                docker compose version | Out-Null
                Write-ColorOutput "• ✅ docker compose (v2) detected" "Green"
            } catch {
                try {
                    docker-compose --version | Out-Null
                    Write-ColorOutput "• ✅ docker-compose (v1) detected" "Green"
                } catch {
                    Write-ColorOutput "• ⚠️ docker-compose not found" "Yellow"
                }
            }
        } catch {
            Write-ColorOutput "• ❌ No container engine found" "Red"
            Write-ColorOutput "   Install Podman or Docker" "Gray"
        }
    }
    
    # Check Node.js
    try {
        node --version | Out-Null
        Write-ColorOutput "• ✅ Node.js detected" "Green"
        
        try {
            pnpm --version | Out-Null
            Write-ColorOutput "• ✅ pnpm detected" "Green"
        } catch {
            Write-ColorOutput "• ⚠️ pnpm not found (install with: npm install -g pnpm)" "Yellow"
        }
    } catch {
        Write-ColorOutput "• ❌ Node.js not found" "Red"
    }
    
    Write-ColorOutput "`n📁 Project Structure:" "Yellow"
    Write-ColorOutput "• setup.ps1 - This main menu" "White"
    Write-ColorOutput "• full-setup.ps1 - Complete environment setup" "White"
    Write-ColorOutput "• add-schema.ps1 - Schema management" "White"
    Write-ColorOutput "• templates/ - Configuration templates" "White"
}

# Main execution loop
function Main {
    do {
        Show-Banner
        Show-MainMenu
        
        $choice = Get-UserChoice
        
        switch ($choice) {
            "1" { Invoke-FullSetup }
            "2" { Invoke-AddSchema }
            "3" { Show-Passwords }
            "4" { Show-ProjectStatus }
            "5" { Invoke-CleanReset }
            "6" { Show-Help }
            "0" { 
                Write-ColorOutput "`n👋 Goodbye!" "Green"
                exit 0
            }
            default {
                Write-ColorOutput "`n❌ Invalid choice. Please try again." "Red"
                Start-Sleep 2
            }
        }
        
        if ($choice -ne "0") {
            Write-Host ""
            Write-ColorOutput "Press any key to return to main menu..." "Gray"
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($true)
}

# Run the main function
Main