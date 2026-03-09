# 🦞 Lobster Legion - Directory Structure

This document describes the recommended directory structure for Lobster Legion.

---

## 📁 Current Structure

```
lobster-legion/
├── .github/                          # GitHub configuration
│   ├── ISSUE_TEMPLATE/               # Issue templates
│   │   ├── bug_report.md             # Bug report template
│   │   └── feature_request.md        # Feature request template
│   └── PULL_REQUEST_TEMPLATE.md      # PR template
│
├── docs/                             # Documentation
│   ├── ARCHITECTURE.md               # Architecture design
│   └── API.md                        # API reference
│
├── examples/                         # Usage examples
│   └── usage-examples.md             # 10 use cases
│
├── src/                              # Core source code
│   ├── coordinator.ps1               # Chief Coordinator
│   ├── chief-lobster.ps1             # Chief Lobster template
│   ├── router.ps1                    # Task Router
│   └── knowledge-base.ps1            # Knowledge Base Manager
│
├── test/                             # Test scripts
│   ├── test.ps1                      # Routing test (✅ verified)
│   ├── multi-level-spawn.ps1         # Multi-level spawn test
│   └── multi-coordinator-test.ps1    # Multi-coordinator test
│
├── workspaces/                       # Workspaces (auto-generated)
│   └── .gitkeep                      # Keep empty directory in git
│
├── knowledge-base/                   # Knowledge base (auto-generated)
│   └── .gitkeep                      # Keep empty directory in git
│
├── .gitignore                        # Git ignore rules
├── CITATION.cff                      # Citation information
├── CODE_OF_CONDUCT.md                # Code of conduct
├── CONTRIBUTING.md                   # Contribution guidelines
├── config.example.yml                # Configuration template
├── config.yml                        # Active configuration
├── DEPLOY.md                         # Deployment guide
├── LICENSE                           # MIT License
├── QUICKSTART.md                     # Quick start guide
├── README-CN.md                      # 中文文档
├── README.md                         # Main documentation
└── SKILL.md                          # OpenClaw skill description
```

---

## 📋 File Descriptions

### Root Files

| File | Purpose |
|------|---------|
| `README.md` | Main English documentation |
| `README-CN.md` | Chinese documentation |
| `QUICKSTART.md` | 1-minute quick start guide |
| `SKILL.md` | OpenClaw skill definition |
| `config.yml` | Active configuration |
| `config.example.yml` | Configuration template for users |
| `LICENSE` | MIT License |
| `CITATION.cff` | Citation information for research |
| `CODE_OF_CONDUCT.md` | Community code of conduct |
| `CONTRIBUTING.md` | Contribution guidelines |
| `DEPLOY.md` | Deployment instructions |
| `.gitignore` | Git ignore patterns |

### Directories

| Directory | Purpose |
|-----------|---------|
| `.github/` | GitHub templates and workflows |
| `docs/` | Technical documentation |
| `examples/` | Usage examples and demos |
| `src/` | Core PowerShell source code |
| `test/` | Test scripts |
| `workspaces/` | Auto-generated workspaces |
| `knowledge-base/` | Auto-generated knowledge base |

---

## 🔄 Suggested Improvements

### Phase 1: Current (✅ Complete)

- Basic structure in place
- Core documentation exists
- Tests are functional

### Phase 2: Recommended

```
lobster-legion/
├── src/
│   ├── core/                    # Core modules
│   │   ├── coordinator.ps1
│   │   ├── router.ps1
│   │   └── knowledge-base.ps1
│   ├── chiefs/                  # Chief implementations
│   │   ├── chief-code.ps1
│   │   ├── chief-doc.ps1
│   │   └── chief-research.ps1
│   └── utils/                   # Utility functions
│       ├── logger.ps1
│       └── helpers.ps1
│
├── scripts/                     # Utility scripts
│   ├── install.ps1              # Installation script
│   ├── update.ps1               # Update script
│   └── cleanup.ps1              # Cleanup script
│
└── logs/                        # Log files (auto-generated)
    └── .gitkeep
```

### Phase 3: Advanced

```
lobster-legion/
├── .github/
│   └── workflows/               # CI/CD workflows
│       └── test.yml             # Automated testing
│
├── benchmarks/                  # Performance benchmarks
│   └── performance-tests.ps1
│
└── integrations/                # Third-party integrations
    ├── discord.ps1
    └── slack.ps1
```

---

## 📝 Best Practices

### File Organization

1. **Keep related files together** - Group by functionality
2. **Use descriptive names** - Clear, self-explanatory filenames
3. **Separate config from code** - Configuration in root, code in `src/`
4. **Document as you go** - Update docs when adding features

### Git Hygiene

1. **Track templates, not generated files** - `.gitkeep` for auto-generated dirs
2. **Keep `.gitignore` updated** - Exclude logs, workspaces, knowledge-base
3. **Use meaningful commits** - Follow conventional commits

### Testing

1. **One test per file** - Clear test organization
2. **Name tests descriptively** - `test-feature-name.ps1`
3. **Keep tests independent** - No cross-test dependencies

---

## 🚀 Migration Guide

If you're updating from an older structure:

```powershell
# Move source files to src/core
mkdir src\core
move coordinator.ps1 src\core\
move router.ps1 src\core\
move knowledge-base.ps1 src\core\

# Create utility scripts folder
mkdir scripts
move install.ps1 scripts\ 2>$null

# Create logs directory
mkdir logs
echo "" > logs\.gitkeep
```

---

## 📬 Questions?

Open an issue if you have questions about the directory structure:
https://github.com/graduy/lobster-legion/issues

---

*Last Updated: 2026-03-09*
