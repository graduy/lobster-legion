# 🦞 Lobster Legion - Unit Tests for Router
# Uses Pester framework for PowerShell testing

param()

# Import modules to test
$commonPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src\common.ps1"
$routerPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\src\router.ps1"

if (Test-Path $commonPath) { . $commonPath }
if (Test-Path $routerPath) { . $routerPath }

Describe "Task Router" {
    
    BeforeAll {
        $testConfig = @{
            chiefs = @(
                @{ id = "chief-code"; name = "代码专家"; specialty = @("代码", "编程", "debug", "optimize") },
                @{ id = "chief-doc"; name = "文档专家"; specialty = @("文档", "写作", "翻译") },
                @{ id = "chief-research"; name = "调研专家"; specialty = @("调研", "搜索", "分析") }
            )
            routing = @{
                default = "chief-code"
                rules = @(
                    @{ keywords = @("代码", "编程", "debug", "optimize"); target = "chief-code"; priority = "high" },
                    @{ keywords = @("文档", "写作", "翻译"); target = "chief-doc"; priority = "normal" },
                    @{ keywords = @("调研", "搜索", "分析"); target = "chief-research"; priority = "normal" }
                )
            }
        }
    }
    
    Context "Test-KeywordMatch" {
        It "Should match exact keyword" {
            $result = Test-KeywordMatch -Message "Help me code" -Keywords @("code", "debug")
            
            $result.Matched | Should -BeTrue
            $result.Keyword | Should -Be "code"
            $result.Score | Should -BeGreaterThan 0.5
        }
        
        It "Should not match unrelated keywords" {
            $result = Test-KeywordMatch -Message "Help me cook" -Keywords @("code", "debug")
            
            $result.Matched | Should -BeFalse
        }
        
        It "Should prefer longer matches" {
            $result = Test-KeywordMatch -Message "Optimize this code" -Keywords @("code", "optimize")
            
            $result.Matched | Should -BeTrue
            $result.Score | Should -BeGreaterThan 0.7
        }
        
        It "Should be case-insensitive" {
            $result = Test-KeywordMatch -Message "HELP ME CODE" -Keywords @("code")
            
            $result.Matched | Should -BeTrue
        }
    }
    
    Context "Detect-SpecifiedChief" {
        It "Should detect @mention" {
            $result = Detect-SpecifiedChief -Message "@Doc Expert write this"
            
            $result.Specified | Should -Be "Doc"
            $result.Confidence | Should -BeGreaterThan 0.9
        }
        
        It "Should detect 给 xxx pattern" {
            $result = Detect-SpecifiedChief -Message "给文档专家 写这个"
            
            $result.Specified | Should -Be "文档专家"
        }
        
        It "Should return null for no specification" {
            $result = Detect-SpecifiedChief -Message "Help me code"
            
            $result.Specified | Should -BeNullOrEmpty
        }
    }
    
    Context "Detect-MultiTask" {
        It "Should detect numbered list" {
            $result = Detect-MultiTask -Message "1. Write code`n2. Test it`n3. Deploy"
            
            $result.IsMultiTask | Should -BeTrue
            $result.Count | Should -Be 3
        }
        
        It "Should detect bullet points" {
            $result = Detect-MultiTask -Message "- Task 1`n- Task 2`n- Task 3"
            
            $result.IsMultiTask | Should -BeTrue
            $result.Count | Should -Be 3
        }
        
        It "Should detect conjunctions" {
            $result = Detect-MultiTask -Message "Write code 同时 write docs"
            
            $result.IsMultiTask | Should -BeTrue
            $result.Count | Should -BeGreaterThan 1
        }
        
        It "Should return single task for simple message" {
            $result = Detect-MultiTask -Message "Help me optimize this code"
            
            $result.IsMultiTask | Should -BeFalse
            $result.Count | Should -Be 1
        }
    }
    
    Context "Get-TaskComplexity" {
        It "Should return low complexity for short task" {
            $result = Get-TaskComplexity -Task "Fix bug"
            
            $result.Score | Should -BeLessThan 0.4
            $result.Difficulty | Should -Be "easy"
        }
        
        It "Should return high complexity for long task" {
            $longTask = "Design and implement a comprehensive multi-agent system with distributed coordination, fault tolerance, automatic scaling, performance monitoring, and detailed documentation including API references and usage examples"
            $result = Get-TaskComplexity -Task $longTask
            
            $result.Score | Should -BeGreaterThan 0.6
            $result.Difficulty | Should -BeIn @("hard", "expert")
        }
        
        It "Should detect multiple domains" {
            $task = "Write code and create documentation and research existing solutions"
            $result = Get-TaskComplexity -Task $task
            
            $result.Factors.Domains | Should -BeGreaterThan 0.5
        }
        
        It "Should recommend more workers for complex tasks" {
            $simple = Get-TaskComplexity -Task "Simple task"
            $complex = Get-TaskComplexity -Task "Complex multi-domain comprehensive task"
            
            $complex.RecommendedWorkers | Should -BeGreaterThan $simple.RecommendedWorkers
        }
    }
    
    Context "Get-RoutingDecision" {
        It "Should route code tasks to code chief" {
            $result = Get-RoutingDecision -Message "Help me optimize this code" -Config $testConfig
            
            $result.Chief.id | Should -Be "chief-code"
            $result.Confidence | Should -BeGreaterThan 0.7
        }
        
        It "Should route doc tasks to doc chief" {
            $result = Get-RoutingDecision -Message "Please translate this document" -Config $testConfig
            
            $result.Chief.id | Should -Be "chief-doc"
        }
        
        It "Should route research tasks to research chief" {
            $result = Get-RoutingDecision -Message "Research AI market trends" -Config $testConfig
            
            $result.Chief.id | Should -Be "chief-research"
        }
        
        It "Should respect @mention override" {
            $result = Get-RoutingDecision -Message "@文档专家 Help me code something" -Config $testConfig
            
            $result.Chief.id | Should -Be "chief-doc"
            $result.Reason | Should -Match "User specified"
        }
        
        It "Should use default for unknown tasks" {
            $result = Get-RoutingDecision -Message "Make me a sandwich" -Config $testConfig
            
            $result.Chief.id | Should -Be "chief-code"  # Default
            $result.Reason | Should -Match "Default"
        }
        
        It "Should return confidence score" {
            $result = Get-RoutingDecision -Message "Debug this code please" -Config $testConfig
            
            $result.Confidence | Should -BeGreaterThan 0
            $result.Confidence | Should -BeLessThanOrEqual 1
        }
    }
    
    Context "Route-MultiTasks" {
        It "Should route multiple tasks to different chiefs" {
            $tasks = @(
                "Write code for API",
                "Create documentation",
                "Research competitors"
            )
            
            $result = Route-MultiTasks -Tasks $tasks -Config $testConfig
            
            $result.TaskCount | Should -Be 3
            $result.ChiefCount | Should -Be 3
            $result.Details.Count | Should -Be 3
        }
        
        It "Should group tasks by chief" {
            $tasks = @(
                "Write code",
                "Debug code",
                "Write docs"
            )
            
            $result = Route-MultiTasks -Tasks $tasks -Config $testConfig
            
            $result.Grouped.Count | Should -Be 2  # code and doc chiefs
        }
    }
    
    Context "Invoke-TaskRouter" {
        It "Should handle single task routing" {
            $result = Invoke-TaskRouter -Message "Help me write code" -Config $testConfig
            
            $result.IsMultiTask | Should -BeFalse
            $result.Chief | Should -Not -BeNullOrEmpty
            $result.Confidence | Should -BeGreaterThan 0
        }
        
        It "Should handle multi-task routing" {
            $result = Invoke-TaskRouter -Message "1. Write code`n2. Write docs" -Config $testConfig
            
            $result.IsMultiTask | Should -BeTrue
            $result.TaskCount | Should -Be 2
        }
        
        It "Should include complexity analysis" {
            $result = Invoke-TaskRouter -Message "Build a complex system" -Config $testConfig
            
            $result.Complexity | Should -Not -BeNullOrEmpty
            $result.Complexity.Score | Should -BeGreaterThan 0
        }
        
        It "Should recommend workers based on complexity" {
            $result = Invoke-TaskRouter -Message "Simple task" -Config $testConfig
            
            $result.RecommendedWorkers | Should -BeGreaterThan 0
        }
    }
}

Describe "Router Performance" {
    
    BeforeAll {
        $testConfig = @{
            chiefs = @(
                @{ id = "chief-code"; name = "代码专家"; specialty = @("代码") }
            )
            routing = @{
                default = "chief-code"
                rules = @(
                    @{ keywords = @("代码"); target = "chief-code" }
                )
            }
        }
    }
    
    It "Should route within 100ms" {
        $time = Measure-Command {
            Invoke-TaskRouter -Message "Help me code" -Config $testConfig
        }
        
        $time.TotalMilliseconds | Should -BeLessThan 100
    }
    
    It "Should handle 100 routing decisions in under 1 second" {
        $time = Measure-Command {
            1..100 | ForEach-Object {
                Invoke-TaskRouter -Message "Task $_" -Config $testConfig
            }
        }
        
        $time.TotalMilliseconds | Should -BeLessThan 1000
    }
}

# Run tests if executed directly
if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    Write-Host "`n🧪 Running Router Tests" -ForegroundColor Magenta
    Invoke-Pester -Path $PSCommandPath -Output Detailed
}
