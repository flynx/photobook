#----------------------------------------------------------------------
#
#
#
#----------------------------------------------------------------------
# make config...

.SECONDEXPANSION:

.DEFAULT_GOAL := all



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# config...

DIST_DIR := dist/PRINT


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# sources...

SETUP := \
	setup.tex \
	macros.tex



#----------------------------------------------------------------------
# config/commands...

MD = @mkdir -p


# primary engine, everything works...
# NOTE: several hacks had to be made -- see setup.tex
CMD = lualatex

ARGS = -output-driver="xdvipdfmx -q -E -V 3"



#----------------------------------------------------------------------
# components and rules...


# book blocks...
#
# generic latex -> pdf...
#
%.pdf: %.tex $(SETUP)
	-$(CMD) $<



#----------------------------------------------------------------------
# production targets...

.PHONY: test
test: test.pdf


.PHONY: all
all: main.pdf cover.pdf endpaper.pdf



#----------------------------------------------------------------------
# packageing...

.PHONY: dist-%
dist-%: %
	$(MD) $(DIST_DIR)/$<
	cp *$<*.pdf components/*$<*.pdf $(DIST_DIR)/$</


.PHONY: dist-cover
dist-cover: $(wildcard components/*main*.pdf) components/endpaper.png
	$(MD) $(DIST_DIR)/cover
	cp $? $(DIST_DIR)/cover/



.PHONY: dist
dist: dist-main



#----------------------------------------------------------------------
# utility trgets...

.PHONY: sweep
sweep:
	-rm *.out *.aux *.log *.upa ; true


.PHONY: clean-dist
clean-dist:
	-rm -rf ./dist


.PHONY: clean
clean: sweep
	-rm -rf *.pdf PRINT *.image-list ; true



.PHONY: clean-all
clean-all: clean clean-dist




#----------------------------------------------------------------------
#
