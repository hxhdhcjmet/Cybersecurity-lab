LATEXMK ?= latexmk

SOURCE = report.tex
BUILD_DIR = build
DIST_DIR = dist
PDF = $(DIST_DIR)/report.pdf

.PHONY: all clean distclean

all: $(PDF)

ifeq ($(OS),Windows_NT)
$(PDF): $(SOURCE) lab1report.cls references.bib content/task1.tex content/task2.tex content/task3.tex
	powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '$(BUILD_DIR)','$(DIST_DIR)' | Out-Null"
	$(LATEXMK) -xelatex -interaction=nonstopmode -halt-on-error -outdir=$(BUILD_DIR) $(SOURCE)
	powershell -NoProfile -Command "Copy-Item '$(BUILD_DIR)/report.pdf' '$(PDF)' -Force"

clean:
	powershell -NoProfile -Command "Remove-Item '$(BUILD_DIR)' -Recurse -Force -ErrorAction SilentlyContinue"

distclean: clean
	powershell -NoProfile -Command "Remove-Item '$(DIST_DIR)' -Recurse -Force -ErrorAction SilentlyContinue"

else

$(PDF): $(SOURCE) lab1report.cls references.bib content/task1.tex content/task2.tex content/task3.tex
	mkdir -p $(BUILD_DIR) $(DIST_DIR)
	$(LATEXMK) -xelatex -interaction=nonstopmode -halt-on-error -outdir=$(BUILD_DIR) $(SOURCE)
	cp $(BUILD_DIR)/report.pdf $(PDF)

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf $(DIST_DIR)

endif