#!/bin/bash
shopt -s nullglob extglob

#----------------------------------------------------------------------
# 
# TIP: It is better to think of a visual book as a set of spreads 
#		rather than a set of pages, hence the focus on spreads in the 
#		code below.
#		The main unit of a "visual" book is a spread, it's the thing 
#		you see when you hold the book open, and the main workflow 
#		when building a book is creating spreads and ordering them so 
#		a single page is almost never treated as an independent unit.
# TIP: it is not recommended to use too many templates, the layout 
#		should be and feel structured and this structure should not be 
#		too complex for the average reader to get comfortable in.
# 
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# Template structure:
#	templates/
#		spread.tex
#		imagepage.tex
#		textpage.tex
#		...
#	captions/
#		<image>.txt
#			image caption.
#			this is separated to decouple caption writing from the 
#			changes to the layout/sequencing and this drastically 
#			simplify the work with writers.
#			For this reason this takes priority over local captions (XXX revise).
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
#						replaced with image path
#					${CAPTION0}
#						replaced with content of caption file if found
#						and empty otherwise.
#					${TEXT0}
#						replaced with the content of a text file if 
#						found and empty otherwise.
#					...
#				NOTE: if images are included, hi-res source
#					substitution is not done here.
#				NOTE: fields are ordered and matched according to their
#					position and not their number, e.g. in the following 
#					sequence:
#						IMAGE, IMAGE10, IMAGE20, ..,
#						CAPTION2, CAPTION7, CAPTION12, ..
#					IMAGE10 will be filled with the second found image 
#					and CAPTION7 will be filled with the second found 
#					caption.
#			<spread-template-name>.tpl
#				indicates the spread template to use.
#				if given the rest of the .tex files in 
#				directory are ignored.
#				resolves to:
#					templates/<spread-template-name>.tex
#				fields:
#					${IMAGE0}
#					${CAPTION0}
#					${TEXT0}
#					...
#			imagepage.tex
#				image page template.
#				fields:
#					${IMAGE}
#					${CAPTION}
#					${TEXT0}
#					...
#			textpage.tex
#				text page template.
#				fields:
#					${TEXT}
#					...
#			<spread-template-name>-imagepage.tpl
#			<spread-template-name>-textpage.tpl
#				indicates the image/text page template to use.
#				ignored if explicit templates are given.
#				fields:
#					${IMAGE}
#					${CAPTION}
#					${TEXT}
#					...
#			00-<image>.png
#				image.
#				if $IMAGE_HIRES_DIR is set then this will 
#				resolve to:
#					$IMAGE_HIRES_DIR/<image>
#				supported formats:
#					.jpeg, .png, .pdf, .svg, .eps 
#					(see $IMAGE_FORMATS)
#			00-<image>.txt
#				local image caption text.
#				NOTE: this must be named the same as the image.
#			01-<text>.txt
#				text.
#			...
#		...
#
#
# Env variables:
#	ANOTATE_IMAGE_PATHS=
#	TEXT_FORMATS=<ext>|..
#	IMAGE_FORMATS=<ext>|..
#	IMAGE_DIR=<path>
#	IMAGE_HIRES_DIR=<path>
#		sets the path to which the hi-res images are resolved.
#	CAPTION_DIR=<path>
#	TEMPLATE_DIR=<path>
#	EMPTY_PAGE=<name>
#	TEXT_PAGE=<name>
#	IMAGE_PAGE=<name>
#	IMAGE_SPREAD=<array>
#
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# XXX COUNT semantics are off, update docs/code...
#
#
#
#----------------------------------------------------------------------

# load config...
CONFIG=${CONFIG:=$(basename ${0%.*}).cfg}
[ -e $CONFIG ] \
	&& source "$CONFIG"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# defaults...
# NOTE: all of these options can be either set in the $CONFIG file or 
#		set in the script env.
# NOTE: env takes priority over $CONFIG

# if set add pdf annotations of paths to each image...
ANOTATE_IMAGE_PATHS=${ANOTATE_IMAGE_PATHS:=}

# supported formats/extensions...
TEXT_FORMATS=${TEXT_FORMATS:=txt}
IMAGE_FORMATS=${IMAGE_FORMATS:=jpeg|jpg|png|pdf|svg|eps}

IMAGE_DIR=${IMAGE_DIR:=pages/}
IMAGE_HIRES_DIR=${IMAGE_HIRES_DIR:=}
CAPTION_DIR=${CAPTION_DIR:=captions/}
TEMPLATE_DIR=${TEMPLATE_DIR:=templates/}

# Default timplates
# NOTE: if a template is not found we will try and build a spread from 
#		page components...

# page templates...
EMPTY_PAGE=${EMPTY_PAGE:=emptypage}
TEXT_PAGE=${TEXT_PAGE:=textpage}
IMAGE_PAGE=${IMAGE_PAGE:=imagepage}

# dynamic spread templates...
# NOTE: the index here corresponds to the number of images found in a 
#		spread directory...
IMAGE_SPREAD=${IMAGE_SPREAD:=(
	[0]=text-spread
	[1]=imagebleedleft
	[2]=image-image
)}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# post-process config...

# prep format regexps...
TEXT_FORMATS='.*\.('$TEXT_FORMATS')$'
IMAGE_FORMATS='.*\.('$IMAGE_FORMATS')$'



#----------------------------------------------------------------------

printhelp(){
	echo "Usage: `basename $0` [ARGUMENTS] [PATH]"
	echo "       `basename $0` [ARGUMENTS] PATH FROM [COUNT]"
	echo
	echo "Generate LaTeX layout from directory structure."
	echo
	echo "Arguments:"
	echo "  -h --help   - print this help and exit."
	echo "  -a --annotate"
	echo "              - add annotations with image paths to pages."
	echo "  --templates=PATH"
	echo "              - path to search for templates (default: $TEMPLATE_DIR)."
	echo "  --single-image-tpl=NAME"
	echo "              - single image default template (default: ${IMAGE_SPREAD[1]})."
	echo "  --double-image-tpl=NAME"
	echo "              - double image default template (default: ${IMAGE_SPREAD[2]})."
	echo "  --text-spread-tpl=NAME"
	echo "              - text spread default template (default: ${IMAGE_SPREAD[0]})."
	echo "  --captions=PATH"
	echo "              - path to search for captions (default: $CAPTION_DIR)."
	echo
	echo "Parameters:"
	echo "  PATH        - path to root pages directory (default: $IMAGE_DIR)"
	echo "  FROM        - spread to start from (default: 0)"
	echo "  COUNT       - number of spreads to generate (default: 1)"
	echo
	echo "Environment:"
	echo "  \$IMAGE_HIRES_DIR "
	echo "              - source directory for replacement hi-res images."
	echo "  \$ANOTATE_IMAGE_PATHS "
	echo "              - if true add image paths in anotations."
	echo "  \$CONFIG   - sets the config file name (default: $CONFIG)"
	echo
	echo "Configuration defaults can be stored in a config file: $CONFIG"
	echo
	echo "NOTE: COUNT is relevant iff FROM is given, otherwise all available "
	echo "        spreads are generated."
	echo
	echo "Examples:"
	echo "  $ `basename $0` ./pages > pages.tex"
	echo "              - generate a layout fron the contents of ./pages"
	echo
	echo "  $ IMAGE_HIRES_DIR=images/hi-res `basename $0` ./pages"
	echo "              - generate a layout fron the contents of ./pages and "
	echo "                replaceing local images with images in ./images/hi-res"
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
		-a|--annotate)
			ANOTATE_IMAGE_PATHS=1
			shift
			;;

		--templates)
			TEMPLATE_DIR=$2
			shift
			shift
			;;
		--single-image-tpl)
			IMAGE_SPREAD[1]=$2
			shift
			shift
			;;
		--double-image-tpl)
			IMAGE_SPREAD[2]=$2
			shift
			shift
			;;
		--text-spread-tpl)
			IMAGE_SPREAD[0]=$2
			shift
			shift
			;;
		--captions)
			CAPTION_DIR=$2
			shift
			shift
			;;

		# handle unknown options...
		-*|--*)
			echo "Error: unknown option \"$1\""
			exit
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


# calculate spread index range...
# XXX add support for negative indexing...
FROM=$2
COUNT=$( [ -z $3 ] && echo 1 || echo $3 )
STOP=$(( FROM + COUNT ))



#----------------------------------------------------------------------

# Get image caption...
# usage:
#	getCaption SPREAD IMAGE
getCaption(){
	local spread=$1
	local name=`basename "${2%.*}"`

	local captions=(
		"$CAPTION_DIR/${name}.txt"
		"${spread}/${name}.txt"
	)

	local caption
	for caption in "${captions[@]}" ; do
		if [ -e "${caption}" ] ; then
			echo ${caption}
			return
		fi
	done
}


# Read/print caption text...
# usage:
#	readCaption PATH
readCaption(){
	[ -z "$1" ] \
		&& return 1
	cat "$1" \
		| sed -e 's/\\/\\\\\\/g'
}


# Get template...
# usage:
#	getTemplate SPREAD TYPE
#
getTemplate(){
	local SPREAD=$1
	local TYPE=$2
	local TEMPLATE=($SPREAD/*-$TYPE.tex)
	if [ -z $TEMPLATE ] ; then
		TEMPLATE=($SPREAD/*-$TYPE.tpl)
		if ! [ -z $TEMPLATE ] ; then
			TEMPLATE=${TEMPLATE/$SPREAD\//}
			TEMPLATE=${TEMPLATE/[0-9]-/}
			TEMPLATE="$TEMPLATE_DIR/${TEMPLATE[0]%-${TYPE}.*}.tex"
		fi
	fi
	if [ -z $TEMPLATE ] ; then
		 TEMPLATE="$TEMPLATE_DIR/${TYPE}.tex"
	fi
	if ! [ -e $TEMPLATE ] ; then
		return
	fi
	echo $TEMPLATE
}


# Get template slots (cached)...
# usage:
#	templateSlots TEMPLATE
declare -A TEMPLATE_INDEX
templateSlots(){
	# cache the vars...
	#if [ ${TEMPLATE_INDEX[$1]+_} ] ; then
	if [ -z ${TEMPLATE_INDEX[$1]} ] ; then
		TEMPLATE_INDEX[$1]=$(cat "$1" \
			| grep -o '\${[A-Z0-9_]\+}' \
			| sed 's/\${\(.*\)}/\1/g' \
			| sort -V)
	fi
	echo ${TEMPLATE_INDEX[$1]}
}


# Populate template image/text slots
# usage:
#	populateTemplate SPREAD TEMPLATE ITEMS...
#
populateTemplate(){
	local spread="$1"
	local tpl="$2"
	[ -e "$tpl" ] \
		|| return 1
	local slots=( $(templateSlots "${tpl}") )
	local text=$(cat "${tpl}")

	# items/img/txt...
	shift 2
	local items=("$@")
	if [ ${#items[@]} = 0 ] ; then
		items=( $spread/* )
	fi
	local img=()
	local txt=()
	local elem
	for elem in "${items[@]}" ; do
		if [[ "$elem" =~ $IMAGE_FORMATS ]] ; then
			img+=("$elem")
		elif [[ "$elem" =~ $TEXT_FORMATS ]] ; then
			txt+=("$elem")
		fi
	done

	local var
	local val
	local index=()
	local captions=()
	local name
	# pass 1: images...
	# NOTE: we are doing this in three passes as caption and image slots
	#		can be included in the template in any order but the captions
	#		need all the images to be fully populated/indexed (passes 1 
	#		and 2), and text is done as a separate pass to prevent it 
	#		from competing with captions.
	local i=0
	for var in ${slots[@]} ; do
		name=${var//[0-9]/}
		if ! [ ${name} = "IMAGE" ] ; then
			continue
		fi

		val=${img[$i]}
		# index images for caption retrieval...
		index[${var/$name/}]="$val"
		# warn if no image found for slot...
		if [ -z ${val} ] ; then
			echo %
			{
				echo "% WARNING: image #${i} requested but not found"
				echo "%     in: ${tpl}"
				echo "%     by: ${spread}"
			} | tee >(cat >&2)
			echo %
		fi
		i=$(( i + 1 ))

		val=${val//\//\\/}
		text=$(echo -e "${text}" | \
			sed "s/\${${var}}/${val%.*}/g")
	done

	# pass 2: captions...
	for var in ${slots[@]} ; do
		name=${var//[0-9]/}
		if ! [ ${name} = "CAPTION" ] ; then
			continue
		fi

		# get global caption...
		val=$(getCaption "$spread" "${index[${var/$name/}]}" "${txt[@]}")

		if [ -n "${val}" ] ; then
			# clear the used texts... (XXX test)
			for i in "${!txt[@]}" ; do
				[ "$val" = "${txt[$i]}" ] \
					&& unset "txt[$i]"
			done
			val=$(readCaption "${val}")
		fi

		text=$(echo -e "${text}" | \
			sed "s/\${${var}}/${val}/g")
	done

	# pass 3: texts...
	for var in ${slots[@]} ; do
		name=${var//[0-9]/}
		if [ ${name} = "CAPTION" ] || [ ${name} = "IMAGE" ] ; then
			continue
		fi

		val=
		for i in ${!txt[@]} ; do
			# NOTE: we do not care as much if not text is found...
			val=${txt[$i]}
			unset "txt[$i]"
			# we only need the first text...
			break
		done

		val=${val//\//\\/}
		text=$(echo -e "${text}" | \
			sed "s/\${${var}}/${val}/g")
	done

	# print out the filled template...
	echo % template: $tpl
	echo -e "${text}"
	return 0
}


# Handle/print spread...
# usage:
#	handleSpread SPREAD
#
# closure: $IMAGE_HIRES_DIR, $IMAGE_SPREAD
handleSpread(){
	local spread="$1"
	# skip non-spreads...
	[ -d "$spread" ] \
		|| return 1

	# auto layout / templates...
	# NOTE: to use a specific template just `touch <template-name>.tpl`
	#	in the spread directory...

	# layout tweaks...
	local tweaks=($spread/*tweak.tex)
	if ! [ -z ${tweaks} ] ; then
		echo "% tweaks: ${tweaks[0]}"
		cat ${tweaks[0]}
	fi

	# collect images and text...
	# NOTE: we are filling these manually to support configurable 
	#		image/text patterns...
	local img=()
	local txt=()
	local items=()
	for elem in "$spread"/* ; do
		if [[ "$elem" =~ $IMAGE_FORMATS ]] ; then
			img+=("$elem")
			items+=("$elem")
		elif [[ "$elem" =~ $TEXT_FORMATS ]] ; then
			txt+=("$elem")
			items+=("$elem")
		fi
	done

	# get hi-res image paths...
	if ! [ -z $IMAGE_HIRES_DIR ] ; then
		local C=0
		for image in "${img[@]}" ; do
			# skip non-images...
			local new="$IMAGE_HIRES_DIR/`basename ${image/[0-9]-/}`"
			# ignore file ext for availability test...
			# NOTE: the first match may be an unsupported format...
			new="${new%.*}"
			new=($new.*)
			if [ -e "${new[0]}" ] ; then
				img[$C]=${new[0]}
			else
				echo %
				echo "% WARNING: hi-res image not found for: \"${image}\" -> \"${new}\"" \
					| tee >(cat >&2)
				echo %
			fi
			C=$(( C + 1 ))
		done
	fi

	# manual layout...
	local template
	local layout=( $spread/*layout.tex )
	if ! [ -z $layout ] ; then
		template=${layout[0]}

	# templates and partial templates...
	else
		local template=( $spread/*.tpl )
		# skip page template refs: *-imagepage.tpl / *-textpage.tpl
		# XXX this will also eat 0-imagepage.tpl / 20-textpage.tpl -- do a better pattern...
		if ! [ -z $template ] ; then
			template=(`ls "$spread/"*.tpl \
				| egrep -v '.*-('${IMAGE_PAGE}'|'${TEXT_PAGE}')\.tpl'`)
		fi
		# no template explicitly defined -> match auto-template...
		if [ -z $layout ] && [ -z $template ] ; then
			# N images...
			if [ -z $template ] && [ -n "${IMAGE_SPREAD[${#img[@]}]}" ] ; then
				template=$(getTemplate "$spread" "${IMAGE_SPREAD[${#img[@]}]}")
			fi
			# build spread from pages...
			if [ -z $template ] ; then
				local C=0
				local P
				local elem
				# only one page in spread...
				# NOTE since the right page is more important we prioritize 
				#		it over the left page, placing the blank left...
				if [ ${#items[@]} = 1 ] ; then
					C=1
					echo "%"
					echo "% empty page..."
					template=$(getTemplate "$spread" "$EMPTY_PAGE")
					if [ -z "$teplate" ] ; then
						echo "\\null"
						echo "\\newpage"
					else
						cat "${template}"
					fi
				fi
				for elem in "${items[@]}" ; do
					C=$(( C + 1 ))
					P=$([ $C == 1 ] \
						&& echo "left" \
						|| echo "right")

					# XXX need to use populateTemplate here...
					#		...to do this need to somehow remove the used
					#		slots/files from list...

					# image...
					if [[ "$elem" =~ $IMAGE_FORMATS ]] ; then
						echo %
						echo "% $P page (image)..."
						template=`getTemplate "$spread" "$IMAGE_PAGE"`
						echo % template: $template
						anotatePath "${elem}"
						local caption=$(getCaption "$spread" "${elem}")
						caption=$(readCaption "$caption")
						cat "${template}" \
							| sed -e "s%\${IMAGE0\?}%${elem%.*}%" \
								-e "s%\${CAPTION0\?}%${caption}%"
					# text...
					else
						echo %
						echo "% $P page (text)..."
						template=$(getTemplate "$spread" "$TEXT_PAGE")
						echo % template: $template
						cat "${template}" \
							| sed "s%\${TEXT}%${elem}%"
					fi
					# reset for next page...
					template=
					# ignore the rest of the items when we are done 
					# creating two pages...
					[ $C == 2 ] \
						&& return 0
				done
			fi
		fi
		# formatting done...
		[ -z $template ] \
			&& return 0

		# format template path...
		template=${template/$spread\//}
		template=${template/[0-9]-/}
		# get...
		template="${template[0]%.*}.tex"
		if ! [ -e "$template" ] ; then
			template="$TEMPLATE_DIR/${template[0]%.*}.tex"
		fi
	fi

	populateTemplate "$spread" "$template" "${img[@]}" "${txt[@]}"

	return 0
}


# Add pdf notes with image path used in template
# usage:
#	anotatePath PATH
#
anotatePath(){
	if [ -z "$1" ] || [ -z "$ANOTATE_IMAGE_PATHS" ] ; then
		return
	fi
	path=$(basename ${1%.*})
	# NOTE: did not figure out how to make a verbatim comment in latex 
	#		so here we are, doing it in shell...
	path=${path//_/\\_}
	#echo "\\pdfmargincomment{Image: $path}%"
	echo "\\pdfcommentcell{Image: $path}%"
}



#----------------------------------------------------------------------
# generate the template...

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

l=$(ls "$IMAGE_DIR/" | wc -l)
c=0
d=0
SPREADS=("$(ls "${IMAGE_DIR}" | sort -n)")
for spread in ${SPREADS[@]} ; do
	spread="${IMAGE_DIR}/${spread}"

	# skip non-spreads...
	if ! [ -d "$spread" ] ; then
		continue
	fi
	# skip temporarily disabled...
	if [[ "${spread}" =~ -.* ]] ; then
		SKIP_FIRST=1
		echo "% spread: ${spread/-/}: skipped..." | tee >(cat >&2)
		echo %
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

	printf "Spread ($c/$l): ${spread/-/}                         \r" >&2
	echo "% spread: ${spread/-/}"
	handleSpread "$spread"

	d=$(( d + 1 ))
done

echo %
echo %
echo %
echo %----------------------------------------------------------------------
echo

echo "Spread created: $d of $l                                         " >&2



#----------------------------------------------------------------------
# vim:set ts=4 sw=4 :
