# Setup.Templates.psm1
# Template expansion and file generation

function Get-EnvironmentPort {
    <#
    .SYNOPSIS
    Returns the port number for a given environment
    
    .PARAMETER Environment
    The environment name (dev, staging, prod)
    
    .EXAMPLE
    $port = Get-EnvironmentPort -Environment 'dev'
    #>
    [OutputType([int])]
    param([string]$Environment)
    
    $ports = @{ 
        dev = 5173
        staging = 5174
        prod = 5175 
    }
    
    if (-not $ports.ContainsKey($Environment)) {
        throw "Unknown environment: $Environment"
    }
    
    return $ports[$Environment]
}

function Get-EnvironmentSpecificVariables {
    <#
    .SYNOPSIS
    Returns environment-specific variables for template expansion
    
    .PARAMETER Environment
    The target environment (dev, staging, prod)
    
    .PARAMETER AppName
    The application name
    
    .EXAMPLE
    $vars = Get-EnvironmentSpecificVariables -Environment 'dev' -AppName 'myapp'
    #>
    [OutputType([hashtable])]
    param(
        [string]$Environment,
        [string]$AppName
    )
    
    $vars = @{}
    
    if ($Environment -eq 'dev') {
        $vars.BUILD_TARGET = 'development'
        $vars.NODE_ENV = 'development'
        $vars.INTERNAL_PORT = '5173'
        $vars.HMR_PORT_MAPPING = "`n      - `"24678:24678`""
        $vars.VITE_ENV_VARS = @"

      VITE_DEV: "true"
      VITE_HMR_HOST: "localhost"
      VITE_HMR_PORT: "24678"
"@
        $vars.CHOKIDAR_VARS = @"

      CHOKIDAR_USEPOLLING: "1"
      WATCHPACK_POLLING: "1"
"@
        $vars.DEV_VOLUMES = @"

    volumes:
      - type: bind
        source: ./app
        target: /app
      - type: volume
        source: node_modules
        target: /app/node_modules
      - type: volume
        source: pnpm_store
        target: /pnpm/store
"@
        $vars.DEV_VOLUME_DEFINITIONS = @"

  node_modules:
    name: ${AppName}_node_modules_${Environment}
    driver: local
    labels:
      com.${AppName}.volume.type: "node_modules"
      com.${AppName}.environment: "${Environment}"
  pnpm_store:
    name: ${AppName}_pnpm_store_${Environment}
    driver: local
    labels:
      com.${AppName}.volume.type: "pnpm-store"
      com.${AppName}.environment: "${Environment}"
"@
    } else {
        $vars.BUILD_TARGET = 'production'
        $vars.NODE_ENV = 'production'
        $vars.INTERNAL_PORT = '3000'
        $vars.HMR_PORT_MAPPING = ''
        $vars.VITE_ENV_VARS = ''
        $vars.CHOKIDAR_VARS = ''
        $vars.DEV_VOLUMES = ''
        $vars.DEV_VOLUME_DEFINITIONS = ''
    }
    
    return $vars
}

function Get-NetworkConfiguration {
    <#
    .SYNOPSIS
    Gets or generates network configuration for an environment
    
    .PARAMETER Environment
    The target environment
    
    .PARAMETER RepoRoot
    Root directory of the repository
    
    .DESCRIPTION
    Attempts to read existing network configuration from .env file.
    If not found, generates a new random network in the 172.20-31.0.0/16 range.
    
    .EXAMPLE
    $network = Get-NetworkConfiguration -Environment 'dev' -RepoRoot $PSScriptRoot
    #>
    [OutputType([hashtable])]
    param(
        [string]$Environment,
        [string]$RepoRoot
    )
    
    $envFilePath = Join-Path $RepoRoot ".env.$Environment"
    $networkOctet = $null
    
    # Try to read existing network configuration
    if (Test-Path $envFilePath) {
        try {
            Import-Module (Join-Path $PSScriptRoot 'Setup.Secrets.psm1') -Force
            $existingEnv = Read-EnvFileSecrets -EnvFile $envFilePath
            
            if ($existingEnv.ContainsKey('NETWORK_OCTET')) {
                $value = $existingEnv['NETWORK_OCTET']
                if ($value -match '^\d+$') {
                    $networkOctet = [int]$value
                }
            } elseif ($existingEnv.ContainsKey('NETWORK_SUBNET')) {
                if ($existingEnv['NETWORK_SUBNET'] -match '^172\.(\d+)\.0\.0/16$') {
                    $networkOctet = [int]$matches[1]
                }
            }
        } catch {
            # Ignore errors, will generate new network
        }
    }
    
    # Generate new network if not found
    if (-not $networkOctet) {
        $candidates = 20..31
        $networkOctet = Get-Random -InputObject $candidates
    }
    
    return [ordered]@{
        NETWORK_OCTET    = [string]$networkOctet
        NETWORK_SUBNET   = "172.$networkOctet.0.0/16"
        NETWORK_GATEWAY  = "172.$networkOctet.0.1"
        NETWORK_APP_IP   = "172.$networkOctet.0.10"
        NETWORK_DB_IP    = "172.$networkOctet.0.20"
        NETWORK_REDIS_IP = "172.$networkOctet.0.30"
    }
}

function Expand-Template {
    <#
    .SYNOPSIS
    Expands a template file with variable substitution
    
    .PARAMETER TemplatePath
    Path to the template file
    
    .PARAMETER DestinationPath
    Path where the expanded file should be written
    
    .PARAMETER Variables
    Hashtable of variables to substitute
    
    .PARAMETER DryRun
    If specified, only reports what would be done
    
    .EXAMPLE
    Expand-Template -TemplatePath 'init.template.sql' -DestinationPath 'init.dev.sql' -Variables @{APP_NAME='myapp'}
    #>
    [OutputType([PSCustomObject])]
    param(
        [string]$TemplatePath,
        [string]$DestinationPath,
        [hashtable]$Variables,
        [switch]$DryRun
    )
    
    if (-not (Test-Path $TemplatePath)) {
        throw "Template '$TemplatePath' was not found."
    }
    
    $content = Get-Content -Path $TemplatePath -Raw
    
    # Perform variable substitution
    foreach ($key in $Variables.Keys) {
        $content = $content.Replace("{{${key}}}", [string]$Variables[$key])
    }
    
    # Remove comments and empty lines for specific file types
    $extension = [System.IO.Path]::GetExtension($DestinationPath).ToLower()
    if ($extension -in @('.acl', '.conf', '.sql')) {
        $lines = $content -split "`r?`n"
        $filteredLines = @()
        
        foreach ($line in $lines) {
            $trimmed = $line.TrimStart()
            
            # Skip comment lines and empty lines
            if ($trimmed.StartsWith('#') -or [string]::IsNullOrWhiteSpace($trimmed)) {
                continue
            }
            
            # For SQL files, also skip lines starting with --
            if ($extension -eq '.sql' -and $trimmed.StartsWith('--')) {
                continue
            }
            
            $filteredLines += $line
        }
        
        $content = ($filteredLines -join "`n")
    }
    
    # Ensure file ends with newline
    if (-not $content.EndsWith("`n")) { $content += "`n" }
    
    $status = 'created'
    if (Test-Path $DestinationPath) {
        $existing = Get-Content -Path $DestinationPath -Raw
        $status = if ($existing -eq $content) { 'unchanged' } else { 'updated' }
    }
    
    if ($DryRun) {
        Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
        Write-Info "DRY-RUN: Would write $DestinationPath ($status)"
    } else {
        Set-Content -Path $DestinationPath -Value $content -Encoding utf8
    }
    
    $resolvedPath = $DestinationPath
    if (-not $DryRun -and (Test-Path $DestinationPath)) {
        $resolvedPath = (Resolve-Path -Path $DestinationPath).Path
    }
    
    return [pscustomobject]@{
        File   = $resolvedPath
        Status = $status
    }
}

function Get-TemplateExpansionPlan {
    <#
    .SYNOPSIS
    Returns the list of templates to expand for an environment
    
    .PARAMETER Environment
    The target environment
    
    .PARAMETER RepoRoot
    Root directory of the repository
    
    .PARAMETER TemplatesPath
    Path to templates directory
    
    .PARAMETER DbPath
    Path to database directory
    
    .EXAMPLE
    $plan = Get-TemplateExpansionPlan -Environment 'dev' -RepoRoot $root -TemplatesPath $templates -DbPath $db
    #>
    [OutputType([Array])]
    param(
        [string]$Environment,
        [string]$RepoRoot,
        [string]$TemplatesPath,
        [string]$DbPath
    )
    
    return @(
        @{ 
            Template = Join-Path $TemplatesPath '.env.template'
            Destination = Join-Path $RepoRoot ".env.$Environment" 
        },
        @{ 
            Template = Join-Path $TemplatesPath 'docker-compose.template.yml'
            Destination = Join-Path $RepoRoot "docker-compose.$Environment.yml" 
        },
        @{ 
            Template = Join-Path $TemplatesPath 'init.template.sql'
            Destination = Join-Path $DbPath "init.$Environment.sql" 
        },
        @{ 
            Template = Join-Path $TemplatesPath 'redis.conf.template'
            Destination = Join-Path $RepoRoot "redis.$Environment.conf" 
        },
        @{ 
            Template = Join-Path $TemplatesPath 'redis.acl.template'
            Destination = Join-Path $RepoRoot "redis.$Environment.acl" 
        }
    )
}

# Export module members
Export-ModuleMember -Function @(
    'Get-EnvironmentPort',
    'Get-EnvironmentSpecificVariables',
    'Get-NetworkConfiguration',
    'Expand-Template',
    'Get-TemplateExpansionPlan'
)