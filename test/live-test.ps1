# Lobster Legion - Live Multi-Agent Test
# 测试真实 spawn 多个子 Agent

Write-Host "`n=== Lobster Legion - Live Agent Test ===`n" -ForegroundColor Magenta

# 三个总龙虾同时执行不同任务
$tasks = @(
    @{
        id = "chief-code"
        name = "Code Expert"
        task = "Write a Python function to calculate fibonacci sequence"
    },
    @{
        id = "chief-doc"
        name = "Doc Expert"
        task = "Write a short README introduction for a project"
    },
    @{
        id = "chief-research"
        name = "Research Expert"
        task = "List 3 popular AI agent frameworks in 2026"
    }
)

Write-Host "Spawning 3 sub-agents in parallel...`n" -ForegroundColor Cyan

$sessions = @()

foreach ($t in $tasks) {
    Write-Host "[$($t.name)] Task: $($t.task)" -ForegroundColor Yellow
    
    # 这里调用 OpenClaw sessions_spawn
    # 由于这是在技能目录中，我们通过 message 或直接调用
    Write-Host "  -> Would spawn session for $($t.id)" -ForegroundColor Gray
    Write-Host "  -> Task prompt: $($t.task)" -ForegroundColor Gray
    
    $sessions += @{
        id = $t.id
        task = $t.task
        status = "spawned"
    }
    
    Write-Host ""
}

Write-Host "========================================`n" -ForegroundColor Magenta
Write-Host "Spawned $($sessions.Count) sessions:" -ForegroundColor Green
foreach ($s in $sessions) {
    Write-Host "  - $($s.id): $($s.status)" -ForegroundColor Cyan
}

Write-Host "`nNext step: Implement actual sessions_spawn calls`n" -ForegroundColor Yellow
