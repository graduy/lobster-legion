# Lobster Legion - Multi Chief Test Script

Write-Host "`n=== Lobster Legion - Multi Chief Test ===`n" -ForegroundColor Magenta

# Config
$Config = @{
    chiefs = @(
        @{ id = "chief-code"; name = "Code Expert"; specialty = @("code", "python", "debug") },
        @{ id = "chief-doc"; name = "Doc Expert"; specialty = @("doc", "write", "translate") },
        @{ id = "chief-research"; name = "Research Expert"; specialty = @("research", "search", "analyze") }
    )
    routing = @{
        default = "chief-code"
        rules = @(
            @{ keywords = @("code", "python", "debug"); target = "chief-code" },
            @{ keywords = @("doc", "write", "translate"); target = "chief-doc" },
            @{ keywords = @("research", "search", "analyze"); target = "chief-research" }
        )
    }
}

Write-Host "Loaded $($Config.chiefs.Count) chiefs:" -ForegroundColor Cyan
foreach ($c in $Config.chiefs) {
    Write-Host "  - $($c.name) ($($c.id))" -ForegroundColor Gray
}

# Test cases
$tests = @(
    @{ msg = "Help me optimize this python code"; expected = "chief-code" },
    @{ msg = "Translate this document to English"; expected = "chief-doc" },
    @{ msg = "Research AI agent frameworks"; expected = "chief-research" },
    @{ msg = "@Doc Expert write a README"; expected = "chief-doc" }
)

Write-Host "`nRunning tests...`n" -ForegroundColor Cyan

$passed = 0
foreach ($test in $tests) {
    $msg = $test.msg
    Write-Host "Test: $msg" -ForegroundColor Yellow
    
    # Check for @mention
    if ($msg -match "@(\w+)") {
        $specified = $matches[1]
        $chief = $Config.chiefs | Where-Object { $_.id -like "*$specified*" -or $_.name -like "*$specified*" }
        if ($chief) {
            Write-Host "  Routed to: $($chief.name) (specified)" -ForegroundColor Green
            if ($chief.id -eq $test.expected) { $passed++ }
            continue
        }
    }
    
    # Keyword matching
    $matched = $false
    foreach ($rule in $Config.routing.rules) {
        foreach ($kw in $rule.keywords) {
            if ($msg -match $kw) {
                $chief = $Config.chiefs | Where-Object { $_.id -eq $rule.target }
                Write-Host "  Routed to: $($chief.name) (keyword: $kw)" -ForegroundColor Green
                if ($chief.id -eq $test.expected) { $passed++ }
                $matched = $true
                break
            }
        }
        if ($matched) { break }
    }
    
    if (!$matched) {
        Write-Host "  Routed to: default" -ForegroundColor Gray
    }
    
    Write-Host ""
}

Write-Host "=== Results: $passed / $($tests.Count) passed ===" -ForegroundColor Magenta
if ($passed -eq $tests.Count) {
    Write-Host "All tests passed!" -ForegroundColor Green
}
Write-Host ""
