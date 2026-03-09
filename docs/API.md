# 🦞 Lobster Legion - API Documentation

## Overview

This document describes the configuration API and runtime interfaces for Lobster Legion.

---

## 📋 Configuration API

### Configuration File Structure

```yaml
# config.yml
chiefs: []           # List of Chief Lobsters
routing: {}          # Routing rules
subagents: {}        # Sub-agent limits and budget
```

---

## 🦞 Chiefs Configuration

### Chief Object

```yaml
chiefs:
  - id: string              # Unique identifier (required)
    name: string            # Display name (required)
    agentId: string         # Agent ID, default: "main" (optional)
    specialty: string[]     # Keywords for routing (required)
    workspace: string       # Workspace path (optional)
    maxSubAgents: number    # Max sub-agents for this chief (optional)
    description: string     # Human-readable description (optional)
```

### Example

```yaml
chiefs:
  - id: chief-code
    name: Code Expert
    agentId: main
    specialty: ["code", "programming", "debug", "optimize", "refactor"]
    workspace: ./workspaces/code
    maxSubAgents: 6
    description: "Expert in software development, code review, and optimization"
  
  - id: chief-doc
    name: Documentation Expert
    specialty: ["docs", "writing", "translation", "proofread"]
    workspace: ./workspaces/docs
    maxSubAgents: 3
```

### Chief Methods

#### `Get-ChiefLobster`

Get a chief by ID.

**Parameters:**
- `Id` (string): Chief identifier

**Returns:** Chief object or null

**Example:**
```powershell
$chief = Get-ChiefLobster -Id "chief-code"
```

#### `Get-AllChiefs`

Get all configured chiefs.

**Returns:** Array of chief objects

**Example:**
```powershell
$chiefs = Get-AllChiefs
```

#### `Add-ChiefLobster`

Add a new chief at runtime.

**Parameters:**
- `Chief` (object): Chief configuration object

**Returns:** Boolean (success/failure)

**Example:**
```powershell
$newChief = @{
    id = "chief-security"
    name = "Security Expert"
    specialty = @("security", "audit", "vulnerability")
}
Add-ChiefLobster -Chief $newChief
```

---

## 🎯 Routing Configuration

### Routing Rules

```yaml
routing:
  rules:
    - keywords: string[]     # Trigger keywords (required)
      target: string         # Target chief ID (required)
      priority: string       # "low" | "normal" | "high" (optional)
      fallback: string       # Fallback chief if primary unavailable (optional)
```

### Example

```yaml
routing:
  rules:
    - keywords: ["code", "programming", "debug"]
      target: chief-code
      priority: high
    
    - keywords: ["docs", "writing"]
      target: chief-doc
      fallback: chief-code  # Use code chief if doc chief unavailable
```

### Router Methods

#### `Route-Task`

Route a task to the appropriate chief.

**Parameters:**
- `Task` (string): Task description
- `Chiefs` (array): Available chiefs

**Returns:** Target chief object

**Example:**
```powershell
$target = Route-Task -Task "Help me optimize this code" -Chiefs $chiefs
```

#### `Get-RoutingRules`

Get all routing rules.

**Returns:** Array of routing rule objects

---

## ⚙️ Sub-Agent Configuration

### Sub-Agent Limits

```yaml
subagents:
  # Hierarchy limits
  maxChiefsPerCoordinator: number    # Default: 6
  maxWorkersPerChief: number         # Default: 6
  maxConcurrentAgents: number        # Default: 36
  
  # Token budget
  tokenBudget:
    maxTokensPerAgent: number        # Default: 50000
    maxTokensPerTask: number         # Default: 500000
    onBudgetExceeded: string         # "warn" | "stop" (default: "warn")
```

### Example

```yaml
subagents:
  maxChiefsPerCoordinator: 6
  maxWorkersPerChief: 6
  maxConcurrentAgents: 36
  
  tokenBudget:
    maxTokensPerAgent: 50000
    maxTokensPerTask: 500000
    onBudgetExceeded: warn
```

### Budget Methods

#### `Get-TokenBudget`

Get current token budget status.

**Returns:** Budget status object

**Example:**
```powershell
$budget = Get-TokenBudget
Write-Host "Used: $($budget.used) / $($budget.total)"
```

#### `Check-TokenBudget`

Check if a task would exceed budget.

**Parameters:**
- `EstimatedTokens` (number): Estimated token usage

**Returns:** Boolean (within budget: true)

---

## 📚 Knowledge Base API

### Knowledge Base Configuration

```yaml
knowledgeBase:
  enabled: boolean           # Default: true
  path: string               # Storage path (optional)
  autoSave: boolean          # Auto-save conversations (optional)
```

### Knowledge Base Methods

#### `Save-ToKnowledgeBase`

Save content to knowledge base.

**Parameters:**
- `Content` (string): Content to save
- `Category` (string): Category/tag
- `ChiefId` (string): Owner chief ID

**Example:**
```powershell
Save-ToKnowledgeBase -Content $paperRefs -Category "references" -ChiefId "chief-research"
```

#### `Load-FromKnowledgeBase`

Load content from knowledge base.

**Parameters:**
- `Category` (string): Category to load
- `ChiefId` (string): Owner chief ID (optional)

**Returns:** Array of saved items

**Example:**
```powershell
$refs = Load-FromKnowledgeBase -Category "references" -ChiefId "chief-research"
```

#### `Search-KnowledgeBase`

Search knowledge base.

**Parameters:**
- `Query` (string): Search query
- `Category` (string): Filter by category (optional)

**Returns:** Array of matching items

---

## 🚀 Coordinator API

### Coordinator Methods

#### `Start-Coordinator`

Start the chief coordinator.

**Parameters:**
- `ConfigPath` (string): Path to config file (optional)

**Example:**
```powershell
Start-Coordinator -ConfigPath "./config.yml"
```

#### `Stop-Coordinator`

Stop the coordinator and all active agents.

**Example:**
```powershell
Stop-Coordinator
```

#### `Get-CoordinatorStatus`

Get coordinator status.

**Returns:** Status object with active chiefs, workers, and tasks

**Example:**
```powershell
$status = Get-CoordinatorStatus
Write-Host "Active chiefs: $($status.activeChiefs)"
```

---

## 📊 Runtime Events

### Event Types

```yaml
events:
  - task-received          # Task received by coordinator
  - task-routed            # Task routed to chief
  - chief-spawned          # Chief agent spawned
  - worker-spawned         # Worker agent spawned
  - task-completed         # Task completed
  - budget-warning         # Token budget warning
  - budget-exceeded        # Token budget exceeded
  - error                  # Error occurred
```

### Event Handlers

```powershell
# Register event handler
Register-EventHandler -Event "task-completed" -Action {
    param($task)
    Write-Host "Task completed: $($task.id)"
}
```

---

## 🔍 Debugging

### Debug Mode

```yaml
debug:
  enabled: boolean         # Enable debug logging
  verbose: boolean         # Verbose output
  logPath: string          # Log file path
```

### Debug Commands

```powershell
# Enable debug mode
$env:LOBSTER_DEBUG = "true"

# View logs
Get-Content "./logs/lobster-legion.log" -Tail 50

# Run diagnostic
Invoke-Diagnostic
```

---

## 📝 Examples

### Complete Configuration Example

```yaml
chiefs:
  - id: chief-code
    name: Code Expert
    specialty: ["code", "programming", "debug"]
    maxSubAgents: 6
  
  - id: chief-doc
    name: Doc Expert
    specialty: ["docs", "writing", "translation"]
    maxSubAgents: 3

routing:
  rules:
    - keywords: ["code", "debug"]
      target: chief-code
      priority: high
    - keywords: ["docs", "write"]
      target: chief-doc

subagents:
  maxChiefsPerCoordinator: 6
  maxWorkersPerChief: 6
  maxConcurrentAgents: 36
  
  tokenBudget:
    maxTokensPerAgent: 50000
    maxTokensPerTask: 500000
    onBudgetExceeded: warn

knowledgeBase:
  enabled: true
  path: ./knowledge-base
  autoSave: true

debug:
  enabled: false
  verbose: false
```

### Programmatic Usage

```powershell
# Load configuration
$config = Get-Content "config.yml" | ConvertFrom-Yaml

# Initialize coordinator
$coordinator = New-Coordinator -Config $config

# Start coordinator
Start-Coordinator -Coordinator $coordinator

# Submit task
$task = "Help me optimize this Python code"
$result = Submit-Task -Task $task -Coordinator $coordinator

# Wait for completion
Wait-Task -TaskId $result.id

# Get result
$output = Get-TaskResult -TaskId $result.id
Write-Host $output
```

---

## 📬 Support

- **Issues**: [GitHub Issues](https://github.com/graduy/lobster-legion/issues)
- **Discussions**: [GitHub Discussions](https://github.com/graduy/lobster-legion/discussions)

---

*Last Updated: 2026-03-09*
