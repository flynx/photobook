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

# NOTE: this makes things run consistently on different systems including 
# 		things like Android...
SHELL := bash

MODULE = photobook

# LaTeX...
TEX_LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
TEX_HOME = $(shell kpsewhich --var-value TEXMFHOME)

ARGS :=

# NOTE: need to run latex two+ times to build index, the simpler way to 
# 		go is to use latexmk...
#TEX := lualatex $(ARGS)
TEX := latexmk -lualatex $(ARGS)

# Doc generator...
DOC := ./scripts/cls2tex.sh

CP := cp
MD := mkdir -p

# XXX revise...
ifeq ($(OS),Windows_NT)
	SYS_CP := ${CP} 
	SYS_MD := ${CP} 
else
	SYS_CP := sudo cp
	SYS_MD := sudo mkdir -p
endif


DIST_FILES := \
	${MODULE}.cls \
	${MODULE}.pdf




#----------------------------------------------------------------------

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

.PHONY: doc
doc: ${MODULE}.pdf


# XXX zip stuff...
.PHONY: dist
dist: ${DIST_FILES}


.PHONY: install
install: all
	${SYS_MD} $(TEX_LOCAL)/{tex,source,doc}/latex/$(MODULE)
	${SYS_CP} $(MODULE).cls $(TEX_LOCAL)/source/latex/$(MODULE)
	${SYS_CP} $(MODULE).cls $(TEX_LOCAL)/tex/latex/$(MODULE)
	${SYS_CP} $(MODULE).pdf $(TEX_LOCAL)/doc/latex/$(MODULE)

.PHONY: install-user
install-user: all
	${MD} $(TEX_HOME)/{tex,source,doc}/latex/$(MODULE)
	${CP} $(MODULE).cls $(TEX_HOME)/source/latex/$(MODULE)
	${CP} $(MODULE).cls $(TEX_HOME)/tex/latex/$(MODULE)
	${CP} $(MODULE).pdf $(TEX_HOME)/doc/latex/$(MODULE)


.PHONY: all
all: doc sweep



#----------------------------------------------------------------------

.PHONY: sweep
sweep:
	rm -f *.{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out,toc,fdb_latexmk}


.PHONY: clean
clean: sweep
	rm -f *.pdf



#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
