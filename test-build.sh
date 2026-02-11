#!/bin/bash

# 测试构建脚本 - 用于本地验证
# 此脚本会清理之前的构建并重新构建，模拟 CI/CD 环境

set -e

echo "================================================"
echo "本地构建测试"
echo "================================================"
echo ""

# 1. 清理之前的构建
echo "→ 清理之前的构建..."
rm -rf build/
rm -f 深入理解Linux_Folio.pdf
rm -f build_output.log
echo "✓ 清理完成"
echo ""

# 2. 验证项目结构
echo "→ 验证项目结构..."
if [ ! -f "main.tex" ]; then
    echo "✗ 错误: main.tex 不存在"
    exit 1
fi

if [ ! -d "chapters" ]; then
    echo "✗ 错误: chapters 目录不存在"
    exit 1
fi

if [ ! -d "appendix" ]; then
    echo "✗ 错误: appendix 目录不存在"
    exit 1
fi

echo "✓ 项目结构正常"
echo "  - main.tex: $(wc -l < main.tex) 行"
echo "  - chapters: $(ls chapters/*.tex 2>/dev/null | wc -l) 个文件"
echo "  - appendix: $(ls appendix/*.tex 2>/dev/null | wc -l) 个文件"
echo ""

# 3. 检查必要的工具
echo "→ 检查编译工具..."
if ! command -v lualatex &> /dev/null; then
    echo "✗ 错误: 未找到 lualatex"
    echo "  请安装 TeX Live: sudo apt-get install texlive-full"
    exit 1
fi

if ! command -v makeindex &> /dev/null; then
    echo "✗ 错误: 未找到 makeindex"
    echo "  请安装 TeX Live: sudo apt-get install texlive-full"
    exit 1
fi

echo "✓ 编译工具已安装"
echo "  - lualatex: $(lualatex --version | head -1)"
echo ""

# 4. 运行构建
echo "→ 开始构建 PDF..."
echo "  (这可能需要几分钟，请耐心等待...)"
echo ""

if ./build.sh 2>&1 | tee build_output.log; then
    echo ""
    echo "✓ 构建脚本执行完成"
else
    echo ""
    echo "✗ 构建脚本执行失败"
    echo ""
    echo "=== 查看错误日志 ==="
    if [ -f "build/main.log" ]; then
        echo "最后 30 行编译日志:"
        tail -30 build/main.log
    fi
    exit 1
fi

echo ""

# 5. 验证输出
echo "→ 验证构建结果..."
if [ ! -f "深入理解Linux_Folio.pdf" ]; then
    echo "✗ 错误: PDF 文件未生成"
    echo ""
    echo "=== 调试信息 ==="
    echo "build 目录内容:"
    ls -lh build/
    echo ""
    if [ -f "build/main.log" ]; then
        echo "最后 30 行编译日志:"
        tail -30 build/main.log
    fi
    exit 1
fi

PDF_SIZE=$(du -h 深入理解Linux_Folio.pdf | cut -f1)
PDF_PAGES=$(pdfinfo 深入理解Linux_Folio.pdf 2>/dev/null | grep "Pages:" | awk '{print $2}')

echo "✓ PDF 生成成功"
echo "  - 文件: 深入理解Linux_Folio.pdf"
echo "  - 大小: $PDF_SIZE"
if [ -n "$PDF_PAGES" ]; then
    echo "  - 页数: $PDF_PAGES"
fi
echo ""

# 6. 检查日志中的错误和警告
echo "→ 检查编译日志..."
if [ -f "build/main.log" ]; then
    ERRORS=$(grep -i "^!" build/main.log | wc -l)
    WARNINGS=$(grep -i "Warning" build/main.log | wc -l)

    echo "  - 错误数: $ERRORS"
    echo "  - 警告数: $WARNINGS"

    if [ $ERRORS -gt 0 ]; then
        echo ""
        echo "⚠ 发现编译错误:"
        grep -i "^!" build/main.log | head -5
    fi

    if [ $WARNINGS -gt 10 ]; then
        echo ""
        echo "⚠ 发现较多警告 ($WARNINGS 个)"
        echo "  前 5 个警告:"
        grep -i "Warning" build/main.log | head -5
    fi
fi
echo ""

# 7. 总结
echo "================================================"
echo "测试完成"
echo "================================================"
echo ""
echo "✓ 构建成功！PDF 文件已生成"
echo ""
echo "接下来你可以:"
echo "  1. 查看 PDF: open 深入理解Linux_Folio.pdf"
echo "  2. 提交更改: git add . && git commit -m 'Update'"
echo "  3. 推送到 GitHub: git push origin main"
echo "  4. 创建发布标签: git tag -a v1.0.0 -m 'Release v1.0.0' && git push origin v1.0.0"
echo ""
