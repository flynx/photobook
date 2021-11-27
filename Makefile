#----------------------------------------------------------------------
#
#
#
# Main targets:
# 	doc				- build class documentation
# 	dist			- build a distributable zip
# 	install			- install to user home latex path
#	uninstall		- uninstall/remove from user home latex path
# 	install-local	- install to local latex path 
# 						(may require elevated privileges)
# 	uninstall-local	- uninstall/remove from local latex path
# 						(may require elevated privileges)
#
# Other targets:
# 	sweep			- cleanup auxiliary generated files
# 	clean			- cleanup repo
#
# Variables:
# 	STRIP_CODE		- if "yes" strip docs from installed code
# 						(only for install and install-local targets)
# 	INSTALL_PATH	- install path
# 						(only for install target)
#
#
# Examples:
#
# 	$ INSTALL_PATH=./test STRIP_CODE=no make install
# 		install to "./test" and do not strip docs.
#
#
#----------------------------------------------------------------------
# Config...

# NOTE: this makes things run consistently on different systems including 
# 		things like Android...
SHELL := bash

MODULE := photobook

#STRIP_CODE ?= no
STRIP_CODE ?= yes

ifeq ($(STRIP_CODE),yes)
	MODULE_CODE := $(MODULE)-stripped
else
	MODULE_CODE := $(MODULE)
endif


# get version...
# NOTE: the code version is in the code...
VERSION := $(shell \
	cat $(MODULE).cls \
		| grep 'VERSION{' \
		| sed 's/.*{\(.*\)}.*/\1/')


# LaTeX paths...
TEX_LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
TEX_HOME = $(shell kpsewhich --var-value TEXMFHOME)

# default install target...
INSTALL_PATH ?= $(TEX_HOME)


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



#----------------------------------------------------------------------
# Rules...

%.pdf: %.tex
	$(TEX) $< > /dev/null


# docs...
#
# NOTE: .sty and .cls are essentially the same in terms of documentation 
# 		generation...
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

.PHONY: doc
doc: $(MODULE).pdf


.PHONY: dist
dist: $(DIST_FILES) sweep
	$(MD) $(DIST_DIR)
	zip -Drq $(DIST_DIR)/$(MODULE)-$(VERSION).zip $(DIST_FILES)


.PHONY: all
all: doc


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install/uninstall targets...

# NOTE: keep the dir clean unless this is explicitly built...
.INTERMEDIATE: \
		$(MODULE)-stripped.cls \
		$(MODULE)-stripped.sty \
		$(MODULE)-stripped.tex

# user install...
.PHONY: install
install: doc $(MODULE_CODE).cls
	$(MD) $(INSTALL_PATH)/{tex,source,doc}/latex/$(MODULE)
	$(CP) $(MODULE).cls $(INSTALL_PATH)/source/latex/$(MODULE)
	$(CP) $(MODULE).pdf $(INSTALL_PATH)/doc/latex/$(MODULE)
	$(CP) $(MODULE_CODE).cls $(INSTALL_PATH)/tex/latex/$(MODULE)/$(MODULE).cls

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
	rm -rf $(DIST_DIR) *.pdf



#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
