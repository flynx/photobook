#----------------------------------------------------------------------


TEX := lualatex



#----------------------------------------------------------------------


%.pdf: %.tex
	$(TEX) $< > /dev/null


# Generate docs from latex package/class...
#
# 	- keep only lines starting with '%%'
# 	- %%%% Text -> \section(Text)
# 	- %%%%% Text -> \subsection(Text)
# 	- %% >> code -> \begin{verbatim}code\end{verbatim}
#
# NOTE: the idea of keeping latex docs in a latex file is far similar 
# 		than all the stuff crammed into .dtx, at least for my needs:
# 			- keep the code readable
# 			- keep the docs readable
# 		in both the repo and in installed form.
# NOTE: this is evolving as need arises, when this gets too complicated 
# 		we'll split it out into it's own script.
#
# XXX need to do this without repeating the recipe...
#%.tex: %.sty
%.tex: %.cls
	cat $< \
		| egrep "^%%" \
		| sed 's/%%%%%% \(.*\)/%%\\\\subsubsection{\1}/' \
		| sed 's/%%%%% \(.*\)/%%\\\\subsection{\1}/' \
		| sed 's/%%%% \(.*\)/%%\\\\section{\1}/' \
		| sed 's/%%\s\+>>\s\+\(.*\)/%%\\\\begin{verbatim} \1 \\\\end{verbatim}/' \
		| cut -c 3- - > $@

#----------------------------------------------------------------------
# XXX install... (see: ./tmp/Makefile)


#----------------------------------------------------------------------

.PHONY: sweep
sweep:
	rm -f *.{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out}


.PHONY: clean
clean: sweep
	rm -f *.pdf


#----------------------------------------------------------------------
#                                                   vim:set ts=4 sw=4 :
