#!/usr/bin/env bash

# usage: cls2tex.sh INPUT OUTPUT PREFIX

cat $1 \
	| egrep '(^%$3|^\\\\edef\\\\$*@[A-Z][A-Z]+)' \
	| sed 's/^\(\\\\edef\\\\\)$*@/%$3\\1/' \
	| sed 's/%$3%%%% \(.*\)/%$3\\\\subsubsection{\1}\\\\label{subsubsec:\1}/' \
	| sed 's/%$3%%% \(.*\)/%$3\\\\subsection{\1}\\\\label{subsec:\1}/' \
	| sed 's/%$3%% \(.*\)/%$3\\\\section{\1}\\\\label{sec:\1}/' \
	| sed 's/%$3\s\+>>\s\+\(.*\)/%$3\\\\begin{verbatim} \1 \\\\end{verbatim}/' \
	| cut -c 3- - > $2

