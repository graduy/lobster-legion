# 🦞 Lobster Legion - Unit Tests for Common Utilities
# Uses Pester framework for PowerShell testing

param()

# Import module to test
$modulePath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src\common.ps1"
if (Test-Path $modulePath) {
    . $modulePath
}

Describe "Common Utilities" {
    
    Context "Get-Logger" {
        It "Should return logger object with all methods" {
            $logger = Get-Logger
            
            $logger | Should -Not -BeNullOrEmpty
            $logger.Info | Should -Not -BeNullOrEmpty
            $logger.Warn | Should -Not -BeNullOrEmpty
            $logger.Error | Should -Not -BeNullOrEmpty
            $logger.Debug | Should -Not -BeNullOrEmpty
            $logger.Success | Should -Not -BeNullOrEmpty
        }
        
        It "Should create log directory if not exists" {
            $testLogPath = "TestDrive:\logs\test.log"
            $logger = Get-Logger -LogPath $testLogPath
            
            Test-Path (Split-Path -Parent $testLogPath) | Should -BeTrue
        }
    }
    
    Context "Test-ConfigValid" {
        It "Should return true for valid config" {
            $validConfig = @{
                chiefs = @(
                    @{ id = "chief-1"; name = "Test Chief"; specialty = @("test") }
                )
                routing = @{
                    default = "chief-1"
                    rules = @(
                        @{ keywords = @("test"); target = "chief-1" }
                    )
                }
            }
            
            Test-ConfigValid -Config $validConfig | Should -BeTrue
        }
        
        It "Should return false for empty chiefs" {
            $invalidConfig = @{
                chiefs = @()
                routing = @{
                    default = "chief-1"
                    rules = @()
                }
            }
            
            Test-ConfigValid -Config $invalidConfig | Should -BeFalse
        }
        
        It "Should return false for missing routing" {
            $invalidConfig = @{
                chiefs = @(
                    @{ id = "chief-1"; name = "Test"; specialty = @("test") }
                )
            }
            
            Test-ConfigValid -Config $invalidConfig | Should -BeFalse
        }
        
        It "Should validate chief required fields" {
            $invalidConfig = @{
                chiefs = @(
                    @{ id = "chief-1" }  # Missing name and specialty
                )
                routing = @{
                    default = "chief-1"
                    rules = @()
                }
            }
            
            Test-ConfigValid -Config $invalidConfig | Should -BeFalse
        }
    }
    
    Context "Format-Timespan" {
        It "Should format milliseconds" {
            Format-Timespan -Milliseconds 500 | Should -Be "500ms"
        }
        
        It "Should format seconds" {
            Format-Timespan -Milliseconds 1500 | Should -Be "1.5s"
        }
        
        It "Should format minutes and seconds" {
            Format-Timespan -Milliseconds 125000 | Should -Be "2m 5s"
        }
        
        It "Should format hours, minutes, and seconds" {
            Format-Timespan -Milliseconds 3725000 | Should -Be "1h 2m 5s"
        }
    }
    
    Context "Truncate-String" {
        It "Should not truncate short strings" {
            Truncate-String -Text "Short" -MaxLength 10 | Should -Be "Short"
        }
        
        It "Should truncate long strings with ellipsis" {
            $result = Truncate-String -Text "This is a very long text" -MaxLength 10
            $result | Should -Be "This is..."
            $result.Length | Should -Be 10
        }
        
        It "Should handle exact length strings" {
            Truncate-String -Text "Exact" -MaxLength 5 | Should -Be "Exact"
        }
    }
    
    Context "Extract-Keywords" {
        It "Should extract meaningful keywords" {
            $keywords = Extract-Keywords -Text "Help me optimize this code"
            $keywords | Should -Contain "optimize"
            $keywords | Should -Contain "code"
        }
        
        It "Should filter out stop words" {
            $keywords = Extract-Keywords -Text "The quick brown fox jumps over the lazy dog"
            $keywords | Should -Not -Contain "the"
            $keywords | Should -Not -Contain "over"
        }
        
        It "Should respect minimum length" {
            $keywords = Extract-Keywords -Text "I am a bee" -MinLength 4
            $keywords | Should -Not -Contain "I"
            $keywords | Should -Not -Contain "am"
            $keywords | Should -Not -Contain "a"
        }
    }
    
    Context "Ensure-Directory" {
        It "Should create directory if not exists" {
            $testPath = "TestDrive:\new\directory\path"
            $created = Ensure-Directory -Path $testPath
            
            $created | Should -BeTrue
            Test-Path $testPath | Should -BeTrue
        }
        
        It "Should return false if directory already exists" {
            $testPath = "TestDrive:\existing\directory"
            New-Item -ItemType Directory -Path $testPath -Force | Out-Null
            
            $created = Ensure-Directory -Path $testPath
            $created | Should -BeFalse
        }
    }
    
    Context "New-SessionTracker" {
        It "Should create session tracker with all properties" {
            $session = New-SessionTracker -SessionId "test-123" -Task "Test task"
            
            $session.SessionId | Should -Be "test-123"
            $session.Task | Should -Be "Test task"
            $session.Status | Should -Be "running"
            $session.StartTime | Should -Not -BeNullOrEmpty
            $session.EndTime | Should -BeNullOrEmpty
            $session.Result | Should -BeNullOrEmpty
        }
    }
    
    Context "Update-Session" {
        It "Should update session status and end time" {
            $session = New-SessionTracker -SessionId "test-456"
            
            Start-Sleep -Milliseconds 100
            
            Update-Session -Session $session -Status "completed"
            
            $session.Status | Should -Be "completed"
            $session.EndTime | Should -Not -BeNullOrEmpty
            $session.Duration | Should -Not -BeNullOrEmpty
        }
        
        It "Should store result data" {
            $session = New-SessionTracker -SessionId "test-789"
            $testResult = @{ Output = "test data" }
            
            Update-Session -Session $session -Status "completed" -Result $testResult
            
            $session.Result | Should -Be $testResult
        }
    }
    
    Context "Invoke-SafeScript" {
        It "Should execute script block successfully" {
            $logger = Get-Logger
            
            $result = Invoke-SafeScript -ScriptBlock { return "success" } -Operation "Test" -Logger $logger
            
            $result | Should -Be "success"
        }
        
        It "Should throw on error" {
            $logger = Get-Logger
            
            {
                Invoke-SafeScript -ScriptBlock { throw "test error" } -Operation "Test" -Logger $logger
            } | Should -Throw
        }
    }
    
    Context "Performance Monitoring" {
        It "Should track performance metrics" {
            Start-Performance "TestOp"
            Start-Sleep -Milliseconds 50
            $duration = Stop-Performance "TestOp"
            
            $duration | Should -Not -BeNullOrEmpty
            $duration.TotalMilliseconds | Should -BeGreaterThan 40
        }
        
        It "Should generate performance report" {
            Start-Performance "ReportTest"
            Start-Sleep -Milliseconds 30
            Stop-Performance "ReportTest" | Out-Null
            
            $report = Get-PerformanceReport
            
            $report | Should -Not -BeNullOrEmpty
            $testMetric = $report | Where-Object { $_.Operation -eq "ReportTest" }
            $testMetric | Should -Not -BeNullOrEmpty
            $testMetric.Count | Should -BeGreaterThan 0
        }
    }
}

Describe "Configuration Validation" {
    
    Context "Test-ChiefConfig" {
        It "Should validate complete chief config" {
            $chief = @{
                id = "chief-test"
                name = "Test Chief"
                specialty = @("test", "validation")
                maxSubAgents = 5
            }
            
            Test-ChiefConfig -Chief $chief | Should -BeTrue
        }
        
        It "Should reject missing id" {
            $chief = @{
                name = "Test Chief"
                specialty = @("test")
            }
            
            Test-ChiefConfig -Chief $chief | Should -BeFalse
        }
        
        It "Should reject non-array specialty" {
            $chief = @{
                id = "chief-test"
                name = "Test"
                specialty = "test"  # Should be array
            }
            
            Test-ChiefConfig -Chief $chief | Should -BeFalse
        }
        
        It "Should accept chief without maxSubAgents" {
            $chief = @{
                id = "chief-test"
                name = "Test"
                specialty = @("test")
            }
            
            Test-ChiefConfig -Chief $chief | Should -BeTrue
        }
    }
}

# Run tests if executed directly
if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    Write-Host "`n🧪 Running Common Utilities Tests" -ForegroundColor Magenta
    Invoke-Pester -Path $PSCommandPath -Output Detailed
}
