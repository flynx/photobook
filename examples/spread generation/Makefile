#
# Example spread generator...
#
# Usage:
# 	$ make
#
# To make a specifc spread (0-based index) use:
# 	$ SPREAD=1 make
#
# For more info use:
# 	make-images.sh --help
#
#

MAKESPREADS := ../../scripts/make-images.sh


spreads.tex: spreads
	$(MAKESPREADS) $< $(SPREAD) > $@

dist:

clean:
	rm -f spreads.tex

all: spreads.tex

