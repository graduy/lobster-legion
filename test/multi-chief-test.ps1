# 🧪 Lobster Legion - 多总龙虾测试脚本

param(
    [switch]$Verbose
)

Write-Host "`n🦞 ========================================" -ForegroundColor Magenta
Write-Host "🦞   Lobster Legion - 多总龙虾测试        " -ForegroundColor Magenta
Write-Host "🦞 ========================================" -ForegroundColor Magenta

# ==================== 模拟配置 ====================

$Config = @{
    chiefs = @(
        @{
            id = "chief-code"
            name = "代码专家"
            agentId = "main"
            specialty = @("代码", "编程", "debug", "优化", "python", "javascript")
            workspace = "./workspaces/code"
            maxSubAgents = 5
        },
        @{
            id = "chief-doc"
            name = "文档专家"
            agentId = "main"
            specialty = @("文档", "写作", "翻译", "readme", "markdown")
            workspace = "./workspaces/docs"
            maxSubAgents = 3
        },
        @{
            id = "chief-research"
            name = "调研专家"
            agentId = "main"
            specialty = @("调研", "搜索", "分析", "报告", "查")
            workspace = "./workspaces/research"
            maxSubAgents = 5
        }
    )
    routing = @{
        default = "chief-code"
        rules = @(
            @{ keywords = @("代码", "编程", "debug", "优化"); target = "chief-code"; priority = "high" },
            @{ keywords = @("文档", "写", "翻译", "readme"); target = "chief-doc"; priority = "normal" },
            @{ keywords = @("调研", "搜索", "查", "分析"); target = "chief-research"; priority = "normal" }
        )
    }
}

Write-Host "`n📋 配置加载完成" -ForegroundColor Green
Write-Host "   总龙虾数量：$($Config.chiefs.Count)" -ForegroundColor Cyan
foreach ($chief in $Config.chiefs) {
    Write-Host "   • $($chief.name) ($($chief.id))" -ForegroundColor Gray
}

# ==================== 测试用例 ====================

$testCases = @(
    @{
        name = "测试 1: 代码任务"
        message = "帮我优化这段 Python 代码的性能"
        expected = "chief-code"
    },
    @{
        name = "测试 2: 文档任务"
        message = "帮我把这个文档翻译成英文"
        expected = "chief-doc"
    },
    @{
        name = "测试 3: 调研任务"
        message = "调研一下 AI Agent 框架的市场情况"
        expected = "chief-research"
    },
    @{
        name = "测试 4: 指定总龙虾"
        message = "@文档专家 帮我写个 README"
        expected = "chief-doc"
    },
    @{
        name = "测试 5: 多任务并行"
        message = "同时帮我：1. 优化代码 2. 写文档 3. 调研现有方案"
        expected = "multi"
    }
)

# ==================== 路由逻辑 ====================

function Test-Route {
    param(
        [string]$Message,
        [hashtable]$Config
    )
    
    # 检测指定总龙虾
    if ($Message -match "@(\S+)") {
        $specifiedId = $matches[1]
        $chief = $Config.chiefs | Where-Object { $_.id -eq $specifiedId -or $_.name -eq $specifiedId }
        if ($chief) {
            return @($chief)
        }
    }
    
    # 检测多任务
    if ($Message -match "(1\.|2\.|3\.|同时)") {
        Write-Host "   ↳ 检测到多任务，需要分派给多个总龙虾" -ForegroundColor Yellow
        return $Config.chiefs  # 简化：返回所有总龙虾
    }
    
    # 关键词匹配
    foreach ($rule in $Config.routing.rules) {
        foreach ($keyword in $rule.keywords) {
            if ($Message -match $keyword) {
                $chief = $Config.chiefs | Where-Object { $_.id -eq $rule.target }
                return @($chief)
            }
        }
    }
    
    # 默认
    $defaultChief = $Config.chiefs | Where-Object { $_.id -eq $Config.routing.default }
    return @($defaultChief)
}

# ==================== 执行测试 ====================

Write-Host "`n🧪 开始执行测试..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Magenta

$passed = 0
$failed = 0

foreach ($test in $testCases) {
    Write-Host "[$($test.name)]" -ForegroundColor Cyan
    Write-Host "  消息：$($test.message)" -ForegroundColor Gray
    
    $routedChiefs = Test-Route -Message $test.message -Config $Config
    
    Write-Host "  路由到：$($routedChiefs.name -join ", ")" -ForegroundColor Green
    
    # 验证
    if ($test.expected -eq "multi") {
        if ($routedChiefs.Count -gt 1) {
            Write-Host "  ✅ PASS (多任务正确分派)" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  ❌ FAIL (应该是多总龙虾)" -ForegroundColor Red
            $failed++
        }
    } else {
        if ($routedChiefs[0].id -eq $test.expected) {
            Write-Host "  ✅ PASS" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  ❌ FAIL (期望：$($test.expected), 实际：$($routedChiefs[0].id))" -ForegroundColor Red
            $failed++
        }
    }
    
    Write-Host ""
}

# ==================== 测试报告 ====================

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "📊 测试报告" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  总测试数：$($testCases.Count)" -ForegroundColor White
Write-Host "  ✅ 通过：$passed" -ForegroundColor Green
Write-Host "  ❌ 失败：$failed" -ForegroundColor Red
Write-Host "  成功率：$([math]::Round($passed / $testCases.Count * 100, 1))%" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host "`n🎉 所有测试通过！多总龙虾路由逻辑正常！" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  有失败的测试，需要修复" -ForegroundColor Yellow
}

Write-Host ""
