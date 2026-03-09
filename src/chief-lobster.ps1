# 🦞 Lobster Legion - Chief Lobster (Optimized)
# Receives tasks from coordinator, spawns worker agents, aggregates results

param()

# Import common utilities
$commonPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1"
if (Test-Path $commonPath) {
    . $commonPath
}

# ==================== Worker Spawning ====================

<#
.SYNOPSIS
    Spawns a worker agent for task execution.
.DESCRIPTION
    Creates a sub-agent session with proper error handling and tracking.
.PARAMETER TaskPrompt
    Task description for the worker.
.PARAMETER AgentId
    Agent identifier (default: "main").
.PARAMETER TimeoutSeconds
    Maximum execution time.
.EXAMPLE
    $session = Spawn-WorkerAgent -TaskPrompt "Optimize this function" -AgentId "main"
#>
function Spawn-WorkerAgent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TaskPrompt,
        [string]$AgentId = "main",
        [int]$TimeoutSeconds = 300,
        [hashtable]$Config = $null
    )
    
    $logger = Get-Logger
    $sessionId = "worker_$(Get-Date -Format 'yyyyMMdd_HHmmss')_$(Get-Random -Maximum 9999)"
    
    try {
        $logger.Info.Invoke("🐛 Spawning worker agent: $sessionId")
        
        # Create session tracker
        $session = New-SessionTracker -SessionId $sessionId -Task $TaskPrompt
        
        # TODO: Replace with actual OpenClaw sessions_spawn call
        # For now, simulate with background job
        $scriptBlock = {
            param($task, $timeout)
            # Simulate work
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
            return @{
                Success = $true
                Content = "Worker completed: $task"
                Duration = $timeout
            }
        }
        
        $job = Start-ScriptBlock -ScriptBlock $scriptBlock -ArgumentList $TaskPrompt, $TimeoutSeconds
        
        $session.Job = $job
        $session.Timeout = $TimeoutSeconds
        
        $logger.Success.Invoke("Worker spawned successfully")
        
        return $session
    }
    catch {
        $logger.Error.Invoke("Failed to spawn worker: $_")
        Update-Session -Session $session -Status "failed" -Error $_
        throw
    }
}

# ==================== Task Breakdown ====================

<#
.SYNOPSIS
    Breaks down complex task into subtasks.
.DESCRIPTION
    Uses AI or heuristic methods to decompose tasks.
.PARAMETER Task
    Original task description.
.PARAMETER MaxSubTasks
    Maximum number of subtasks.
.PARAMETER UseAI
    Whether to use AI for breakdown (requires OpenClaw).
.EXAMPLE
    $subTasks = Break-Down-Task -Task "Build a web app" -MaxSubTasks 5
#>
function Break-Down-Task {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Task,
        [int]$MaxSubTasks = 5,
        [bool]$UseAI = $false,
        [hashtable]$Config = $null
    )
    
    $logger = Get-Logger
    $logger.Info.Invoke("🔪 Breaking down task...")
    
    $subTasks = @()
    
    if ($UseAI) {
        # TODO: Implement AI-powered task breakdown
        $logger.Warn.Invoke("AI breakdown not yet implemented, using heuristic method")
    }
    
    # Heuristic breakdown
    
    # Pattern 1: Already a list
    $lines = $Task -split "`n"
    $listItems = $lines | Where-Object {
        $_ -match '^\s*(\d+[.,、]?|[-•])\s*\S'
    }
    
    if ($listItems.Count -ge 2) {
        foreach ($item in $listItems) {
            $cleaned = $item -replace '^\s*(\d+[.,、]?|[-•])\s*', ''
            if ($cleaned) {
                $subTasks += $cleaned.Trim()
            }
        }
    }
    # Pattern 2: Contains semicolons or commas with substantial clauses
    elseif ($Task -match '[;,.]') {
        $parts = $Task -split '[;,.]' | Where-Object { $_.Trim().Length -gt 20 }
        if ($parts.Count -ge 2) {
            $subTasks += $parts | ForEach-Object { $_.Trim() }
        }
    }
    # Pattern 3: Single task - don't break down
    else {
        $subTasks += $Task
    }
    
    # Limit to max
    if ($subTasks.Count -gt $MaxSubTasks) {
        $logger.Warn.Invoke("Task has $($subTasks.Count) parts, limiting to $MaxSubTasks")
        $subTasks = $subTasks | Select-Object -First $MaxSubTasks
    }
    
    $logger.Success.Invoke("Broke down into $($subTasks.Count) subtasks")
    
    return $subTasks
}

# ==================== Parallel Execution ====================

<#
.SYNOPSIS
    Executes tasks in parallel with concurrency control.
.DESCRIPTION
    Manages worker pool and respects max concurrent limit.
.PARAMETER SubTasks
    Array of subtasks to execute.
.PARAMETER ChiefConfig
    Chief configuration with limits.
.PARAMETER MaxConcurrent
    Maximum concurrent workers.
.EXAMPLE
    $sessions = Execute-Parallel -SubTasks $tasks -ChiefConfig $chief -MaxConcurrent 3
#>
function Execute-Parallel {
    param(
        [Parameter(Mandatory=$true)]
        [array]$SubTasks,
        [hashtable]$ChiefConfig,
        [int]$MaxConcurrent = 3
    )
    
    $logger = Get-Logger
    $logger.Info.Invoke("🚀 Starting parallel execution ($($SubTasks.Count) tasks, max concurrent: $MaxConcurrent)")
    
    $sessions = @()
    $activeJobs = @()
    
    foreach ($subTask in $SubTasks) {
        # Wait if at capacity
        while ($activeJobs.Count -ge $MaxConcurrent) {
            $logger.Debug.Invoke("Waiting for worker slot...")
            Start-Sleep -Milliseconds 500
            
            # Check for completed jobs
            $activeJobs = $activeJobs | Where-Object {
                $_.Job.State -eq 'Running'
            }
        }
        
        # Spawn worker
        $session = Spawn-WorkerAgent -TaskPrompt $subTask -AgentId $ChiefConfig.agentId
        
        if ($session.Job) {
            $activeJobs += @{
                Job = $session.Job
                Session = $session
                Task = $subTask
            }
            $sessions += $session
            
            $truncatedTask = Truncate-String $subTask 50
            $logger.Info.Invoke("  ↳ Started: $truncatedTask")
        }
    }
    
    $logger.Success.Invoke("All workers spawned: $($sessions.Count)")
    
    return @{
        Sessions = $sessions
        ActiveJobs = $activeJobs
        Count = $sessions.Count
    }
}

# ==================== Result Collection ====================

<#
.SYNOPSIS
    Collects results from all worker sessions.
.DESCRIPTION
    Waits for completion with timeout and error handling.
.PARAMETER ExecutionInfo
    Output from Execute-Parallel.
.PARAMETER TimeoutSeconds
    Maximum wait time.
.EXAMPLE
    $results = Collect-Worker-Results -ExecutionInfo $execInfo -TimeoutSeconds 300
#>
function Collect-Worker-Results {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ExecutionInfo,
        [int]$TimeoutSeconds = 300
    )
    
    $logger = Get-Logger
    $logger.Info.Invoke("⏳ Collecting results from $($ExecutionInfo.Sessions.Count) workers...")
    
    $results = @()
    $startTime = Get-Date
    
    foreach ($jobInfo in $ExecutionInfo.ActiveJobs) {
        $session = $jobInfo.Session
        $job = $jobInfo.Job
        $elapsed = (New-TimeSpan -Start $startTime).TotalSeconds
        
        # Check timeout
        if ($elapsed -gt $TimeoutSeconds) {
            $logger.Warn.Invoke("Timeout reached, stopping collection")
            Update-Session -Session $session -Status "timeout"
            $results += @{
                SessionId = $session.SessionId
                Status = "timeout"
                Error = "Collection timeout"
            }
            continue
        }
        
        # Wait for job
        try {
            $jobResult = $job | Wait-Job -Timeout ($TimeoutSeconds - $elapsed) | Receive-Job
            
            if ($jobResult) {
                Update-Session -Session $session -Status "completed" -Result $jobResult
                
                $results += @{
                    SessionId = $session.SessionId
                    Status = "completed"
                    Content = $jobResult.Content
                    Data = $jobResult
                    CompletedAt = $session.EndTime
                    Duration = $session.Duration
                }
                
                $logger.Success.Invoke("✓ Worker completed: $($session.SessionId)")
            } else {
                Update-Session -Session $session -Status "failed" -Error "No output"
                $results += @{
                    SessionId = $session.SessionId
                    Status = "failed"
                    Error = "No output received"
                }
                $logger.Warn.Invoke("✗ Worker failed: $($session.SessionId)")
            }
        }
        catch {
            Update-Session -Session $session -Status "failed" -Error $_
            $results += @{
                SessionId = $session.SessionId
                Status = "failed"
                Error = $_.Exception.Message
            }
            $logger.Error.Invoke("✗ Worker error: $($_.Exception.Message)")
        }
        finally {
            # Cleanup job
            $job | Remove-Job -Force -ErrorAction SilentlyContinue
        }
    }
    
    $completedCount = ($results | Where-Object { $_.Status -eq "completed" }).Count
    $logger.Success.Invoke("Collected $completedCount / $($results.Count) results")
    
    return $results
}

# ==================== Result Summarization ====================

<#
.SYNOPSIS
    Summarizes worker results into report.
.DESCRIPTION
    Aggregates results and generates formatted report.
.PARAMETER Results
    Array of result objects.
.PARAMETER ChiefName
    Name of the chief for the report.
.PARAMETER Format
    Output format (markdown, text, json).
.EXAMPLE
    $report = Summarize-Results -Results $results -ChiefName "代码专家"
#>
function Summarize-Results {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results,
        [Parameter(Mandatory=$true)]
        [string]$ChiefName,
        [ValidateSet("markdown", "text", "json")]
        [string]$Format = "markdown"
    )
    
    $logger = Get-Logger
    $logger.Info.Invoke("📊 Summarizing results...")
    
    $completed = $Results | Where-Object { $_.Status -eq "completed" }
    $failed = $Results | Where-Object { $_.Status -ne "completed" }
    $successRate = if ($Results.Count -gt 0) { ($completed.Count / $Results.Count) * 100 } else { 0 }
    
    if ($Format -eq "json") {
        return @{
            ChiefName = $ChiefName
            CompletedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            TotalTasks = $Results.Count
            CompletedTasks = $completed.Count
            FailedTasks = $failed.Count
            SuccessRate = $successRate
            Results = $Results
        } | ConvertTo-Json -Depth 5
    }
    
    # Markdown format
    $report = @"
# 🦞 $ChiefName - 执行报告

**完成时间:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**任务总数:** $($Results.Count)
**成功:** $($completed.Count)
**失败:** $($failed.Count)
**成功率:** $([math]::Round($successRate, 1))%

---

## ✅ 成功任务

"@
    
    $i = 1
    foreach ($result in $completed) {
        $report += "
### 任务 $i
- **会话 ID:** $($result.SessionId)
- **状态:** $($result.Status)
- **耗时:** $(if ($result.Duration) { Format-Timespan $result.Duration.TotalMilliseconds } else { "N/A" })
- **结果:** $($result.Content)
"
        $i++
    }
    
    if ($failed.Count -gt 0) {
        $report += "
## ⚠️ 失败任务

"
        foreach ($result in $failed) {
            $report += "
### 失败任务
- **会话 ID:** $($result.SessionId)
- **状态:** $($result.Status)
- **错误:** $($result.Error)
"
        }
    }
    
    return $report
}

# ==================== Chief Execution ====================

<#
.SYNOPSIS
    Main entry point for chief lobster execution.
.DESCRIPTION
    Orchestrates task breakdown, execution, and result aggregation.
.PARAMETER ChiefId
    Chief identifier.
.PARAMETER Task
    Task to execute.
.PARAMETER Config
    Configuration object.
.EXAMPLE
    $result = Start-ChiefLobster -ChiefId "chief-code" -Task "Optimize this" -Config $config
#>
function Start-ChiefLobster {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ChiefId,
        [Parameter(Mandatory=$true)]
        [string]$Task,
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $logger = Get-Logger
    Start-Performance "ChiefExecution"
    
    try {
        $logger.Info.Invoke("`n🦞 [Chief: $ChiefId] Starting execution")
        
        # Step 1: Get chief config
        $chiefConfig = $Config.chiefs | Where-Object { $_.id -eq $ChiefId }
        if (!$chiefConfig) {
            throw "Chief configuration not found: $ChiefId"
        }
        
        if ($chiefConfig.enabled -eq $false) {
            throw "Chief is disabled: $ChiefId"
        }
        
        $logger.Info.Invoke("📋 Chief: $($chiefConfig.name)")
        $logger.Info.Invoke("🎯 Specialty: $($chiefConfig.specialty -join ', ')")
        
        $maxWorkers = $chiefConfig.maxSubAgents -or 5
        $logger.Info.Invoke("🐛 Max workers: $maxWorkers")
        
        # Step 2: Break down task
        $subTasks = Break-Down-Task -Task $Task -MaxSubTasks $maxWorkers -Config $Config
        
        # Step 3: Execute in parallel
        $execInfo = Execute-Parallel -SubTasks $subTasks -ChiefConfig $chiefConfig -MaxConcurrent $maxWorkers
        
        # Step 4: Collect results
        $timeout = $Config.subagents.timeoutSeconds -or 300
        $results = Collect-Worker-Results -ExecutionInfo $execInfo -TimeoutSeconds $timeout
        
        # Step 5: Generate report
        $report = Summarize-Results -Results $results -ChiefName $chiefConfig.name
        
        $elapsed = Stop-Performance "ChiefExecution"
        $logger.Success.Invoke("`n✅ [Chief: $ChiefId] Execution completed in $(Format-Timespan $elapsed.TotalMilliseconds)")
        
        return @{
            ChiefId = $ChiefId
            ChiefName = $chiefConfig.name
            Success = $true
            Report = $report
            Results = $results
            TaskCount = $subTasks.Count
            CompletedCount = ($results | Where-Object { $_.Status -eq "completed" }).Count
            Duration = $elapsed
        }
    }
    catch {
        $elapsed = Stop-Performance "ChiefExecution"
        $logger.Error.Invoke("`n❌ [Chief: $ChiefId] Execution failed: $_")
        
        return @{
            ChiefId = $ChiefId
            Success = $false
            Error = $_.Exception.Message
            Duration = $elapsed
        }
    }
}

# ==================== Exports ====================

Export-ModuleMember -Function Start-ChiefLobster, Spawn-WorkerAgent, Break-Down-Task,
                      Execute-Parallel, Collect-Worker-Results, Summarize-Results

# ==================== CLI Entry Point ====================

if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    Write-Host "`n🦞 Testing Chief Lobster" -ForegroundColor Magenta
    
    $testConfig = @{
        chiefs = @(
            @{
                id = "chief-code"
                name = "代码专家"
                agentId = "main"
                specialty = @("代码", "编程", "debug")
                maxSubAgents = 3
                enabled = $true
            }
        )
        subagents = @{
            timeoutSeconds = 60
        }
    }
    
    $result = Start-ChiefLobster -ChiefId "chief-code" -Task "帮我优化这段代码" -Config $testConfig
    
    if ($result.Success) {
        Write-Host "`nExecution successful!" -ForegroundColor Green
        Write-Host "Tasks: $($result.TaskCount)" -ForegroundColor Cyan
        Write-Host "Completed: $($result.CompletedCount)" -ForegroundColor Cyan
        Write-Host "Duration: $(Format-Timespan $result.Duration.TotalMilliseconds)" -ForegroundColor Cyan
        
        Write-Host "`nReport:" -ForegroundColor Magenta
        Write-Host $result.Report -ForegroundColor Gray
    } else {
        Write-Host "`nExecution failed: $($result.Error)" -ForegroundColor Red
    }
}
