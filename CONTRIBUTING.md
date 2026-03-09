# 🦞 Contributing to Lobster Legion

Thank you for your interest in contributing to Lobster Legion! This guide will help you get started.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community](#community)

---

## 🤝 Code of Conduct

Please be respectful and inclusive in all interactions. We welcome contributors of all backgrounds and experience levels.

---

## 🚀 Getting Started

### 1. Fork the Repository

Click the "Fork" button on GitHub to create your own copy of the repository.

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR-USERNAME/lobster-legion.git
cd lobster-legion
```

### 3. Set Up Remote

```bash
git remote add upstream https://github.com/graduy/lobster-legion.git
git fetch upstream
```

---

## 💻 Development Setup

### Prerequisites

- **OpenClaw** installed and configured
- **PowerShell** (Windows) or **Bash** (Linux/Mac)
- **Git** for version control

### Install Dependencies

```bash
# Clone into your OpenClaw workspace
cp -r lobster-legion ~/.openclaw/workspace/skills/

# Verify installation
cd ~/.openclaw/workspace/skills/lobster-legion
.\test\test.ps1
```

---

## 🔧 Making Changes

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or for bug fixes
git checkout -b fix/your-bug-fix
```

### 2. Make Your Changes

- Follow the existing code style
- Add comments for complex logic
- Update documentation as needed
- Add tests for new features

### 3. Test Your Changes

```bash
# Run all tests
.\test\test.ps1

# Run specific test
.\test\multi-coordinator-test.ps1
```

---

## 📬 Pull Request Process

### 1. Commit Your Changes

```bash
git add .
git commit -m "feat: add new chief lobster type"
# or
git commit -m "fix: resolve routing issue for code tasks"
```

**Commit Message Format:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### 2. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 3. Open a Pull Request

1. Go to your fork on GitHub
2. Click "Pull Request"
3. Fill in the PR template:
   - **Description**: What does this PR do?
   - **Motivation**: Why is this needed?
   - **Testing**: How was it tested?
   - **Screenshots**: If applicable

### 4. Address Review Feedback

- Respond to all comments
- Make requested changes
- Re-request review when ready

---

## 📝 Coding Standards

### PowerShell Style

```powershell
# Use Verb-Noun naming for functions
function Get-ChiefLobster {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Id
    )
    
    # Your code here
}

# Use clear variable names
$chiefConfig = Get-Content "config.yml"
$taskRouter = New-Object Router

# Add comments for complex logic
# Route task to chief based on keyword matching
$targetChief = $chiefs | Where-Object { $_.specialty -contains $keyword }
```

### Configuration Files

```yaml
# Use descriptive IDs
chiefs:
  - id: chief-code-expert      # ✅ Good
  - id: c1                      # ❌ Bad
  
  name: Code Expert            # Clear, human-readable
  specialty: ["code", "dev"]   # Lowercase, concise
```

---

## 🧪 Testing

### Test Types

1. **Unit Tests** - Test individual functions
2. **Integration Tests** - Test chief coordination
3. **E2E Tests** - Test full workflow

### Running Tests

```bash
# All tests
.\test\test.ps1

# Multi-level spawn test
.\test\multi-level-spawn.ps1

# Multi-coordinator test
.\test\multi-coordinator-test.ps1
```

### Adding New Tests

```powershell
# test/test-your-feature.ps1
Write-Host "=== Testing Your Feature ==="

$testResult = Test-YourFeature
if ($testResult -eq $expected) {
    Write-Host "✅ Test passed"
} else {
    Write-Host "❌ Test failed"
    exit 1
}
```

---

## 📚 Documentation

### Updating README

- Keep examples concise and runnable
- Update version numbers
- Add screenshots for UI changes

### Adding Examples

```markdown
## New Use Case

```
User: Your example task

Lobster Legion auto-assigns:
├─ Chief A → Task description
└─ Chief B → Task description

Output: Expected output
```
```

### API Documentation

When adding new functions or configuration options:

```markdown
## `function-name`

**Description**: What does it do?

**Parameters**:
- `param1` (type): Description

**Returns**: What does it return?

**Example**:
```powershell
$result = function-name -param1 "value"
```
```

---

## 🐛 Reporting Bugs

### Bug Report Template

```markdown
**Describe the bug**
Clear description of what went wrong.

**To Reproduce**
Steps to reproduce:
1. Configure chiefs: [...]
2. Run task: [...]
3. See error: [...]

**Expected behavior**
What should have happened?

**Screenshots**
If applicable, add screenshots.

**Environment**
- OpenClaw version: [e.g., 1.0.0]
- OS: [e.g., Windows 11]
- PowerShell version: [e.g., 7.4]

**Additional context**
Any other relevant information.
```

---

## 💡 Feature Requests

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
Clear description of the problem.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Other solutions you've thought about.

**Additional context**
Any other relevant information.
```

---

## 🎓 Learning Resources

- [OpenClaw Documentation](https://openclaw.ai/docs)
- [PowerShell Best Practices](https://docs.microsoft.com/powerscript)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

---

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- GitHub Contributors graph
- Release notes (for significant contributions)

---

## 📬 Contact

- **GitHub Issues**: [Report bugs or request features](https://github.com/graduy/lobster-legion/issues)
- **Discussions**: [Ask questions or share ideas](https://github.com/graduy/lobster-legion/discussions)

---

**🦞 Thank you for contributing to Lobster Legion!**

*Every contribution, no matter how small, makes a difference.*
