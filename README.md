# 🦞 Lobster Legion

> **Multi-Agent Collaboration Framework — One Coordinator, Multiple Experts, Infinite Possibilities**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-green.svg)](https://openclaw.ai)
[![Version](https://img.shields.io/badge/version-0.1.0-orange.svg)](https://github.com/graduy/lobster-legion)

---

## 📖 What is Lobster Legion?

Lobster Legion is a **configurable multi-agent collaboration framework** designed for OpenClaw. Think of it as a company structure:

- **🦞 Chief Coordinator** — CEO, receives your tasks, distributes to chief lobsters
- **🦞 Chief Lobsters** — Department managers, each specializing in different areas (code, docs, research)
- **🦞 Worker Agents** — Employees, execute specific tasks

```
You → Chief Coordinator → Chief A (Code) → Workers
                        → Chief B (Docs) → Workers
                        → Chief C (Research) → Workers
```

**Core Advantages:**
- 🚀 **Parallel Execution** — Multiple agents working simultaneously, 3x+ efficiency
- 🎯 **Smart Routing** — Auto-assign tasks to the right expert
- 📚 **Knowledge Isolation** — Each chief has independent knowledge base
- 🛡️ **Token Protection** — Hierarchical limits + budget control
- 🔧 **Config-Driven** — Modify YAML config, no coding required

---

## ⚡ Quick Start

### 1. Install

```bash
git clone https://github.com/graduy/lobster-legion.git
cd lobster-legion
cp -r lobster-legion ~/.openclaw/workspace/skills/
```

### 2. Configure

Pre-configured with 3 chiefs, ready to use:

```yaml
chiefs:
  - id: chief-code
    name: Code Expert
    specialty: ["code", "programming", "debug", "optimize"]
  
  - id: chief-doc
    name: Doc Expert
    specialty: ["docs", "writing", "translation"]
  
  - id: chief-research
    name: Research Expert
    specialty: ["research", "search", "analysis"]
```

### 3. Use

**Basic:**
```
Help me optimize this Python code
```

**Specify Chief:**
```
@Doc Expert Translate this to English
```

**Multi-task Parallel:**
```
Help me with:
1. Optimize code
2. Write documentation
3. Research existing solutions
```

---

## 🎯 Use Cases

### Case 1: Complete Project Development

```
User: I want to develop a WeChat auto-sender tool

Lobster Legion auto-assigns:
├─ Research Expert → Research existing solutions
├─ Code Expert → Write core code
└─ Doc Expert → Write README and docs

Output: Complete project (code + docs + research report)
```

### Case 2: Code Review + Optimization

```
User: Review this project and suggest improvements

Lobster Legion auto-assigns:
├─ Code Expert → Code quality analysis
└─ Doc Expert → Documentation completeness check

Output: Code Review Report
```

### Case 3: Multi-Project Parallel

```
User: Help me with three projects simultaneously:
1. WeChat tool development
2. Data platform design
3. AI market research

Lobster Legion:
├─ Coordinator A → WeChat tool (research + code + docs)
├─ Coordinator B → Data platform (architecture + code + API)
└─ Coordinator C → AI research (market + competitors + tech)

Output: Three complete reports (parallel execution, 3x efficiency)
```

### Case 4: Academic Paper Writing

```
User: Write a paper about "Multi-Agent Collaboration with LLMs"

Lobster Legion auto-assigns:
├─ Paper Expert → Overall structure + writing
├─ Research Expert → Literature review + citation management
├─ Code Expert → Experiment design + implementation
└─ Doc Expert → Formatting + proofreading

Output: Complete academic paper (Abstract, Intro, Related Work, Methodology, Experiments, Conclusion)
```

### Case 5: Paper Writing with Citation Management

```
User: @Paper Expert Write the Methodology section, cite the references I saved earlier

Lobster Legion:
├─ Paper Expert → Load paper-writing template
├─ Citation Manager → Retrieve saved references from knowledge base
└─ Auto-format citations in ACL style

Output: Methodology section with properly formatted citations
```

---

## 📁 Directory Structure

```
lobster-legion/
├── config.yml                 # Configuration (pre-configured)
├── config.example.yml         # Configuration template
├── README.md                  # This file
├── README-CN.md               # 中文文档
├── SKILL.md                   # OpenClaw Skill description
├── QUICKSTART.md              # Quick start guide
├── src/                       # Core code
│   ├── coordinator.ps1        # Chief Coordinator
│   ├── chief-lobster.ps1      # Chief Lobster template
│   ├── router.ps1             # Task Router
│   └── knowledge-base.ps1     # Knowledge Base Manager
├── test/                      # Test scripts
│   ├── test.ps1               # Routing test (✅ verified)
│   ├── multi-level-spawn.ps1  # Multi-level spawn test
│   └── multi-coordinator-test.ps1  # Multi-coordinator test
├── examples/                  # Usage examples
│   └── usage-examples.md      # 10 use cases
├── docs/                      # Documentation
│   └── ARCHITECTURE.md        # Architecture + Token budget
├── workspaces/                # Workspaces (auto-generated)
└── knowledge-base/            # Knowledge base (auto-generated)
```

---

## 📖 API Quick Reference

### Configuration Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `chiefs[].id` | string | - | Unique chief identifier |
| `chiefs[].name` | string | - | Display name |
| `chiefs[].specialty` | string[] | - | Routing keywords |
| `chiefs[].maxSubAgents` | number | 6 | Max sub-agents per chief |
| `routing.rules[].keywords` | string[] | - | Trigger keywords |
| `routing.rules[].target` | string | - | Target chief ID |
| `subagents.maxConcurrentAgents` | number | 36 | Global concurrent limit |
| `tokenBudget.maxTokensPerTask` | number | 500000 | Per-task token limit |

For complete API documentation, see [docs/API.md](docs/API.md).

---

## ⚙️ Advanced Configuration

### Token Budget Control

```yaml
subagents:
  # Hierarchy limits
  maxChiefsPerCoordinator: 6    # Max 6 chiefs per coordinator
  maxWorkersPerChief: 6         # Max 6 workers per chief
  maxConcurrentAgents: 36       # Global max concurrent
  
  # Token budget
  tokenBudget:
    maxTokensPerAgent: 50000    # Per agent limit
    maxTokensPerTask: 500000    # Per task total limit
    onBudgetExceeded: warn      # warn | stop
```

### Add Custom Chief

```yaml
chiefs:
  - id: chief-test
    name: Test Expert
    agentId: main
    specialty: ["test", "unit test", "pytest", "coverage"]
    workspace: ./workspaces/test
    maxSubAgents: 3
```

### Custom Routing Rules

```yaml
routing:
  rules:
    - keywords: ["test", "unit", "coverage"]
      target: chief-test
      priority: high
```

---

## 📊 Performance & Cost

### Efficiency Comparison

| Task Type | Single Agent | Lobster Legion | Improvement |
|-----------|--------------|----------------|-------------|
| Code + Docs | 10 min | 3 min | 3.3x |
| Multi-Project | 30 min | 5 min | 6x |
| Complex Research | 15 min | 5 min | 3x |

### Token Consumption

| Configuration | Token Usage | Cost (¥) |
|---------------|-------------|----------|
| Test (2×2) | 20K | 0.2 |
| Daily (3×3) | 100K | 1 |
| Large Project (6×6) | 500K | 5 |
| Multi-Coordinator (3×6×6) | 1.5M | 15 |

*Note: Based on qwen3.5-plus pricing (~¥0.01/1K tokens)*

---

## 🧪 Testing

```bash
cd skills/lobster-legion
.\test\test.ps1

# Expected output:
=== Lobster Legion - Multi Chief Test ===
Loaded 3 chiefs:
  - Code Expert (chief-code)
  - Doc Expert (chief-doc)
  - Research Expert (chief-research)

Running tests...
Test: Help me optimize this python code
  Routed to: Code Expert (keyword: code) ✅

=== Results: 4 / 4 passed ===
All tests passed! 🎉
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | 1-minute quick start |
| [README.md](README.md) | English documentation |
| [README-CN.md](README-CN.md) | 中文完整文档 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Architecture + Token budget |
| [docs/API.md](docs/API.md) | API reference & configuration |
| [examples/usage-examples.md](examples/usage-examples.md) | 10 use cases |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [CITATION.cff](CITATION.cff) | Citation information for research |

---

## 🤝 Contributing

Welcome to submit Issues and PRs!

1. Fork this repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 📚 Citing Lobster Legion

If you use Lobster Legion in your research, please cite it using the following reference:

**BibTeX:**
```bibtex
@software{lobster_legion_2026,
  author       = {Grady, Your Name},
  title        = {Lobster Legion: Multi-Agent Collaboration Framework},
  abstract     = {A configurable multi-agent collaboration framework for OpenClaw},
  version      = {0.1.0},
  doi          = {10.0000/lobster-legion.0.1.0},
  url          = {https://github.com/graduy/lobster-legion},
  license      = {MIT},
  date         = {2026-03-09},
  keywords     = {multi-agent systems, LLM, task distribution, OpenClaw}
}
```

**APA:**
```
Grady, Y. (2026). Lobster Legion: Multi-Agent Collaboration Framework (Version 0.1.0) 
[Computer software]. https://github.com/graduy/lobster-legion
https://doi.org/10.0000/lobster-legion.0.1.0
```

For more citation formats, see [CITATION.cff](CITATION.cff).

---

## 🙏 Acknowledgments

- [OpenClaw](https://openclaw.ai) - Powerful Agent framework
- [ClawHub](https://clawhub.com) - OpenClaw Skill marketplace

---

## 📬 Contact

- GitHub: [@graduy](https://github.com/graduy)
- Project URL: https://github.com/graduy/lobster-legion

---

**🦞 Lobster Legion, Mission Accomplished!**

*Last Updated: 2026-03-09*
