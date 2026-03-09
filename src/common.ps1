# 🦞 Lobster Legion - Common Utilities Module
# Provides shared functions for logging, validation, and error handling

param()

# ==================== Module State ====================

$Script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:LogPath = Join-Path $ModuleRoot "..\logs"
$Script:LogEnabled = $true

# ==================== Logging ====================

<#
.SYNOPSIS
    Creates or gets the logger instance.
.DESCRIPTION
    Initializes logging infrastructure with file and console output.
.PARAMETER LogPath
    Optional custom log file path.
.EXAMPLE
    $logger = Get-Logger
    $logger.Info("Starting task")
#>
function Get-Logger {
    param(
        [string]$LogPath = (Join-Path $Script:LogPath "lobster-legion.log")
    )
    
    if (!(Test-Path $Script:LogPath)) {
        New-Item -ItemType Directory -Path $Script:LogPath -Force | Out-Null
    }
    
    return @{
        Info = {
            param($Message)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logLine = "[$timestamp] [INFO] $Message"
            if ($Script:LogEnabled) {
                Add-Content -Path $LogPath -Value $logLine -Encoding UTF8
            }
            Write-Host "ℹ️  $Message" -ForegroundColor Cyan
        }
        Warn = {
            param($Message)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logLine = "[$timestamp] [WARN] $Message"
            if ($Script:LogEnabled) {
                Add-Content -Path $LogPath -Value $logLine -Encoding UTF8
            }
            Write-Host "⚠️  $Message" -ForegroundColor Yellow
        }
        Error = {
            param($Message)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logLine = "[$timestamp] [ERROR] $Message"
            if ($Script:LogEnabled) {
                Add-Content -Path $LogPath -Value $logLine -Encoding UTF8
            }
            Write-Host "❌ $Message" -ForegroundColor Red
        }
        Debug = {
            param($Message)
            if ($env:LOBSTER_DEBUG -eq "true") {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logLine = "[$timestamp] [DEBUG] $Message"
                if ($Script:LogEnabled) {
                    Add-Content -Path $LogPath -Value $logLine -Encoding UTF8
                }
                Write-Host "🔍 $Message" -ForegroundColor Gray
            }
        }
        Success = {
            param($Message)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logLine = "[$timestamp] [SUCCESS] $Message"
            if ($Script:LogEnabled) {
                Add-Content -Path $LogPath -Value $logLine -Encoding UTF8
            }
            Write-Host "✅ $Message" -ForegroundColor Green
        }
    }
}

# ==================== Validation ====================

<#
.SYNOPSIS
    Validates configuration structure.
.DESCRIPTION
    Checks if the configuration has all required fields and valid values.
.PARAMETER Config
    Configuration hashtable to validate.
.EXAMPLE
    if (Test-ConfigValid -Config $config) { ... }
#>
function Test-ConfigValid {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $errors = @()
    
    # Check chiefs
    if (!$Config.chiefs -or $Config.chiefs.Count -eq 0) {
        $errors += "chiefs array is required and must not be empty"
    } else {
        foreach ($chief in $Config.chiefs) {
            if (!$chief.id) { $errors += "Chief missing required field: id" }
            if (!$chief.name) { $errors += "Chief missing required field: name" }
            if (!$chief.specialty -or $chief.specialty.Count -eq 0) {
                $errors += "Chief missing required field: specialty"
            }
            if ($chief.maxSubAgents -and $chief.maxSubAgents -lt 1) {
                $errors += "Chief maxSubAgents must be >= 1"
            }
        }
    }
    
    # Check routing
    if (!$Config.routing) {
        $errors += "routing section is required"
    } else {
        if (!$Config.routing.default) {
            $errors += "routing.default is required"
        }
        if (!$Config.routing.rules) {
            $errors += "routing.rules array is required"
        }
    }
    
    # Check subagents config
    if ($Config.subagents) {
        if ($Config.subagents.maxConcurrentAgents -lt 1) {
            $errors += "subagents.maxConcurrentAgents must be >= 1"
        }
        if ($Config.subagents.tokenBudget) {
            if ($Config.subagents.tokenBudget.maxTokensPerAgent -lt 1000) {
                $errors += "tokenBudget.maxTokensPerAgent must be >= 1000"
            }
        }
    }
    
    if ($errors.Count -gt 0) {
        Write-Warning "Configuration validation failed:"
        foreach ($error in $errors) {
            Write-Warning "  - $error"
        }
        return $false
    }
    
    return $true
}

<#
.SYNOPSIS
    Validates a chief configuration object.
.DESCRIPTION
    Checks if a chief has all required and optional fields with valid values.
.PARAMETER Chief
    Chief configuration hashtable.
.EXAMPLE
    Test-ChiefConfig -Chief $chiefConfig
#>
function Test-ChiefConfig {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Chief
    )
    
    $requiredFields = @('id', 'name', 'specialty')
    $missingFields = @()
    
    foreach ($field in $requiredFields) {
        if (!$Chief.$field) {
            $missingFields += $field
        }
    }
    
    if ($missingFields.Count -gt 0) {
        Write-Warning "Chief config missing fields: $($missingFields -join ', ')"
        return $false
    }
    
    # Validate specialty is array
    if ($Chief.specialty -isnot [array]) {
        Write-Warning "Chief specialty must be an array"
        return $false
    }
    
    # Validate maxSubAgents if present
    if ($Chief.maxSubAgents -and $Chief.maxSubAgents -isnot [int]) {
        Write-Warning "Chief maxSubAgents must be an integer"
        return $false
    }
    
    return $true
}

# ==================== Error Handling ====================

<#
.SYNOPSIS
    Wraps a script block with error handling.
.DESCRIPTION
    Executes a script block with try-catch and logging.
.PARAMETER ScriptBlock
    The code to execute.
.PARAMETER Operation
    Name of the operation for logging.
.PARAMETER Logger
    Logger object from Get-Logger.
.EXAMPLE
    Invoke-SafeScript -ScriptBlock { ... } -Operation "Loading config" -Logger $logger
#>
function Invoke-SafeScript {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,
        [Parameter(Mandatory=$true)]
        [string]$Operation,
        [hashtable]$Logger
    )
    
    try {
        if ($Logger) {
            $Logger.Debug.Invoke("Starting: $Operation")
        }
        
        $result = & $ScriptBlock
        
        if ($Logger) {
            $Logger.Success.Invoke("Completed: $Operation")
        }
        
        return $result
    }
    catch {
        if ($Logger) {
            $Logger.Error.Invoke("$Operation failed: $_")
        }
        throw
    }
}

# ==================== Time Utilities ====================

<#
.SYNOPSIS
    Formats a timespan into human-readable format.
.DESCRIPTION
    Converts milliseconds to formatted string (e.g., "1.5s", "2m 30s").
.PARAMETER Milliseconds
    Time in milliseconds.
.EXAMPLE
    Format-Timespan -Milliseconds 1500
    Returns: "1.5s"
#>
function Format-Timespan {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Milliseconds
    )
    
    if ($Milliseconds -lt 1000) {
        return "${Milliseconds}ms"
    }
    
    $seconds = [math]::Round($Milliseconds / 1000, 1)
    
    if ($seconds -lt 60) {
        return "${seconds}s"
    }
    
    $minutes = [int]($seconds / 60)
    $remainingSeconds = [int]($seconds % 60)
    
    if ($minutes -lt 60) {
        return "${minutes}m ${remainingSeconds}s"
    }
    
    $hours = [int]($minutes / 60)
    $remainingMinutes = $minutes % 60
    
    return "${hours}h ${remainingMinutes}m ${remainingSeconds}s"
}

<#
.SYNOPSIS
    Gets current timestamp in milliseconds.
.DESCRIPTION
    Returns Unix timestamp in milliseconds for timing operations.
.EXAMPLE
    $start = Get-Timestamp
    # ... do work ...
    $duration = (Get-Timestamp) - $start
#>
function Get-Timestamp {
    return [int][double]::Parse((Get-Date -UFormat %s)) * 1000
}

# ==================== Session Management ====================

<#
.SYNOPSIS
    Creates a session tracking object.
.DESCRIPTION
    Manages session state for spawned agents.
.PARAMETER SessionId
    Unique session identifier.
.PARAMETER Task
    Task description.
.EXAMPLE
    $session = New-SessionTracker -SessionId "worker-001" -Task "Optimize code"
#>
function New-SessionTracker {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SessionId,
        [string]$Task = "",
        [string]$ChiefId = ""
    )
    
    return @{
        SessionId = $SessionId
        Task = $Task
        ChiefId = $ChiefId
        StartTime = Get-Date
        EndTime = $null
        Status = "running"
        Result = $null
        Error = $null
        Duration = $null
    }
}

<#
.SYNOPSIS
    Updates session status.
.DESCRIPTION
    Updates the status and optionally result of a session.
.PARAMETER Session
    Session tracker object.
.PARAMETER Status
    New status (running, completed, failed).
.PARAMETER Result
    Optional result data.
.EXAMPLE
    Update-Session -Session $session -Status "completed" -Result $output
#>
function Update-Session {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Session,
        [Parameter(Mandatory=$true)]
        [ValidateSet("running", "completed", "failed", "timeout")]
        [string]$Status,
        $Result = $null,
        $Error = $null
    )
    
    $Session.Status = $Status
    $Session.EndTime = Get-Date
    $Session.Result = $Result
    $Session.Error = $Error
    
    if ($Session.StartTime) {
        $Session.Duration = New-TimeSpan -Start $Session.StartTime -End $Session.EndTime
    }
}

<#
.SYNOPSIS
    Cleans up completed sessions.
.DESCRIPTION
    Removes sessions that are older than specified age.
.PARAMETER Sessions
    Array of session trackers.
.PARAMETER MaxAgeMinutes
    Maximum age in minutes (default: 60).
.EXAMPLE
    Cleanup-Sessions -Sessions $allSessions -MaxAgeMinutes 30
#>
function Cleanup-Sessions {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Sessions,
        [int]$MaxAgeMinutes = 60
    )
    
    $cutoff = (Get-Date).AddMinutes(-$MaxAgeMinutes)
    $cleaned = 0
    
    for ($i = $Sessions.Count - 1; $i -ge 0; $i--) {
        $session = $Sessions[$i]
        
        if ($session.EndTime -and $session.EndTime -lt $cutoff) {
            $Sessions.RemoveAt($i)
            $cleaned++
        }
    }
    
    return $cleaned
}

# ==================== String Utilities ====================

<#
.SYNOPSIS
    Truncates a string to specified length.
.DESCRIPTION
    Truncates string and adds ellipsis if needed.
.PARAMETER Text
    String to truncate.
.PARAMETER MaxLength
    Maximum length.
.EXAMPLE
    Truncate-String -Text "Very long text" -MaxLength 10
    Returns: "Very long..."
#>
function Truncate-String {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [Parameter(Mandatory=$true)]
        [int]$MaxLength
    )
    
    if ($Text.Length -le $MaxLength) {
        return $Text
    }
    
    return $Text.Substring(0, $MaxLength - 3) + "..."
}

<#
.SYNOPSIS
    Extracts keywords from text.
.DESCRIPTION
    Splits text into keywords, removing common stop words.
.PARAMETER Text
    Text to extract keywords from.
.PARAMETER MinLength
    Minimum keyword length (default: 3).
.EXAMPLE
    Extract-Keywords -Text "Help me optimize this code"
    Returns: @("optimize", "code")
#>
function Extract-Keywords {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [int]$MinLength = 3
    )
    
    $stopWords = @("the", "a", "an", "is", "are", "was", "were", "be", "been",
                   "being", "have", "has", "had", "do", "does", "did", "will",
                   "would", "could", "should", "may", "might", "must", "shall",
                   "can", "need", "dare", "ought", "used", "to", "of", "in",
                   "for", "on", "with", "at", "by", "from", "as", "into",
                   "through", "during", "before", "after", "above", "below",
                   "between", "under", "again", "further", "then", "once",
                   "here", "there", "when", "where", "why", "how", "all",
                   "each", "few", "more", "most", "other", "some", "such",
                   "no", "nor", "not", "only", "own", "same", "so", "than",
                   "too", "very", "just", "and", "but", "if", "or", "because",
                   "until", "while", "this", "that", "these", "those", "i",
                   "me", "my", "myself", "we", "our", "ours", "ourselves",
                   "you", "your", "yours", "yourself", "yourselves", "he",
                   "him", "his", "himself", "she", "her", "hers", "herself",
                   "it", "its", "itself", "they", "them", "their", "theirs",
                   "themselves", "what", "which", "who", "whom", "help", "please")
    
    $words = $Text.ToLower() -split '\s+' | Where-Object {
        $_.Length -ge $MinLength -and $_ -notin $stopWords
    }
    
    return $words | Select-Object -Unique
}

# ==================== File Utilities ====================

<#
.SYNOPSIS
    Ensures a directory exists.
.DESCRIPTION
    Creates directory if it doesn't exist.
.PARAMETER Path
    Directory path to ensure exists.
.EXAMPLE
    Ensure-Directory -Path "C:\logs"
#>
function Ensure-Directory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        return $true
    }
    
    return $false
}

<#
.SYNOPSIS
    Reads file with error handling.
.DESCRIPTION
    Safely reads file content with encoding detection.
.PARAMETER Path
    File path to read.
.EXAMPLE
    $content = Read-FileSafe -Path "config.yml"
#>
function Read-FileSafe {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    try {
        if (!(Test-Path $Path)) {
            throw "File not found: $Path"
        }
        
        return Get-Content -Path $Path -Raw -Encoding UTF8
    }
    catch {
        Write-Error "Failed to read file: $_"
        throw
    }
}

<#
.SYNOPSIS
    Writes file with error handling.
.DESCRIPTION
    Safely writes content to file with encoding.
.PARAMETER Path
    File path to write.
.PARAMETER Content
    Content to write.
.EXAMPLE
    Write-FileSafe -Path "output.txt" -Content "Hello"
#>
function Write-FileSafe {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Content
    )
    
    try {
        $directory = Split-Path -Parent $Path
        Ensure-Directory -Path $directory | Out-Null
        
        $Content | Out-File -FilePath $Path -Encoding UTF8 -Force
        return $true
    }
    catch {
        Write-Error "Failed to write file: $_"
        return $false
    }
}

# ==================== Performance Monitoring ====================

$Script:PerformanceMetrics = @{}

<#
.SYNOPSIS
    Starts performance tracking.
.DESCRIPTION
    Begins timing an operation.
.PARAMETER Operation
    Operation name.
.EXAMPLE
    Start-Performance "Loading config"
#>
function Start-Performance {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Operation
    )
    
    $Script:PerformanceMetrics[$Operation] = @{
        StartTime = Get-Date
        Count = 0
        TotalMs = 0
    }
}

<#
.SYNOPSIS
    Stops performance tracking.
.DESCRIPTION
    Ends timing and records metrics.
.PARAMETER Operation
    Operation name.
.EXAMPLE
    Stop-Performance "Loading config"
#>
function Stop-Performance {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Operation
    )
    
    if ($Script:PerformanceMetrics.ContainsKey($Operation)) {
        $metric = $Script:PerformanceMetrics[$Operation]
        $endTime = Get-Date
        $duration = New-TimeSpan -Start $metric.StartTime -End $endTime
        
        $metric.Count++
        $metric.TotalMs += $duration.TotalMilliseconds
        $metric.LastDuration = $duration
        
        return $duration
    }
    
    return $null
}

<#
.SYNOPSIS
    Gets performance report.
.DESCRIPTION
    Returns metrics for all tracked operations.
.EXAMPLE
    Get-PerformanceReport
#>
function Get-PerformanceReport {
    $report = @()
    
    foreach ($key in $Script:PerformanceMetrics.Keys) {
        $metric = $Script:PerformanceMetrics[$key]
        $avgMs = if ($metric.Count -gt 0) { $metric.TotalMs / $metric.Count } else { 0 }
        
        $report += @{
            Operation = $key
            Count = $metric.Count
            TotalMs = $metric.TotalMs
            AverageMs = $avgMs
            LastDuration = $metric.LastDuration
        }
    }
    
    return $report
}

# ==================== Exports ====================

Export-ModuleMember -Function Get-Logger, Test-ConfigValid, Test-ChiefConfig,
                      Invoke-SafeScript, Format-Timespan, Get-Timestamp,
                      New-SessionTracker, Update-Session, Cleanup-Sessions,
                      Truncate-String, Extract-Keywords, Ensure-Directory,
                      Read-FileSafe, Write-FileSafe, Start-Performance,
                      Stop-Performance, Get-PerformanceReport
