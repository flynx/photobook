#!/usr/bin/env bash
shopt -s nullglob extglob

#----------------------------------------------------------------------
#
# For docs see README.md
#
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# XXX DOC:
#		$spread/
#			...
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
#			...
#
#
#
#----------------------------------------------------------------------
# load config...

CONFIG=${CONFIG:=$(basename ${0%.*}).cfg}
# prepend CFG_ to settings in config...
# NOTE: this is done to prevent them overriding the environment...
[ -e $CONFIG ] \
	&& eval $(cat "$CONFIG" \
		| sed -e 's/^\(\s*\)\([A-Z_]\+=\)/\1CFG_\2/')


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# defaults...
#
# NOTE: all of these options can be either set in the $CONFIG file or 
#		set in the script env.
# NOTE: env takes priority over $CONFIG

# if set add pdf annotations of paths to each image...
ANOTATE_IMAGE_PATHS=${ANOTATE_IMAGE_PATHS:=$CFG_ANOTATE_IMAGE_PATHS}
ANOTATE_IMAGE_PATHS=${ANOTATE_IMAGE_PATHS:=}

# supported formats/extensions...
TEXT_FORMATS=${TEXT_FORMATS:=$CFG_TEXT_FORMATS}
TEXT_FORMATS=${TEXT_FORMATS:=txt}
TEXT_FORMATS=${TEXT_FORMATS,,}

IMAGE_FORMATS=${IMAGE_FORMATS:=$CFG_IMAGE_FORMATS}
IMAGE_FORMATS=${IMAGE_FORMATS:=jpeg|jpg|png|pdf|svg|eps}
IMAGE_FORMATS=${IMAGE_FORMATS,,}


SPREADS_DIR=${SPREADS_DIR:=$CFG_SPREADS_DIR}
SPREADS_DIR=${SPREADS_DIR:=spreads/}

IMAGE_HIRES_DIR=${IMAGE_HIRES_DIR:=$CFG_IMAGE_HIRES_DIR}
IMAGE_HIRES_DIR=${IMAGE_HIRES_DIR:=}

CAPTION_DIR=${CAPTION_DIR:=$CFG_CAPTION_DIR}
CAPTION_DIR=${CAPTION_DIR:=captions/}

TEMPLATE_DIR=${TEMPLATE_DIR:=$CFG_TEMPLATE_DIR}
TEMPLATE_DIR=${TEMPLATE_DIR:=templates/}

# Default templates
# NOTE: if a template is not found we will try and build a spread from 
#		page components...

# page templates...
EMPTY_PAGE=${EMPTY_PAGE:=$CFG_EMPTY_PAGE}
EMPTY_PAGE=${EMPTY_PAGE:=emptypage}

TEXT_PAGE=${TEXT_PAGE:=$CFG_TEXT_PAGE}
TEXT_PAGE=${TEXT_PAGE:=textpage}

IMAGE_PAGE=${IMAGE_PAGE:=$CFG_IMAGE_PAGE}
IMAGE_PAGE=${IMAGE_PAGE:=imagepage}

# dynamic spread templates...
# NOTE: the index here corresponds to the number of images found in a 
#		spread directory...
if [ ${#IMAGE_SPREAD[@]} = 0 ] ; then
	if [ ${#CFG_IMAGE_SPREAD[@]} != 0 ] ; then
		IMAGE_SPREAD=()
		for i in ${!CFG_IMAGE_SPREAD[@]} ; do
			IMAGE_SPREAD[$i]=${CFG_IMAGE_SPREAD[$i]}
		done
	else
		IMAGE_SPREAD=(
			[0]=text-spread
			[2]=image-image
		)
	fi
fi



#----------------------------------------------------------------------

printhelp(){
	echo "Usage: `basename $0` [ARGUMENTS] [PATH]"
	echo "       `basename $0` [ARGUMENTS] PATH INDEX"
	echo "       `basename $0` [ARGUMENTS] PATH FROM COUNT"
	echo
	echo "Generate LaTeX layout from directory structure."
	echo
	echo "Arguments:"
	echo "  -h --help   - print this help and exit."
	echo "  -c PATH     - load configuration from PATH."
	echo "  -a --annotate"
	echo "              - add annotations with image paths to pages."
	echo "  --templates PATH"
	echo "              - path to search for templates (default: $TEMPLATE_DIR)."
	echo "  --single-image-tpl NAME"
	echo "              - single image default template (default: ${IMAGE_SPREAD[1]})."
	echo "  --double-image-tpl NAME"
	echo "              - double image default template (default: ${IMAGE_SPREAD[2]})."
	echo "  --text-spread-tpl NAME"
	echo "              - text spread default template (default: ${IMAGE_SPREAD[0]})."
	echo "  --captions PATH"
	echo "              - path to search for captions (default: $CAPTION_DIR)."
	echo "  --graphicx-path"
	echo "              - reference images by their basenames and let graphicx manage"
	echo "                searching."
	echo
	echo "Parameters:"
	echo "  PATH        - path to root pages directory (default: $SPREADS_DIR)"
	echo "  INDEX       - index of spread to generate"
	echo "  FROM        - spread to start from"
	echo "  COUNT       - number of spreads to generate"
	echo
	echo "Environment:"
	echo "  \$IMAGE_HIRES_DIR "
	echo "              - source directory for replacement hi-res images."
	echo "  \$ANOTATE_IMAGE_PATHS "
	echo "              - if true add image paths in anotations."
	echo "  \$CONFIG     - sets the config file name (default: $CONFIG)"
	echo "  \$TEXT_FORMATS "
	echo "              - list of file extensions treated as text (default: $TEXT_FORMATS)."
	echo "  \$IMAGE_FORMATS "
	echo "              - list of file extensions treated as images"
	echo "                (default: $IMAGE_FORMATS)."
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
			continue
			;;
		-c)
			$CONFIG="$2"
			[ -e "$CONFIG" ] \
				&& source "$CONFIG"
			shift 2
			continue
			;;

		--templates)
			TEMPLATE_DIR=$2
			shift 2
			continue
			;;
		--single-image-tpl)
			IMAGE_SPREAD[1]=$2
			shift 2
			continue
			;;
		--double-image-tpl)
			IMAGE_SPREAD[2]=$2
			shift 2
			continue
			;;
		--text-spread-tpl)
			IMAGE_SPREAD[0]=$2
			shift 2
			continue
			;;
		--captions)
			CAPTION_DIR=$2
			shift 2
			continue
			;;
		--graphicx-path)
			GRAPHICX_PATH=1
			shift
			continue
			;;

		# handle unknown options...
		-*|--*)
			echo "Error: unknown option \"$1\"" >&2
			exit
			;;

		*)
			break
			;;
	esac
done


if [ -z $1 ] ; then
	SPREADS_DIR=spreads/
else
	SPREADS_DIR=$1/
fi


# calculate spread index range...
# XXX add support for negative indexing...
FROM=$2
COUNT=$( [ -z $3 ] && echo 1 || echo $3 )
STOP=$(( FROM + COUNT ))


# prep format regexps...
TEXT_FORMATS='.*\.('$TEXT_FORMATS')$'
IMAGE_FORMATS='.*\.('$IMAGE_FORMATS')$'



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
	local spread=$1
	local name=$2
	local template

	if [[ $name =~ .*\.tex ]] ; then 
		# already an existing template...
		if [ -e "$name" ] ; then
			echo $name
			return
		fi
		# normalize...
		name=${name%.tex}
	# normalize template name...
	elif [[ $name =~ .*\.tpl ]] ; then
		name=$( echo $name \
			| sed \
				-e 's/.tpl$//' \
				-e "s%$spread/%%" \
				-e 's/^[0-9]\+-//' )
	fi

	# local template...
	template=($spread/*-$name.tex)
	if [ ${#template[@]} != 0 ] ; then
		template=${template[0]}
	else
		template=($spread/$name.tex)
	fi
	# global template...
	if [ -z $template ] \
			|| ! [ -e "$template" ] ; then
		 template="$TEMPLATE_DIR/${name}.tex"
	fi
	# check if the thing exists...
	if ! [ -e $template ] ; then
		return 1
	fi
	echo $template
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
# closure: $populateTemplate_img, $populateTemplate_txt
#
# NOTE: this is the least hacky/ugly but could not figure out a better 
#		way to update a list from within a function...
populateTemplate_img=
populateTemplate_txt=
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
		if [[ "${elem,,}" =~ $IMAGE_FORMATS ]] ; then
			img+=("$elem")
		elif [[ "${elem,,}" =~ $TEXT_FORMATS ]] ; then
			txt+=("$elem")
		fi
	done
	local global_img=
	if ! [ -z $populateTemplate_img ] ; then 
		global_img=1
		img=(${populateTemplate_img[@]})
	fi
	local global_txt=
	if ! [ -z $populateTemplate_txt ] ; then
		global_txt=1
		txt=(${populateTemplate_txt[@]})
	fi

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
		if [ ${name} != "IMAGE" ] ; then
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
		text=$(echo "${text}" | \
			sed "s/\${${var}}/${val%.*}/g")
	done
	if ! [ -z $global_img ] ; then
		populateTemplate_img=("${populateTemplate_img[@]:$i}")
	fi

	# pass 2: captions...
	for var in ${slots[@]} ; do
		name=${var//[0-9]/}
		if [ ${name} != "CAPTION" ] ; then
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

		text=$(echo "${text}" | \
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
		text=$(echo "${text}" | \
			sed "s/\${${var}}/${val}/g")
	done
	if ! [ -z $global_txt ] ; then
		populateTemplate_txt=("${txt[@]}")
	fi

	# print out the filled template...
	echo % template: $tpl
	echo "${text}"
	return
}


# Handle/print spread...
# usage:
#	handleSpread SPREAD
#
# closure: $GRAPHICX_PATH, $IMAGE_HIRES_DIR, $IMAGE_SPREAD
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
		if [[ "${elem,,}" =~ $IMAGE_FORMATS ]] ; then
			img+=("$elem")
			items+=("$elem")
		elif [[ "${elem,,}" =~ $TEXT_FORMATS ]] ; then
			txt+=("$elem")
			items+=("$elem")
		fi
	done

	# graphicx paths...
	if ! [ -z $GRAPHICX_PATH ] ; then
		local C=0
		for image in "${img[@]}" ; do
			local new=`basename ${image}`
			new="${new#+([0-9])-}"
			img[$C]=$new
			C=$(( C + 1 ))
		done
	# get hi-res image paths...
	elif ! [ -z $IMAGE_HIRES_DIR ] ; then
		local C=0
		for image in "${img[@]}" ; do
			# skip non-images...
			local new=`basename ${image}`
			new="$IMAGE_HIRES_DIR/${new#+([0-9])-}"
			# ignore file ext for availability test...
			# NOTE: the first match may be an unsupported format...
			new="${new%.*}"
			local target=$new
			new=($new.*)
			if [ -e "${new[0]}" ] ; then
				img[$C]=${new[0]}
			else
				echo %
				echo "% WARNING: hi-res image not found for: \"${image}\" -> \"${target}\"" \
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
				populateTemplate_img=("${img[@]}")
				populateTemplate_txt=("${txt[@]}")

				for elem in "${items[@]}" ; do
					C=$(( C + 1 ))
					P=$([ $C == 1 ] \
						&& echo "left" \
						|| echo "right")

					# image...
					if [[ "${elem,,}" =~ $IMAGE_FORMATS ]] ; then
						echo %
						echo "% $P page (image)..."
						template=`getTemplate "$spread" "$IMAGE_PAGE"`
						populateTemplate "$spread" "$template" 
					# text...
					else
						echo %
						echo "% $P page (text)..."
						template=$(getTemplate "$spread" "$TEXT_PAGE")
						populateTemplate "$spread" "$template" 
					fi
					# reset for next page...
					template=
					# ignore the rest of the items when we are done 
					# creating two pages...
					if [ $C == 2 ] ; then
						populateTemplate_img=
						populateTemplate_txt=
						return
					fi
				done
			fi
		fi
		# formatting done...
		[ -z $template ] \
			&& return

		# resolve the template path...
		local p=$template
		template=$(getTemplate "$spread" "$template")

		# not found...
		if [ -z $template ] ; then
			echo "%"
			echo "% ERROR: could not resolve template: $p" | tee >(cat >&2)
			echo "%"
		fi
	fi

	populateTemplate_img=
	populateTemplate_txt=
	populateTemplate "$spread" "$template" "${img[@]}" "${txt[@]}"

	return $?
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
echo % WARNING: This file is auto-generated by make-spreads.sh and will be 
echo "%          overwritten on next run..."
echo %
echo "% Image source (preview): \"$SPREADS_DIR\""
echo "% Image source (hi-res): \"$IMAGE_HIRES_DIR\""
echo %
echo %----------------------------------------------------------------------
echo %

l=$(ls "$SPREADS_DIR/" | wc -l)
c=0
d=0
SPREADS=("$(ls "${SPREADS_DIR}" | sort -n)")
for spread in ${SPREADS[@]} ; do
	spread="${SPREADS_DIR}/${spread}"

	# skip non-spreads...
	if ! [ -d "$spread" ] ; then
		l=$(( l - 1 ))
		continue
	# skip temporarily disabled...
	elif [[ "${spread}" =~ [\\\/]-.*$ ]] ; then
		SKIP_FIRST=1
		echo "% spread: ${spread}: skipped..." | tee >(cat >&2)
		continue
	fi

	c=$(( c + 1 ))

	# if $FROM is given print only stuff in range...
	[ -z $FROM ] \
		|| if (( $(( c - 1 )) < $FROM )) || (( $c > $STOP )) ; then
			continue
		fi

	# if we are building only a specific spread...
	##if ! [ -z $SPREAD ] && [[ "$spread" != "$SPREADS_DIR/$SPREAD" ]]; then
	##	continue
	##fi

	if ! [ -z $SKIP_FIRST ] ; then
		echo %
		echo %
		echo % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	fi
	SKIP_FIRST=1

	printf "Spread ($c/$l): ${spread}                         \r" >&2
	echo "% spread: ${spread}"
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
#                                            vim:set ts=4 sw=4 nowrap :
