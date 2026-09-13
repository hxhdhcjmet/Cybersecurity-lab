# Lab 1 实验报告

本目录是《网络基础实验》的 XeLaTeX 报告模板。`lab1report.cls` 负责版式，`report.tex` 负责封面和公共章节，三个实验任务分别位于 `content/task1.tex`、`content/task2.tex` 和 `content/task3.tex`。

## 编译和清理

在本目录执行：

```powershell
make
```

Makefile 使用 XeLaTeX 和 Biber 编译，过程文件放入 `build/`，最终 PDF 复制到 `dist/report.pdf`。

```powershell
make clean       # 删除编译过程文件，保留最终 PDF
make distclean   # 删除编译过程文件和最终 PDF
```

如果系统没有 `make`，可直接运行：

```powershell
latexmk -xelatex -outdir=build report.tex
```

## 填写约定

- 封面信息在 `report.tex` 开头修改。
- 任务一、二、三的正文分别写入 `content/task1.tex`、`content/task2.tex`、`content/task3.tex`。
- 图片放入 `figures/`，正文使用 `\includegraphics` 或 `\labfigure` 插入。
- 代码使用 `lstlisting` 或 `\lstinputlisting`，保留命令、参数、输出和必要注释。
- 直接引用使用 `\labquote[页码]{references.bib 中的键}`，模板生成带页码的圆圈数字脚注；实际引用或参考过的资料都应在 `references.bib` 中建立真实条目。
- `\todo{...}` 仅用于模板占位，提交前应全部替换或删除。

模板对应的硬性版式：A4；上下左右 2.5 cm；正文宋体小四、首行缩进 2 字符、固定 20 磅、段前段后 0；一级/二级/三级标题黑体三号/小三/四号，段前段后 0.5 行；页码底部居中。
