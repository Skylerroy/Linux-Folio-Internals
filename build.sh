#!/bin/bash

# folio书籍编译脚本

set -e

echo "开始编译深入理解Linux Folio书籍..."

# 检查必要的工具
echo "检查编译环境..."
if ! command -v lualatex &> /dev/null; then
    echo "错误: 未找到 lualatex，请安装 TeX Live"
    exit 1
fi

if ! command -v makeindex &> /dev/null; then
    echo "错误: 未找到 makeindex，请安装 TeX Live"
    exit 1
fi

# 创建必要的目录
echo "创建目录结构..."
mkdir -p build
mkdir -p build/chapters
mkdir -p build/appendix

# 复制文件到构建目录
echo "准备编译文件..."
cp main.tex build/
cp -r chapters/*.tex build/chapters/
cp -r appendix/*.tex build/appendix/

# 进入构建目录
cd build

# 第一次编译（生成aux文件）
echo "第一次编译..."
lualatex -interaction=nonstopmode main.tex || {
    echo "警告: 第一次编译出现错误，但继续执行..."
    echo "查看 build/main.log 了解详细信息"
}

# 生成索引（如果 idx 文件存在）
if [ -f "main.idx" ]; then
    echo "生成索引..."
    makeindex main.idx || {
        echo "警告: 索引生成失败，但继续执行..."
    }
else
    echo "跳过索引生成（main.idx 不存在）"
fi

# 第二次编译（包含索引和目录）
echo "第二次编译..."
lualatex -interaction=nonstopmode main.tex || {
    echo "警告: 第二次编译出现错误，但继续执行..."
}

# 第三次编译（最终版本，确保目录完整）
echo "第三次编译..."
lualatex -interaction=nonstopmode main.tex || {
    echo "警告: 第三次编译出现错误"
}

# 检查是否成功生成PDF
if [ -f "main.pdf" ]; then
    echo "编译成功！"
    echo "生成的PDF文件: build/main.pdf"
    echo "文件大小: $(du -h main.pdf | cut -f1)"
    
    # 复制到上级目录
    cp main.pdf ../深入理解Linux_Folio.pdf
    echo "PDF已复制到: ../深入理解Linux_Folio.pdf"
else
    echo "编译失败，请检查错误信息"
    exit 1
fi

# 清理临时文件（保留 log 文件以便调试）
echo "清理临时文件..."
rm -f *.aux *.toc *.lof *.lot *.idx *.ind *.ilg *.out

echo "编译完成！"
echo "日志文件保存在: build/*.log"