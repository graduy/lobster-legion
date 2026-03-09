# 🦞 Lobster Legion - 快速启动

## 1 分钟快速开始

### Step 1: 安装
```bash
cd skills/lobster-legion
```

### Step 2: 配置（已完成）
配置文件 `config.yml` 已预配置 3 个总龙虾：
- 🦞 代码专家
- 🦞 文档专家  
- 🦞 调研专家

### Step 3: 使用

**直接使用（在 OpenClaw 中）：**
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

## 目录结构

```
lobster-legion/
├── config.yml              # 配置文件（已配置）
├── config.example.yml      # 配置模板
├── README.md               # 完整文档
├── SKILL.md               # Skill 描述
├── src/                   # 核心代码
│   ├── coordinator.ps1    # 总协调器
│   ├── chief-lobster.ps1  # 总龙虾模板
│   ├── router.ps1         # 任务路由
│   └── knowledge-base.ps1 # 知识库管理
├── test/                  # 测试脚本
│   └── test.ps1           # 路由测试（已验证通过）
├── examples/              # 使用示例
│   └── usage-examples.md  # 10 个使用场景
├── workspaces/            # 工作空间（自动生成）
└── knowledge-base/        # 知识库（自动生成）
```

---

## 自定义配置

### 添加新的总龙虾

编辑 `config.yml`：
```yaml
chiefs:
  - id: chief-test
    name: 测试专家
    agentId: main
    specialty: ["测试", "unit test", "pytest"]
    workspace: ./workspaces/test
    maxSubAgents: 3
```

### 调整路由规则

```yaml
routing:
  rules:
    - keywords: ["测试", "unit"]
      target: chief-test
```

---

## 测试

```bash
# 运行路由测试
.\test\test.ps1
```

---

## 下一步

1. 查看 `examples/usage-examples.md` - 10 个使用场景
2. 查看 `README.md` - 完整文档
3. 开始使用！🦞

---

**🦞 龙虾军团，使命必达！**
