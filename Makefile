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


# LaTeX...
ARGS :=

# NOTE: need to run latex two+ times to build index, the simpler way to 
# 		go is to use latexmk...
#TEX := lualatex $(ARGS)
TEX := latexmk -lualatex $(ARGS)

# Doc generator...
DOC := ./scripts/cls2tex.sh



#----------------------------------------------------------------------

%.pdf: %.tex
	$(TEX) $< > /dev/null


# NOTE: .sty and .cls are essentially the same in terms of documentation 
# 		generation...
# XXX should these depend on the $(DOC) script ???
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
doc: photobook.pdf


# XXX
.PHONY: dist
dist: all

# XXX install... (see: ./tmp/Makefile)
# 		- local
# 		- root
.PHONY: install
install: dist


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
