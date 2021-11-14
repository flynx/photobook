#!/usr/bin/env bash

# Generate docs from latex package/class...
#
# Usage: cls2tex.sh INPUT OUTPUT [PREFIX]
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

INPUT=$1

OUTPUT=$2

PREFIX=$3
if [ -z $PREFIX ] ; then
	PREFIX=%
fi


cat "$INPUT" \
	| egrep '(^%'$PREFIX'|^\\edef\\.*@[A-Z][A-Z]+)' \
	| sed 's/^\(\\edef\\\).*@/%'$PREFIX'\1/' \
	| sed 's/%'$PREFIX'%%%% \(.*\)/%'$PREFIX'\\subsubsection{\1}\\label{subsubsec:\1}/' \
	| sed 's/%'$PREFIX'%%% \(.*\)/%'$PREFIX'\\subsection{\1}\\label{subsec:\1}/' \
	| sed 's/%'$PREFIX'%% \(.*\)/%'$PREFIX'\\section{\1}\\label{sec:\1}/' \
	| sed 's/%'$PREFIX'\s\+>>\s\+\(.*\)/%'$PREFIX'\\begin{verbatim} \1 \\end{verbatim}/' \
	| cut -c 3- - > "$OUTPUT"


# vim:set ts=4 sw=4 nowrap :
