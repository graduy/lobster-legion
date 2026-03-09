# Lobster Legion - Multi-Level Auto Spawn
# 总总龙虾和总龙虾自动 spawn 子节点

param(
    [string]$Task,
    [hashtable]$Config
)

Write-Host "`n🦞 ========================================" -ForegroundColor Magenta
Write-Host "🦞   Multi-Level Auto Spawn Test          " -ForegroundColor Magenta
Write-Host "🦞 ========================================" -ForegroundColor Magenta

# ==================== Level 1: 总总龙虾 (Coordinator) ====================

Write-Host "`n[Level 1] 总总龙虾接收任务" -ForegroundColor Cyan
Write-Host "  Task: $Task" -ForegroundColor Gray

# 分析任务，决定需要几个总龙虾
$neededChiefs = 3  # 简化：固定 3 个总龙虾
Write-Host "  分析：需要 $neededChiefs 个总龙虾并行执行" -ForegroundColor Yellow

# ==================== Level 2: 总龙虾 (Chief Lobsters) ====================

Write-Host "`n[Level 2] Spawning 总龙虾..." -ForegroundColor Cyan

$chiefTasks = @(
    @{ id = "chief-code"; task = "代码相关子任务" },
    @{ id = "chief-doc"; task = "文档相关子任务" },
    @{ id = "chief-research"; task = "调研相关子任务" }
)

$chiefSessions = @()

foreach ($chief in $chiefTasks) {
    Write-Host "  Spawning: $($chief.id) - $($chief.task)" -ForegroundColor Yellow
    
    # 这里调用 sessions_spawn
    $chiefSessions += @{
        id = $chief.id
        task = $chief.task
        status = "spawned"
        subAgentsNeeded = 3  # 每个总龙虾 spawn 3 个小龙虾
    }
}

Write-Host "  Spawned $($chiefSessions.Count) 总龙虾" -ForegroundColor Green

# ==================== Level 3: 小龙虾 (Worker Agents) ====================

Write-Host "`n[Level 3] 总龙虾自动 spawn 小龙虾..." -ForegroundColor Cyan

$workerCount = 0

foreach ($chief in $chiefSessions) {
    Write-Host "  [$($chief.id)] Spawning $($chief.subAgentsNeeded) 小龙虾..." -ForegroundColor Yellow
    
    for ($i = 1; $i -le $chief.subAgentsNeeded; $i++) {
        Write-Host "    ↳ Worker $($chief.id)-$i" -ForegroundColor Gray
        $workerCount++
    }
}

Write-Host "`n  Total 小龙虾 spawned: $workerCount" -ForegroundColor Green

# ==================== 统计 ====================

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "📊 Spawn 统计" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Level 1 (总总龙虾): 1" -ForegroundColor White
Write-Host "  Level 2 (总龙虾):   $($chiefSessions.Count)" -ForegroundColor White
Write-Host "  Level 3 (小龙虾):   $workerCount" -ForegroundColor White
Write-Host "  总 Agent 数：        $($workerCount + $chiefSessions.Count + 1)" -ForegroundColor Cyan
Write-Host ""
