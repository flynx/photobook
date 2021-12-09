#----------------------------------------------------------------------
#
#
#
# Main targets:
# 	doc				- build class documentation
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
# 			- $(LN) vs. $(CP) in the install target...
CODE_INSTALL ?= strip

ifeq ($(CODE_INSTALL),strip)
	MODULE_CODE := $(MODULE)-stripped
else
	MODULE_CODE := $(MODULE)
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
CP := cp
# copy preserving relative paths...
RCP := cp -r --parents
LN := cp -l



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


# XXX STUB
.PHONY: manual
manual:
	$(MAKE) -C $(MODULE)-manual.pdf
	mv manual/$(MODULE)-manual.pdf .


.PHONY: dist
dist: $(DIST_FILES)
	$(MD) $(DIST_DIR)
	zip -Drq $(DIST_DIR)/$(DIST_NAME).zip $(DIST_FILES)


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
	$(CP) "$(MODULE).pdf" $(INSTALL_PATH)/doc/latex/$(MODULE)
	$(CP) "$(MODULE_CODE).cls" $(INSTALL_PATH)/tex/latex/$(MODULE)/$(MODULE).cls
#	# NOTE: we are printing only the stuff we are doing...
	@run(){ echo "$$@" ;  "$$@" ; } ;\
	if [[ $${CODE_INSTALL} == "link" ]] ; then \
		run $(LN) \
			"$(INSTALL_PATH)/tex/latex/$(MODULE)/$(MODULE).cls" \
			"$(INSTALL_PATH)/source/latex/$(MODULE)/" ;\
	else \
		run $(CP) "$(MODULE).cls" "$(INSTALL_PATH)/source/latex/$(MODULE)" ;\
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
install-devel: CP := cp -s
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
	rm -rf $(DIST_DIR) $(BUILD_DIR) *.pdf



#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
