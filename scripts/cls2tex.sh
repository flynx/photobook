#!/usr/bin/env bash
#----------------------------------------------------------------------

SCRIPT_NAME=$(basename $0)

printusage(){
	echo "Usage:"
	echo "  $SCRIPT_NAME [OPTIONS] [[INPUT] OUTPUT]"
}

printhelp(){
	echo "Generate docs from latex package/class"
	echo
	printusage
	echo
	echo "Options:"
	echo "  -h | --help         Show this message and exit"
	echo "  -p | --prefix PREFIX"
	echo "                      Set the doc comment PREFIX (default: \"%\")"
	echo
	echo "This will:"
	echo "  - read the INPUT"
	echo "  - keep lines starting with \\def\\<module-name>@[A-Z]\\+"
	echo "  - keep lines starting with '%%'"
	echo "  - %%%%% Text -> \\subsection(Text)"
	echo "  - %%%% Text -> \\section(Text)"
	echo "  - %% >> code -> \\begin{verbatim}code\\end{verbatim}"
	echo "  - write the result to OUTPUT"
	echo
	echo "If no OUTPUT is given $SCRIPT_NAME will read stdout. If no INPUT"
	echo "is given $SCRIPT_NAME will read stdin."
	echo
	echo "PREFIX can replace the second \"%\" in the above patterns to make it"
	echo "possible to integrate multiple layers of documentation in one file"
	echo "and to integrate them in various ways, for example, in the photobook"
	echo "document class documentation \"M\" prefix is used to indicate"
	echo "meta-command docs, this enables us to document them in the relevant"
	echo "location (i.e. at the implementation) in source but move the docs to"
	echo "a unified location in docs, effectively decoupling the source and doc"
	echo "structure when needed."
	echo
	echo "NOTE: the idea of keeping latex docs in a latex file is far simpler"
	echo "      than all the stuff crammed into .dtx, at least for my needs:"
	echo "          - keep the code readable"
	echo "          - keep the docs readable"
	echo "      in both the repo and in installed form, so .dtx is not used."
}

printerror(){
	echo Error: $@
	echo
	printusage
}



#----------------------------------------------------------------------
# Args and defaults...

PREFIX=%

while true ; do
	case $1 in
		-h|--help)
			printhelp
			exit
			;;
		-p|--prefix)
			PREFIX=$2
			shift
			shift
			;;

		# handle unknown options...
		-*|--*)
			printerror "unknown option \"$1\""
			exit
			;;

		# non-flag, option parsing done...
		*)
			break
			;;
	esac
done

INPUT=${1:-/dev/stdin}

OUTPUT=${2:-/dev/stdout}


# generate the module name...
MODULE=$(basename "$INPUT")
MODULE=${MODULE/.*/}


#----------------------------------------------------------------------
# do the work...

cat "$INPUT" \
	| egrep '(^%'$PREFIX'|^\\edef\\'$MODULE'@[A-Z][A-Z]+)' \
	| sed 's/^\(\\edef\\\)'$MODULE'@/%'$PREFIX'\1/' \
	| sed 's/%'$PREFIX'%%%% \(.*\)/%'$PREFIX'\\subsubsection{\1}\\label{subsubsec:\1}/' \
	| sed 's/%'$PREFIX'%%% \(.*\)/%'$PREFIX'\\subsection{\1}\\label{subsec:\1}/' \
	| sed 's/%'$PREFIX'%% \(.*\)/%'$PREFIX'\\section{\1}\\label{sec:\1}/' \
	| sed 's/%'$PREFIX'\s\+>>\s\+\(.*\)/%'$PREFIX'\\begin{verbatim} \1 \\end{verbatim}/' \
	| cut -c 3- - \
	> "$OUTPUT"



#----------------------------------------------------------------------
#                                           vim:set ts=4 sw=4 nowrap :
