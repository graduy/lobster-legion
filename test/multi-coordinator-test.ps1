# Lobster Legion - Multi Chief Coordinator Test
# 测试多个总总龙虾并行工作

Write-Host "`n🦞 ========================================" -ForegroundColor Magenta
Write-Host "🦞   Multi Chief Coordinator Test         " -ForegroundColor Magenta
Write-Host "🦞 ========================================" -ForegroundColor Magenta

# ==================== 场景：3 个总总龙虾并行 ====================

Write-Host "`n场景：同时启动 3 个总总龙虾，每个负责一个大项目`n" -ForegroundColor Cyan

$coordinators = @(
    @{
        id = "coordinator-project-a"
        name = "项目 A 总指挥"
        task = "开发微信自动发送工具：1.调研 2.编码 3.文档"
    },
    @{
        id = "coordinator-project-b"
        name = "项目 B 总指挥"
        task = "数据分析平台：1.架构设计 2.核心代码 3.API 文档"
    },
    @{
        id = "coordinator-project-c"
        name = "项目 C 总指挥"
        task = "AI 调研任务：1.市场研究 2.竞品分析 3.技术选型"
    }
)

Write-Host "准备 Spawn 3 个总总龙虾...`n" -ForegroundColor Yellow

foreach ($coord in $coordinators) {
    Write-Host "[$($coord.name)]" -ForegroundColor Cyan
    Write-Host "  Task: $($coord.task)" -ForegroundColor Gray
    Write-Host "  Status: Ready to spawn" -ForegroundColor Green
    Write-Host ""
}

Write-Host "========================================`n" -ForegroundColor Magenta
Write-Host "Next: Call sessions_spawn for each coordinator" -ForegroundColor Yellow
Write-Host ""
