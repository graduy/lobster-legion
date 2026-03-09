# 🧪 Lobster Legion - Test Runner

param(
    [switch]$Unit,
    [switch]$Integration,
    [switch]$All,
    [switch]$Coverage,
    [switch]$Detailed,
    [string]$OutputFile = ""
)

# Default to all tests if no switch specified
if (-not ($Unit -or $Integration -or $All)) {
    $All = $true
}

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptRoot

Write-Host "`n🦞 ========================================" -ForegroundColor Magenta
Write-Host "🦞     Lobster Legion - Test Runner       " -ForegroundColor Magenta
Write-Host "🦞 ========================================" -ForegroundColor Magenta

# Build Pester configuration
$config = New-PesterConfiguration

if ($Detailed) {
    $config.Output.Verbosity = "Detailed"
} else {
    $config.Output.Verbosity = "Normal"
}

# Set test paths
$testPaths = @()

if ($Unit -or $All) {
    $unitPath = Join-Path $ProjectRoot "test\unit"
    if (Test-Path $unitPath) {
        $testPaths += $unitPath
        Write-Host "`n📋 Including unit tests" -ForegroundColor Cyan
    }
}

if ($Integration -or $All) {
    $integrationPath = Join-Path $ProjectRoot "test\integration"
    if (Test-Path $integrationPath) {
        $testPaths += $integrationPath
        Write-Host "📋 Including integration tests" -ForegroundColor Cyan
    }
}

if ($testPaths.Count -eq 0) {
    Write-Host "❌ No test directories found!" -ForegroundColor Red
    exit 1
}

$config.Run.Path = $testPaths

# Configure code coverage
if ($Coverage) {
    $srcPath = Join-Path $ProjectRoot "src"
    if (Test-Path $srcPath) {
        $config.CodeCoverage.Enabled = $true
        $config.CodeCoverage.Path = $srcPath
        $config.CodeCoverage.OutputPath = Join-Path $ProjectRoot "test\coverage.xml"
        Write-Host "📊 Code coverage enabled" -ForegroundColor Cyan
    }
}

# Configure output file
if ($OutputFile) {
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = $OutputFile
    Write-Host "💾 Results will be saved to: $OutputFile" -ForegroundColor Cyan
}

# Run tests
Write-Host "`n🚀 Running tests..." -ForegroundColor Green
Write-Host "   Paths: $($testPaths -join ', ')" -ForegroundColor Gray

try {
    $results = Invoke-Pester -Configuration $config
    
    Write-Host "`n🦞 ========================================" -ForegroundColor Magenta
    
    # Summary
    $totalTests = $results.TotalCount
    $passedTests = $results.PassedCount
    $failedTests = $results.FailedCount
    $skippedTests = $results.SkippedCount
    
    Write-Host "📊 Test Summary:" -ForegroundColor Cyan
    Write-Host "   Total:   $totalTests" -ForegroundColor White
    Write-Host "   Passed:  $passedTests" -ForegroundColor Green
    Write-Host "   Failed:  $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
    Write-Host "   Skipped: $skippedTests" -ForegroundColor Yellow
    
    if ($Coverage) {
        Write-Host "`n📈 Code Coverage:" -ForegroundColor Cyan
        if (Test-Path $config.CodeCoverage.OutputPath) {
            $coverage = [xml](Get-Content $config.CodeCoverage.OutputPath)
            # Parse coverage report
            Write-Host "   Report saved to: $($config.CodeCoverage.OutputPath)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n🦞 ========================================" -ForegroundColor Magenta
    
    if ($failedTests -gt 0) {
        Write-Host "❌ Some tests failed!" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "✅ All tests passed!" -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Host "`n❌ Test execution failed: $_" -ForegroundColor Red
    exit 1
}
