#----------------------------------------------------------------------


ARGS :=

TEX := lualatex $(ARGS)



#----------------------------------------------------------------------

# Generate docs from latex package/class...
#
# 	- keep lines starting with \def\<module-name>@[A-Z]\+
# 	- keep lines starting with '%%'
# 	- %%%%% Text -> \subsection(Text)
# 	- %%%% Text -> \section(Text)
# 	- %% >> code -> \begin{verbatim}code\end{verbatim}
#
# NOTE: the idea of keeping latex docs in a latex file is far similar 
# 		than all the stuff crammed into .dtx, at least for my needs:
# 			- keep the code readable
# 			- keep the docs readable
# 		in both the repo and in installed form.
# NOTE: this is evolving as need arises, when this gets too complicated 
# 		we'll split it out into it's own script.
texToDoc = \
	@echo "texToDoc: $1 -> $2"; \
	cat $1 \
		| egrep '(^%%|^\\\\edef\\\\$*@[A-Z][A-Z]+)' \
		| sed 's/^\(\\\\edef\\\\\)$*@/%%\\1/'\
		| sed 's/%%%%%% \(.*\)/%%\\\\subsubsection{\1}/' \
		| sed 's/%%%%% \(.*\)/%%\\\\subsection{\1}/' \
		| sed 's/%%%% \(.*\)/%%\\\\section{\1}/' \
		| sed 's/%%\s\+>>\s\+\(.*\)/%%\\\\begin{verbatim} \1 \\\\end{verbatim}/' \
		| cut -c 3- - > $2



#----------------------------------------------------------------------

%.pdf: %.tex
	$(TEX) $< > /dev/null


# NOTE: .sty and .cls are essentially the same in terms of documentation 
# 		generation...
%.tex: %.sty
	$(call texToDoc,$<,$@)

%.tex: %.cls
	$(call texToDoc,$<,$@)



#----------------------------------------------------------------------

.PHONY: doc
doc: photobook.pdf


.PHONY: all
all: doc sweep


# XXX
.PHONY: dist
dist: all

# XXX install... (see: ./tmp/Makefile)
# 		- local
# 		- root
.PHONY: install
install: dist



#----------------------------------------------------------------------

.PHONY: sweep
sweep:
	rm -f *.{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out}


.PHONY: clean
clean: sweep
	rm -f *.pdf



#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
