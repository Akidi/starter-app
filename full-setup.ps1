#!/usr/bin/env pwsh
#Requires -Version 7.0

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Env,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowPasswords,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoStart
)

# Configuration
$TemplateDir = "templates"  # Change this if templates are in a different folder
$DbDir = "db"              # Change this if database files should go elsewhere
$ContainerEngine = "podman"  # Change to "docker" if using Docker

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

function Write-Step {
    param(
        [string]$Message,
        [string]$Step
    )
    Write-ColorOutput "[$Step] $Message" "Cyan"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️ $Message" "Blue"
}

# Validate inputs
if (-not ($AppName -match '^[a-z][a-z0-9-]*$')) {
    Write-Error "App name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens"
    exit 1
}

if ($AppName.Length -gt 20) {
    Write-Error "App name must be 20 characters or less"
    exit 1
}

Write-ColorOutput "`n🚀 SvelteKit Starter Full Setup" "Cyan"
Write-ColorOutput "═══════════════════════════════" "Cyan"
Write-ColorOutput "App Name: $AppName" "White"
Write-ColorOutput "Environment: $Env" "White"
Write-ColorOutput "Show Passwords: $ShowPasswords" "White"
Write-ColorOutput "Auto-start containers: $(-not $NoStart)" "White"
Write-Host ""

# Function to generate a secure random password
function New-Password {
    param([int]$Length = 32)
    
    # Try OpenSSL first for consistency with bash version
    try {
        $opensslAvailable = Get-Command openssl -ErrorAction SilentlyContinue
        if ($opensslAvailable) {
            # Calculate base64 length needed (4/3 ratio, plus padding)
            $base64Length = [math]::Ceiling($Length * 4 / 3)
            $opensslOutput = openssl rand -base64 $base64Length 2>$null
            if ($opensslOutput -and $opensslOutput.Length -ge $Length) {
                # Remove base64 padding and special chars, take only what we need
                $cleanPassword = ($opensslOutput -replace '[=+/]', '').Substring(0, $Length)
                if ($cleanPassword.Length -eq $Length) {
                    return $cleanPassword
                }
            }
        }
    } catch {
        # OpenSSL failed, will fall back to PowerShell method
    }
    
    # Fallback to PowerShell method
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_'
    $password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $password
}

# Function to replace template variables in a file
function Update-TemplateFile {
    param(
        [string]$TemplateFile,
        [string]$OutputFile,
        [hashtable]$Variables
    )
    
    if (-not (Test-Path $TemplateFile)) {
        Write-Error "Template file $TemplateFile not found"
        return $false
    }
    
    try {
        $content = Get-Content $TemplateFile -Raw
        
        foreach ($key in $Variables.Keys) {
            $content = $content -replace "{{$key}}", $Variables[$key]
        }
        
        Set-Content -Path $OutputFile -Value $content -NoNewline
        Write-Success "Generated $OutputFile"
        return $true
    } catch {
        Write-Error "Failed to process template $TemplateFile`: $($_.Exception.Message)"
        return $false
    }
}

# Generate all passwords
Write-Step "Generating secure passwords..." "1/6"

$passwords = @{
    APP_SECRET = New-Password -Length 64
    POSTGRES_SUPERUSER_PASSWORD = New-Password
    ADMIN_PASSWORD = New-Password
    DEVELOPER_PASSWORD = New-Password
    API_PASSWORD = New-Password
    READONLY_PASSWORD = New-Password
    BACKUP_PASSWORD = New-Password
    AUDITOR_PASSWORD = New-Password
    REDIS_PASSWORD = New-Password
    ADMIN_USER_REDIS_PASSWORD = New-Password
    DEVELOPER_USER_REDIS_PASSWORD = New-Password
    API_USER_REDIS_PASSWORD = New-Password
    READONLY_USER_REDIS_PASSWORD = New-Password
    BACKUP_USER_REDIS_PASSWORD = New-Password
    AUDITOR_USER_REDIS_PASSWORD = New-Password
    ADMIN_USER_PASSWORD = New-Password
    DEVELOPER_USER_PASSWORD = New-Password
    API_USER_PASSWORD = New-Password
    READONLY_USER_PASSWORD = New-Password
    BACKUP_USER_PASSWORD = New-Password
    AUDITOR_USER_PASSWORD = New-Password
}

Write-Success "Generated $(([array]$passwords.Keys).Count) secure passwords"

# Define port mapping
$ports = @{
    "dev" = 5173
    "staging" = 5174
    "prod" = 5175
}

$port = $ports[$Env]
Write-Info "Using port $port for $Env environment"

# Create template variables
$templateVars = $passwords.Clone()
$templateVars.APP_NAME = $AppName
$templateVars.ENV = $Env
$templateVars.PORT = $port

Write-Step "Generating configuration files..." "2/6"

# Ensure output directories exist
if (-not (Test-Path $DbDir)) {
    New-Item -ItemType Directory -Path $DbDir -Force | Out-Null
    Write-Success "Created $DbDir directory"
}

# Generate environment file
$envGenerated = Update-TemplateFile -TemplateFile "$TemplateDir/.env.template" -OutputFile ".env.$Env" -Variables $templateVars
if (-not $envGenerated) { exit 1 }

# Generate Docker Compose file
$composeGenerated = Update-TemplateFile -TemplateFile "$TemplateDir/docker-compose.template.yml" -OutputFile "docker-compose.$Env.yml" -Variables $templateVars
if (-not $composeGenerated) { exit 1 }

# Generate database init file
$initGenerated = Update-TemplateFile -TemplateFile "$TemplateDir/init.template.sql" -OutputFile "$DbDir/init.$Env.sql" -Variables $templateVars
if (-not $initGenerated) { exit 1 }

# Note: User data will be seeded via Drizzle migrations and seed script

# Generate Redis configuration
$redisConfGenerated = Update-TemplateFile -TemplateFile "$TemplateDir/redis.conf.template" -OutputFile "redis.$Env.conf" -Variables $templateVars
if (-not $redisConfGenerated) { exit 1 }

# Generate Redis ACL file
$redisAclGenerated = Update-TemplateFile -TemplateFile "$TemplateDir/redis.acl.template" -OutputFile "redis.$Env.acl" -Variables $templateVars
if (-not $redisAclGenerated) { exit 1 }

if ($NoStart) {
    Write-Step "Skipping Docker operations (NoStart flag)" "3/4"
    Write-Info "Docker validation and container startup skipped"
} else {
    Write-Step "Validating container setup..." "3/6"

    # Check if container engine is running
    try {
        if ($ContainerEngine -eq "podman") {
            podman version | Out-Null
            Write-Success "Podman is available"
        } else {
            docker version | Out-Null
            Write-Success "Docker is running"
        }
    } catch {
        Write-Error "$ContainerEngine is not running or not installed"
        Write-Info "Please start $ContainerEngine and try again"
        exit 1
    }

    # Check if compose is available
    try {
        if ($ContainerEngine -eq "podman") {
            # Try podman-compose first (native), then podman compose (external provider)
            try {
                podman-compose --version | Out-Null
                $script:ComposeCommand = "podman-compose"
                $script:ComposeSubcommand = ""
                Write-Success "podman-compose (native) is available"
                Write-ColorOutput "Debug: Will use 'podman-compose' commands" "Gray"
            } catch {
                try {
                    podman compose --version | Out-Null
                    $script:ComposeCommand = "podman"
                    $script:ComposeSubcommand = "compose"
                    Write-Success "podman compose (external provider) is available"
                    Write-ColorOutput "Debug: Will use 'podman compose' commands (via external docker-compose)" "Gray"
                } catch {
                    try {
                        docker-compose --version | Out-Null
                        $script:ComposeCommand = "docker-compose"
                        $script:ComposeSubcommand = ""
                        Write-Success "docker-compose is available (using with Podman)"
                        Write-ColorOutput "💡 Tip: Install podman-compose for better Podman integration" "Yellow"
                        Write-ColorOutput "Debug: Will use 'docker-compose' commands" "Gray"
                    } catch {
                        Write-Error "No compose tool is available"
                        Write-Info "Please install podman-compose: pip install podman-compose"
                        exit 1
                    }
                }
            }
        } else {
            # Try docker compose (newer), then docker-compose
            try {
                docker compose version | Out-Null
                $script:ComposeCommand = "docker"
                $script:ComposeSubcommand = "compose"
                Write-Success "docker compose (v2) is available"
            } catch {
                docker-compose --version | Out-Null
                $script:ComposeCommand = "docker-compose"
                $script:ComposeSubcommand = ""
                Write-Success "docker-compose (v1) is available"
            }
        }
    } catch {
        Write-Error "No compose tool is available"
        if ($ContainerEngine -eq "podman") {
            Write-Info "For Podman, use built-in 'podman compose' or install: pip install podman-compose"
        } else {
            Write-Info "For Docker, install docker-compose or use Docker Desktop"
        }
        exit 1
    }

    Write-Step "Stopping existing containers..." "4/6"

    # Quick cleanup approach for Podman
    try {
        Write-Info "Cleaning up existing containers..."
        
        if ($ContainerEngine -eq "podman") {
            # Direct approach with Podman - much faster
            $containerNames = @("$AppName.$Env", "$AppName.db.$Env", "$AppName.redis.$Env")
            
            foreach ($containerName in $containerNames) {
                try {
                    podman stop $containerName --timeout 5 2>$null
                    podman rm -f $containerName 2>$null
                } catch {
                    # Container doesn't exist, that's fine
                }
            }
            
            # Clean up volumes
            try {
                podman volume rm "$($AppName)_postgres_data_$Env" "$($AppName)_redis_data_$Env" 2>$null
            } catch {
                # Volumes don't exist, that's fine
            }
            
            Write-Success "Cleaned up existing containers and volumes"
        } else {
            # Use compose for Docker (usually more reliable)
            $composeFile = "docker-compose.$Env.yml"
            if (Test-Path $composeFile) {
                if ($script:ComposeSubcommand) {
                    & $script:ComposeCommand $script:ComposeSubcommand -f $composeFile down -v --timeout 10
                } else {
                    & $script:ComposeCommand -f $composeFile down -v --timeout 10
                }
                Write-Success "Stopped existing containers and removed volumes"
            } else {
                Write-Info "No existing compose file found"
            }
        }
    } catch {
        Write-Info "Cleanup completed (some resources may not have existed)"
    }

    Write-Step "Building and starting containers..." "5/6"

    # Start the new environment
    try {
        Write-Info "Building and starting containers with $ContainerEngine (this may take a moment)..."
        if ($script:ComposeSubcommand) {
            & $script:ComposeCommand $script:ComposeSubcommand -f "docker-compose.$Env.yml" up --build -d
        } else {
            & $script:ComposeCommand -f "docker-compose.$Env.yml" up --build -d
        }
        Write-Success "Containers started successfully"
    } catch {
        Write-Error "Failed to start containers"
        Write-Info "Check the container logs for more information"
        exit 1
    }

    Write-Step "Verifying deployment..." "6/6"

    # Wait a moment for containers to start
    Start-Sleep 3

    # Simple container verification
    try {
        Write-Success "Checking containers:"
        
        $containerNames = @("$AppName.$Env", "$AppName.db.$Env", "$AppName.redis.$Env")
        $runningCount = 0
        
        foreach ($containerName in $containerNames) {
            try {
                if ($ContainerEngine -eq "podman") {
                    $status = podman inspect $containerName --format "{{.State.Status}}" 2>$null
                } else {
                    $status = docker inspect $containerName --format "{{.State.Status}}" 2>$null
                }
                
                if ($status -eq "running") {
                    Write-ColorOutput "  ✅ $containerName - running" "Green"
                    $runningCount++
                } else {
                    Write-ColorOutput "  ⚠️ $containerName - $status" "Yellow"
                }
            } catch {
                Write-ColorOutput "  ❌ $containerName - not found" "Red"
            }
        }
        
        if ($runningCount -eq 3) {
            Write-Success "All containers are running!"
        } elseif ($runningCount -gt 0) {
            Write-ColorOutput "⚠️ $runningCount/3 containers are running" "Yellow"
        } else {
            Write-ColorOutput "❌ No containers are running" "Red"
        }
        
    } catch {
        Write-Info "Container verification failed - checking via compose..."
        
        # Fallback to compose ps (without format)
        try {
            if ($script:ComposeSubcommand) {
                $containers = & $script:ComposeCommand $script:ComposeSubcommand -f "docker-compose.$Env.yml" ps
            } else {
                $containers = & $script:ComposeCommand -f "docker-compose.$Env.yml" ps
            }
            
            if ($containers) {
                Write-Host $containers
            } else {
                Write-Info "No containers found via compose"
            }
        } catch {
            Write-Info "Compose status check also failed - containers may be starting"
        }
    }

    # Test application connectivity
    Write-Info "Testing application connectivity..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$port" -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Success "Application is responding on http://localhost:$port"
        } else {
            Write-Info "Application may still be starting up..."
        }
    } catch {
        Write-Info "Application may still be starting up..."
    }
}

Write-ColorOutput "`n🎉 Setup Complete!" "Green"
Write-ColorOutput "═══════════════════" "Green"

Write-ColorOutput "`n📋 Environment Details:" "Cyan"
Write-ColorOutput "• App Name: $AppName" "White"
Write-ColorOutput "• Environment: $Env" "White"
Write-ColorOutput "• Application URL: http://localhost:$port" "White"
Write-ColorOutput "• Lucia Demo: http://localhost:$port/demo/lucia" "White"

if (-not $NoStart) {
    Write-ColorOutput "`n🐳 Container Commands:" "Cyan"
    if ($script:ComposeSubcommand) {
        Write-ColorOutput "• View logs: $script:ComposeCommand $script:ComposeSubcommand -f docker-compose.$Env.yml logs -f" "White"
        Write-ColorOutput "• Stop: $script:ComposeCommand $script:ComposeSubcommand -f docker-compose.$Env.yml down" "White"
        Write-ColorOutput "• Restart: $script:ComposeCommand $script:ComposeSubcommand -f docker-compose.$Env.yml restart" "White"
    } else {
        Write-ColorOutput "• View logs: $script:ComposeCommand -f docker-compose.$Env.yml logs -f" "White"
        Write-ColorOutput "• Stop: $script:ComposeCommand -f docker-compose.$Env.yml down" "White"
        Write-ColorOutput "• Restart: $script:ComposeCommand -f docker-compose.$Env.yml restart" "White"
    }
} else {
    Write-ColorOutput "`n🐳 To start containers:" "Cyan"
    # Show the best available command
    if ($ContainerEngine -eq "podman") {
        try {
            podman compose --version | Out-Null
            Write-ColorOutput "• Start: podman compose -f docker-compose.$Env.yml up --build -d" "White"
            Write-ColorOutput "• View logs: podman compose -f docker-compose.$Env.yml logs -f" "White"
            Write-ColorOutput "• Stop: podman compose -f docker-compose.$Env.yml down" "White"
        } catch {
            Write-ColorOutput "• Start: podman-compose -f docker-compose.$Env.yml up --build -d" "White"
            Write-ColorOutput "• View logs: podman-compose -f docker-compose.$Env.yml logs -f" "White"
            Write-ColorOutput "• Stop: podman-compose -f docker-compose.$Env.yml down" "White"
        }
    } else {
        Write-ColorOutput "• Start: docker-compose -f docker-compose.$Env.yml up --build -d" "White"
        Write-ColorOutput "• View logs: docker-compose -f docker-compose.$Env.yml logs -f" "White"
        Write-ColorOutput "• Stop: docker-compose -f docker-compose.$Env.yml down" "White"
    }
}

Write-ColorOutput "`n📁 Generated Files:" "Cyan"
Write-ColorOutput "• .env.$Env - Environment variables" "White"
Write-ColorOutput "• docker-compose.$Env.yml - Docker configuration" "White"
Write-ColorOutput "• $DbDir/init.$Env.sql - Database initialization" "White"
Write-ColorOutput "• redis.$Env.conf - Redis configuration" "White"
Write-ColorOutput "• redis.$Env.acl - Redis access control" "White"

Write-ColorOutput "`n🗃️ Database Setup:" "Cyan"
Write-ColorOutput "• Tables will be created via Drizzle migrations" "White"
Write-ColorOutput "• Run 'cd app && pnpm db:generate && pnpm db:migrate' to apply schema" "White"
Write-ColorOutput "• Run 'pnpm db:seed' to populate initial data" "White"

if ($ShowPasswords) {
    Write-ColorOutput "`n🔑 Generated Passwords:" "Magenta"
    Write-ColorOutput "══════════════════════" "Magenta"
    
    # Group passwords logically
    Write-ColorOutput "`n🗄️ Database Passwords:" "Yellow"
    Write-ColorOutput "POSTGRES_SUPERUSER_PASSWORD: $($passwords.POSTGRES_SUPERUSER_PASSWORD)" "White"
    Write-ColorOutput "ADMIN_PASSWORD: $($passwords.ADMIN_PASSWORD)" "White"
    Write-ColorOutput "DEVELOPER_PASSWORD: $($passwords.DEVELOPER_PASSWORD)" "White"
    Write-ColorOutput "API_PASSWORD: $($passwords.API_PASSWORD)" "White"
    Write-ColorOutput "READONLY_PASSWORD: $($passwords.READONLY_PASSWORD)" "White"
    
    Write-ColorOutput "`n🔴 Redis Passwords:" "Yellow"
    Write-ColorOutput "REDIS_PASSWORD: $($passwords.REDIS_PASSWORD)" "White"
    Write-ColorOutput "ADMIN_USER_REDIS_PASSWORD: $($passwords.ADMIN_USER_REDIS_PASSWORD)" "White"
    Write-ColorOutput "API_USER_REDIS_PASSWORD: $($passwords.API_USER_REDIS_PASSWORD)" "White"
    
    Write-ColorOutput "`n👤 Application User Passwords:" "Yellow"
    Write-ColorOutput "ADMIN_USER_PASSWORD: $($passwords.ADMIN_USER_PASSWORD)" "White"
    Write-ColorOutput "DEVELOPER_USER_PASSWORD: $($passwords.DEVELOPER_USER_PASSWORD)" "White"
    
    Write-ColorOutput "`n🔐 Application Secret:" "Yellow"
    Write-ColorOutput "APP_SECRET: $($passwords.APP_SECRET)" "White"
    
    Write-ColorOutput "`n💾 All passwords are saved in .env.$Env" "Gray"
}

if (-not $NoStart) {
    Write-ColorOutput "`n🚀 Next Steps:" "Green"
    Write-ColorOutput "1. Visit http://localhost:$port to see your application" "White"
    Write-ColorOutput "2. Create database tables: cd app && pnpm db:generate && pnpm db:migrate" "White"
    Write-ColorOutput "3. Seed initial data: pnpm db:seed" "White"
    Write-ColorOutput "4. Try the Lucia auth demo at http://localhost:$port/demo/lucia" "White"
    Write-ColorOutput "5. Start developing in the ./app directory" "White"
    Write-ColorOutput "6. Use './setup.ps1' to access the main menu for more options" "White"
} else {
    Write-ColorOutput "`n🚀 Next Steps:" "Green"
    Write-ColorOutput "1. Start containers: docker-compose -f docker-compose.$Env.yml up --build -d" "White"
    Write-ColorOutput "2. Create database tables: cd app && pnpm db:generate && pnpm db:migrate" "White"
    Write-ColorOutput "3. Seed initial data: pnpm db:seed" "White"
    Write-ColorOutput "4. Visit http://localhost:$port to see your application" "White"
    Write-ColorOutput "5. Start developing in the ./app directory" "White"
    Write-ColorOutput "6. Use './setup.ps1' to access the main menu for more options" "White"
}

Write-Host ""