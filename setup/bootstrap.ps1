#!/usr/bin/env pwsh
#Requires -Version 7.2

<#
.SYNOPSIS
SvelteKit Starter setup assistant

.DESCRIPTION
Orchestrates environment setup, secret generation, and container management
for the SvelteKit starter project.

.PARAMETER Action
The action to perform (full, schema, passwords, status, clean, help)

.PARAMETER AppName
Application name (lowercase, hyphens allowed, max 20 chars)

.PARAMETER Environment
Target environment (dev, staging, prod)

.PARAMETER NoStart
Skip starting containers after setup

.PARAMETER ShowSecrets
Display generated secrets in output

.PARAMETER DryRun
Show what would be done without making changes

.PARAMETER SchemaName
Name of the schema to add (for 'schema' action)

.EXAMPLE
.\setup.ps1 -Action full -AppName myapp -Environment dev

.EXAMPLE
.\setup.ps1 -Action schema -SchemaName inventory

.EXAMPLE
.\setup.ps1
# Runs in interactive mode
#>

[CmdletBinding(DefaultParameterSetName='Interactive')]
param(
    [Parameter(ParameterSetName='NonInteractive', Mandatory=$true, Position=0)]
    [ValidateSet('full','schema','passwords','status','clean','help')]
    [string]$Action,

    [Parameter(ParameterSetName='NonInteractive')]
    [string]$AppName = 'starter-app',

    [Parameter(ParameterSetName='NonInteractive')]
    [ValidateSet('dev','staging','prod')]
    [string]$Environment = 'dev',

    [Parameter(ParameterSetName='NonInteractive')]
    [switch]$NoStart,

    [Parameter(ParameterSetName='NonInteractive')]
    [switch]$ShowSecrets,

    [Parameter(ParameterSetName='NonInteractive')]
    [switch]$DryRun,

    [Parameter(ParameterSetName='NonInteractive')]
    [string]$SchemaName
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

# Determine script paths
$Script:RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $PSCommandPath) '..')).Path
$Script:ScriptsPath = Join-Path $RepoRoot 'scripts'
$Script:ModulesPath = Join-Path $ScriptsPath 'modules'
$Script:TemplatesPath = Join-Path $RepoRoot 'templates'
$Script:DbPath = Join-Path $RepoRoot 'db'

# Import modules
Import-Module (Join-Path $ModulesPath 'Setup.Core.psm1') -Force -DisableNameChecking -Global
Import-Module (Join-Path $ModulesPath 'Setup.Secrets.psm1') -Force -DisableNameChecking -Global
Import-Module (Join-Path $ModulesPath 'Setup.Templates.psm1') -Force -DisableNameChecking -Global
Import-Module (Join-Path $ModulesPath 'Setup.Container.psm1') -Force -DisableNameChecking -Global
Import-Module (Join-Path $ModulesPath 'Setup.Schema.psm1') -Force -DisableNameChecking -Global

function Invoke-FullSetup {
    <#
    .SYNOPSIS
    Performs a complete environment setup
    #>
    param(
        [string]$AppName,
        [string]$Environment,
        [switch]$ShowSecrets,
        [switch]$NoStart,
        [switch]$DryRun
    )

    $app = Resolve-AppName $AppName
    
    # Validate environment is supported
    $supportedEnvironments = @('dev', 'staging', 'prod')
    if ($Environment -notin $supportedEnvironments) {
        throw "Environment '$Environment' is not supported. Must be one of: $($supportedEnvironments -join ', ')"
    }
    
    Write-Heading "SvelteKit Starter :: Full Setup"
    Write-Info "Project: $app"
    Write-Info "Environment: $Environment"

    # Generate secrets
    $secrets = New-SecretSet
    Write-Success "Generated $($secrets.Keys.Count) secrets"
    
    # Get port for environment
    $port = Get-EnvironmentPort -Environment $Environment

    # Build variables hashtable
    $variables = [ordered]@{}
    foreach ($key in $secrets.Keys) { 
        $variables[$key] = $secrets[$key] 
    }
    $variables.APP_NAME = $app
    $variables.ENV = $Environment
    $variables.PORT = $port

    # Add environment-specific variables
    $envVars = Get-EnvironmentSpecificVariables -Environment $Environment -AppName $app
    foreach ($key in $envVars.Keys) {
        $variables[$key] = $envVars[$key]
    }

    # Get or generate network configuration
    $networkValues = Get-NetworkConfiguration `
        -Environment $Environment `
        -RepoRoot $RepoRoot
    
    foreach ($key in $networkValues.Keys) {
        $variables[$key] = $networkValues[$key]
    }
    Write-Info "Assigned network subnet: $($networkValues.NETWORK_SUBNET)"

    # Ensure db directory exists
    Test-PathExists $DbPath

    # Expand templates
    Write-Step 'Materialising templates' 1 3
    $results = @()
    
    $templatePlan = Get-TemplateExpansionPlan `
        -Environment $Environment `
        -RepoRoot $RepoRoot `
        -TemplatesPath $TemplatesPath `
        -DbPath $DbPath
    
    foreach ($item in $templatePlan) {
        $results += Expand-Template `
            -TemplatePath $item.Template `
            -DestinationPath $item.Destination `
            -Variables $variables `
            -DryRun:$DryRun
    }

    Write-SubHeading 'File summary'
    $results | Sort-Object File | Format-Table File, Status -AutoSize | Out-String | ForEach-Object { Write-Host $_ }

    # Resolve container tool
    Write-Step 'Resolving container runtime' 2 3
    $tool = Resolve-ComposeTool
    if (-not $tool) {
        throw 'No compose-compatible container tool was detected. Install Podman or Docker.'
    }
    Write-Success "Using $($tool.Display)"

    # Start containers if requested
    if (-not $DryRun -and -not $NoStart) {
        Write-Step 'Bootstrapping containers' 3 3
        Start-ContainerEnvironment `
            -Tool $tool `
            -Environment $Environment `
            -DryRun:$DryRun
    } elseif ($NoStart) {
        Write-Info 'Skipping container start (requested).'
    }

    # Summary
    Write-Host ""
    Write-Host "$($PSStyle.Foreground.BrightCyan)Environment Summary$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlack)$('-' * 19)$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightGreen)[OK]$($PSStyle.Reset) App name: $app"
    Write-Host "$($PSStyle.Foreground.BrightGreen)[OK]$($PSStyle.Reset) Environment: $Environment"
    Write-Host "$($PSStyle.Foreground.BrightGreen)[OK]$($PSStyle.Reset) Application URL: http://localhost:$port"
    if (-not $NoStart -and -not $DryRun) {
        Write-Host "$($PSStyle.Foreground.BrightBlue)[i]$($PSStyle.Reset) It may take ~30 seconds for health checks to pass."
    }

    if ($ShowSecrets) {
        Write-Host ""
        Write-Host "$($PSStyle.Foreground.BrightCyan)Generated Secrets$($PSStyle.Reset)"
        Write-Host "$($PSStyle.Foreground.BrightBlack)$('-' * 17)$($PSStyle.Reset)"
        foreach ($key in $secrets.Keys) {
            Write-Host "$($PSStyle.Foreground.BrightBlack)$key$($PSStyle.Reset): $($secrets[$key])"
        }
    }

    # Next steps
    Write-Host ""
    Write-Host "$($PSStyle.Foreground.BrightCyan)Next Steps$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlack)$('-' * 10)$($PSStyle.Reset)"
    $tool = Resolve-ComposeTool  # Get tool again in case it's needed
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Create tables: cd app && pnpm db:generate && pnpm db:migrate"
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Seed data: pnpm db:seed"
    if ($NoStart -or $DryRun) {
        if ($tool) {
            Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Start stack: $($tool.Display) -f docker-compose.$Environment.yml up --build -d"
        }
    } else {
        if ($tool) {
            Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Tail logs: $($tool.Display) -f docker-compose.$Environment.yml logs -f"
        }
    }
}

function Invoke-Clean {
    <#
    .SYNOPSIS
    Removes all generated files for an environment
    #>
    param([string]$Environment)
    
    Write-Heading "Clean $Environment"
    $targets = @(
        ".env.$Environment",
        "docker-compose.$Environment.yml",
        "redis.$Environment.conf",
        "redis.$Environment.acl",
        (Join-Path $DbPath "init.$Environment.sql")
    )
    
    foreach ($item in $targets) {
        if (Test-Path $item) {
            Remove-Item $item -Force
            Write-Success "Removed $item"
        }
    }
}

function Invoke-Status {
    <#
    .SYNOPSIS
    Shows the current status of an environment
    #>
    param([string]$Environment)
    
    Write-Heading "Project Status :: $Environment"
    
    # Container status
    Get-ContainerStatus -Environment $Environment

    # File status
    Write-SubHeading 'Generated files'
    $files = @(
        ".env.$Environment",
        "docker-compose.$Environment.yml",
        "redis.$Environment.conf",
        "redis.$Environment.acl",
        (Join-Path $DbPath "init.$Environment.sql")
    )
    
    $table = foreach ($file in $files) {
        [pscustomobject]@{
            File   = $file
            Exists = Test-Path $file
        }
    }
    $table | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Host $_ }
}

function Show-HelpPanel {
    <#
    .SYNOPSIS
    Displays help information
    #>
    Write-Heading 'Setup Assistant :: Help'
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)full      $($PSStyle.Foreground.BrightBlack)- generate configs, secrets, and optionally start containers$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)schema    $($PSStyle.Foreground.BrightBlack)- append a new PostgreSQL schema to templates$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)passwords $($PSStyle.Foreground.BrightBlack)- display stored secrets for an environment$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)status    $($PSStyle.Foreground.BrightBlack)- show container and file status$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)clean     $($PSStyle.Foreground.BrightBlack)- remove generated files for an environment$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)help      $($PSStyle.Foreground.BrightBlack)- show this reference$($PSStyle.Reset)"
}

function Invoke-InteractiveMenu {
    <#
    .SYNOPSIS
    Displays an interactive menu for user-driven setup
    #>
    while ($true) {
        Clear-Host
        Write-Heading 'SvelteKit Starter :: Setup Assistant'
        Write-Host "$($PSStyle.Foreground.BrightBlue)[1]$($PSStyle.Reset) Full setup"
        Write-Host "$($PSStyle.Foreground.BrightBlue)[2]$($PSStyle.Reset) Add schema"
        Write-Host "$($PSStyle.Foreground.BrightBlue)[3]$($PSStyle.Reset) Show secrets"
        Write-Host "$($PSStyle.Foreground.BrightBlue)[4]$($PSStyle.Reset) Project status"
        Write-Host "$($PSStyle.Foreground.BrightBlue)[5]$($PSStyle.Reset) Clean environment"
        Write-Host "$($PSStyle.Foreground.BrightBlue)[6]$($PSStyle.Reset) Help"
        Write-Host "$($PSStyle.Foreground.BrightBlue)[0]$($PSStyle.Reset) Exit"

        $choice = Read-Input 'Select an option'
        switch ($choice) {
            '1' {
                $name = Resolve-AppName (Read-Input 'Application name')
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                $show = Confirm-YesNo 'Show generated secrets?' -DefaultYes:$false
                $skip = Confirm-YesNo 'Skip container start?' -DefaultYes:$false
                Invoke-FullSetup -AppName $name -Environment $env -ShowSecrets:$show -NoStart:$skip
                Invoke-Pause
            }
            '2' {
                $schema = Read-Input 'Schema name'
                Add-SchemaToTemplate `
                    -SchemaName $schema `
                    -RepoRoot $RepoRoot `
                    -TemplatesPath $TemplatesPath
                Invoke-Pause
            }
            '3' {
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                Show-SecretReport -Environment $env -RepoRoot $RepoRoot
                Invoke-Pause
            }
            '4' {
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                Invoke-Status -Environment $env
                Invoke-Pause
            }
            '5' {
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                Invoke-Clean -Environment $env
                Invoke-Pause
            }
            '6' {
                Show-HelpPanel
                Invoke-Pause
            }
            '0' { return }
            default { Write-Warn 'Unknown option.'; Start-Sleep 1 }
        }
    }
}

try {
    Push-Location $RepoRoot
    
    if ($PSCmdlet.ParameterSetName -eq 'Interactive') {
        Invoke-InteractiveMenu
        return
    }

    switch ($Action) {
        'full' {
            if (-not $AppName) { throw 'AppName is required for full setup.' }
            Invoke-FullSetup `
                -AppName $AppName `
                -Environment $Environment `
                -ShowSecrets:$ShowSecrets `
                -NoStart:$NoStart `
                -DryRun:$DryRun
        }
        'schema' {
            if (-not $SchemaName) { throw 'SchemaName is required for schema action.' }
            Add-SchemaToTemplate `
                -SchemaName $SchemaName `
                -RepoRoot $RepoRoot `
                -TemplatesPath $TemplatesPath `
                -DryRun:$DryRun
        }
        'passwords' {
            Show-SecretReport -Environment $Environment -RepoRoot $RepoRoot
        }
        'status' {
            Invoke-Status -Environment $Environment
        }
        'clean' {
            Invoke-Clean -Environment $Environment
        }
        'help' {
            Show-HelpPanel
        }
    }
} catch {
    Write-Host ""
    Write-Host "$($PSStyle.Foreground.BrightRed)[X] Error: $($_.Exception.Message)$($PSStyle.Reset)"
    if ($_.ScriptStackTrace) {
        Write-Host "$($PSStyle.Foreground.BrightBlack)$($_.ScriptStackTrace)$($PSStyle.Reset)"
    }
    exit 1
} finally {
    Pop-Location
}