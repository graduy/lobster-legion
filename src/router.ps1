# 🦞 Lobster Legion - 任务路由器
# 职责：分析任务内容，匹配关键词，路由到合适的总龙虾

param(
    [string]$Message,
    [hashtable]$Config,
    [switch]$Verbose
)

# ==================== 关键词匹配 ====================

function Test-KeywordMatch {
    param(
        [string]$Message,
        [array]$Keywords
    )
    
    $messageLower = $Message.ToLower()
    
    foreach ($keyword in $Keywords) {
        if ($messageLower -match $keyword.ToLower()) {
            return @{
                matched = $true
                keyword = $keyword
            }
        }
    }
    
    return @{ matched = $false }
}

# ==================== 指定总龙虾检测 ====================

function Detect-SpecifiedChief {
    param([string]$Message)
    
    # 检测 @总龙虾 格式
    if ($Message -match "@(\S+)") {
        $specifiedId = $matches[1]
        Write-Host "🎯 检测到指定总龙虾：$specifiedId" -ForegroundColor Cyan
        return $specifiedId
    }
    
    # 检测 "给 xxx" 格式
    if ($Message -match "给 ([^\s,，]+)") {
        $specifiedName = $matches[1]
        Write-Host "🎯 检测到指定总龙虾：$specifiedName" -ForegroundColor Cyan
        return $specifiedName
    }
    
    return $null
}

# ==================== 多任务检测 ====================

function Detect-MultiTask {
    param([string]$Message)
    
    $tasks = @()
    
    # 检测列表格式 (1. 2. 3.)
    if ($Message -match "(1\.|2\.|3\.)") {
        $lines = $Message -split "`n"
        foreach ($line in $lines) {
            if ($line -match "^\s*\d+\.?\s*(.+)") {
                $tasks += $matches[1].Trim()
            }
        }
    }
    
    # 检测 "同时"、"并且" 等连接词
    if ($Message -match "(同时 | 并且 | 还有 | 另外)") {
        # 简单拆分
        $parts = $Message -split "(同时 | 并且 | 还有 | 另外)"
        $tasks += $parts | Where-Object { $_ -match "\S" }
    }
    
    if ($tasks.Count -gt 1) {
        Write-Host "📋 检测到多任务：$($tasks.Count) 个" -ForegroundColor Cyan
        return @{
            isMultiTask = $true
            tasks = $tasks
        }
    }
    
    return @{ isMultiTask = $false; tasks = @($Message) }
}

# ==================== 路由决策 ====================

function Get-RoutingDecision {
    param(
        [string]$Message,
        [hashtable]$Config
    )
    
    # 1. 检测是否指定了总龙虾
    $specifiedChief = Detect-SpecifiedChief -Message $Message
    if ($specifiedChief) {
        $chief = $Config.chiefs | Where-Object { 
            $_.id -eq $specifiedChief -or $_.name -eq $specifiedChief 
        }
        
        if ($chief) {
            return @{
                chief = $chief
                reason = "用户指定"
                confidence = 1.0
            }
        }
    }
    
    # 2. 关键词匹配
    $bestMatch = $null
    $bestScore = 0
    
    foreach ($rule in $Config.routing.rules) {
        $matchResult = Test-KeywordMatch -Message $Message -Keywords $rule.keywords
        
        if ($matchResult.matched) {
            $score = 1.0
            
            # 优先级加分
            if ($rule.priority -eq "high") {
                $score += 0.2
            }
            
            # 关键词长度加分（越长越精确）
            $score += ($matchResult.keyword.Length * 0.01)
            
            if ($score -gt $bestScore) {
                $bestScore = $score
                $bestMatch = @{
                    chief = $Config.chiefs | Where-Object { $_.id -eq $rule.target }
                    reason = "关键词匹配 '$($matchResult.keyword)'"
                    confidence = $score
                }
            }
        }
    }
    
    # 3. 默认路由
    if ($bestMatch) {
        return $bestMatch
    }
    
    $defaultChief = $Config.chiefs | Where-Object { $_.id -eq $Config.routing.default }
    return @{
        chief = $defaultChief
        reason = "默认路由"
        confidence = 0.5
    }
}

# ==================== 多任务路由 ====================

function Route-MultiTasks {
    param(
        [array]$Tasks,
        [hashtable]$Config
    )
    
    Write-Host "🔀 多任务路由分析..." -ForegroundColor Cyan
    
    $routingResults = @()
    
    foreach ($task in $Tasks) {
        $result = Get-RoutingDecision -Message $task -Config $Config
        $routingResults += @{
            task = $task
            chief = $result.chief
            reason = $result.reason
        }
    }
    
    # 按总龙虾分组
    $grouped = $routingResults | Group-Object { $_.chief.id }
    
    Write-Host "📊 路由分组：$($grouped.Count) 个总龙虾" -ForegroundColor Green
    
    return @{
        grouped = $grouped
        details = $routingResults
    }
}

# ==================== 主函数 ====================

function Invoke-TaskRouter {
    param(
        [string]$Message,
        [hashtable]$Config
    )
    
    Write-Host "`n🔀 ========================================" -ForegroundColor Magenta
    Write-Host "🔀       Lobster Legion - 任务路由        " -ForegroundColor Magenta
    Write-Host "🔀 ========================================" -ForegroundColor Magenta
    
    # 检测是否多任务
    $multiTaskInfo = Detect-MultiTask -Message $Message
    
    if ($multiTaskInfo.isMultiTask) {
        # 多任务路由
        $result = Route-MultiTasks -Tasks $multiTaskInfo.tasks -Config $Config
        
        Write-Host "`n📋 路由结果:" -ForegroundColor Cyan
        foreach ($detail in $result.details) {
            Write-Host "  • '$($detail.task.Substring(0, 40))...' → $($detail.chief.name) ($($detail.reason))" -ForegroundColor Gray
        }
        
        return @{
            isMultiTask = $true
            grouped = $result.grouped
            details = $result.details
        }
    } else {
        # 单任务路由
        $result = Get-RoutingDecision -Message $Message -Config $Config
        
        Write-Host "`n✅ 路由决策:" -ForegroundColor Green
        Write-Host "  总龙虾：$($result.chief.name)" -ForegroundColor Cyan
        Write-Host "  原因：$($result.reason)" -ForegroundColor Gray
        Write-Host "  置信度：$([math]::Round($result.confidence * 100, 1))%" -ForegroundColor Gray
        
        return @{
            isMultiTask = $false
            chief = $result.chief
            reason = $result.reason
            confidence = $result.confidence
        }
    }
}

# ==================== 导出函数 ====================

Export-ModuleMember -Function Invoke-TaskRouter, Get-RoutingDecision, Detect-MultiTask

# ==================== 命令行入口 ====================

if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    # 测试
    $testConfig = @{
        chiefs = @(
            @{ id = "chief-code"; name = "代码专家" },
            @{ id = "chief-doc"; name = "文档专家" },
            @{ id = "chief-research"; name = "调研专家" }
        )
        routing = @{
            default = "chief-code"
            rules = @(
                @{ keywords = @("代码", "编程"); target = "chief-code"; priority = "high" },
                @{ keywords = @("文档", "写"); target = "chief-doc"; priority = "normal" },
                @{ keywords = @("调研", "搜索"); target = "chief-research"; priority = "normal" }
            )
        }
    }
    
    $testMessage = "帮我写代码，同时写文档"
    Invoke-TaskRouter -Message $testMessage -Config $testConfig
}
