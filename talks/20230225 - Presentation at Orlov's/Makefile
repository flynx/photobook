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


#----------------------------------------------------------------------
# config/commands...

MD = @mkdir -p


# primary engine, everything works...
# NOTE: several hacks had to be made -- see setup.tex
CMD = lualatex

ARGS = -output-driver="xdvipdfmx -q -E -V 3"

COMPONENTS := \
	photobook-cover.pdf \
	photobook-jacket.pdf \
	photobook-endpaper.pdf \
	hello-world.pdf

IMAGES := $(wildcard images/*)

ifeq ($(DEBUG),)
	STDERR := > /dev/null
endif


#----------------------------------------------------------------------
# components and rules...


# book blocks...
#
# generic latex -> pdf...
#
%.pdf: %.tex $(SETUP)
	-$(CMD) $< $(STDERR)

# XXX need to figure this out with patterns...
photobook-slides-en.pdf: $(COMPONENTS) 

photobook-slides-ru.pdf: $(COMPONENTS) 

photobook-web-en.pdf: photobook-slides-en.pdf

photobook-web-ru.pdf: photobook-slides-ru.pdf


#----------------------------------------------------------------------
# production targets...

#.INTERMEDIATE: $(COMPONENTS)

.PHONY: all 
all: web

.PHONY: slides
slides: photobook-slides-en.pdf photobook-slides-ru.pdf $(IMAGES)

.PHONY: web
web: photobook-web-en.pdf photobook-web-ru.pdf slides 

.PHONY: components
components: $(COMPONENTS)


#----------------------------------------------------------------------
# packageing...



#----------------------------------------------------------------------
# utility trgets...

.PHONY: sweep
sweep:
	-rm -f *.out *.aux *.log *.upa *.cpt *.synctex* \
		$(COMPONENTS) ; true


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
