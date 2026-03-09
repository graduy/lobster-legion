# 🦞 Lobster Legion - 层级架构图

## 完整架构

```
你 (用户)
│
└─── [总总龙虾 Coordinator] ───────────────┐
     │  (Level 1)                          │
     │ Max: 6 总龙虾                        │
     ├─→ [总龙虾 Chief A] ──→ 小龙虾 A1    │
     │   (Level 2)         │  小龙虾 A2    │
     │   Max: 6 小龙虾     │  ... A6       │
     │                     │               │
     ├─→ [总龙虾 Chief B] ──→ 小龙虾 B1    │
     │                     │  ... B6       │
     │                                     │
     ├─→ [总龙虾 Chief C] ──→ 小龙虾 C1    │
     │                     │  ... C6       │
     │                                     │
     ├─→ [总龙虾 Chief D] ──→ 小龙虾 D1    │
     │                     │  ... D6       │
     │                                     │
     ├─→ [总龙虾 Chief E] ──→ 小龙虾 E1    │
     │                     │  ... E6       │
     │                                     │
     └─→ [总龙虾 Chief F] ──→ 小龙虾 F1    │
                           │  ... F6       │
                                           │
└─── [总总龙虾 Coordinator 2] ─────────────┤
     │  (独立并行)                          │
     └─→ ... (同样最多 6×6=36 个 Agent)      │
                                           │
└─── [总总龙虾 Coordinator 3] ─────────────┘
     └─→ ...
```

## 层级限制

| 层级 | 角色 | 最大数量 | 说明 |
|------|------|----------|------|
| Level 1 | 总总龙虾 (Coordinator) | 无限制 | 由用户任务数决定 |
| Level 2 | 总龙虾 (Chief) | 6/Coordinator | 每个总总龙虾最多 6 个 |
| Level 3 | 小龙虾 (Worker) | 6/Chief | 每个总龙虾最多 6 个 |

## Token 预算

### 单任务最大 Token 消耗

```
1 个总总龙虾
├─ 6 个总龙虾 × 50,000 tokens = 300,000
   └─ 每个总龙虾 spawn 6 个小龙虾
      └─ 36 个小龙虾 × 50,000 tokens = 1,800,000

最大理论值：~2,100,000 tokens/任务
```

### 实际消耗 (经验值)

| 任务类型 | 实际消耗 | 说明 |
|----------|----------|------|
| 简单任务 | 10K-50K | 单总龙虾 + 1-2 小龙虾 |
| 中等任务 | 50K-200K | 2-3 总龙虾 + 各 2-3 小龙虾 |
| 复杂任务 | 200K-500K |  full 6×6 架构 |
| 多任务并行 | 500K-1M+ | 多个总总龙虾 |

### 预算控制配置

```yaml
subagents:
  tokenBudget:
    maxTokensPerAgent: 50000    # 每个 Agent 上限
    maxTokensPerTask: 500000    # 每任务总上限
    onBudgetExceeded: warn      # warn | stop
```

## 并发控制

### 推荐配置

| 场景 | maxChiefs | maxWorkers | maxConcurrent | 预估 Token |
|------|-----------|------------|---------------|------------|
| 测试 | 2 | 2 | 4 | <50K |
| 日常 | 3 | 3 | 9 | 100K-300K |
| 大项目 | 6 | 6 | 36 | 500K-1M |
| 极限 | 10 | 10 | 100 | 1M+ ⚠️ |

### 计算公式

```
最大并发 Agent 数 = maxChiefsPerCoordinator × maxWorkersPerChief

示例：
- 6 × 6 = 36 个 Agent 并行
- 每个 Agent 平均 50K tokens
- 总消耗 ≈ 1.8M tokens
```

## 最佳实践

### 1. 从小开始
```yaml
# 初始配置（安全测试）
maxChiefsPerCoordinator: 2
maxWorkersPerChief: 2
maxConcurrentAgents: 4
```

### 2. 按需调整
```yaml
# 简单文档任务
maxChiefsPerCoordinator: 1
maxWorkersPerChief: 2

# 复杂项目开发
maxChiefsPerCoordinator: 6
maxWorkersPerChief: 6
```

### 3. 监控 Token
- 查看每次任务的 token 统计
- 如果接近预算，减少并发数
- 定期 review config.yml

### 4. 任务分解策略
```
❌ 坏：一个大任务 spawn 36 个 Agent
✅ 好：分解为多个小任务，每任务 4-9 个 Agent
```

## 成本估算 (参考)

假设模型价格：~¥0.01/1K tokens (输入 + 输出平均)

| 配置 | Token 消耗 | 单次成本 | 100 次成本 |
|------|-----------|----------|-----------|
| 测试 (2×2) | 20K | ¥0.2 | ¥20 |
| 日常 (3×3) | 100K | ¥1 | ¥100 |
| 大项目 (6×6) | 500K | ¥5 | ¥500 |
| 多总总龙虾 (3×6×6) | 1.5M | ¥15 | ¥1500 |

**💡 省钱技巧：**
1. 用便宜的模型做小龙虾（如 qwen-turbo）
2. 总龙虾用好的模型（如 qwen3.5-plus）
3. 能串行就别并行
4. 设置严格的 token 预算

---

**🦞 理性 spawn，保护钱包！**
