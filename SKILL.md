# Lobster Legion - 多 Agent 协作框架

## 描述
多 Agent 任务分发与协作框架。支持配置多个"总龙虾"(协调 Agent)，每个总龙虾可指挥多个"小龙虾"(子 Agent)，实现任务自动分解、分配、执行和结果汇总。

## 触发条件
用户提到以下关键词时激活：
- "龙虾军团" / "lobster legion"
- "多 agent 协作" / "multi-agent"
- "任务分发" / "task distribution"
- "总龙虾" / "chief lobster"
- 配置了龙虾军团后，根据任务路由规则自动触发

## 核心功能
1. **总龙虾管理** - 配置多个协调 Agent，每个有独立专长和知识库
2. **任务路由** - 根据任务类型/关键词自动分配给合适的总龙虾
3. **子 Agent 协调** - 总龙虾可 spawn 多个子 Agent 并行执行
4. **结果汇总** - 自动收集各 Agent 结果，统一汇报
5. **知识库隔离** - 每个总龙虾有独立的知识库/工作空间
6. **引用管理** - 支持学术论文写作的参考文献管理（BibTeX 格式）
7. **论文写作模板** - 内置标准论文结构模板（Abstract/Intro/Methodology 等）

## 配置方式
1. 复制 `config.example.yml` 为 `config.yml`
2. 配置总龙虾数量、专长、agentId
3. 配置任务路由规则
4. 配置知识库路径
5. （可选）配置论文写作模板和引用格式

## 依赖
- OpenClaw `sessions_spawn` 工具
- OpenClaw `subagents` 工具
- 可选：Feishu 文档 API（用于知识库管理）

## 文件结构
```
lobster-legion/
├── SKILL.md                 # 本文件
├── README.md                # 用户使用文档
├── config.example.yml       # 配置模板（含论文写作配置）
├── src/
│   ├── coordinator.ps1      # 总协调器（总总龙虾）
│   ├── chief-lobster.ps1    # 总龙虾模板
│   ├── router.ps1           # 任务路由
│   └── knowledge-base.ps1   # 知识库管理（含引用管理）
├── examples/
│   └── usage-examples.md    # 使用示例（含论文写作案例）
└── test/
    └── test.ps1             # 测试脚本
```

## 版本
v0.1.0 - 初始框架
v0.2.0 - 新增论文写作场景、引用管理功能
