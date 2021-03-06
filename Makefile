#----------------------------------------------------------------------
#
#
#
# Main targets:
# 	pdf				- build class pdf documentation...
# 	md				- build class markdown documentation (XXX EXPERIMENTAL)...
#
# Distribution and install:
# 	dist			- build a distributable zip
# 	install			- install to user home latex path
#	uninstall		- uninstall/remove from user home latex path
# 	install-local	- install to local latex path 
# 						(may require elevated privileges)
# 	uninstall-local	- uninstall/remove from local latex path
# 						(may require elevated privileges)
# 	install-devel	- XXX
# 	uninstall-devel	- XXX
#
# Other targets:
# 	sweep			- cleanup auxiliary generated files
# 	clean			- cleanup repo
#
#
# Variables:
# 	CODE_INSTALL	- set how we handle the installing code/source.
# 						this can be:
# 							strip		- strip the docs from code (default)
# 							copy		- copy the code/doc file
# 							link		- link the code/doc files
# 						(affects install and install-local targets)
# 	INSTALL_PATH	- install path
# 						(only affects install target)
#
#
# Examples:
#
# 	$ INSTALL_PATH=./test CODE_INSTALL=link make install
# 		install to "./test" and do not strip docs.
#
#
# XXX Q: shold dist: pack into a dir or into the archive root??
# 		...have to make a decision here and stop asking the same question
# 		for every single project...
#
#
#----------------------------------------------------------------------
# Config...

.EXPORT_ALL_VARIABLES:

# NOTE: this makes things run consistently on different systems including 
# 		things like Android...
SHELL := bash

MODULE := photobook


# metadata...
#
# NOTE: the code version is in the code...
VERSION = $(strip $(shell \
	cat $(MODULE).cls \
		| grep 'VERSION{' \
	 	| sed 's/.*{\(.*\)}.*/\1/'))
DATE = $(strip $(shell date "+%Y%m%d%H%M"))
COMMIT = $(strip $(shell git rev-parse HEAD))


# installing code...
#
# this can be:
# 	- strip
# 	- copy
# 	- link
#
# NOTE: we are doing things in different ways for different modes:
# 		- copy vs. strip
# 			- simply change the target name and let make figure it out...
# 		- link vs. copy/strip
# 			- $(LN) vs. $(INSTALL) in the install target...
CODE_INSTALL ?= strip
ifeq ($(CODE_INSTALL),strip)
	MODULE_CODE := $(MODULE)-stripped
else
	MODULE_CODE := $(MODULE)
endif


# markdown dialect...
#
# XXX still needs some tweaking...
MD_FORMAT ?= markdown_github


# debug output...
#
# $DEBUG can either be empty or anything else...
DEBUG ?=
ifeq ($(DEBUG),)
	STDERR := > /dev/null
else
	STDERR :=
endif



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Paths and files...

# LaTeX...
TEX_LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
TEX_HOME = $(shell kpsewhich --var-value TEXMFHOME)

# default install target...
INSTALL_PATH ?= $(TEX_HOME)

# build...
BUILD_DIR := build

# distribution...
#DIST_NAME := $(MODULE)-$(VERSION)
DIST_NAME := $(MODULE)-$(VERSION)-$(DATE)
DIST_DIR := dist
DIST_FILES = \
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

MD := mkdir -p
# XXX cp/install, technically this is only used in install* targets so 
# 		renaming CP -> INSTALL would seem logical...
#INSTALL := cp
INSTALL := install
# copy preserving relative paths...
RCP := cp -r --parents
LN := cp -l



#----------------------------------------------------------------------
# Rules...

# docs (pdf)...
#
%.pdf: %.tex
	$(TEX) $< $(STDERR)

# docs (markdown)...
#
# XXX this still needs some tweaking...
# 			- |..|	- verbatim does not work...
# 			- ||	- parts of doc omitted...
#			- verbatim blocks get merged sometimes...
#			- ...
#		...not sure if this can be tweaked...
#%.md: %.tex
#	pandoc -t $(MD_FORMAT) -s $< -o $@

# XXX EXPERIMENTAL...
# XXX revise:
#		...for this to work we need to replace:
#			\documentclass{ltxdoc}
#		to:
#			\documentclass[markdownextra]{internet}
# XXX install the internet class...
#			https://github.com/loopspace/latex-to-internet
#		...needs testing...
%.md: %.tex
	cat $< \
		| sed 's/documentclass{ltxdoc}/documentclass[markdownextra]{internet}/' \
		> $<.tmp
	mv $<{.tmp,}
	$(TEX) $< $(STDERR)


# meta-section...
#
# NOTE: .sty and .cls are essentially the same in terms of documentation 
# 		generation...
# XXX might be a good idea to place a link/footnote where metadocs were 
#		originally located...
#		...not sure yet manually or automatically...
%.tex: %.sty %-meta.tex
	$(DOC) $< > $@

%.tex: %.cls %-meta.tex
	$(DOC) $< > $@


# meta docs...
#
# NOTE: this is a bit ugly, but allot less so than trying to push \verb
# 		into a LaTeX macro/env and then getting it out again in one pice...
%-meta.tex: %.sty
	$(DOC) --prefix M $< > $@

%-meta.tex: %.cls
	$(DOC) --prefix M $< > $@


# strip docs out...
#
# XXX can we unify these???
%-stripped.tex: %.tex
	$(DOC) --strip $< \
		$(DOC) --prefix M --strip \
		> $@

%-stripped.sty: %.sty
	$(DOC) --strip $< \
		| $(DOC) --prefix M --strip \
		> $@

%-stripped.cls: %.cls
	$(DOC) --strip $< \
		| $(DOC) --prefix M --strip \
		> $@



#----------------------------------------------------------------------
# Info targets...

.PHONY: version
version:
	@echo $(VERSION)



#----------------------------------------------------------------------
# Main targets...

.PHONY: pdf
pdf: $(MODULE).pdf


.PHONY: md
md: $(MODULE).md


# XXX STUB -- not sure how to approach this yet...
# 		on one hand the manual should be a self-contained example in 
# 		itself on the other hand we already have a working Makefile 
# 		building the docs...
.PHONY: manual
manual:
	$(MAKE) -C manual all
	mv manual/*.pdf .


.PHONY: dist
dist: $(DIST_FILES)
	$(MD) $(DIST_DIR)
	zip -Drq $(DIST_DIR)/$(DIST_NAME).zip $(DIST_FILES)


.PHONY: all
all: pdf


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install/uninstall targets...

# NOTE: keep the dir clean unless this is explicitly built...
.INTERMEDIATE: \
		$(MODULE)-stripped.cls \
		$(MODULE)-stripped.sty \
		$(MODULE)-stripped.tex


# user install...
.PHONY: install
install: pdf $(MODULE_CODE).cls
	$(MD) $(INSTALL_PATH)/{tex,source,doc}/latex/$(MODULE)
	$(INSTALL) "$(MODULE).pdf" $(INSTALL_PATH)/doc/latex/$(MODULE)
	$(INSTALL) "$(MODULE_CODE).cls" $(INSTALL_PATH)/tex/latex/$(MODULE)/$(MODULE).cls
#	# NOTE: we are printing only the stuff we are doing...
	@run(){ echo "$$@" ;  "$$@" ; } ;\
	if [[ $${CODE_INSTALL} == "link" ]] ; then \
		run $(LN) \
			"$(INSTALL_PATH)/tex/latex/$(MODULE)/$(MODULE).cls" \
			"$(INSTALL_PATH)/source/latex/$(MODULE)/" ;\
	else \
		run $(INSTALL) "$(MODULE).cls" "$(INSTALL_PATH)/source/latex/$(MODULE)" ;\
	fi

.PHONY: uninstall
uninstall:
	rm -rf $(INSTALL_PATH)/{tex,source,doc}/latex/$(MODULE)
	@echo "###"
	@echo "### NOTE: this can leave the following dirs empty:"
	@echo "###         $(INSTALL_PATH)/{tex,source,doc}/latex/"
	@echo "###"


# local/system install...
# NOTE: this should be run with sudo, i.e.:
# 			$ sudo make install-local
.PHONY: install-local
install-local: INSTALL_PATH := $(TEX_LOCAL)
install-local: install

.PHONY: uninstall-local
uninstall-local: INSTALL_PATH := $(TEX_LOCAL)
uninstall-local: uninstall


# XXX need to make this work for windows...
# 		...this must depend not on the OS but rather on in what context 
# 		(cygwin/wsl/windows), latex is running...
# 		...this seems to work:
# 			> mkling TO FROM
# 		but like ln, it's args are in the wrong order...
# 		...cp -s creates links usable from cygwin but not usable from 
# 		windows...
.PHONY: install-devel
install-devel: CODE_INSTALL := copy
install-devel: INSTALL := cp -s
install-devel: install

.PHONY: uninstall-devel
uninstall-devel: uninstall



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Cleanup targets...

.PHONY: sweep
sweep:
	rm -f \
		*.{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out,toc,fdb_latexmk} \
		*-stripped.{tex,sty,cls} \
		*-meta.{tex,sty,cls} \
		${MODULE}.tex


.PHONY: clean
clean: sweep
	rm -rf $(DIST_DIR) $(BUILD_DIR) $(MODULE).md *.pdf



#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
