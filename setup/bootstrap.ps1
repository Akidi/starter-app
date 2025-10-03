#!/usr/bin/env pwsh
#Requires -Version 7.2

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

$Script:RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $PSCommandPath) '..')).Path
$Script:TemplatesPath = Join-Path $RepoRoot 'templates'
$Script:DbPath = Join-Path $RepoRoot 'db'
$Script:Style = [ordered]@{
    Accent  = $PSStyle.Foreground.BrightCyan
    Success = $PSStyle.Foreground.BrightGreen
    Info    = $PSStyle.Foreground.BrightBlue
    Warn    = $PSStyle.Foreground.BrightYellow
    Danger  = $PSStyle.Foreground.BrightRed
    Muted   = $PSStyle.Foreground.BrightBlack
    Reset   = $PSStyle.Reset
}
$Script:Glyphs = [ordered]@{
    Success = '[OK]'
    Info    = '[i]'
    Warn    = '[!!]'
    Danger  = '[X]'
    Step    = '>>'
    Bullet  = '-'
}
$Script:EnvironmentPorts = @{ dev = 5173; staging = 5174; prod = 5175 }

function Write-Heading {
    param([string]$Text)
    Write-Host ""
    Write-Host "$($Style.Accent)$Text$($Style.Reset)"
    Write-Host "$($Style.Muted)$('-' * [Math]::Min([Text.Encoding]::UTF8.GetByteCount($Text), 64))$($Style.Reset)"
}

function Write-SubHeading {
    param([string]$Text)
    Write-Host "$($Style.Info)$Text$($Style.Reset)"
}

function Write-Success {
    param([string]$Text)
    Write-Host "$($Style.Success)$($Glyphs.Success) $Text$($Style.Reset)"
}

function Write-Info {
    param([string]$Text)
    Write-Host "$($Style.Info)$($Glyphs.Info) $Text$($Style.Reset)"
}

function Write-Warn {
    param([string]$Text)
    Write-Host "$($Style.Warn)$($Glyphs.Warn) $Text$($Style.Reset)"
}

function Write-ErrorLine {
    param([string]$Text)
    Write-Host "$($Style.Danger)$($Glyphs.Danger) $Text$($Style.Reset)"
}

function Write-Step {
    param(
        [string]$Title,
        [int]$Index,
        [int]$Total
    )
    Write-Host ""
    Write-Host "$($Style.Accent)$($Glyphs.Step) Step $Index/$Total$($Style.Reset) $Title"
}

function Read-Input {
    param(
        [string]$Prompt,
        [string]$Default
    )
    $suffix = if ($Default) { " [$Default]" } else { '' }
    Write-Host -NoNewline "$($Style.Info)$Prompt$suffix$($Style.Reset): "
    $value = Read-Host
    if ([string]::IsNullOrWhiteSpace($value) -and $Default) { return $Default }
    return $value.Trim()
}

function Confirm-YesNo {
    param(
        [string]$Prompt,
        [switch]$DefaultYes
    )
    $defaultHint = if ($DefaultYes) { 'Y/n' } else { 'y/N' }
    do {
        $response = Read-Input "$Prompt ($defaultHint)"
        if (-not $response) { return $DefaultYes }
        switch ($response.ToLower()) {
            {$_ -in 'y','yes'} { return $true }
            {$_ -in 'n','no'} { return $false }
        }
        Write-Warn 'Please answer y or n.'
    } while ($true)
}

function Resolve-AppName {
    param([string]$Value)
    if (-not $Value) {
        throw 'Application name is required.'
    }
    if ($Value -notmatch '^[a-z][a-z0-9-]{0,19}$') {
        throw 'App name must start with a lowercase letter, contain only lowercase letters, digits, or hyphens, and be ≤ 20 characters.'
    }
    return $Value
}

function Resolve-ComposeTool {
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
            & $candidate.Command @versionArgs | Out-Null
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
    param(
        [Parameter(Mandatory=$true)]
        $Tool,
        [string[]]$Arguments,
        [switch]$DryRun
    )
    if (-not $Tool) { throw 'Compose tool not resolved.' }
    $cmd = $Tool.Command
    $prefix = @()
    if ($Tool.Args) { $prefix = @($Tool.Args) }
    $args = @()
    if ($prefix.Count -gt 0) { $args += $prefix }
    if ($Arguments) { $args += $Arguments }
    if ($DryRun) {
        Write-Info "DRY-RUN: $cmd $($args -join ' ')"
        return
    }
    & $cmd @args
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Success "Created directory $Path"
    }
}

function New-Password {
    param([int]$Length = 32)
    try {
        $openssl = Get-Command openssl -ErrorAction Stop
        $bytes = [math]::Ceiling($Length * 4 / 3)
        $raw = & $openssl.Source rand -base64 $bytes
        if ($raw) {
            $clean = ($raw -replace '[=+/]', '').Substring(0, [Math]::Min($Length, $raw.Length))
            if ($clean.Length -eq $Length) { return $clean }
        }
    } catch {
        # ignore, fallback to RNG
    }
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' 
    -join (0..($Length-1) | ForEach-Object { $alphabet[(Get-Random -Maximum $alphabet.Length)] })
}

function New-SecretSet {
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

function Expand-Template {
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

function Invoke-FullSetup {
    param(
        [string]$AppName,
        [string]$Environment,
        [switch]$ShowSecrets,
        [switch]$NoStart,
        [switch]$DryRun
    )

    $app = Resolve-AppName $AppName
    if (-not $EnvironmentPorts.ContainsKey($Environment)) {
        throw "Environment '$Environment' is not supported."
    }

    Write-Heading "SvelteKit Starter :: Full Setup"
    Write-Info "Project: $app"
    Write-Info "Environment: $Environment"

    $secrets = New-SecretSet
    Write-Success "Generated $($secrets.Keys.Count) secrets"
    $port = $EnvironmentPorts[$Environment]

    $variables = [ordered]@{}; foreach ($key in $secrets.Keys) { $variables[$key] = $secrets[$key] }
    $variables.APP_NAME = $app
    $variables.ENV = $Environment
    $variables.PORT = $port

    Ensure-Directory $DbPath

    Write-Step 'Materialising templates' 1 3
    $results = @()
    $templatePlan = @(
        @{ Template = Join-Path $TemplatesPath '.env.template'; Destination = Join-Path $RepoRoot ".env.$Environment" },
        @{ Template = Join-Path $TemplatesPath 'docker-compose.template.yml'; Destination = Join-Path $RepoRoot "docker-compose.$Environment.yml" },
        @{ Template = Join-Path $TemplatesPath 'init.template.sql'; Destination = Join-Path $DbPath "init.$Environment.sql" },
        @{ Template = Join-Path $TemplatesPath 'redis.conf.template'; Destination = Join-Path $RepoRoot "redis.$Environment.conf" },
        @{ Template = Join-Path $TemplatesPath 'redis.acl.template'; Destination = Join-Path $RepoRoot "redis.$Environment.acl" }
    )
    foreach ($item in $templatePlan) {
        $results += Expand-Template -TemplatePath $item.Template -DestinationPath $item.Destination -Variables $variables -DryRun:$DryRun
    }

    Write-SubHeading 'File summary'
    $results | Sort-Object File | Format-Table File, Status -AutoSize | Out-String | ForEach-Object { Write-Host $_ }

    Write-Step 'Resolving container runtime' 2 3
    $tool = Resolve-ComposeTool
    if (-not $tool) {
        throw 'No compose-compatible container tool was detected. Install Podman or Docker.'
    }
    Write-Success "Using $($tool.Display)"

    if (-not $DryRun -and -not $NoStart) {
        if (-not (Test-Path "docker-compose.$Environment.yml")) {
            throw "docker-compose.$Environment.yml was not generated."
        }
        Write-Step 'Bootstrapping containers' 3 3
        try {
            Invoke-ComposeCommand -Tool $tool -Arguments @('-f', "docker-compose.$Environment.yml", 'down', '-v', '--remove-orphans', '--timeout', '10') -DryRun:$DryRun | Out-Null
        } catch {
            Write-Warn 'Existing environment could not be torn down (continuing)'
        }
        Invoke-ComposeCommand -Tool $tool -Arguments @('-f', "docker-compose.$Environment.yml", 'up', '--build', '-d') -DryRun:$DryRun | Out-Null
        Write-Success 'Environment is starting in the background.'
    } elseif ($NoStart) {
        Write-Info 'Skipping container start (requested).'
    }

    Write-Heading 'Environment Summary'
    Write-Success "App name: $app"
    Write-Success "Environment: $Environment"
    Write-Success "Application URL: http://localhost:$port"
    if (-not $NoStart) {
        Write-Info 'It may take ~30 seconds for health checks to pass.'
    }

    if ($ShowSecrets) {
        Write-Heading 'Generated Secrets'
        foreach ($key in $secrets.Keys) {
            Write-Host "$($Style.Muted)$key$($Style.Reset): $($secrets[$key])"
        }
    }

    Write-Heading 'Next Steps'
    Write-Host "$($Style.Info)$($Glyphs.Bullet) Create tables: cd app && pnpm db:generate && pnpm db:migrate$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) Seed data: pnpm db:seed$($Style.Reset)"
    if ($NoStart) {
        Write-Host "$($Style.Info)$($Glyphs.Bullet) Start stack: $($tool.Display) -f docker-compose.$Environment.yml up --build -d$($Style.Reset)"
    } else {
        Write-Host "$($Style.Info)$($Glyphs.Bullet) Tail logs: $($tool.Display) -f docker-compose.$Environment.yml logs -f$($Style.Reset)"
    }
}

function Read-EnvFileSecrets {
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

function Show-PasswordReport {
    param([string]$Environment)
    $envFile = Join-Path $RepoRoot ".env.$Environment"
    $data = Read-EnvFileSecrets -EnvFile $envFile
    Write-Heading "Secrets for $Environment"
    foreach ($key in ($data.Keys | Sort-Object)) {
        Write-Host "$($Style.Muted)$key$($Style.Reset): $($data[$key])"
    }
}

function Invoke-Clean {
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
    param([string]$Environment)
    Write-Heading "Project Status :: $Environment"
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

function Invoke-AddSchemaCommand {
    param(
        [string]$SchemaName,
        [switch]$DryRun
    )
    if (-not $SchemaName) { throw 'Schema name is required.' }
    if ($SchemaName -notmatch '^[a-z_][a-z0-9_]*$') {
        throw 'Schema name must be lowercase and may include underscores and digits.'
    }

    $drizzleConfig = Join-Path $RepoRoot 'app/drizzle.config.ts'
    $initTemplate = Join-Path $TemplatesPath 'init.template.sql'
    if (-not (Test-Path $drizzleConfig)) { throw "drizzle.config.ts not found at $drizzleConfig" }
    if (-not (Test-Path $initTemplate)) { throw "init.template.sql not found at $initTemplate" }

    Write-Heading "Add schema '$SchemaName'"
    if ($DryRun) { Write-Info 'DRY RUN - no files will be modified.' }

    $drizzleContent = Get-Content -Path $drizzleConfig -Raw
    if ($drizzleContent -match 'schemaFilter:\s*\[(.*?)\]') {
        $currentSchemas = $matches[1]
        $schemaPattern = "'{0}'|`"{0}`"" -f [regex]::Escape($SchemaName)
        if ($currentSchemas -match $schemaPattern) {
            Write-Warn "Schema '$SchemaName' already exists in drizzle.config.ts"
        } else {
            $replacement = "schemaFilter: [$currentSchemas, '$SchemaName']"
            if ($DryRun) {
                Write-Info "DRY-RUN: Would update schemaFilter to include '$SchemaName'"
            } else {
                $newContent = $drizzleContent -replace 'schemaFilter:\s*\[(.*?)\]', $replacement
                Set-Content -Path $drizzleConfig -Value $newContent -Encoding utf8
                Write-Success 'Updated drizzle.config.ts'
            }
        }
    } else {
        Write-Warn 'Unable to locate schemaFilter in drizzle.config.ts'
    }

    $initContent = Get-Content -Path $initTemplate -Raw
    if ($initContent -match "CREATE SCHEMA $SchemaName;") {
        Write-Warn "Schema '$SchemaName' already exists in init.template.sql"
    } else {
        $updated = $initContent
        $updated = $updated.Replace('CREATE SCHEMA migrations;', "CREATE SCHEMA migrations;
CREATE SCHEMA $SchemaName;")
        $updated = $updated.Replace('ALTER SCHEMA migrations OWNER TO admin;', "ALTER SCHEMA migrations OWNER TO admin;
ALTER SCHEMA $SchemaName OWNER TO admin;")
        $usageLine = 'GRANT USAGE ON SCHEMA migrations TO admin, developer;'
        $updated = $updated.Replace($usageLine, "GRANT USAGE ON SCHEMA $SchemaName TO admin, developer, api, read_only, backup, auditor;
$usageLine")
        $createLine = 'GRANT CREATE ON SCHEMA migrations TO admin, developer;'
        $updated = $updated.Replace($createLine, "GRANT CREATE ON SCHEMA $SchemaName TO admin, developer;
$createLine")
        foreach ($role in @('archon','tinkerer','lorekeeper','runesmith')) {
            $pattern = "(ALTER ROLE $role SET search_path TO [^;]+);"
            $updated = [regex]::Replace($updated, $pattern, { param($m) "{0}, $SchemaName;" -f $m.Groups[1].Value })
        }
        if ($DryRun) {
            Write-Info 'DRY-RUN: Would append schema definitions inside init.template.sql'
        } else {
            Set-Content -Path $initTemplate -Value $updated -Encoding utf8
            Write-Success 'Updated init.template.sql'
        }
    }    Write-Heading 'Next Steps'
    Write-Host "$($Style.Info)$($Glyphs.Bullet) Create app/src/lib/server/db/schemas/$SchemaName.ts$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) Export it from app/src/lib/server/db/schema.ts$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) Run migrations: cd app && pnpm db:generate && pnpm db:migrate$($Style.Reset)"
}
function Show-HelpPanel {
    Write-Heading 'Setup Assistant :: Help'
    Write-Host "$($Style.Info)$($Glyphs.Bullet) full      $($Style.Muted)- generate configs, secrets, and optionally start containers$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) schema    $($Style.Muted)- append a new PostgreSQL schema to templates$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) passwords $($Style.Muted)- display stored secrets for an environment$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) status    $($Style.Muted)- show container and file status$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) clean     $($Style.Muted)- remove generated files for an environment$($Style.Reset)"
    Write-Host "$($Style.Info)$($Glyphs.Bullet) help      $($Style.Muted)- show this reference$($Style.Reset)"
}

function Invoke-InteractiveMenu {
    while ($true) {
        Clear-Host
        Write-Heading 'SvelteKit Starter :: Setup Assistant'
        Write-Host "$($Style.Info)[1] Full setup$($Style.Reset)"
        Write-Host "$($Style.Info)[2] Add schema$($Style.Reset)"
        Write-Host "$($Style.Info)[3] Show secrets$($Style.Reset)"
        Write-Host "$($Style.Info)[4] Project status$($Style.Reset)"
        Write-Host "$($Style.Info)[5] Clean environment$($Style.Reset)"
        Write-Host "$($Style.Info)[6] Help$($Style.Reset)"
        Write-Host "$($Style.Info)[0] Exit$($Style.Reset)"

        $choice = Read-Input 'Select an option'
        switch ($choice) {
            '1' {
                $name = Resolve-AppName (Read-Input 'Application name')
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                $show = Confirm-YesNo 'Show generated secrets?' -DefaultYes:$false
                $skip = Confirm-YesNo 'Skip container start?' -DefaultYes:$false
                Invoke-FullSetup -AppName $name -Environment $env -ShowSecrets:$show -NoStart:$skip
                Pause
            }
            '2' {
                $schema = Read-Input 'Schema name'
                Invoke-AddSchemaCommand -SchemaName $schema
                Pause
            }
            '3' {
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                Show-PasswordReport -Environment $env
                Pause
            }
            '4' {
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                Invoke-Status -Environment $env
                Pause
            }
            '5' {
                $env = (Read-Input 'Environment (dev/staging/prod)' 'dev').ToLower()
                Invoke-Clean -Environment $env
                Pause
            }
            '6' {
                Show-HelpPanel
                Pause
            }
            '0' { break }
            default { Write-Warn 'Unknown option.'; Start-Sleep 1 }
        }
    }
}

function Pause {
    Write-Host ""
    Write-Host "$($Style.Muted)Press Enter to continue...$($Style.Reset)" -NoNewline
    [void][System.Console]::ReadLine()
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
            Invoke-FullSetup -AppName $AppName -Environment $Environment -ShowSecrets:$ShowSecrets -NoStart:$NoStart -DryRun:$DryRun
        }
        'schema' {
            Invoke-AddSchemaCommand -SchemaName $SchemaName -DryRun:$DryRun
        }
        'passwords' {
            Show-PasswordReport -Environment $Environment
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
    Write-ErrorLine $_.Exception.Message
    exit 1
} finally {
    Pop-Location
}









