#----------------------------------------------------------------------
#
#
#
#----------------------------------------------------------------------
# make config...

.SECONDEXPANSION:

.DEFAULT_GOAL := all

ifeq ($(DEBUG),)
	STDERR := > /dev/null
endif


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# config...

DIST_DIR := dist/PRINT
SPREAD_DIR := spreads
TEMPLATE_DIR := templates


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# sources...

SETUP := \
	setup.tex \
	macros.tex

TEMPLATE_FILES := \
	$(wildcard $(TEMPLATE_DIR)/*)

SPREADS := \
	spreads.tex

COMPONENTS := \
	cover.pdf jacket.pdf endpaper.pdf \
	block.pdf

# things that we need that does not need to be built my this Makefile,
# this could include custom graphics, manual layouts, ...etc.
EXTRAS :=



#----------------------------------------------------------------------
# config/commands...

MD = @mkdir -p

# primary engine, everything works...
# NOTE: several hacks had to be made -- see setup.tex
CMD = lualatex
#ARGS = -output-driver="xdvipdfmx -q -E -V 3"

MAKESPREADS := ../../scripts/make-spreads.sh



#----------------------------------------------------------------------
# components and rules...

# generic latex -> pdf...
%.pdf: %.tex $(SETUP)
	-$(CMD) $< $(STDERR)


spreads.tex: $(SPREAD_DIR) $(wildcard $(SPREAD_DIR)/*/*) $(TEMPLATE_FILES)
	$(MAKESPREADS) $< $(SPREAD) > $@

# in case we need multiple chapters/sections, i.e. sets of spreads...
# XXX needs testing -- % in the wildcard function...
%-spreads.tex: $(SPREAD_DIR)/% $(wildcard $(SPREAD_DIR)/%/*/*) $(TEMPLATE_FILES)
	$(MAKESPREADS) $< $(SPREAD) > $@


block.pdf: $(SPREADS) 



#----------------------------------------------------------------------
# production targets...

.PHONY: all
all: $(COMPONENTS) $(EXTRAS)



#----------------------------------------------------------------------
# packageing...

.PHONY: dist
dist: $(COMPONENTS) $(EXTRAS)
	$(MD) $(DIST_DIR)
	cp $? $(DIST_DIR)



#----------------------------------------------------------------------
# utility trgets...

.PHONY: sweep
sweep:
	-rm -f *.out *.aux *.log *.upa ; true


.PHONY: clean
clean: sweep
	-rm -rf *.pdf PRINT *.image-list $(SPREADS) ; true


.PHONY: clean-dist
clean-dist:
	-rm -rf dist ; true


.PHONY: clean-all
clean-all: clean clean-dist




#----------------------------------------------------------------------
#
