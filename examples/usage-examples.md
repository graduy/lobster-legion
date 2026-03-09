# Lobster Legion - 使用示例

## 示例 1: 单任务 - 代码优化

**用户指令：**
```
帮我优化这段 Python 代码的性能
```

**龙虾军团处理流程：**
1. 总协调器分析任务 → 识别关键词"优化"、"Python"、"代码"
2. 路由规则匹配 → 分配到"代码专家"总龙虾
3. 代码专家 spawn 小龙虾执行代码分析
4. 返回优化建议

**配置：**
```yaml
routing:
  rules:
    - keywords: ["优化", "python", "代码"]
      target: chief-code
```

---

## 示例 2: 单任务 - 文档翻译

**用户指令：**
```
@文档专家 帮我把这个 README 翻译成英文
```

**龙虾军团处理流程：**
1. 检测到 @提及 → 直接路由到文档专家
2. 文档专家 spawn 小龙虾执行翻译
3. 返回翻译结果

**配置：**
```yaml
chiefs:
  - id: chief-doc
    name: 文档专家
    specialty: ["翻译", "文档", "写作"]
```

---

## 示例 3: 多任务并行

**用户指令：**
```
同时帮我：
1. 优化这个脚本的性能
2. 写一份使用说明文档
3. 调研一下有没有现成的库
```

**龙虾军团处理流程：**
1. 检测到多任务（1. 2. 3.）
2. 任务分解：
   - 任务 1 → 代码专家
   - 任务 2 → 文档专家
   - 任务 3 → 调研专家
3. 三个总龙虾并行执行
4. 汇总所有结果

**预期输出：**
```
🦞 龙虾军团任务报告

=== 代码专家 ===
优化建议：
1. 使用列表推导式代替循环
2. 添加缓存机制
3. ...

=== 文档专家 ===
使用说明文档：
# 项目名称
...

=== 调研专家 ===
现有库调研：
1. library-a - 功能类似，但...
2. library-b - 更轻量，支持...
```

---

## 示例 4: 指定总龙虾 + 知识库

**用户指令：**
```
@代码专家 记住这个编码规范，以后都用这个标准
```

**龙虾军团处理流程：**
1. 检测到 @提及 → 路由到代码专家
2. 识别"记住"关键词 → 保存到代码专家的知识库
3. 确认保存成功

**知识库保存：**
```
knowledge-base/chief-code/coding-standards/standard_20260309.md
```

---

## 示例 5: 基于历史知识的任务

**用户指令：**
```
@代码专家 按照之前的编码规范优化这个文件
```

**龙虾军团处理流程：**
1. 路由到代码专家
2. 代码专家检索知识库 → 找到之前保存的编码规范
3. 应用规范进行优化
4. 返回优化后的代码

---

## 示例 6: 完整项目开发

**用户指令：**
```
我要开发一个微信自动发送工具，帮我：
- 调研现有方案
- 设计架构
- 编写核心代码
- 写文档
```

**龙虾军团处理流程：**
```
总协调器
├─ 调研专家 → 调研现有微信自动化方案
├─ 代码专家 → 设计架构 + 编写核心代码
└─ 文档专家 → 编写 README 和使用文档
```

**输出：**
```
🦞 龙虾军团 - 微信自动发送工具开发报告

【调研专家】
现有方案：
1. wechaty - Node.js 库，功能强大但复杂
2. itchat - Python 库，已停止维护
3. 微信 PC 协议 - 需要逆向工程

【代码专家】
架构设计：
- 使用 PowerShell SendKeys 模拟输入
- 配置文件管理联系人和消息
- 命令行接口

核心代码：
[代码内容...]

【文档专家】
README.md:
# 微信自动发送工具
...
```

---

## 示例 7: 代码 Review 流程

**用户指令：**
```
帮我 review 这个 PR，检查代码质量和文档完整性
```

**龙虾军团处理流程：**
1. 识别"review"、"代码质量" → 代码专家
2. 识别"文档完整性" → 文档专家
3. 两个总龙虾并行 review
4. 汇总报告

**输出：**
```
🦞 Code Review 报告

【代码专家 - 代码质量】
✅ 优点：
- 代码结构清晰
- 变量命名规范

⚠️ 建议：
- 第 23 行：添加错误处理
- 第 45 行：可以提取为函数

【文档专家 - 文档完整性】
✅ 已有：
- README.md
- 函数注释

❌ 缺失：
- 安装说明
- 使用示例
- API 文档
```

---

## 示例 8: 配置自定义总龙虾

**场景：** 你需要一个"测试专家"总龙虾

**配置：**
```yaml
chiefs:
  - id: chief-test
    name: 测试专家
    agentId: main
    specialty: ["测试", "unit test", "pytest", "jest", "coverage"]
    workspace: ./workspaces/test
    maxSubAgents: 3

routing:
  rules:
    - keywords: ["测试", "unit", "coverage"]
      target: chief-test
```

**使用：**
```
@测试专家 帮我为这个项目写单元测试
```

---

## 示例 9: 知识库隔离

**场景：** 不同项目有不同的编码规范

**操作：**
```bash
# 项目 A 的规范
@代码专家 记住项目 A 的编码规范：[规范内容]

# 项目 B 的规范
@代码专家 记住项目 B 的编码规范：[规范内容]
```

**知识库结构：**
```
knowledge-base/
├── chief-code/
│   ├── project-a/
│   │   └── coding-standard.md
│   ├── project-b/
│   │   └── coding-standard.md
│   └── general/
│       └── common-standards.md
```

**使用：**
```
@代码专家 按照项目 A 的规范优化这个文件
```

---

## 示例 10: 批量任务处理

**用户指令：**
```
帮我处理这 10 个 Python 文件：
- 格式化代码
- 添加类型注解
- 生成文档字符串
```

**龙虾军团处理流程：**
1. 代码专家接收任务
2. 分解为 10 个子任务（每个文件一个）
3. spawn 10 个小龙虾并行处理
4. 汇总所有文件的结果

**配置：**
```yaml
chiefs:
  - id: chief-code
    maxSubAgents: 10  # 允许最多 10 个小龙虾并行
```

---

## 示例 11: 论文写作 - 完整流程

**用户指令：**
```
我要写一篇关于"大语言模型在多 Agent 协作中的应用"的学术论文，帮我：
- 调研相关文献
- 设计论文结构
- 撰写初稿
- 格式化参考文献
```

**龙虾军团处理流程：**
```
总协调器
├─ 调研专家 → 检索 ACL/EMNLP/NeurIPS 相关论文
├─ 代码专家 → 设计实验 + 编写代码
└─ 文档专家 → 撰写论文 + 格式化引用
```

**输出：**
```
🦞 龙虾军团 - 论文写作报告

【调研专家】
核心文献：
1. "Multi-Agent Collaboration with LLMs" (EMNLP 2025)
2. "LLM-Based Task Decomposition" (NeurIPS 2025)
3. "Distributed Agent Communication" (ACL 2025)

【代码专家】
实验设计：
- 对比实验：单 Agent vs 多 Agent
- 评估指标：任务完成率、Token 效率
- 数据集：AgentBench

【文档专家】
论文结构：
1. Introduction
2. Related Work
3. Methodology
4. Experiments
5. Conclusion

参考文献 (BibTeX):
@inproceedings{liu2025multi,
  title={Multi-Agent Collaboration with LLMs},
  author={Liu et al.},
  booktitle={EMNLP},
  year={2025}
}
```

---

## 示例 12: 论文写作 - 指定场景配置

**用户指令：**
```
@论文专家 使用论文写作模板，帮我写 Methodology 章节
```

**龙虾军团处理流程：**
1. 检测到 @提及 → 路由到论文专家总龙虾
2. 加载论文写作配置模板
3. 应用学术写作规范
4. 生成 Methodology 章节

**配置：**
```yaml
chiefs:
  - id: chief-paper
    name: 论文专家
    specialty: ["论文", "学术写作", "methodology", "experiment"]
    template: paper-writing
    workspace: ./workspaces/paper
    maxSubAgents: 5
```

**输出：**
```
🦞 论文专家 - Methodology 章节

## 3. Methodology

### 3.1 Framework Overview
Our Lobster Legion framework employs a hierarchical multi-agent...

### 3.2 Task Routing Mechanism
The routing mechanism uses keyword matching with priority...

### 3.3 Knowledge Isolation
Each chief agent maintains an independent knowledge base...
```

---

## 示例 13: 论文写作 - 引用管理

**用户指令：**
```
@论文专家 记住这些参考文献，后续写作中使用：
1. "Attention Is All You Need" - Vaswani et al. 2017
2. "Language Models are Few-Shot Learners" - Brown et al. 2020
```

**龙虾军团处理流程：**
1. 路由到论文专家
2. 识别"记住"关键词 → 保存到引用知识库
3. 生成 BibTeX 格式
4. 确认保存成功

**引用知识库保存：**
```
knowledge-base/chief-paper/references/paper-writing.bib
```

**后续使用：**
```
@论文专家 在 Related Work 中引用之前保存的文献
```

---

## 最佳实践

### 1. 任务描述要清晰
❌ 模糊：`帮我弄一下这个`
✅ 清晰：`帮我优化这个 Python 函数的性能`

### 2. 善用@提及
- 明确指定总龙虾：`@文档专家 写个 README`
- 避免路由错误

### 3. 多任务用列表格式
```
同时帮我：
1. 任务 A
2. 任务 B
3. 任务 C
```

### 4. 知识库及时保存
重要决策、规范、约定及时让总龙虾记住：
```
@代码专家 记住：我们项目使用 4 空格缩进
```

### 5. 合理配置 maxSubAgents
- 小任务：3-5 个小龙虾
- 大任务：10+ 个小龙虾
- 注意资源限制

---

## 常见问题

**Q: 任务路由错了怎么办？**
A: 使用 @ 明确指定总龙虾，或调整 config.yml 中的路由规则关键词

**Q: 怎么让总龙虾记住东西？**
A: 使用"记住"、"保存"等关键词，总龙虾会自动保存到知识库

**Q: 最多能同时跑多少个任务？**
A: 取决于 `maxConcurrentTasks` 配置（默认 5）和系统资源

**Q: 知识库能存多少东西？**
A: 本地文件系统，理论上无限制，建议定期整理

---

**🦞 龙虾军团，使命必达！**
