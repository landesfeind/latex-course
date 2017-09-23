#!/usr/bin/make
###############
## Makefile to generate Slides for the LaTeX course
##   by Manuel Landesfeind <manuel@landesfeind.de>
###############

# Set variables
CWD=$(shell pwd)
tex=presentation
pdflatex = pdflatex -interaction nonstopmode -halt-on-error -file-line-error
echo=echo
TEXS=$(shell find -name '*.tex' | grep -v hausarbeiten)
CODE_TEXS = $(shell find code -name '*.tex' | grep -v '\-fail.tex')
CODE_PDFS = $(patsubst %.tex, %.pdf, $(CODE_TEXS))
IMAGE_SVGS = $(shell find images -name '*.svg')
IMAGE_PDFS = $(patsubst %.svg, %.pdf, $(IMAGE_SVGS))
SECTIONS = $(shell grep 'input{' slides/presentation.tex | cut -d \{ -f 2 | cut -d \} -f 1 | sed 's/^/section_/')

.SUFFIXES:

export TEXINPUTS := ${CWD}/slides:${CWD}/lib:${CWD}/images/:${CWD}/code/:${TEXINPUTS}
export BIBINPUTS := ${CWD}/code/:${BIBINPUTS}

# Defines a command to generate a PDF from the TeX file
generate_pdf = \
	cd $(2) && \
    ${pdflatex} $(1) || exit; \
	bibtex $(basename $(1)); \
	${pdflatex} $(1); \
	${pdflatex} $(1) 

# Pattern to generate the code examples _without_ preamble
#../code/%-np.pdf: ../code/%-np.tex images latex-course.sty
code/%-np.pdf: code/%-np.tex images
	echo Compiling code example $@
	$(eval TMPDIR := $(shell mktemp -d))
	mkdir -p $(TMPDIR)
	cp $< $(TMPDIR)/$(notdir $<)
	sed -i '2 i \\\pagestyle{empty}' $(TMPDIR)/$(notdir $<)        # Insert line to supress page numbers
	sed -i '/maketitle/a \\\thispagestyle{empty}' $(TMPDIR)/$(notdir $<)        # Insert line to supress page numbers
	$(call generate_pdf,$(TMPDIR)/$(notdir $<),$(TMPDIR))
	cp $(TMPDIR)/$(addsuffix .pdf, $(basename $(notdir $<))) $@
	pdfcrop --margins 5 $@ $(patsubst %.pdf, %-crop.pdf, $@)
	rm -rf $(TMPDIR)

# Pattern to generate code examples _with_ preamble
#../code/%.pdf: ../code/%.tex images latex-course.sty
code/%.pdf: code/%.tex images
	${echo} Compiling code example $@
	$(eval TMPDIR := $(shell mktemp -d))
	mkdir -p $(TMPDIR)
	${echo} '\\documentclass{article}' > $(TMPDIR)/$(notdir $<)
	grep -F '\usepackage' lib/latex-course.sty >> $(TMPDIR)/$(notdir $<)
	# Copy the required packages
	grep -F  '\usepackage' $< >> $(TMPDIR)/$(notdir $<) || true
	${echo} '\\pagestyle{empty}' >> $(TMPDIR)/$(notdir $<)
	${echo} '\\setlength\parindent{0pt}' >> $(TMPDIR)/$(notdir $<)
	${echo} '\\begin{document}' >> $(TMPDIR)/$(notdir $<)
	# Copy the code (without packages)
	grep -F -v '\usepackage' $< >> $(TMPDIR)/$(notdir $<)
	${echo} '\\end{document}' >> $(TMPDIR)/$(notdir $<)
	$(call generate_pdf,$(TMPDIR)/$(notdir $<),$(TMPDIR))
	cp $(TMPDIR)/$(addsuffix .pdf, $(basename $(notdir $<))) $@
	pdfcrop --margins 5 $@ $(patsubst %.pdf, %-crop.pdf, $@)
	rm -rf $(TMPDIR)

# Transform SVGs to PDFs using Inkscape
images/%.pdf: images/%.svg
	inkscape --export-area-drawing --export-pdf=$@ $< || exit 1

section_%: slides/%.tex images code_examples
	echo Generating section for $<
	$(eval TMPDIR := $(shell mktemp -d))
	mkdir -p $(TMPDIR)
	${echo} '\documentclass[presentation.tex]{subfiles}' > $(TMPDIR)/$(notdir $<)
	${echo} '\begin{document}' >> $(TMPDIR)/$(notdir $<)
	cat $< >> $(TMPDIR)/$(notdir $<)
	${echo} '\end{document}' >> $(TMPDIR)/$(notdir $<)
	$(call generate_pdf, $(TMPDIR)/$(basename $(notdir $<)), $(TMPDIR));
	mv $(TMPDIR)/$(addsuffix .pdf, $(basename $(notdir $<))) $(addsuffix .pdf, $@)
	rm -rf $(TMPDIR)

.PHONY: clean

all: sections slides wide notes

slides: $(TEXS) code_examples images
	@echo '>>> Creating normal slides'
	$(eval TMPDIR := $(shell mktemp -d))
	@cp slides/${tex}.tex $(TMPDIR)/${tex}_Slides.tex && \
		$(call generate_pdf,${tex}_Slides,$(TMPDIR))
	cp $(TMPDIR)/${tex}_Slides.pdf .
	@rm -rf $(TMPDIR)

wide: images code_examples $(TEXS) 
	@echo '>>> Creating widescreen slides'
	$(eval TMPDIR := $(shell mktemp -d))
	sed s/9pt/9pt,aspectratio=169/ slides/${tex}.tex > $(TMPDIR)/${tex}_Wide.tex && \
		$(call generate_pdf,$(TMPDIR)/${tex}_Wide,$(TMPDIR))
	cp $(TMPDIR)/${tex}_Wide.pdf .
	rm -rf $(TMPDIR)

sections: $(SECTIONS)

notes: $(TEXS) code_examples images
	@echo '>>> Creating notes'
	$(eval TMPDIR := $(shell mktemp -d))
	sed s/9pt/9pt,shownotes/ slides/${tex}.tex > $(TMPDIR)/${tex}_Notes.tex && \
		$(call generate_pdf,$(TMPDIR)/${tex}_Notes,$(TMPDIR))
	cp $(TMPDIR)/${tex}_Notes.pdf .
	rm -rf $(TMPDIR)

exercises: 
	@echo '>>> Creating exercises'
	$(eval TMPDIR := $(shell mktemp -d))
	@cp slides/exercises.tex $(TMPDIR)
	$(call generate_pdf, exercises, $(TMPDIR))
	cp $(TMPDIR)/exercises.pdf .
	rm -rf $(TMPDIR)

homework: 
	$(eval TMPDIR := $(shell mktemp -d))
	@cp slides/hausarbeit.tex $(TMPDIR)
	$(call generate_pdf, hausarbeit, $(TMPDIR))
	cp $(TMPDIR)/hausarbeit.pdf .
	

images: $(IMAGE_PDFS)

code_examples: $(CODE_PDFS) images

test: ../code/bibtex-bibliography.pdf
	

clean:
	rm -f $(CODE_PDFS)
	rm -f $(patsubst %.pdf, %-crop.pdf, $(CODE_PDFS))
	rm -f $(IMAGE_PDFS)
	rm -f ${tex}_Wide.*
	rm -f ${tex}_Slides.*
	rm -f ${tex}_Notes.*
	rm -f section_*
