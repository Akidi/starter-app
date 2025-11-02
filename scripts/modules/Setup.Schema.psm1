
# Setup.Schema.psm1
# PostgreSQL schema addition logic

function Add-SchemaToTemplate {
    <#
    .SYNOPSIS
    Adds a new PostgreSQL schema to the init.template.sql and drizzle.config.ts
    
    .PARAMETER SchemaName
    Name of the schema to add (must be lowercase with underscores)
    
    .PARAMETER RepoRoot
    Root directory of the repository
    
    .PARAMETER TemplatesPath
    Path to templates directory
    
    .PARAMETER DryRun
    If specified, only reports what would be done
    
    .DESCRIPTION
    This modifies the template files permanently, so the schema will be included
    in all future environment generations. It:
    1. Adds schema creation and ownership to init.template.sql
    2. Adds the schema to the ACL system (GRANT USAGE, GRANT CREATE)
    3. Updates search paths for relevant roles
    4. Updates drizzle.config.ts schemaFilter
    
    .EXAMPLE
    Add-SchemaToTemplate -SchemaName 'inventory' -RepoRoot $root -TemplatesPath $templates
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SchemaName,
        [string]$RepoRoot,
        [string]$TemplatesPath,
        [switch]$DryRun
    )
    
    Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
    
    # Validate schema name
    if ($SchemaName -notmatch '^[a-z_][a-z0-9_]*') {
        throw 'Schema name must be lowercase and may include underscores and digits.'
    }
    
    $drizzleConfig = Join-Path $RepoRoot 'app/drizzle.config.ts'
    $initTemplate = Join-Path $TemplatesPath 'init.template.sql'
    
    if (-not (Test-Path $drizzleConfig)) { 
        throw "drizzle.config.ts not found at $drizzleConfig" 
    }
    if (-not (Test-Path $initTemplate)) { 
        throw "init.template.sql not found at $initTemplate" 
    }
    
    Write-Heading "Add schema '$SchemaName'"
    if ($DryRun) { Write-Info 'DRY RUN - no files will be modified.' }
    
    # Update drizzle.config.ts
    $drizzleUpdated = Update-DrizzleConfig `
        -ConfigPath $drizzleConfig `
        -SchemaName $SchemaName `
        -DryRun:$DryRun
    
    # Update init.template.sql
    $initUpdated = Update-InitTemplate `
        -TemplatePath $initTemplate `
        -SchemaName $SchemaName `
        -DryRun:$DryRun
    
    if ($drizzleUpdated -or $initUpdated) {
        Write-Heading 'Next Steps'
        Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Create app/src/lib/server/db/schemas/$SchemaName.ts"
        Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Export it from app/src/lib/server/db/schema.ts"
        Write-Host "$($PSStyle.Foreground.BrightBlue)- $($PSStyle.Reset)Run migrations: cd app && pnpm db:generate && pnpm db:migrate"
    }
}

function Update-DrizzleConfig {
    <#
    .SYNOPSIS
    Updates drizzle.config.ts to include a new schema
    
    .PARAMETER ConfigPath
    Path to drizzle.config.ts
    
    .PARAMETER SchemaName
    Name of the schema to add
    
    .PARAMETER DryRun
    If specified, only reports what would be done
    #>
    [OutputType([bool])]
    param(
        [string]$ConfigPath,
        [string]$SchemaName,
        [switch]$DryRun
    )
    
    Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
    
    $content = Get-Content -Path $ConfigPath -Raw
    
    if ($content -match 'schemaFilter:\s*\[(.*?)\]') {
        $currentSchemas = $matches[1]
        $schemaPattern = "'{0}'|`"{0}`"" -f [regex]::Escape($SchemaName)
        
        if ($currentSchemas -match $schemaPattern) {
            Write-Warn "Schema '$SchemaName' already exists in drizzle.config.ts"
            return $false
        }
        
        $replacement = "schemaFilter: [$currentSchemas, '$SchemaName']"
        
        if ($DryRun) {
            Write-Info "DRY-RUN: Would update schemaFilter to include '$SchemaName'"
        } else {
            $newContent = $content -replace 'schemaFilter:\s*\[(.*?)\]', $replacement
            Set-Content -Path $ConfigPath -Value $newContent -Encoding utf8
            Write-Success 'Updated drizzle.config.ts'
        }
        return $true
    } else {
        Write-Warn 'Unable to locate schemaFilter in drizzle.config.ts'
        return $false
    }
}

function Update-InitTemplate {
    <#
    .SYNOPSIS
    Updates init.template.sql to include a new schema
    
    .PARAMETER TemplatePath
    Path to init.template.sql
    
    .PARAMETER SchemaName
    Name of the schema to add
    
    .PARAMETER DryRun
    If specified, only reports what would be done
    #>
    [OutputType([bool])]
    param(
        [string]$TemplatePath,
        [string]$SchemaName,
        [switch]$DryRun
    )
    
    Import-Module (Join-Path $PSScriptRoot 'Setup.Core.psm1') -Force
    
    $content = Get-Content -Path $TemplatePath -Raw
    
    # Check if schema already exists
    if ($content -match "CREATE SCHEMA $SchemaName;") {
        Write-Warn "Schema '$SchemaName' already exists in init.template.sql"
        return $false
    }
    
    $updated = $content
    $changesMade = $false
    
    # 1. Add schema creation after migrations schema
    $createSchemaPattern = '(CREATE SCHEMA migrations;)'
    if ($updated -match $createSchemaPattern) {
        $updated = $updated -replace $createSchemaPattern, "$1`nCREATE SCHEMA $SchemaName;"
        $changesMade = $true
    } else {
        Write-Warn "Could not find 'CREATE SCHEMA migrations;' anchor point"
    }
    
    # 2. Add to apply_standard_schema_acls calls at the end
    $aclCallsPattern = "(SELECT apply_standard_schema_acls\('migrations', 'restricted'\);)"
    if ($updated -match $aclCallsPattern) {
        $updated = $updated -replace $aclCallsPattern, "SELECT apply_standard_schema_acls('$SchemaName', 'app');`n$1"
        $changesMade = $true
    } else {
        Write-Warn "Could not find ACL application anchor point"
    }
    
    # 3. Update search paths for roles that need the new schema
    foreach ($role in @('archon', 'tinkerer', 'lorekeeper', 'runesmith')) {
        $searchPathPattern = "(ALTER ROLE $role SET search_path TO ([^;]+));"
        if ($updated -match $searchPathPattern) {
            $currentPath = $matches[2]
            # Only add if not already present
            if ($currentPath -notmatch [regex]::Escape($SchemaName)) {
                $newPath = "$currentPath, $SchemaName"
                $updated = $updated -replace $searchPathPattern, "ALTER ROLE $role SET search_path TO $newPath;"
                $changesMade = $true
            }
        }
    }
    
    if (-not $changesMade) {
        Write-Warn 'No changes could be made to init.template.sql'
        return $false
    }
    
    if ($DryRun) {
        Write-Info 'DRY-RUN: Would update init.template.sql with schema definitions'
    } else {
        Set-Content -Path $TemplatePath -Value $updated -Encoding utf8
        Write-Success 'Updated init.template.sql'
    }
    
    return $true
}

# Export module members
Export-ModuleMember -Function @(
    'Add-SchemaToTemplate'
)