# Setup.Core.psm1
# UI/UX functions for the setup assistant

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

function Write-Heading {
    <#
    .SYNOPSIS
    Writes a prominent heading with underline
    #>
    param([string]$Text)
    Write-Host ""
    Write-Host "$($Style.Accent)$Text$($Style.Reset)"
    Write-Host "$($Style.Muted)$('-' * [Math]::Min([Text.Encoding]::UTF8.GetByteCount($Text), 64))$($Style.Reset)"
}

function Write-SubHeading {
    <#
    .SYNOPSIS
    Writes a sub-heading
    #>
    param([string]$Text)
    Write-Host "$($Style.Info)$Text$($Style.Reset)"
}

function Write-Success {
    <#
    .SYNOPSIS
    Writes a success message with checkmark
    #>
    param([string]$Text)
    Write-Host "$($Style.Success)$($Glyphs.Success) $Text$($Style.Reset)"
}

function Write-Info {
    <#
    .SYNOPSIS
    Writes an informational message
    #>
    param([string]$Text)
    Write-Host "$($Style.Info)$($Glyphs.Info) $Text$($Style.Reset)"
}

function Write-Warn {
    <#
    .SYNOPSIS
    Writes a warning message
    #>
    param([string]$Text)
    Write-Host "$($Style.Warn)$($Glyphs.Warn) $Text$($Style.Reset)"
}

function Write-ErrorLine {
    <#
    .SYNOPSIS
    Writes an error message
    #>
    param([string]$Text)
    Write-Host "$($Style.Danger)$($Glyphs.Danger) $Text$($Style.Reset)"
}

function Write-Step {
    <#
    .SYNOPSIS
    Writes a step indicator for multi-step processes
    #>
    param(
        [string]$Title,
        [int]$Index,
        [int]$Total
    )
    Write-Host ""
    Write-Host "$($Style.Accent)$($Glyphs.Step) Step $Index/$Total$($Style.Reset) $Title"
}

function Read-Input {
    <#
    .SYNOPSIS
    Prompts for user input with optional default value
    #>
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
    <#
    .SYNOPSIS
    Prompts for yes/no confirmation
    #>
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

function Invoke-Pause {
    <#
    .SYNOPSIS
    Pauses execution until user presses Enter
    #>
    Write-Host ""
    Write-Host "$($Style.Muted)Press Enter to continue...$($Style.Reset)" -NoNewline
    [void][System.Console]::ReadLine()
}

function Resolve-AppName {
    <#
    .SYNOPSIS
    Validates and returns a properly formatted application name
    #>
    param([string]$Value)
    
    if (-not $Value) {
        throw 'Application name is required.'
    }
    if ($Value -notmatch '^[a-z][a-z0-9-]{0,19}$') {
        throw 'App name must start with a lowercase letter, contain only lowercase letters, digits, or hyphens, and be ≤ 20 characters.'
    }
    return $Value
}

function Test-PathExists {
    <#
    .SYNOPSIS
    Tests if a path exists and creates it if missing
    #>
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Success "Created directory $Path"
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Write-Heading',
    'Write-SubHeading',
    'Write-Success',
    'Write-Info',
    'Write-Warn',
    'Write-ErrorLine',
    'Write-Step',
    'Read-Input',
    'Confirm-YesNo',
    'Invoke-Pause',
    'Resolve-AppName',
    'Test-PathExists'
)