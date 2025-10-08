# Setup.Container.psm1
# Docker/Podman compose operations

function Resolve-ComposeTool {
    <#
    .SYNOPSIS
    Finds and returns the best available container compose tool
    
    .PARAMETER Preferred
    Preferred container engine (podman or docker)
    
    .DESCRIPTION
    Searches for available compose tools in order of preference.
    Returns the first working tool found.
    
    .EXAMPLE
    $tool = Resolve-ComposeTool -Preferred 'podman'
    #>
    [OutputType([PSCustomObject])]
    param(
        [ValidateSet('podman','docker')]
        [string]$Preferred = 'podman'
    )
    
    $candidates = @()
    
    if ($Preferred -eq 'podman') {
        $candidates += @(
            @{ Display='podman compose'; Command='podman'; Args=@('compose'); Engine='podman' },
            @{ Display='podman-compose'; Command='podman-compose'; Args=@(); Engine='podman' }
        )
        $candidates += @(
            @{ Display='docker compose'; Command='docker'; Args=@('compose'); Engine='docker' },
            @{ Display='docker-compose'; Command='docker-compose'; Args=@(); Engine='docker' }
        )
    } else {
        $candidates += @(
            @{ Display='docker compose'; Command='docker'; Args=@('compose'); Engine='docker' },
            @{ Display='docker-compose'; Command='docker-compose'; Args=@(); Engine='docker' },
            @{ Display='podman compose'; Command='podman'; Args=@('compose'); Engine='podman' },
            @{ Display='podman-compose'; Command='podman-compose'; Args=@(); Engine='podman' }
        )
    }

    foreach ($candidate in $candidates) {
        try {
            $versionArgs = $candidate.Args + 'version'
            & $candidate.Command @versionArgs 2>&1 | Out-Null
            return [pscustomobject]@{
                Display = $candidate.Display
                Command = $candidate.Command
                Args    = $candidate.Args
                Engine  = $candidate.Engine
            }
        } catch {
            continue
        }
    }
    
    return $null
}

function Invoke-ComposeCommand {
    <#
    .SYNOPSIS
    Executes a compose command with the detected tool
    
    .PARAMETER Tool
    The compose tool object from Resolve-ComposeTool
    
    .PARAMETER Arguments
    Arguments to pass to the compose command
    
    .PARAMETER DryRun
    If specified, only prints the command without executing
    
    .EXAMPLE
    Invoke-ComposeCommand -Tool $tool -Arguments @('-f', 'docker-compose.yml', 'up', '-d')
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Tool,
        [string[]]$Arguments,
        [switch]$DryRun
    )
    
    if (-not $Tool) { 
        throw 'Compose tool not resolved.' 
    }
    
    $cmd = $Tool.Command
    $prefix = @()
    if ($Tool.Args) { $prefix = @($Tool.Args) }
    
    $args = @()
    if ($prefix.Count -gt 0) { $args += $prefix }
    if ($Arguments) { $args += $Arguments }
    
    if ($DryRun) {
        Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
        Write-Info "DRY-RUN: $cmd $($args -join ' ')"
        return
    }
    
    & $cmd @args
}

function Start-ContainerEnvironment {
    <#
    .SYNOPSIS
    Starts a container environment for the specified configuration
    
    .PARAMETER Tool
    The compose tool object
    
    .PARAMETER Environment
    The environment name (dev, staging, prod)
    
    .PARAMETER DryRun
    If specified, only reports what would be done
    
    .EXAMPLE
    Start-ContainerEnvironment -Tool $tool -Environment 'dev'
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Tool,
        [string]$Environment,
        [switch]$DryRun
    )
    
    Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
    
    $composeFile = "docker-compose.$Environment.yml"
    
    if (-not $DryRun -and -not (Test-Path $composeFile)) {
        throw "$composeFile was not found."
    }
    
    # Tear down existing environment
    try {
        Invoke-ComposeCommand `
            -Tool $Tool `
            -Arguments @('-f', $composeFile, 'down', '-v', '--remove-orphans', '--timeout', '10') `
            -DryRun:$DryRun | Out-Null
    } catch {
        Write-Warn 'Existing environment could not be torn down (continuing)'
    }
    
    # Start new environment
    Invoke-ComposeCommand `
        -Tool $Tool `
        -Arguments @('-f', $composeFile, 'up', '--build', '-d') `
        -DryRun:$DryRun | Out-Null
    
    if (-not $DryRun) {
        Write-Success 'Environment is starting in the background.'
    }
}

function Get-ContainerStatus {
    <#
    .SYNOPSIS
    Gets the status of containers for an environment
    
    .PARAMETER Environment
    The environment name
    
    .EXAMPLE
    Get-ContainerStatus -Environment 'dev'
    #>
    param([string]$Environment)
    
    Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
    
    $compose = Resolve-ComposeTool
    if ($compose) {
        try {
            $args = @('-f', "docker-compose.$Environment.yml", 'ps')
            $output = & $compose.Command @($compose.Args + $args) 2>$null
            
            Write-SubHeading 'Compose Services'
            if ($output) {
                Write-Host $output
            } else {
                Write-Warn 'No active services reported.'
            }
        } catch {
            Write-Warn "Unable to query services: $($_.Exception.Message)"
        }
    } else {
        Write-Warn 'No compose-capable engine detected.'
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Resolve-ComposeTool',
    'Invoke-ComposeCommand',
    'Start-ContainerEnvironment',
    'Get-ContainerStatus'
)