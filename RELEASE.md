# 版本发布指南

本文档说明如何使用 Git 标签（Tag）自动发布新版本。

## 快速开始

### 1. 创建版本标签

```bash
# 创建带注释的标签（推荐）
git tag -a v1.0.0 -m "Release version 1.0.0 - 初始发布版本"

# 推送标签到远程仓库
git push origin v1.0.0
```

### 2. 自动化流程

推送标签后，GitHub Actions 会自动：

1. ✅ 检出代码
2. ✅ 安装 TeX Live 环境
3. ✅ 运行构建脚本生成 PDF
4. ✅ 创建 GitHub Release
5. ✅ 上传 PDF 到 Release

整个过程大约需要 5-10 分钟。

### 3. 查看发布结果

访问仓库的 Releases 页面：
```
https://github.com/<your-username>/<repo-name>/releases
```

## 版本号规范

建议使用 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

- **主版本号**：进行不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 示例

```bash
# 主要版本发布
git tag -a v1.0.0 -m "Release version 1.0.0 - 首个正式版本"

# 功能更新
git tag -a v1.1.0 -m "Release version 1.1.0 - 新增第9章内容"

# 错误修正
git tag -a v1.1.1 -m "Release version 1.1.1 - 修复第3章代码示例错误"

# 推送所有标签
git push origin --tags
```

## 完整发布流程

### 准备发布

1. **确保所有更改已提交**
   ```bash
   git status
   git add .
   git commit -m "Prepare for release v1.0.0"
   ```

2. **推送到主分支**
   ```bash
   git push origin main
   ```

3. **确认构建成功**
   - 访问 GitHub Actions 页面
   - 确认最新的构建工作流成功完成

### 创建发布

4. **创建版本标签**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0

   主要更新：
   - 完成前8章内容
   - 添加3个附录
   - 优化代码示例
   - 改进排版和格式"
   ```

5. **推送标签**
   ```bash
   git push origin v1.0.0
   ```

6. **验证发布**
   - 等待 GitHub Actions 完成
   - 检查 Releases 页面
   - 下载并验证 PDF 文件

## 管理标签

### 查看所有标签

```bash
# 列出所有标签
git tag

# 查看标签详细信息
git show v1.0.0
```

### 删除标签

```bash
# 删除本地标签
git tag -d v1.0.0

# 删除远程标签
git push origin --delete v1.0.0
```

**注意**：删除已发布的标签会影响 Release，请谨慎操作。

### 修改标签

如果需要修改已推送的标签：

```bash
# 1. 删除本地和远程标签
git tag -d v1.0.0
git push origin --delete v1.0.0

# 2. 重新创建标签
git tag -a v1.0.0 -m "Updated release message"

# 3. 强制推送（需要谨慎）
git push origin v1.0.0
```

## 发布版本建议

### 预发布版本

对于测试版本，可以使用预发布标记：

```bash
# Alpha 版本
git tag -a v1.0.0-alpha.1 -m "Alpha release for testing"

# Beta 版本
git tag -a v1.0.0-beta.1 -m "Beta release for review"

# 候选版本
git tag -a v1.0.0-rc.1 -m "Release candidate 1"
```

### 发布频率建议

- **主要版本**：内容有重大更新或重构时
- **次要版本**：添加新章节、新功能时（如每季度）
- **修订版本**：修复错误、改进内容时（随时）

## 自动化说明

### Workflow 触发条件

GitHub Actions workflow 在以下情况触发：

1. **所有推送和 PR**：构建 PDF 并上传为 Artifact
2. **推送 `v*` 标签**：额外创建 GitHub Release

### Release 内容

自动创建的 Release 包含：

- **标题**：标签名称（如 v1.0.0）
- **描述**：自动生成的发布说明和提交信息
- **附件**：生成的 PDF 文件（深入理解Linux_Folio.pdf）

### 自定义 Release 描述

如果需要手动编辑 Release 描述：

1. 等待自动 Release 创建完成
2. 访问 Releases 页面
3. 点击 "Edit" 按钮
4. 修改描述内容
5. 保存更改

## 故障排除

### 构建失败

如果 GitHub Actions 构建失败：

1. 查看 Actions 页面的错误日志
2. 确认本地可以成功构建：`./build.sh`
3. 检查是否有语法错误或缺失文件
4. 修复问题后重新推送

### Release 未创建

如果标签推送后没有创建 Release：

1. 确认标签名以 `v` 开头（如 v1.0.0）
2. 检查 GitHub Actions 权限设置
3. 查看 workflow 运行日志
4. 确认 `release` job 是否执行

### 手动创建 Release

如果自动化失败，可以手动创建：

1. 在 GitHub 仓库页面点击 "Releases"
2. 点击 "Draft a new release"
3. 选择或创建标签
4. 上传本地构建的 PDF 文件
5. 发布 Release

## 最佳实践

1. ✅ **使用有意义的标签消息**：清楚描述版本更新内容
2. ✅ **遵循版本规范**：使用语义化版本号
3. ✅ **测试后再发布**：确保本地构建成功
4. ✅ **保持更新日志**：在 CHANGELOG.md 中记录变更
5. ✅ **定期发布**：根据更新频率合理安排版本发布

## 相关资源

- [语义化版本规范](https://semver.org/lang/zh-CN/)
- [Git 标签文档](https://git-scm.com/book/zh/v2/Git-基础-打标签)
- [GitHub Releases 指南](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
