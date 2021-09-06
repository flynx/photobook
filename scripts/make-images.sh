#!/bin/bash
shopt -s nullglob extglob

#----------------------------------------------------------------------
#
# Template structure:
#	templates/
#		imagepage.tex
#		textpage.tex
#		...
#	$IMAGE_DIR/
#		$spread/
#			tweaks.tex
#				template tweaks.
#				loaded before the templates are handled.
#			layout.tex
#				manual layout of spread.
#				if given rest of directory contents are 
#				ignored.
#				fields:
#					${IMAGE0}
#					${CAPTION0}
#					${IMAGE1}
#					${CAPTION1}
#				NOTE: if images are included, hi-res source
#					substitution is not done here.
#			<spread-template-name>.tpl
#				indicates the spread template to use.
#				if given the rest of the .tex files in 
#				directory are ignored.
#				resolves to:
#					templates/<spread-template-name>.tex
#				fields:
#					${IMAGE0}
#					${CAPTION0}
#					${IMAGE1}
#					${CAPTION1}
#			imagepage.tex
#				image page template.
#				fields:
#					${IMAGE}
#					${CAPTION}
#			textpage.tex
#				text page template.
#				fields:
#					${TEXT}
#			<spread-template-name>-imagepage.tpl
#			<spread-template-name>-textpage.tpl
#				indicates the image/text page template to use.
#				ignored if explicit templates are given.
#				image fields:
#					${IMAGE}
#					${CAPTION}
#				text fields:
#					${TEXT}
#			00-<image>.png
#				image.
#				if $IMAGE_HIRES_DIR is set then this will 
#				resolve to:
#					$IMAGE_HIRES_DIR/<image>
#				XXX hi-res substitution currently disabled.
#			01-<text>.txt
#				text.
#			...
#		...
#
#
#
# Env variables:
#	IMAGE_HIRES_DIR=<path>
#		sets the path to which the hi-res images are resolved.
#
#
#
#
# XXX TODO:
#		- revise printed comments...
#		- add --help support...
#		- add real arg handling...
#		- add abbility to apply template to a specific page in spread...
#			...something like:
#				<template-name>-left.tpl
#				<template-name>-right.tpl
#
#
#
#----------------------------------------------------------------------

# defaults...

CFG_FILE=`basename $0`.cfg

TEMPLATE_PATH=templates/

IMAGE_DIR=pages/

#IMAGE_HIRES_DIR=


# Default timplates
#SINGLE_IMAGE=blank-image
SINGLE_IMAGE=imagebleedleft
DOUBLE_IMAGE=image-image


# load config...
[ -e $CFG_FILE ] && source $CFG_FILE



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printhelp(){
	echo "Usage: `basename $0` [ARGUMENTS] [PATH]"
	echo "       `basename $0` [ARGUMENTS] PATH FROM [COUNT]"
	echo
	echo "Arguments:"
	echo "  -h --help   - print this help and exit."
	echo "  --templates=PATH"
	echo "              - path to search for templates (default: $TEMPLATE_PATH)."
	echo "  --single-image-tpl=NAME"
	echo "              - single image default template (default: $SINGLE_IMAGE)."
	echo "  --double-image-tpl=NAME"
	echo "              - double image default template (default: $DOUBLE_IMAGE)."
	echo
	echo "Parameters:"
	echo "  PATH        - path to root pages directory (default: $IMAGE_DIR)"
	echo "  FROM        - spread to start from (default: 0)"
	echo "  COUNT       - number of spreads to generate (default: 1)"
	echo
	echo "Environment:"
	echo "  \$IMAGE_HIRES_DIR "
	echo "              - source directory for replacement hi-res images."
	echo
	echo "Configuration defaults can be stored in a config file: $CFG_FILE"
	echo
	echo "NOTE: COUNT is relevant iff FROM is given, otherwise all available "
	echo "        spreads are generated."
	echo
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# handle arguments...

while true ; do
	case $1 in
		-h|--help)
			printhelp
			exit
			;;
		--templates)
			TEMPLATE_PATH=$2
			shift
			shift
			;;
		--single-image-tpl)
			SINGLE_IMAGE=$2
			shift
			shift
			;;
		--double-image-tpl)
			DOUBLE_IMAGE=$2
			shift
			shift
			;;

		*)
			break
			;;
	esac
done


if [ -z $1 ] ; then
	IMAGE_DIR=pages/
else
	IMAGE_DIR=$1/
fi


# XXX add support for negative indexing...
FROM=$2
COUNT=$( [ -z $3 ] && echo 1 || echo $3 )
STOP=$(( FROM + COUNT ))



#----------------------------------------------------------------------

# XXX should we report images w/o captions???
getCaption(){
	local C=`basename "${1%.*}"`
	#C="${C/[0-9]-}"
	C="captions/${C}.txt"

	if [ -e "${C}" ] ; then
		C=`cat "${C}" | sed 's/\\\/\\\\\\\/g'`
	else
		C=""
	fi

	echo ${C[*]}
}


getTemplate(){
	local SPREAD=$1
	local TYPE=$2
	local TEMPLATE=($SPREAD/*-$TYPE.tex)
	if [ -z $TEMPLATE ] ; then
		TEMPLATE=($SPREAD/*-$TYPE.tpl)
		if ! [ -z $TEMPLATE ] ; then
			TEMPLATE=${TEMPLATE/$SPREAD\//}
			TEMPLATE=${TEMPLATE/[0-9]-/}
			TEMPLATE="$TEMPLATE_PATH/${TEMPLATE[0]%-${TYPE}.*}.tex"
		fi
	fi
	if [ -z $TEMPLATE ] ; then
		 TEMPLATE="$TEMPLATE_PATH/${TYPE}.tex"
	fi
	echo $TEMPLATE
}

anotatePath(){
	if [ -z "$1" ] || [ -z "$ANOTATE_IMAGE_PATHS" ] ; then
		return
	fi
	path=$(basename ${1%.*})
	# NOTE: did not figure out how to make a verbatim comment in latex 
	#		so here we are, doing it in shell...
	path=${path//_/\\_}
	echo "\\marginpar{\\pdfcomment{Image: $path}}"
}


#----------------------------------------------------------------------


echo %----------------------------------------------------------------------
echo %
echo % WARNING: This file is auto-generated by make-images.sh and will be 
echo "%          overwritten on next run..."
echo %
echo "% Image source (preview): \"$IMAGE_DIR\""
echo "% Image source (hi-res): \"$IMAGE_HIRES_DIR\""
echo %
echo %----------------------------------------------------------------------
echo %
#echo % set image source directory...
#echo "\\graphicspath{{${IMAGE_DIR}}}"
#echo %
#echo %----------------------------------------------------------------------
#echo %
#
#cd ${IMAGE_DIR}

l=$(ls "$IMAGE_DIR/" | wc -l)
c=0

for spread in "${IMAGE_DIR}"/* ; do
	# skip non-spreads...
	if ! [ -d "$spread" ] ; then
		continue
	fi

	c=$(( c + 1 ))

	# if $FROM is given print only stuff in range...
	[ -z $FROM ] \
		|| if (( $(( c - 1 )) < $FROM )) || (( $c > $STOP )) ; then
			continue
		fi

	# if we are building only a specific spread...
	##if ! [ -z $SPREAD ] && [[ "$spread" != "$IMAGE_DIR/$SPREAD" ]]; then
	##	continue
	##fi

	if ! [ -z $SKIP_FIRST ] ; then
		echo %
		echo %
		echo % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	fi
	SKIP_FIRST=1
	# skip temporarily disabled...
	if [ -z ${spread/-*/} ] ; then
		echo "% spread: ${spread/-/}: skipped..." | tee >(cat >&2)
		echo %
		continue
	else
		printf "Spread ($c/$l): ${spread/-/}                         \r" >&2
		echo "% spread: ${spread/-/}"
	fi


	# auto layout / templates...
	# NOTE: to use a specific template just `touch <template-name>.tpl`
	#	in the spread directory...

	# layout tweaks...
	tweaks=($spread/*tweak.tex)
	if ! [ -z ${tweaks} ] ; then
		echo "% tweaks: ${tweaks[0]}"
		cat ${tweaks[0]}
	fi


	# NOTE: we also get *.txt files here...
	items=($spread/*.!(tex|tpl|bak))

	# get hi-res image paths...
	if ! [ -z $IMAGE_HIRES_DIR ] ; then
		C=0
		for img in "${items[@]}" ; do
			# skip non-images...
			if [[ "$img" == "${img/.txt/}" ]] ; then
				#new="../$IMAGE_HIRES_DIR/`basename ${img/[0-9]-/}`"
				new="$IMAGE_HIRES_DIR/`basename ${img/[0-9]-/}`"
				# ignore file ext for availability test...
				# NOTE: the first match may be an unsupported format...
				new="${new%.*}"
				new=($new.*)
				if [ -e "${new[0]}" ] ; then
					items[$C]=${new[0]}
				else
					echo %
					echo "% WARNING: hi-res image not found for: \"${img}\" -> \"${new}\"" | tee >(cat >&2)
					echo %
				fi
			fi
			C=$(( C + 1 ))
		done
	fi


	# manual layout...
	layout=($spread/*layout.tex)
	if ! [ -z $layout ] ; then
		TEMPLATE=${layout[0]}

	# templates and partial templates...
	else
		# spread template...
		TEMPLATE=($spread/*.tpl)
		# skip page template refs: *-imagepage.tpl / *-textpage.tpl
		# XXX this will also eat 0-imagepage.tpl / 20-textpage.tpl -- do a better pattern...
		if ! [ -z $TEMPLATE ] ; then
			TEMPLATE=(`ls "$spread/"*.tpl | egrep -v '.*-(imagepage|textpage)\.tpl'`)
		fi
		# no template explicitly defined -> match auto-template...
		AUTO=
		if [ -z $layout ] && [ -z $TEMPLATE ] ; then
			AUTO=" (auto)"
			if [ ${#items[@]} == 1 ] ; then
				TEMPLATE=$SINGLE_IMAGE

			# multiple items...
			else 
				C=0
				for img in "${items[@]}" ; do
					C=$(( C + 1 ))
					P=`[ $C == 1 ] && echo "left" || echo "right"`

					# image...
					if [ "${img/.txt/}" == "${img}" ] ; then
						echo %
						echo "% $P page (image)..."
						TEMPLATE=`getTemplate "$spread" "imagepage"`
						echo % page template: $TEMPLATE
						anotatePath "${img}"
						CAPTION=`getCaption "${img}"`
						cat "${TEMPLATE}" \
							| sed "s%\${IMAGE0\?}%${img%.*}%" \
							| sed "s%\${CAPTION0\?}%${CAPTION}%"

					# text...
					else
						echo %
						echo "% $P page (text)..."
						TEMPLATE=`getTemplate "$spread" "textpage"`
						echo % page template: $TEMPLATE
						cat "${TEMPLATE}" \
							| sed "s%\${TEXT}%${img}%"
					fi

					# reset for next page...
					TEMPLATE=
					# only two pages at a time...
					[ $C == 2 ] && break
				done
			fi
		fi
		# formatting done...
		[ -z $TEMPLATE ] && continue

		# format...
		TEMPLATE=${TEMPLATE/$spread\//}
		TEMPLATE=${TEMPLATE/[0-9]-/}
		# get...
		TEMPLATE="$TEMPLATE_PATH/${TEMPLATE[0]%.*}.tex"
	fi

	# captions...
	CAPTION0=`getCaption "${items[0]}"`
	CAPTION1=`getCaption "${items[1]}"`

	echo "% template: (template${AUTO}: $TEMPLATE)"
	anotatePath "${items[0]}"

	# fill the template...
	cat "${TEMPLATE}" \
		| sed "s%\${IMAGE0\?}%${items[0]%.*}%" \
		| sed "s%\${CAPTION0\?}%${CAPTION0}%" \
		| sed "s%\${IMAGE1}%${items[1]%.*}%" \
		| sed "s%\${CAPTION1}%${CAPTION1}%"
done

echo %
echo %
echo %
echo %----------------------------------------------------------------------
echo

echo "Spread created: $c of $l                                         " >&2



#----------------------------------------------------------------------
# vim:set ts=4 sw=4 :
