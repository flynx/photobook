#!/usr/bin/env bash

printhelp(){
	echo "Generate docs from latex package/class"
	echo
	echo "Usage: $(basename $0) [-h|--help] INPUT OUTPUT [PREFIX]"
	echo
	echo "This will:"
	echo "  - keep lines starting with \\def\\<module-name>@[A-Z]\\+"
	echo "  - keep lines starting with '%%'"
	echo "  - %%%%% Text -> \\subsection(Text)"
	echo "  - %%%% Text -> \\section(Text)"
	echo "  - %% >> code -> \\begin{verbatim}code\\end{verbatim}"
	echo
	echo "NOTE: the idea of keeping latex docs in a latex file is far simpler"
	echo "      than all the stuff crammed into .dtx, at least for my needs:"
	echo "          - keep the code readable"
	echo "          - keep the docs readable"
	echo "      in both the repo and in installed form, so .dtx is not used."
}

# args/defaults...
while true ; do
	case $1 in
		-h|--help)
			printhelp
			exit
			;;

		*)
			break
			;;
	esac
done

INPUT=$1

OUTPUT=$2

PREFIX=$3
if [ -z $PREFIX ] ; then
	PREFIX=%
fi


# do the work...
cat "$INPUT" \
	| egrep '(^%'$PREFIX'|^\\edef\\.*@[A-Z][A-Z]+)' \
	| sed 's/^\(\\edef\\\).*@/%'$PREFIX'\1/' \
	| sed 's/%'$PREFIX'%%%% \(.*\)/%'$PREFIX'\\subsubsection{\1}\\label{subsubsec:\1}/' \
	| sed 's/%'$PREFIX'%%% \(.*\)/%'$PREFIX'\\subsection{\1}\\label{subsec:\1}/' \
	| sed 's/%'$PREFIX'%% \(.*\)/%'$PREFIX'\\section{\1}\\label{sec:\1}/' \
	| sed 's/%'$PREFIX'\s\+>>\s\+\(.*\)/%'$PREFIX'\\begin{verbatim} \1 \\end{verbatim}/' \
	| cut -c 3- - \
	> "$OUTPUT"


# vim:set ts=4 sw=4 nowrap :
