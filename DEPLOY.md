# 🦞 Lobster Legion - GitHub 发布指南

## 手动创建仓库步骤

由于 GitHub API 权限限制，请按以下步骤手动创建仓库：

### Step 1: 创建 GitHub 仓库

1. 打开 https://github.com/new
2. 填写以下信息：
   - **Repository name:** `lobster-legion`
   - **Description:** `Multi-Agent Collaboration Framework for OpenClaw - 多 Agent 协作框架`
   - **Visibility:** ✅ Public
   - **Initialize this repository with:** ❌ 不要勾选（我们已有本地代码）

3. 点击 **Create repository**

### Step 2: 推送代码

创建仓库后，在本地执行：

```bash
cd C:\Users\Grady\.openclaw\workspace\skills\lobster-legion

# 如果之前 add remote 失败，重新添加
git remote remove origin 2>$null
git remote add origin git@github.com:graduy/lobster-legion.git

# 推送代码
git push -u origin master
```

### Step 3: 验证推送

打开 https://github.com/graduy/lobster-legion 确认文件已上传。

---

## 自动发布（可选）

如果想自动发布，需要配置 GitHub Token：

### 方式 1: 使用 gh CLI

```bash
# 重新认证，确保有 public_repo 权限
gh auth logout
gh auth login
# 选择 GitHub.com
# 选择 HTTPS 或 SSH
# 确认勾选 public_repo 权限

# 创建并发布
gh repo create graduy/lobster-legion --public --source=. --remote=origin --push
```

### 方式 2: 使用 GitHub Actions

后续可以配置 GitHub Actions 自动发布到 ClawHub。

---

## 发布后步骤

### 1. 添加仓库链接到文档

更新 `README.md` 和 `README-CN.md` 中的链接（已配置好，无需修改）。

### 2. 发布到 ClawHub

```bash
cd skills/lobster-legion
clawhub publish
```

### 3. 通知用户

发布完成后，用户可以通过以下方式安装：

```bash
# 方式 1: ClawHub
clawhub install lobster-legion

# 方式 2: 手动克隆
git clone https://github.com/graduy/lobster-legion.git
cp -r lobster-legion ~/.openclaw/workspace/skills/
```

---

## 常见问题

### Q: git push 失败，提示权限错误
**A:** 检查 SSH key 是否已添加到 GitHub：
```bash
# 查看公钥
cat ~/.ssh/id_rsa.pub

# 添加到 GitHub: Settings → SSH and GPG keys → New SSH key
```

### Q: 想用 HTTPS 而不是 SSH
**A:** 修改 remote URL：
```bash
git remote set-url origin https://github.com/graduy/lobster-legion.git
git push -u origin master
```

### Q: 仓库已存在
**A:** 删除远程仓库重新创建，或推送到现有仓库：
```bash
git remote add origin https://github.com/graduy/lobster-legion.git
git push -u origin master
```

---

## 快速命令汇总

```bash
# 进入目录
cd C:\Users\Grady\.openclaw\workspace\skills\lobster-legion

# 查看远程仓库
git remote -v

# 推送代码
git push -u origin master

# 查看状态
git status

# 查看提交历史
git log --oneline
```

---

**🦞 发布成功记得告诉我！**
