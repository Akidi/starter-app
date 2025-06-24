#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true)]
    [string]$SchemaName,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Validate schema name
if ($SchemaName -notmatch '^[a-z_][a-z0-9_]*$') {
    Write-Error "Schema name must be lowercase, start with letter/underscore, and contain only letters, numbers, and underscores"
    exit 1
}

Write-Host "🔧 Adding schema '$SchemaName' to project..." -ForegroundColor Cyan

# File paths
$drizzleConfigPath = "app/drizzle.config.ts"
$initTemplatePath = "templates/init.template.sql"

if (-not (Test-Path $drizzleConfigPath)) {
    Write-Error "❌ drizzle.config.ts not found at $drizzleConfigPath"
    exit 1
}

if (-not (Test-Path $initTemplatePath)) {
    Write-Error "❌ init.template.sql not found at $initTemplatePath"
    exit 1
}

function Update-DrizzleConfig {
    Write-Host "📝 Updating drizzle.config.ts..." -ForegroundColor Yellow
    
    $content = Get-Content $drizzleConfigPath -Raw
    
    # Find the schemaFilter line and update it
    if ($content -match "schemaFilter:\s*\[(.*?)\]") {
        $currentSchemas = $matches[1]
        
        # Check if schema already exists
        if ($currentSchemas -match "'$SchemaName'|`"$SchemaName`"") {
            Write-Warning "⚠️  Schema '$SchemaName' already exists in drizzle.config.ts"
            return
        }
        
        # Add new schema
        $newSchemas = $currentSchemas.TrimEnd() + ", '$SchemaName'"
        $newContent = $content -replace "schemaFilter:\s*\[(.*?)\]", "schemaFilter: [$newSchemas]"
        
        if ($DryRun) {
            Write-Host "DRY RUN - Would update schemaFilter to: [$newSchemas]" -ForegroundColor Magenta
        } else {
            Set-Content $drizzleConfigPath -Value $newContent -NoNewline
            Write-Host "✅ Updated schemaFilter in drizzle.config.ts" -ForegroundColor Green
        }
    } else {
        Write-Error "❌ Could not find schemaFilter in drizzle.config.ts"
        exit 1
    }
}

function Update-InitTemplate {
    Write-Host "📝 Updating init.template.sql..." -ForegroundColor Yellow
    
    $content = Get-Content $initTemplatePath -Raw
    
    # Check if schema already exists
    if ($content -match "CREATE SCHEMA $SchemaName;") {
        Write-Warning "⚠️  Schema '$SchemaName' already exists in init.template.sql"
        return
    }
    
    # 1. Add schema creation after other CREATE SCHEMA lines
    $schemaCreation = "CREATE SCHEMA $SchemaName;"
    $content = $content -replace "(CREATE SCHEMA migrations;)", "`$1`nCREATE SCHEMA $SchemaName;"
    
    # 2. Add ownership after other ALTER SCHEMA OWNER lines
    $content = $content -replace "(ALTER SCHEMA migrations OWNER TO admin;)", "`$1`nALTER SCHEMA $SchemaName OWNER TO admin;"
    
    # 3. Add usage permissions after other GRANT USAGE lines for migrations
    $usageGrant = "GRANT USAGE ON SCHEMA $SchemaName TO admin, developer, api, read_only, backup, auditor;"
    $content = $content -replace "(GRANT USAGE ON SCHEMA migrations TO admin, developer;)", "$usageGrant`n`$1"
    
    # 4. Add create permissions after other GRANT CREATE lines
    $createGrant = "GRANT CREATE ON SCHEMA $SchemaName TO admin, developer;"
    $content = $content -replace "(GRANT CREATE ON SCHEMA migrations TO admin, developer;)", "$createGrant`n`$1"
    
    # 5. Update search paths for all roles
    $roles = @('archon', 'tinkerer', 'lorekeeper', 'runesmith')
    foreach ($role in $roles) {
        $pattern = "(ALTER ROLE $role SET search_path TO [^;]+);"
        if ($content -match $pattern) {
            $currentPath = $matches[1]
            if ($currentPath -notmatch $SchemaName) {
                $newPath = "$currentPath, $SchemaName"
                $content = $content -replace [regex]::Escape($matches[0]), "$newPath;"
            }
        }
    }
    
    if ($DryRun) {
        Write-Host "DRY RUN - Would add the following to init.template.sql:" -ForegroundColor Magenta
        Write-Host "  - CREATE SCHEMA $SchemaName;" -ForegroundColor Magenta
        Write-Host "  - ALTER SCHEMA $SchemaName OWNER TO admin;" -ForegroundColor Magenta
        Write-Host "  - GRANT USAGE ON SCHEMA $SchemaName TO ...;" -ForegroundColor Magenta
        Write-Host "  - GRANT CREATE ON SCHEMA $SchemaName TO ...;" -ForegroundColor Magenta
        Write-Host "  - Updated search_path for all roles" -ForegroundColor Magenta
    } else {
        Set-Content $initTemplatePath -Value $content -NoNewline
        Write-Host "✅ Updated init.template.sql" -ForegroundColor Green
    }
}

function Show-NextSteps {
    Write-Host "`n🎯 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Create your schema TypeScript file: app/src/lib/server/db/schemas/$SchemaName.ts" -ForegroundColor White
    Write-Host "2. Export it from app/src/lib/server/db/schema.ts:" -ForegroundColor White
    Write-Host "   export * from './schemas/$SchemaName.js';" -ForegroundColor Gray
    Write-Host "3. Generate and apply migrations:" -ForegroundColor White
    Write-Host "   cd app && pnpm db:generate && pnpm db:migrate" -ForegroundColor Gray
    Write-Host "4. Or regenerate your environment:" -ForegroundColor White
    Write-Host "   ./setup.ps1 -AppName yourapp -Env dev" -ForegroundColor Gray
}

# Main execution
try {
    if ($DryRun) {
        Write-Host "🔍 DRY RUN MODE - No files will be modified" -ForegroundColor Magenta
    }
    
    Update-DrizzleConfig
    Update-InitTemplate
    
    if (-not $DryRun) {
        Write-Host "`n✨ Schema '$SchemaName' added successfully!" -ForegroundColor Green
    }
    
    Show-NextSteps
} catch {
    Write-Error "❌ Error adding schema: $($_.Exception.Message)"
    exit 1
}