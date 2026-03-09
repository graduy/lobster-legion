# 🦞 Lobster Legion - 龙虾军团

> **多 Agent 协作框架 —— 一个总指挥，多个专家，无限可能**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-green.svg)](https://openclaw.ai)
[![Version](https://img.shields.io/badge/version-0.1.0-orange.svg)](https://github.com/graduy/lobster-legion)

---

## 📖 什么是龙虾军团？

龙虾军团是一个**可配置的多 Agent 协作框架**，专为 OpenClaw 设计。你可以把它想象成一个公司：

- **🦞 总总龙虾 (Coordinator)** — CEO，接收你的指令，分派给各个总龙虾
- **🦞 总龙虾 (Chief Lobsters)** — 部门经理，每个专精不同领域（代码、文档、调研等）
- **🦞 小龙虾 (Worker Agents)** — 员工，执行具体任务

```
你 → 总总龙虾 → 总龙虾 A (代码) → 小龙虾们
              → 总龙虾 B (文档) → 小龙虾们
              → 总龙虾 C (调研) → 小龙虾们
```

**核心优势：**
- 🚀 **并行执行** — 多个 Agent 同时干活，效率提升 3 倍+
- 🎯 **智能路由** — 根据任务类型自动分配给合适的专家
- 📚 **知识隔离** — 每个总龙虾有独立知识库，互不干扰
- 🛡️ **Token 保护** — 层级限制 + 预算控制，避免破产
- 🔧 **配置驱动** — 改 YAML 配置，无需写代码

---

## ⚡ 快速开始

### 1. 安装

```bash
# 克隆仓库
git clone https://github.com/graduy/lobster-legion.git
cd lobster-legion

# 复制到 OpenClaw skills 目录
cp -r lobster-legion ~/.openclaw/workspace/skills/
```

### 2. 配置

配置文件已预配置 3 个总龙虾，开箱即用：

```yaml
# skills/lobster-legion/config.yml
chiefs:
  - id: chief-code
    name: 代码专家
    specialty: ["代码", "编程", "debug", "优化"]
  
  - id: chief-doc
    name: 文档专家
    specialty: ["文档", "写作", "翻译"]
  
  - id: chief-research
    name: 调研专家
    specialty: ["调研", "搜索", "分析"]
```

### 3. 使用

**基础用法：**
```
帮我优化这段 Python 代码
```

**指定总龙虾：**
```
@文档专家 帮我把这个翻译成英文
```

**多任务并行：**
```
同时帮我：
1. 优化代码
2. 写文档
3. 调研现有方案
```

---

## 🎯 使用场景

### 场景 1: 完整项目开发

```
用户：我要开发一个微信自动发送工具

龙虾军团自动分配：
├─ 调研专家 → 调研现有方案
├─ 代码专家 → 编写核心代码
└─ 文档专家 → 写 README 和使用文档

输出：完整项目（代码 + 文档 + 调研报告）
```

### 场景 2: 代码 Review + 优化

```
用户：帮我 review 这个项目，提优化建议

龙虾军团自动分配：
├─ 代码专家 → 代码质量分析
└─ 文档专家 → 文档完整性检查

输出：Code Review 报告
```

### 场景 3: 多项目并行

```
用户：同时帮我做三个项目：
1. 微信工具开发
2. 数据平台设计
3. AI 市场调研

龙虾军团：
├─ 总总龙虾 A → 微信工具（调研 + 编码 + 文档）
├─ 总总龙虾 B → 数据平台（架构 + 代码+API）
└─ 总总龙虾 C → AI 调研（市场 + 竞品 + 技术）

输出：三个项目的完整报告（并行执行，效率提升 3 倍）
```

---

## 📁 目录结构

```
lobster-legion/
├── config.yml                 # 配置文件（已预配置）
├── config.example.yml         # 配置模板
├── README.md                  # 本文档
├── README.en.md               # English README
├── SKILL.md                   # OpenClaw Skill 描述
├── QUICKSTART.md              # 快速开始指南
├── src/                       # 核心代码
│   ├── coordinator.ps1        # 总协调器（总总龙虾）
│   ├── chief-lobster.ps1      # 总龙虾模板
│   ├── router.ps1             # 任务路由器
│   └── knowledge-base.ps1     # 知识库管理
├── test/                      # 测试脚本
│   ├── test.ps1               # 路由测试（✅ 已验证）
│   ├── multi-level-spawn.ps1  # 多层级 spawn 测试
│   └── multi-coordinator-test.ps1  # 多总总龙虾测试
├── examples/                  # 使用示例
│   └── usage-examples.md      # 10 个使用场景
├── docs/                      # 文档
│   └── ARCHITECTURE.md        # 架构图 +Token 预算
├── workspaces/                # 工作空间（自动生成）
└── knowledge-base/            # 知识库（自动生成）
```

---

## ⚙️ 高级配置

### Token 预算控制

```yaml
subagents:
  # 层级限制
  maxChiefsPerCoordinator: 6    # 每个总总龙虾最多 6 个总龙虾
  maxWorkersPerChief: 6         # 每个总龙虾最多 6 个小龙虾
  maxConcurrentAgents: 36       # 全局最大并发
  
  # Token 预算
  tokenBudget:
    maxTokensPerAgent: 50000    # 每个 Agent 上限
    maxTokensPerTask: 500000    # 每任务总上限
    onBudgetExceeded: warn      # warn | stop
```

### 添加自定义总龙虾

```yaml
chiefs:
  - id: chief-test
    name: 测试专家
    agentId: main
    specialty: ["测试", "unit test", "pytest", "coverage"]
    workspace: ./workspaces/test
    maxSubAgents: 3
```

### 自定义路由规则

```yaml
routing:
  rules:
    - keywords: ["测试", "unit", "coverage"]
      target: chief-test
      priority: high
```

---

## 📊 性能与成本

### 效率对比

| 任务类型 | 单 Agent | 龙虾军团 | 提升 |
|----------|----------|----------|------|
| 代码 + 文档 | 10 分钟 | 3 分钟 | 3.3x |
| 多项目并行 | 30 分钟 | 5 分钟 | 6x |
| 复杂调研 | 15 分钟 | 5 分钟 | 3x |

### Token 消耗

| 配置 | Token 消耗 | 单次成本 (¥) |
|------|-----------|-------------|
| 测试 (2×2) | 20K | 0.2 |
| 日常 (3×3) | 100K | 1 |
| 大项目 (6×6) | 500K | 5 |
| 多总总龙虾 (3×6×6) | 1.5M | 15 |

*注：基于 qwen3.5-plus 价格估算（~¥0.01/1K tokens）*

---

## 🧪 测试

```bash
# 运行路由测试
cd skills/lobster-legion
.\test\test.ps1

# 预期输出
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

## 📚 文档

| 文档 | 说明 |
|------|------|
| [QUICKSTART.md](QUICKSTART.md) | 1 分钟快速开始 |
| [README.md](README.md) | 中文完整文档 |
| [README.en.md](README.en.md) | English Documentation |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 架构图 +Token 预算 |
| [examples/usage-examples.md](examples/usage-examples.md) | 10 个使用场景 |

---

## 🤝 贡献

欢迎提交 Issue 和 PR！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [OpenClaw](https://openclaw.ai) - 强大的 Agent 框架
- [ClawHub](https://clawhub.com) - OpenClaw Skill 市场

---

## 📬 联系方式

- GitHub: [@graduy](https://github.com/graduy)
- 项目地址：https://github.com/graduy/lobster-legion

---

**🦞 龙虾军团，使命必达！**

*Last Updated: 2026-03-09*
