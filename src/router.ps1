# 🦞 Lobster Legion - Task Router (Optimized)
# Analyzes tasks and routes them to appropriate chief lobsters

param()

# Import common utilities
$commonPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1"
if (Test-Path $commonPath) {
    . $commonPath
}

# ==================== Keyword Matching ====================

<#
.SYNOPSIS
    Tests if a message matches any of the provided keywords.
.DESCRIPTION
    Performs case-insensitive keyword matching with scoring.
.PARAMETER Message
    The message to analyze.
.PARAMETER Keywords
    Array of keywords to match.
.EXAMPLE
    $match = Test-KeywordMatch -Message "Help me code" -Keywords @("code", "debug")
#>
function Test-KeywordMatch {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [array]$Keywords
    )
    
    $messageLower = $Message.ToLower()
    $bestMatch = $null
    $bestScore = 0
    
    foreach ($keyword in $Keywords) {
        $keywordLower = $keyword.ToLower()
        
        # Exact match gets higher score
        if ($messageLower -eq $keywordLower) {
            $score = 1.0
        }
        # Word boundary match
        elseif ($messageLower -match "\b$([regex]::Escape($keywordLower))\b") {
            $score = 0.8
        }
        # Partial match (longer keywords preferred)
        elseif ($messageLower -match [regex]::Escape($keywordLower)) {
            $score = 0.5 + ($keyword.Length * 0.01)
        }
        else {
            continue
        }
        
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestMatch = @{
                Matched = $true
                Keyword = $keyword
                Score = $score
            }
        }
    }
    
    return $bestMatch ?: @{ Matched = $false; Score = 0 }
}

# ==================== Chief Detection ====================

<#
.SYNOPSIS
    Detects if user specified a particular chief.
.DESCRIPTION
    Looks for @mention or "给 xxx" patterns in the message.
.PARAMETER Message
    The message to analyze.
.EXAMPLE
    $chief = Detect-SpecifiedChief -Message "@Doc Expert write this"
#>
function Detect-SpecifiedChief {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    # Pattern 1: @mention
    if ($Message -match '@(\S+)') {
        $specified = $Matches[1]
        return @{
            Specified = $specified
            Pattern = '@mention'
            Confidence = 0.95
        }
    }
    
    # Pattern 2: "给 xxx" (Chinese)
    if ($Message -match '给 ([^\s,，]+)') {
        $specified = $Matches[1]
        return @{
            Specified = $specified
            Pattern = '给 xxx'
            Confidence = 0.85
        }
    }
    
    # Pattern 3: "find xxx" or "ask xxx"
    if ($Message -match '(?:find|ask)\s+(\S+)') {
        $specified = $Matches[1]
        return @{
            Specified = $specified
            Pattern = 'find/ask'
            Confidence = 0.75
        }
    }
    
    return @{
        Specified = $null
        Pattern = $null
        Confidence = 0
    }
}

# ==================== Multi-Task Detection ====================

<#
.SYNOPSIS
    Detects if message contains multiple tasks.
.DESCRIPTION
    Identifies numbered lists, bullet points, or conjunction patterns.
.PARAMETER Message
    The message to analyze.
.EXAMPLE
    $multiTask = Detect-MultiTask -Message "1. Code 2. Test 3. Deploy"
#>
function Detect-MultiTask {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    $tasks = @()
    
    # Pattern 1: Numbered list (1. 2. 3. or 1、2、3、)
    if ($Message -match '(^\s*\d+[.,、]\s*.+){2,}') {
        $lines = $Message -split "`n"
        foreach ($line in $lines) {
            if ($line -match '^\s*\d+[.,、]?\s*(.+)') {
                $taskText = $Matches[1].Trim()
                if ($taskText) {
                    $tasks += $taskText
                }
            }
        }
    }
    
    # Pattern 2: Bullet points (- or •)
    if ($tasks.Count -eq 0 -and $Message -match '(^\s*[-•]\s*.+){2,}') {
        $lines = $Message -split "`n"
        foreach ($line in $lines) {
            if ($line -match '^\s*[-•]\s*(.+)') {
                $taskText = $Matches[1].Trim()
                if ($taskText) {
                    $tasks += $taskText
                }
            }
        }
    }
    
    # Pattern 3: Conjunctions (同时，并且，还有，另外)
    if ($tasks.Count -eq 0 -and $Message -match '(同时 | 并且 | 还有 | 另外|and|also|plus)') {
        $parts = $Message -split '(同时 | 并且 | 还有 | 另外|and|also|plus)'
        foreach ($part in $parts) {
            $trimmed = $part.Trim()
            if ($trimmed.Length -gt 10) {  # Avoid splitting small phrases
                $tasks += $trimmed
            }
        }
    }
    
    if ($tasks.Count -gt 1) {
        return @{
            IsMultiTask = $true
            Tasks = $tasks
            Count = $tasks.Count
            DetectionMethod = 'list|conjunction'
        }
    }
    
    return @{
        IsMultiTask = $false
        Tasks = @($Message)
        Count = 1
        DetectionMethod = 'none'
    }
}

# ==================== Task Complexity Analysis ====================

<#
.SYNOPSIS
    Analyzes task complexity for dynamic worker allocation.
.DESCRIPTION
    Estimates task difficulty based on length, keywords, and structure.
.PARAMETER Task
    Task description.
.PARAMETER Config
    Configuration with complexity weights.
.EXAMPLE
    $complexity = Get-TaskComplexity -Task $task -Config $config
#>
function Get-TaskComplexity {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Task,
        [hashtable]$Config = $null
    )
    
    $score = 0
    $factors = @{}
    
    # Factor 1: Length (longer = more complex)
    $lengthScore = [Math]::Min(1.0, $Task.Length / 500)
    $factors.Length = $lengthScore
    $score += $lengthScore * 0.3
    
    # Factor 2: Domain keywords (more domains = more complex)
    $domains = @{
        Code = @("code", "program", "debug", "optimize", "refactor", "test", "deploy")
        Docs = @("document", "write", "translate", "explain", "readme")
        Research = @("research", "analyze", "compare", "survey", "market")
        Design = @("design", "architecture", "system", "pattern", "structure")
    }
    
    $taskLower = $Task.ToLower()
    $domainCount = 0
    foreach ($domain in $domains.Keys) {
        foreach ($keyword in $domains[$domain]) {
            if ($taskLower -match $keyword) {
                $domainCount++
                break
            }
        }
    }
    $domainScore = [Math]::Min(1.0, $domainCount / 3)
    $factors.Domains = $domainScore
    $score += $domainScore * 0.25
    
    # Factor 3: Dependency indicators
    $dependencyKeywords = @("first.*then", "after.*before", "depends", "requires", "prerequisite")
    $hasDependencies = 0
    foreach ($pattern in $dependencyKeywords) {
        if ($Task -match $pattern) {
            $hasDependencies = 1
            break
        }
    }
    $factors.Dependencies = $hasDependencies
    $score += $hasDependencies * 0.25
    
    # Factor 4: Precision requirements
    $precisionKeywords = @("exactly", "precise", "detailed", "comprehensive", "thorough", "complete")
    $hasPrecision = 0
    foreach ($keyword in $precisionKeywords) {
        if ($Task -match $keyword) {
            $hasPrecision = 1
            break
        }
    }
    $factors.Precision = $hasPrecision
    $score += $hasPrecision * 0.2
    
    # Check difficulty keywords for quick classification
    $difficultyKeywords = @{
        Easy = @("简单", "快速", "基础", "模板", "示例", "simple", "quick", "basic")
        Medium = @("中等", "标准", "完整", "分析", "对比", "medium", "standard", "complete")
        Hard = @("复杂", "深度", "全面", "系统", "优化", "complex", "deep", "comprehensive", "optimize")
        Expert = @("极难", "创新", "突破", "多领域", "大规模", "expert", "innovative", "breakthrough", "multi-domain")
    }
    
    $detectedDifficulty = "medium"
    foreach ($level in $difficultyKeywords.Keys) {
        foreach ($keyword in $difficultyKeywords[$level]) {
            if ($Task -match $keyword) {
                $detectedDifficulty = $level.ToLower()
                break
            }
        }
    }
    $factors.Difficulty = $detectedDifficulty
    
    return @{
        Score = [Math]::Round($score, 2)
        Factors = $factors
        Difficulty = $detectedDifficulty
        RecommendedWorkers = Get-RecommendedWorkers -Score $score -Config $Config
    }
}

<#
.SYNOPSIS
    Gets recommended number of workers based on complexity.
.DESCRIPTION
    Maps complexity score to worker count.
.PARAMETER Score
    Complexity score (0-1).
.PARAMETER Config
    Configuration with thresholds.
.EXAMPLE
    $workers = Get-RecommendedWorkers -Score 0.75
#>
function Get-RecommendedWorkers {
    param(
        [float]$Score,
        [hashtable]$Config = $null
    )
    
    # Use config thresholds if available
    if ($Config -and $Config.subagents -and $Config.subagents.dynamicAllocation) {
        $thresholds = $Config.subagents.dynamicAllocation.difficultyThresholds
        
        if ($Score -lt ($thresholds.easy ?: 0.3)) {
            return Get-Random -Minimum 1 -Maximum 3
        } elseif ($Score -lt ($thresholds.medium ?: 0.6)) {
            return Get-Random -Minimum 2 -Maximum 5
        } elseif ($Score -lt ($thresholds.hard ?: 0.8)) {
            return Get-Random -Minimum 4 -Maximum 7
        } else {
            return Get-Random -Minimum 6 -Maximum 10
        }
    }
    
    # Default thresholds
    if ($Score -lt 0.3) {
        return Get-Random -Minimum 1 -Maximum 3
    } elseif ($Score -lt 0.6) {
        return Get-Random -Minimum 2 -Maximum 5
    } elseif ($Score -lt 0.8) {
        return Get-Random -Minimum 4 -Maximum 7
    } else {
        return Get-Random -Minimum 6 -Maximum 10
    }
}

# ==================== Routing Decision ====================

<#
.SYNOPSIS
    Makes routing decision for a single task.
.DESCRIPTION
    Analyzes task and determines best chief with confidence score.
.PARAMETER Message
    Task message.
.PARAMETER Config
    Configuration with chiefs and routing rules.
.EXAMPLE
    $decision = Get-RoutingDecision -Message "Optimize this code" -Config $config
#>
function Get-RoutingDecision {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $logger = Get-Logger
    
    # Step 1: Check for specified chief
    $specifiedChief = Detect-SpecifiedChief -Message $Message
    if ($specifiedChief.Specified) {
        $logger.Debug.Invoke("User specified chief: $($specifiedChief.Specified)")
        
        $chief = $Config.chiefs | Where-Object {
            $_.id -eq $specifiedChief.Specified -or
            $_.name -eq $specifiedChief.Specified -or
            $_.id -like "*$($specifiedChief.Specified)*" -or
            $_.name -like "*$($specifiedChief.Specified)*"
        }
        
        if ($chief) {
            return @{
                Chief = $chief
                Reason = "User specified: $($specifiedChief.Pattern)"
                Confidence = $specifiedChief.Confidence
                MatchedKeywords = @()
            }
        } else {
            $logger.Warn.Invoke("Specified chief not found: $($specifiedChief.Specified)")
        }
    }
    
    # Step 2: Keyword matching with scoring
    $bestMatch = $null
    $bestScore = 0
    
    foreach ($rule in $Config.routing.rules) {
        $matchResult = Test-KeywordMatch -Message $Message -Keywords $rule.keywords
        
        if ($matchResult.Matched) {
            $score = $matchResult.Score
            
            # Priority bonus
            if ($rule.priority -eq "high") {
                $score += 0.2
            } elseif ($rule.priority -eq "normal") {
                $score += 0.1
            }
            
            # Multiple keyword matches bonus
            $matchCount = ($rule.keywords | Where-Object { $Message.ToLower() -match [regex]::Escape($_.ToLower()) }).Count
            if ($matchCount -gt 1) {
                $score += ($matchCount - 1) * 0.1
            }
            
            if ($score -gt $bestScore) {
                $bestScore = $score
                $bestMatch = @{
                    Chief = $Config.chiefs | Where-Object { $_.id -eq $rule.target }
                    Reason = "Keyword match: '$($matchResult.Keyword)' (score: $([math]::Round($score, 2)))"
                    Confidence = [Math]::Min(1.0, $score)
                    MatchedKeywords = @($matchResult.Keyword)
                }
            }
        }
    }
    
    # Step 3: Fallback to default
    if ($bestMatch) {
        return $bestMatch
    }
    
    $defaultChief = $Config.chiefs | Where-Object { $_.id -eq $Config.routing.default }
    if (!$defaultChief) {
        $defaultChief = $Config.chiefs | Select-Object -First 1
    }
    
    return @{
        Chief = $defaultChief
        Reason = "Default routing (no matches found)"
        Confidence = 0.5
        MatchedKeywords = @()
    }
}

# ==================== Multi-Task Routing ====================

<#
.SYNOPSIS
    Routes multiple tasks to appropriate chiefs.
.DESCRIPTION
    Analyzes each task and groups by target chief.
.PARAMETER Tasks
    Array of task descriptions.
.PARAMETER Config
    Configuration object.
.EXAMPLE
    $routing = Route-MultiTasks -Tasks $tasks -Config $config
#>
function Route-MultiTasks {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Tasks,
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $logger = Get-Logger
    $logger.Info.Invoke("Routing $($Tasks.Count) tasks...")
    
    $routingResults = @()
    
    foreach ($task in $Tasks) {
        $decision = Get-RoutingDecision -Message $task -Config $Config
        
        $routingResults += @{
            Task = $task
            Chief = $decision.Chief
            Reason = $decision.Reason
            Confidence = $decision.Confidence
            MatchedKeywords = $decision.MatchedKeywords
        }
    }
    
    # Group by chief
    $groupedByChief = $routingResults | Group-Object { $_.Chief.id }
    
    $logger.Success.Invoke("Routed to $($groupedByChief.Count) chiefs")
    
    return @{
        Grouped = $groupedByChief
        Details = $routingResults
        TaskCount = $Tasks.Count
        ChiefCount = $groupedByChief.Count
    }
}

# ==================== Main Router Function ====================

<#
.SYNOPSIS
    Main entry point for task routing.
.DESCRIPTION
    Analyzes message and returns routing decision(s).
.PARAMETER Message
    User message to route.
.PARAMETER Config
    Configuration object.
.EXAMPLE
    $result = Invoke-TaskRouter -Message "Help me code" -Config $config
#>
function Invoke-TaskRouter {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $logger = Get-Logger
    Start-Performance "TaskRouting"
    
    try {
        $logger.Info.Invoke("Analyzing task...")
        
        # Detect multi-task
        $multiTaskInfo = Detect-MultiTask -Message $Message
        
        if ($multiTaskInfo.IsMultiTask) {
            $logger.Info.Invoke("Detected $($multiTaskInfo.Count) tasks")
            
            $result = Route-MultiTasks -Tasks $multiTaskInfo.Tasks -Config $Config
            
            Stop-Performance "TaskRouting" | Out-Null
            
            return @{
                IsMultiTask = $true
                TaskCount = $result.TaskCount
                ChiefCount = $result.ChiefCount
                Grouped = $result.Grouped
                Details = $result.Details
                Complexity = $multiTaskInfo | ForEach-Object {
                    Get-TaskComplexity -Task $_.Tasks
                }
            }
        } else {
            $result = Get-RoutingDecision -Message $Message -Config $Config
            
            $complexity = Get-TaskComplexity -Task $Message -Config $Config
            
            Stop-Performance "TaskRouting" | Out-Null
            
            return @{
                IsMultiTask = $false
                Chief = $result.Chief
                Reason = $result.Reason
                Confidence = $result.Confidence
                MatchedKeywords = $result.MatchedKeywords
                Complexity = $complexity
                RecommendedWorkers = $complexity.RecommendedWorkers
            }
        }
    }
    catch {
        Stop-Performance "TaskRouting" | Out-Null
        $logger.Error.Invoke("Routing failed: $_")
        throw
    }
}

# ==================== Exports ====================

Export-ModuleMember -Function Invoke-TaskRouter, Get-RoutingDecision, 
                      Detect-MultiTask, Detect-SpecifiedChief,
                      Test-KeywordMatch, Get-TaskComplexity,
                      Route-MultiTasks, Get-RecommendedWorkers

# ==================== CLI Entry Point ====================

if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    Write-Host "`n🔀 Testing Task Router" -ForegroundColor Magenta
    
    $testConfig = @{
        chiefs = @(
            @{ id = "chief-code"; name = "代码专家"; specialty = @("代码", "编程", "debug") },
            @{ id = "chief-doc"; name = "文档专家"; specialty = @("文档", "写作", "翻译") },
            @{ id = "chief-research"; name = "调研专家"; specialty = @("调研", "搜索", "分析") }
        )
        routing = @{
            default = "chief-code"
            rules = @(
                @{ keywords = @("代码", "编程", "debug"); target = "chief-code"; priority = "high" },
                @{ keywords = @("文档", "写作", "翻译"); target = "chief-doc"; priority = "normal" },
                @{ keywords = @("调研", "搜索", "分析"); target = "chief-research"; priority = "normal" }
            )
        }
    }
    
    $testCases = @(
        "帮我优化这段代码",
        "@文档专家 翻译这个文档",
        "帮我调研 AI 市场，同时写代码实现",
        "1. 写代码 2. 写文档 3. 测试"
    )
    
    foreach ($test in $testCases) {
        Write-Host "`nTest: $test" -ForegroundColor Cyan
        $result = Invoke-TaskRouter -Message $test -Config $testConfig
        
        if ($result.IsMultiTask) {
            Write-Host "  Multi-task: $($result.TaskCount) tasks → $($result.ChiefCount) chiefs" -ForegroundColor Green
            foreach ($detail in $result.Details) {
                Write-Host "    • '$(Truncate-String $detail.Task 40)' → $($detail.Chief.name)" -ForegroundColor Gray
            }
        } else {
            Write-Host "  Routed to: $($result.Chief.name)" -ForegroundColor Green
            Write-Host "  Reason: $($result.Reason)" -ForegroundColor Gray
            Write-Host "  Confidence: $([math]::Round($result.Confidence * 100, 1))%" -ForegroundColor Gray
        }
    }
    
    $report = Get-PerformanceReport
    Write-Host "`nPerformance:" -ForegroundColor Magenta
    foreach ($metric in $report) {
        Write-Host "  $($metric.Operation): $($metric.Count) calls, avg $([math]::Round($metric.AverageMs, 1))ms" -ForegroundColor Yellow
    }
}
