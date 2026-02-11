# CI/CD 配置说明

本文档介绍项目的持续集成/持续部署（CI/CD）配置。

## 概述

本项目使用 **GitHub Actions** 自动构建 PDF 文件并发布到 GitHub Releases。

## 功能特性

### ✅ 自动化构建

- 每次推送到 `main` 或 `master` 分支时自动构建
- Pull Request 时自动构建验证
- 支持手动触发构建

### ✅ 产物保存

- 构建的 PDF 文件保存为 Artifact（30 天保留期）
- 构建日志保存为 Artifact（7 天保留期）
- 便于调试和下载

### ✅ 自动发布

- 推送版本标签（如 `v1.0.0`）时自动创建 Release
- PDF 文件自动附加到 Release
- 无需手动上传

### ✅ 详细日志

- 项目结构验证
- 构建过程实时输出
- 错误和警告检测
- 完整的调试信息

## 工作流程

### 1. 日常开发

```bash
# 1. 修改内容
vim chapters/chapter01.tex

# 2. 提交更改
git add chapters/chapter01.tex
git commit -m "Update chapter 1"

# 3. 推送到 GitHub
git push origin main

# 4. GitHub Actions 自动构建
# 访问 Actions 页面查看进度
```

### 2. 发布新版本

```bash
# 1. 确保所有更改已提交
git status

# 2. 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0

主要更新：
- 完成所有章节内容
- 修复已知错误
- 优化排版"

# 3. 推送标签
git push origin v1.0.0

# 4. GitHub Actions 自动：
#    - 构建 PDF
#    - 创建 Release
#    - 上传 PDF 到 Release
```

### 3. 手动触发构建

1. 访问仓库的 Actions 页面
2. 选择 "Build PDF" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支
5. 点击 "Run workflow" 开始构建

## Workflow 配置

### 文件位置

```
.github/workflows/build-pdf.yml
```

### 触发条件

```yaml
on:
  push:
    branches: [main, master]    # 推送到主分支
  pull_request:
    branches: [main, master]    # Pull Request
  workflow_dispatch:            # 手动触发
```

### 构建步骤

1. **检出代码**: 使用 `actions/checkout@v4`
2. **安装 TeX Live**: 安装完整的 LaTeX 环境和中文字体
3. **验证项目结构**: 检查必要的文件和目录
4. **构建 PDF**: 运行 `build.sh` 脚本
5. **检查结果**: 验证 PDF 文件是否生成
6. **上传 Artifact**: 保存 PDF 和日志文件
7. **创建 Release**: (仅在推送标签时) 发布到 GitHub Releases

### 发布条件

```yaml
if: startsWith(github.ref, 'refs/tags/v')
```

只有当推送的标签以 `v` 开头时才会创建 Release。

## 调试和故障排除

### 查看构建日志

1. 访问 GitHub 仓库的 Actions 页面
2. 点击对应的工作流运行
3. 展开各个步骤查看详细日志

### 下载 Artifact

1. 在工作流运行页面底部找到 "Artifacts" 区域
2. 下载 `深入理解Linux_Folio-{commit}` (PDF 文件)
3. 下载 `build-logs-{commit}` (构建日志)

### 本地测试

在推送前本地测试构建：

```bash
# 运行测试脚本
./test-build.sh

# 或手动构建
./build.sh

# 检查生成的 PDF
ls -lh 深入理解Linux_Folio.pdf
```

### 常见错误

#### 1. PDF 未生成

**症状**: Workflow 运行完成但没有 PDF 产物

**可能原因**:
- LaTeX 编译错误
- 缺少必要的包或字体
- 文件路径错误

**解决方法**:
1. 查看 "Check build results" 步骤的输出
2. 下载 build-logs artifact 查看详细日志
3. 在本地运行 `./test-build.sh` 复现问题

#### 2. Release 未创建

**症状**: 推送标签后没有创建 Release

**可能原因**:
- 标签名不以 `v` 开头
- 构建步骤失败
- GitHub token 权限不足

**解决方法**:
1. 确保标签名格式正确: `v1.0.0`
2. 检查 build job 是否成功
3. 查看 release job 的日志

#### 3. 字体缺失

**症状**: PDF 中中文显示异常或编译失败

**解决方法**:
在 workflow 中已安装以下字体包：
- `fonts-noto-cjk`
- `fonts-wqy-microhei`
- `fonts-wqy-zenhei`

如需其他字体，编辑 `.github/workflows/build-pdf.yml`

#### 4. 构建超时

**症状**: 构建运行很长时间后超时

**解决方法**:
1. 检查是否有无限循环的编译错误
2. 减少编译次数（当前是 3 次）
3. 优化 LaTeX 代码

## 进阶配置

### 自定义 Release 描述

编辑 `.github/workflows/build-pdf.yml` 中的 release 步骤：

```yaml
- name: Create Release
  uses: softprops/action-gh-release@v1
  with:
    body: |
      ## 自定义发布说明

      这里可以添加更详细的发布说明
      - 新增功能
      - 修复的问题
      - 已知问题
```

### 添加构建徽章

在 README.md 中添加：

```markdown
![Build PDF](https://github.com/<username>/<repo>/workflows/Build%20PDF/badge.svg)
```

### 修改 Artifact 保留期

编辑 workflow 文件：

```yaml
- name: Upload PDF as artifact
  uses: actions/upload-artifact@v4
  with:
    retention-days: 90  # 改为 90 天
```

### 添加邮件通知

在 workflow 末尾添加：

```yaml
- name: Send notification
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Build failed for ${{ github.repository }}
    body: Build failed. Check ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
    to: your-email@example.com
```

## 性能优化

### 缓存 TeX Live

为了加速构建，可以缓存 TeX Live 安装：

```yaml
- name: Cache TeX Live
  uses: actions/cache@v3
  with:
    path: /usr/share/texlive
    key: texlive-${{ runner.os }}
```

### 并行构建

如果有多个独立的文档需要构建，可以使用矩阵策略：

```yaml
strategy:
  matrix:
    document: [main, appendix]
```

## 安全性

### Secrets 管理

如果需要访问私有资源，使用 GitHub Secrets：

```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### 权限控制

Workflow 默认有以下权限：
- `GITHUB_TOKEN`: 用于创建 Release
- 只读访问代码仓库

## 监控和维护

### 定期检查

- 每月检查 workflow 运行状态
- 更新 Actions 版本（如 `@v4` -> `@v5`）
- 测试新版本的 TeX Live

### 日志分析

使用 GitHub Actions 的 Insights 功能查看：
- 构建成功率
- 平均构建时间
- 资源使用情况

## 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [actions/checkout](https://github.com/actions/checkout)
- [actions/upload-artifact](https://github.com/actions/upload-artifact)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)

## 获取帮助

如遇到问题：

1. 查看本文档的"故障排除"部分
2. 搜索 GitHub Actions 社区讨论
3. 提交 Issue 到项目仓库
