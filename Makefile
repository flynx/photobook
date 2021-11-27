#----------------------------------------------------------------------
#
#
#
# Main targets:
# 	doc		- build class documentation.
# 	dist	- XXX
# 	install	- XXX
#
# Other targets:
# 	sweep	- cleanup auxiliary generated files.
# 	clean	- cleanup repo
#
#
#----------------------------------------------------------------------
# Config...

# NOTE: this makes things run consistently on different systems including 
# 		things like Android...
SHELL := bash

MODULE := photobook

# get version...
# NOTE: the code version is in the code...
VERSION := $(shell \
	cat $(MODULE).cls \
		| grep 'VERSION{' \
		| sed 's/.*{\(.*\)}.*/\1/')

# LaTeX paths...
TEX_LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
TEX_HOME = $(shell kpsewhich --var-value TEXMFHOME)

# distribution...
DIST_DIR := dist
DIST_FILES := \
	$(wildcard scripts/*) \
	$(wildcard examples/*) \
	$(wildcard workflow/*) \
	$(wildcard manual/*) \
	$(MODULE).cls \
	$(MODULE).pdf


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Software...

# NOTE: need to run latex two+ times to build index, the simpler way to 
# 		go is to use latexmk...
#TEX := lualatex
TEX := latexmk -lualatex

# Doc generator...
DOC := ./scripts/cls2tex.sh

CP := cp
MD := mkdir -p

# XXX revise...
ifeq ($(OS),Windows_NT)
	SYS_CP := $(CP)
	SYS_MD := $(CP) 
else
	SYS_CP := sudo cp
	SYS_MD := sudo mkdir -p
endif



#----------------------------------------------------------------------
# Rules...

%.pdf: %.tex
	$(TEX) $< > /dev/null


# NOTE: .sty and .cls are essentially the same in terms of documentation 
# 		generation...
%.tex: %.sty %-meta.tex
	$(DOC) $< > $@

%.tex: %.cls %-meta.tex
	$(DOC) $< > $@


# NOTE: this is a bit ugly, but allot less so than trying to push \verb
# 		into a LaTeX macro/env and then getting it out again in one pice...
%-meta.tex: %.sty
	$(DOC) -p M $< > $@

%-meta.tex: %.cls
	$(DOC) -p M $< > $@



#----------------------------------------------------------------------
# Info targets...

.PHONY: version
version:
	@echo $(VERSION)



#----------------------------------------------------------------------
# Main targets...

.PHONY: doc
doc: $(MODULE).pdf


.PHONY: dist
dist: $(DIST_FILES)
	$(MD) $(DIST_DIR)
	zip -Drq $(DIST_DIR)/$(MODULE)-$(VERSION).zip $(DIST_FILES)


# XXX merge install and install-user...
.PHONY: install
install: all
	$(SYS_MD) $(TEX_LOCAL)/{tex,source,doc}/latex/$(MODULE)
	$(SYS_CP) $(MODULE).cls $(TEX_LOCAL)/source/latex/$(MODULE)
	$(SYS_CP) $(MODULE).cls $(TEX_LOCAL)/tex/latex/$(MODULE)
	$(SYS_CP) $(MODULE).pdf $(TEX_LOCAL)/doc/latex/$(MODULE)

.PHONY: install-user
install-user: all
	$(MD) $(TEX_HOME)/{tex,source,doc}/latex/$(MODULE)
	$(CP) $(MODULE).cls $(TEX_HOME)/source/latex/$(MODULE)
	$(CP) $(MODULE).cls $(TEX_HOME)/tex/latex/$(MODULE)
	$(CP) $(MODULE).pdf $(TEX_HOME)/doc/latex/$(MODULE)


.PHONY: all
all: doc sweep



#----------------------------------------------------------------------
# Cleanup targets...

.PHONY: sweep
sweep:
	rm -f *.{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out,toc,fdb_latexmk}


.PHONY: clean
clean: sweep
	rm -rf $(DIST_DIR) *.pdf



#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
