%----------------------------------------------------------------------
%
%
% This does the following:
%	- sets up the document/pdf for viewing as a book
%	- adds support for page bleeds
%	- adds basic templates for image pages (XXX)
%
%
% XXX BUG: fix \OFFSETFIX
% XXX BUG: fix \CAPTIONWIDTHFIX
% XXX BUG: there seems to be a slight offset bias...
%
%
%----------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}

% XXX set release date...
\ProvidesClass{photobook}[2021/07/28 Photo book Latex class]


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

\RequirePackage{calc}
\RequirePackage{xargs}
\RequirePackage{iftex}
\RequirePackage{kvoptions}
\RequirePackage{etoolbox}
\RequirePackage{atbegshi}
\RequirePackage[unicode]{hyperref}
\RequirePackage{graphicx}
\RequirePackage{geometry}
\RequirePackage{eso-pic}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Helpers...

\newcommand\@DeclareLiteralOptionTo[2]{%
	\DeclareVoidOption{#2}{%
		\expandafter\edef\csname photobook@#1\endcsname{#2}}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% options...

% pdf layout...
%
% see: hyperref's pdfpagelayout for more options...
\DeclareStringOption[TwoPageRight]{pdfpagelayout}[TwoPageRight]
\@DeclareLiteralOptionTo{pdfpagelayout}{SinglePage}
\@DeclareLiteralOptionTo{pdfpagelayout}{OneColumn}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoColumnRight}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoColumnLeft}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoPageRight}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoPageLeft}


% page geometry...
%
%   <---> bleed                                 <---> innerbleed
%
%   + - - - - - - - - - - - - - - - - - - - - - + - +   ^
%   .                                           .   .   | bleed
%   .   +---------------------------------------+   .   v   .   .  ---
%   .   |                           ^       .   =   .
%   .   |   .   .   .   .   .   .   |   .   .   =   .               ^
%   .   |<-- blockwidth ------------------------>=   .               |
%   .   |   .                       |   .   .   =   .               |
%   .   |                           |       .   =   .       textheight
%   .   |   .                       |   .   .   =   .               |
%   .   |                       blockheight  .   =   .               |
%   .   |   .                       |   .   .   =   .               |
%   .   |                           |       <---> bindingoffset     |
%   .   |   .   .   .   .   .   .   |   .   .   =   .               v
%   .   |                           v       .   =   .
%   .   +---------------------------------------+   .   ^   .   .  ---
%   .   .                                       .   .   | bleed
%   + - - - - - - - - - - - - - - - - - - - - - + - +   v
%       .                                       .
%       |   <-- textwidth -------------->   .   |
%                                               ^ binding line
%
% NOTE: innerbleed defaults to bleed...
% NOTE: if blockwidth/blockheight are set they will force recalculations 
%		and overriding of the paperwidth/paperheight if they were changed
%		by the user code anywhere between \documentclass[..]{photobook}
%		and \begin{document}...
\DeclareStringOption[5mm]{bleed}[5mm]
\DeclareStringOption{innerbleed}
% XXX do we need to rename these??? (used by lualatex??)
\DeclareStringOption{blockwidth}
\DeclareStringOption{blockheight}
\DeclareStringOption[0]{bindingoffset}[10mm]

% Image block size relative to text block...
%
% XXX not yet used...
% XXX better name...
\DeclareStringOption[0.85]{imageblockwidth}[1]
\DeclareStringOption[0.85]{imageblockheight}[1]
\DeclareStringOption[-0.05]{imageblockoffsettop}[0]

\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessKeyvalOptions*


% Parent class...
%
\LoadClass[9pt, final, openany]{book}



%----------------------------------------------------------------------
% Globals...

% NOTE: page and bleed block sizes are set via \RecalculatePageLengths
\newlength\blockwidth
\newlength\blockheight
% NOTE: these are equivalent to \paperwidth and \paperheight but are 
%		independent of them...
\newlength\bleedblockwidth
\newlength\bleedblockheight

\newlength\bleed
\setlength\bleed{\photobook@bleed}

\newlength\innerbleed
\setlength\innerbleed{
	\ifx\photobook@innerbleed\empty
		\bleed
	\else
		\photobook@innerbleed
	\fi }

\newlength\bindingoffset
\setlength\bindingoffset{\photobook@bindingoffset}

\edef\imageblockwidth{\photobook@imageblockwidth}

\edef\imageblockheight{\photobook@imageblockheight}

\edef\imageblockoffsettop{\photobook@imageblockoffsettop}

% distance from image to paper border (clearence) for full-page images.
%
% - negative value set bleed siae, 
% - positive value set distance frome paper edge to image.
%
% XXX for some reason this is not even around the page and is less on 
%	the left -- \OFFSETFIX is used to compensate for this effect...
%	...need to find a real fix...
% XXX make configurable...
\newlength{\clearimage}
\setlength{\clearimage}{-4mm}



%----------------------------------------------------------------------
% Commands...

\newcommand\RecalculatePageLengths{
	% final page size...
	\setlength\blockwidth{
		\ifx\photobook@blockwidth\empty
			\dimexpr \paperwidth - \bleed - \innerbleed \relax
		\else
			\photobook@blockwidth
		\fi}
	\setlength\blockheight{
		\ifx\photobook@blockheight\empty
			\dimexpr \paperheight - 2\bleed \relax
		\else
			\photobook@blockheight
		\fi }
	% page with bleeds...
	% NOTE: this is essentially \paperwidth and \paperheight but we do 
	%		not rely on them being defined -- photobook settings take 
	%		priority over \paperwidth and \paperwidth...
	\setlength\bleedblockwidth{\dimexpr 
		\bleed + \blockwidth + \innerbleed 
		\relax}
	\setlength\bleedblockheight{\dimexpr 
		2\bleed + \blockheight 
		\relax} }


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% update global values...

\RecalculatePageLengths



%----------------------------------------------------------------------
% Setup...

\AtEndPreamble{

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Metadata...

	\hypersetup{
		pdfinfo={
			Title={\@title},
			Subject={\@subject},
			Author={\@author},
			Keywords={\@keywords},
		},
		pdfpagelayout=\photobook@pdfpagelayout,
	}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Geometry...

	\RecalculatePageLengths

	\geometry{
		% paper size (incl. bleeds)...
		paperwidth=\bleedblockwidth, paperheight=\bleedblockheight,
		bindingoffset=\bindingoffset,
		% XXX these should be overridable...
		% include header/footer/margin notes in printed area
		twoside, includeall, nomarginpar,
		ignorehead=false, ignorefoot=false, ignoremp=false,
		% center printed area on page
		vcentering, hcentering}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% pdf boxes...

	% calculate pdf box dimensions in pt...
	\edef\@pdfWidthPt{\strip@pt\dimexpr 
		0.996264009963\bleedblockwidth \relax}
	\edef\@pdfHeightPt{\strip@pt\dimexpr 
		0.996264009963\bleedblockheight \relax}
	\edef\@pdfBleedPt{\strip@pt\dimexpr 
		0.996264009963\bleed \relax}
	\edef\@pdfTopPt{\strip@pt\dimexpr 
		0.996264009963\dimexpr 
			\bleedblockheight - \bleed \relax \relax}
	\edef\@pdfRightPt{\strip@pt\dimexpr 
		0.996264009963\dimexpr 
			\bleedblockwidth - \bleed \relax \relax}

	% set the boxes...
	\ifxetex
		% XXX not tested...
		\AtBeginShipout{\AtBeginShipoutAddToBox{
			\special{pdf:put @thispage <<
				/MediaBox [0 0 \@pdfWidthPt\space \@pdfHeightPt]
				/BleedBox [0 0 \@pdfWidthPt\space \@pdfHeightPt]
				/ArtBox [\@pdfBleedPt\space \@pdfBleedPt\space \@pdfRightPt\space \@pdfTopPt]
				/TrimBox [\@pdfBleedPt\space \@pdfBleedPt\space \@pdfRightPt\space \@pdfTopPt]
				/CropBox [\@pdfBleedPt\space \@pdfBleedPt\space \@pdfRightPt\space \@pdfTopPt]
			>>} }} 

	\else
		\edef\pdfboxes{
			/MediaBox [0 0 \@pdfWidthPt\space \@pdfHeightPt]
			/BleedBox [0 0 \@pdfWidthPt\space \@pdfHeightPt]
			/ArtBox [\@pdfBleedPt\space \@pdfBleedPt\space \@pdfRightPt\space \@pdfTopPt]
			/TrimBox [\@pdfBleedPt\space \@pdfBleedPt\space \@pdfRightPt\space \@pdfTopPt]
			/CropBox [\@pdfBleedPt\space \@pdfBleedPt\space \@pdfRightPt\space \@pdfTopPt]
		}
		\expandafter\pdfpageattr\expandafter{\pdfboxes}
	\fi

} % \AtEndPreamble{..}



%----------------------------------------------------------------------
% Generic Commands....

\newcommand\keywords[1]{%
	\def\@keywords{#1}}


\newcommand\subject[1]{%
	\def\@subject{#1}}


\newcommand*{\cleartoleftpage}{%
	\clearpage
	\if@twoside
		\ifodd\c@page
			\hbox{}\newpage
			\if@twocolumn
				\hbox{}\newpage
			\fi
		\fi
	\fi }



% XXX workaround a problem with xelatex vs. lualatex...
\ifxetex
	\newcommand\ShipoutPicture[1]{
		\AddToShipoutPicture*{#1}}

\else
	% XXX for some reason in pdflatex and lualatex \pagecolor{..} and 
	%		\AddToShipoutPicture*{..} start fighting over space...
	% XXX this draws over page numbers...
	\newcommand\ShipoutPicture[1]{
		\AddToShipoutPictureFG*{#1}}
\fi



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% XXX HACKS...

% XXX for some reason we are pushed away from the left edge...
\newlength{\OFFSETFIX}
\setlength{\OFFSETFIX}{-4mm}

% This compensates for caption width being miscalcualted for right 
% alingned captions...
\newlength{\CAPTIONWIDTHFIX}
\setlength{\CAPTIONWIDTHFIX}{-5mm}



%----------------------------------------------------------------------
% Captions...
% XXX need to be able to configure/pass/override:
%		- size / \captionsize...
%		- color...
% XXX captions seem not to account for \imageblockoffsettop...

%\newcommand\captionsize{\scriptsize}
\newcommand\captionsize{\fontsize{6.5pt}{8pt}\selectfont}


% \imagecaption{caption}{location-date}
%
\newcommand\imagecaption[2]{
	{\captionsize%
		#1 %
		\par\vspace{-\parskip}%
		#2}}


% \overlaycaption{caption}{location-date}
%
\newcommand\overlaycaption[2]{
	\begin{flushright}
		\captionsize%
		\color{black}{%
			\colorbox{white}{ #1 }%
			\par\vspace{-\parskip}%
			\colorbox{white}{ #2 }}
	\end{flushright}}


% XXX \blockwidth
% XXX \nudgeimageby
% \captionsidebox[offset]{imagebox}{text}
%
\newcommand\captionsidebox[3][0mm]{
	\begin{minipage}{\dimexpr 
			% caption-image distance...
			-1em
			-\clearimage 
			+\blockwidth
			-(\wd#2 - #1)
			+(\nudgeimageby)
			-(0.5\blockwidth - 0.5\textwidth) \relax}%
		{ \captionsize #3 }
	\end{minipage}}


% \captionboxleft[offset]{imagebox}{text}
% \captionboxright[offset]{imagebox}{text}
%
\newcommand\captionboxleft[3][0mm]{
	\null
	\vfill
	\begin{flushleft}
	\captionsidebox[#1]{#2}{%
		\begin{flushright}
			#3
		\end{flushright}}
	\end{flushleft}}
\newcommand\captionboxright[3][0mm]{
	\null
	\vfill
	\begin{flushright}
	\captionsidebox[#1]{#2}{%
		\begin{flushleft}
			#3
		\end{flushleft}}
	\end{flushright}}


% XXX \CAPTIONWIDTHFIX
% \captionbottombox[offset]{imagebox}{text}
%
% XXX for some reason the width is wrong here...
\newcommand\captionbottombox[3][0mm]{
	\hspace{ #1 }{
		% XXX the \CAPTIONWIDTHFIX factor is compensating for an odd alignment error...
		\begin{minipage}{\dimexpr \CAPTIONWIDTHFIX + \wd#2 \relax}
			{ \captionsize #3 }
		\end{minipage}}}


% \graycaptionpage{text}
%
% XXX should this be \captionsize or \scriptsize
\newcommand\graycaptionpage[1]{
	\pagestyle{empty}
	\pagecolor{normgray}
	\color{white}
	\null
	\vfill
	\hspace{0.66\textwidth}{%
		\begin{minipage}{0.33\textwidth}
			\setlength{\parskip}{0.5em}%
			\captionsize\it%
			#1
		\end{minipage} }
	\newpage
	\nopagecolor
	\color{black} }



%----------------------------------------------------------------------
% Page Templates...

\newsavebox\photobook@imagebox


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% \imagepagefitWH{width}{height}{caption}{image}
%
% NOTE: width and hight are ratios of \textwidth and \textheight 
%		respectively. 
%		i.e. \imagepagefitWH{0.5}{0.5}{...} will set image size to half 
%		the size of the text block....
%
% XXX this generates lots of warnings...
% XXX broblems with captions:
%		- vertical offset is floating depending on image proportions...
%		- width is a bit off...
% XXX this does not account for \innerbleed...
%		- image: 
%			% odd/left 
%			\hspace{\dimexpr \bleed - \innerbleed \relax}{\usebox\photobook@imagebox}
%			% even/right
%			\hspace{\dimexpr -(\bleed - \innerbleed) \relax}{\usebox\photobook@imagebox}
%		- do the same for caption...
% XXX BUG: vertical alignment falls apart if page head is changed...
\newcommand\imagepagefitWH[4]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio=true, 
			width=#1\textwidth, 
			height=#2\textheight]{#4} }
	\null
	\vfill
	% image...
	\vspace{ \imageblockoffsettop\textheight }
	\begin{center}
		\usebox\photobook@imagebox
	\end{center}
	\vfill
	% caption...
	\ShipoutPicture{
		\vfill
		\vspace{ \dimexpr 
				% XXX this is not accurate for some reason...
				( 1em
					+ (\dimexpr \imageblockoffsettop\textheight / 2 \relax)
					+ \paperheight 
					+ \ht\photobook@imagebox ) 
				/ 2 \relax }
			\begin{minipage}{\paperwidth}
				\begin{center}
					\ifthenelse{\isodd{\thepage}}%
						% odd pages...
						{ \captionbottombox[ \bindingoffset ]{\photobook@imagebox}{%
							\begin{flushright}
								#3
							\end{flushright} } }%
						% even pages...
						{ \captionbottombox[ -\bindingoffset ]{\photobook@imagebox}{%
							\begin{flushright}
								#3
							\end{flushright} } }%
				\end{center}
			\end{minipage} }
	\newpage }


% \imagepagefitH[height]{caption}{image}
% \imagepagefitW[width]{caption}{image}
%
\newcommand\imagepagefitH[3][\imageblockheight]{
	\imagepagefitWH{\imageblockwidth}{#1}{#2}{#3} }
\newcommand\imagepagefitW[3][\imageblockwidth]{
	\imagepagefitWH{#1}{\imageblockheight}{#2}{#3} }


% \imagepage{caption}{path}
%
%	+---------------+
%	|				|
%	| +-----------+	|
%	| |.		 .|	|
%	| |	 .	   .  |	|
%	| |	  image	  |	|
%	| |	 .	   .  |	|
%	| |.		 .|	|
%	| +-----------+	|
%	|			  c	|
%	|				|
%	+---------------+
%
\newcommand\imagepage[2]{
	\imagepagefitWH{\imageblockwidth}{\imageblockheight}{#1}{#2} }


% XXX
% XXX captions wrong... 
% \imagepagefit[clearence]{caption}{image}
%
%	+---------------+
%	| |.		 .| |
%	| | .	    . |	|
%	| |  .	   .  | |
%	| |   .   .	  | |
%	| |	  image	  | |
%	| |	  .   .	  | |
%	| |  .	   .  | |
%	| | .		. | |
%	| |.		 .| |
%	+---------------+
%
% NOTE: this is like \imagepage but will fit an image into page...
\newcommand\imagepagefit[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr \blockwidth - ((#1) * 2) \relax,
			height=\dimexpr \blockheight - ((#1) * 2) \relax]{#3} }
	%\clearpage
	\null
	% XXX misaligned...
	\captionboxright{\photobook@imagebox}{#2}%
	\ShipoutPicture{%
		%\AtPageCenter{%
		% XXX this for some reason not at -\bleed horizontally...
		\AtPageLowerLeft{%
			\hspace*{\dimexpr 
					% XXX need to set this to bleed or innerbleed depending on page...
					% XXX when \AtPageCenter{ .. }for some reason -\bleed puts 
					%		the image in the center but adding -0.5\ht\photobook@imagebox 
					%		to it offsets the image to the left -- scaling????!!
					%-\bleed
					+0.5\OFFSETFIX
					+0.5\blockwidth
					-0.5\wd\photobook@imagebox 
					+\bleed
				\relax}{
			\raisebox{\dimexpr 
					+0.5\blockheight
					-0.5\ht\photobook@imagebox 
					+\bleed
				\relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }


% XXX does not work...
% XXX \OFFSETFIX
% \imagepagefill[clearence]{caption}{image}
%
%	+---------------+
%	|---------------|
%	|				|
%	|.			   .|
%	|	.		.	|
%	|	  image		|
%	|	.		.	|
%	|.			   .|
%	|				|
%	|-------------c-|
%	+---------------+
%
% NOTE: this is like \imagepage but will fit an image into page...
% XXX add option to align to top/bottom... 
% XXX captions untested... 
\newcommand\imagepagefill[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr \blockwidth - ((#1) * 2) \relax,
			% XXX make this use the minumum dimention and not width...
			%height=\dimexpr \blockheight - ((#1) * 2) \relax
			]{#3} }
	\clearpage
	\captionboxright[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
					+0.5\blockwidth 
					-0.5\wd\photobook@imagebox 
					-\bleed
					% XXX
					-0.5\OFFSETFIX 
				\relax}{
			\raisebox{\dimexpr 
					(#1)
					+\clearimage 
					+\bleed \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }


% XXX
% XXX \OFFSETFIX
% portraitimagepageleft[clearence]{caption}{image}
%
%	+---------------+
%	|.		   .|	|
%	| .		  .	|	|
%	|  .	 .	|	|
%	|	.	.	|	|
%	|	image	|	|
%	|	.	.	|	|
%	|  .	 .	|	|
%	| .		  .	|	|
%	|.		   .| c |
%	+---------------+
%
\newcommand\portraitimagepageleft[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) \relax]{#3} }
	\clearpage
	\captionboxright[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr \OFFSETFIX + #1 \relax}{
			\raisebox{\dimexpr #1 + \bleed \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }


% XXX
% portraitimagepageright{caption}{image}
%
%	+---------------+
%	|	|.		   .|
%	|	| .		  .	|
%	|	|  .	 .	|
%	|	|	.	.	|
%	|	|	image	|
%	|	|	.	.	|
%	|	|  .	 .	|
%	|	| .		  .	|
%	| c	|.		   .|
%	+---------------+
%
%
\newcommand\portraitimagepageright[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) \relax]{#3} }
	\clearpage
	\captionboxleft[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
				-#1 
				+\blockwidth 
				-\wd\photobook@imagebox \relax}{
			\raisebox{\dimexpr #1 + \bleed \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }



%----------------------------------------------------------------------
% Spread Templates...

\newlength{\photobook@tmpnudgeimageby}
\newlength{\photobook@tmpvnudgeimageby}
\newlength{\photobook@tmpvgrowimageby}

\newlength{\nudgeimageby}
\setlength{\nudgeimageby}{0mm}

\newlength{\vnudgeimageby}
\setlength{\vnudgeimageby}{0mm}

\newlength{\vgrowimageby}
\setlength{\vgrowimageby}{0mm}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% nudgeimage{amount}
%
% NOTE: in addition to spread commands below this is also used by 
%		\captionsidebox
\newcommand\nudgeimage[1]{%
	\setlength{\nudgeimageby}{#1}}

% vnudgeimage{amount}
%
% offset image vertically within bleeds.
%
% NOTE: this should not be used in conjunction with \vgrowimage{..} and 
%		should not exceed 1/2 of the amount given to \vgrowimage{..}
\newcommand\vnudgeimage[1]{%
	\setlength{\vnudgeimageby}{#1}}

% vgrowimage{amount}
%
% This will effectively add to 1/2 amount to top bleed and the same to 
% bottom bleed.
\newcommand\vgrowimage[1]{%
	\setlength{\vgrowimageby}{#1}}


% resetnudgeimage
%
% NOTE: when working with shipout place this after \newpage as when 
%		placed before this will reset the \nudgeimageby BEFORE the image
%		placing commands have a chance to execute.
% XXX rename
\newcommand\resetnudgeimage{%
	\setlength{\vgrowimageby}{0mm}%
	\setlength{\vnudgeimageby}{0mm}%
	\setlength{\nudgeimageby}{0mm}}



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% XXX
% portraitspreadbleedleft[clearence]{caption}{image}
%
%	+---------------+---------------+
%	|	|.		   .|				|
%	|	| .		  .	|				|
%	|	|  .	 .	|				|
%	|	|	.	.	|				|
%	|	|	image	|				|
%	|	|	.	.	|				|
%	|	|  .	 .	|				|
%	|	| .		  .	|				|
%	|	|.		   .| c				|
%	+---------------+---------------+
%
\newcommand\portraitspreadbleedleft[3][\clearimage]{
	\cleartoleftpage
	% style the caption...
	\null
	\vfill
	\begin{flushright}
		#2%
	\end{flushright}
	\newpage
	% XXX add \bleed
	\portraitimagepageleft[#1]{}{#3} }


% XXX
% portraitspreadbleedright[clearence]{caption}{image}
%
%	+---------------+---------------+
%	|				|.		   .|	|
%	|				| .		  .	|	|
%	|				|  .	 .	|	|
%	|				|	.	.	|	|
%	|				|	image	|	|
%	|				|	.	.	|	|
%	|				|  .	 .	|	|
%	|				| .		  .	|	|
%	|			  c	|.		   .|	|
%	+---------------+---------------+
%
\newcommand\portraitspreadbleedright[3][\clearimage]{
	\cleartoleftpage
	% style the caption...
	% XXX add \bleed
	\portraitimagepageright[#1]{}{#3} 
	\null
	\vfill
	\begin{flushleft}
		#2%
	\end{flushleft}
	\newpage }


% XXX
% XXX \OFFSETFIX
% imagespreadleft[clearence]{caption}{image}
%
% 	Image spread aligned left (with bleed)...
%
%	+---------------+---------------+
%	| .			 	. 		  .	|	|
%	|    .			.	   .	|	|
%	|	    .		.	.		|	|
%	|		   .	..			|	|
%	|			image			|	|
%	|		   .	..			|	|
%	|	    .		.	.		|	|
%	|    .			.	   .	|	|
%	| .			 	. 		  .	| c	|
%	+---------------+---------------+
%
%
% XXX might be a good idea to do a version of this with min/max width of 
%		the caption block...
\newcommand\imagespreadleft[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) + \vgrowimageby \relax]{#3} }
	% left page...
	% XXX BUG: this in some cases creates an extra empty spread before this...
	%		...appears to be a problem where we have a tweak.tex
	%\cleartoleftpage
	\null
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
					\OFFSETFIX 
					-(\nudgeimageby)
					+#1 
					+\bleed 
				\relax}{
			\raisebox{\dimexpr 
						#1 
						+ \bleed 
						- 0.5\vgrowimageby 
						- \vnudgeimageby 
					\relax}{
				\usebox\photobook@imagebox } } } }
	\newpage
	% right page...
	\captionboxright[\blockwidth]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
					\OFFSETFIX 
					-(\nudgeimageby)
					+#1 
					-\blockwidth 
					+\innerbleed 
				\relax}{
			\raisebox{\dimexpr 
						#1 
						+ \bleed 
						- 0.5\vgrowimageby 
						- \vnudgeimageby 
					\relax}{
				\usebox\photobook@imagebox } } } }
	\newpage 
	\resetnudgeimage }


% XXX
% imagespreadright[clearence]{caption}{image}
%
% 	Image spread aligned right (with bleed)...
%
%	+---------------+---------------+
%	|	| .			.	 		  .	|
%	|	|    .		.		   .	|
%	|	|	    .	.		.		|
%	|	|		   ..	.			|
%	|	|		   image			|
%	|	|		   ..	.			|
%	|	|	    .	.		.		|
%	|	|    .		.		   .	|
%	| c	| .			.	 		  .	|
%	+---------------+---------------+
%
\newcommand\imagespreadright[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) + \vgrowimageby \relax]{#3} }
	% left page...
	%\cleartoleftpage
	\null
	\captionboxleft[\blockwidth]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
				-#1
				+0.5\OFFSETFIX
				+(\nudgeimageby)
				+2\blockwidth
				+\bleed
				-\wd\photobook@imagebox \relax}{
			\raisebox{\dimexpr 
					#1 + \bleed 
					- 0.5\vgrowimageby - \vnudgeimageby \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage
	% right page...
	\null
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
				-#1
				+0.5\OFFSETFIX
				+(\nudgeimageby)
				+\blockwidth
				+\innerbleed
				-\wd\photobook@imagebox \relax}{
			\raisebox{\dimexpr 
					#1 + \bleed 
					- 0.5\vgrowimageby - \vnudgeimageby \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage 
	\resetnudgeimage }


% XXX
% XXX \OFFSETFIX
% imageleftspreadfullbleed[vertical-offset]{caption}{image}
%
%	Image spread with full bleed...
%
%	+---------------+
%	|	.			.
%	|	   .		.
%	|		  .		.
%	|			 .	.
%	|			  ima
%	|			 .	.
%	|		  .		.
%	|	   .		.
%	|	.		  c	.
%	+---------------+
%
\newcommand\imageleftspreadfullbleed[3][0mm]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr 
				2\blockwidth - 2\clearimage + \vgrowimageby \relax]{#3} }
	\clearpage
	\null
	\vfill
	\begin{flushright}
		#2
	\end{flushright}
	\ShipoutPicture{
		\AtPageCenter{
			\hspace{\dimexpr 
				\OFFSETFIX
				-(\nudgeimageby)
				+\clearimage
				-0.5\blockwidth \relax}{
			\raisebox{\dimexpr
					(#1)
					+\clearimage
					-(0.5\blockheight
						+(0.5\ht\photobook@imagebox - 0.5\blockheight)) 
					- 0.5\vgrowimageby - \vnudgeimageby \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage 
	\resetnudgeimage }


% XXX
% XXX \OFFSETFIX
% imagerightspreadfullbleed[vertical-offset]{caption}{image}
%
%	Image spread with full bleed...
%
%	+---------------+
%	.			.	|
%	.		 .		|
%	.	  .			|
%	.  .			|
%	age				|
%	.  .			|
%	.	  .			|
%	.		 .		|
%	.			. c	|
%	+---------------+
%
\newcommand\imagerightspreadfullbleed[3][0mm]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr 
				2\blockwidth - 2\clearimage + \vgrowimageby \relax]{#3} }
	\clearpage
	\null
	\vfill
	% XXX for some reason the last line here is a bit off...
	% XXX do we need to restrict caption width here??? ...0.5\textwidth??
	% XXX make caption sizing a bit more flexible...
	\begin{flushright}
		\captionsize #2
	\end{flushright}
	\ShipoutPicture{
		\AtPageCenter{
			\hspace{\dimexpr 
				\OFFSETFIX
				-(\nudgeimageby)
				+\clearimage
				-1.5\blockwidth \relax}{
			\raisebox{\dimexpr
					(#1)
					+\clearimage
					-(0.5\blockheight
						+(0.5\ht\photobook@imagebox - 0.5\blockheight))
					- 0.5\vgrowimageby - \vnudgeimageby \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage 
	\resetnudgeimage }


% XXX
% imagespreadfullbleed[vertical-offset]{caption}{image}
%
%	Image spread with full bleed...
%
%	+---------------+---------------+
%	|	.			.			.	|
%	|	   .		.		 .		|
%	|		  .		.	  .			|
%	|			 .	.  .			|
%	|			  image				|
%	|			 .	.  .			|
%	|		  .		.	  .			|
%	|	   .		.		 .		|
%	|	.			.			. c	|
%	+---------------+---------------+
%
% XXX do we need the same thing but with a left caption???
\newcommand\imagespreadfullbleed[3][0mm]{
	\setlength{\photobook@tmpnudgeimageby}{\nudgeimageby}
	\setlength{\photobook@tmpvnudgeimageby}{\vnudgeimageby}
	\setlength{\photobook@tmpvgrowimageby}{\vgrowimageby}
	\cleartoleftpage
	\imageleftspreadfullbleed[#1]{}{#3}
	\nudgeimage{\photobook@tmpnudgeimageby}
	\vnudgeimage{\photobook@tmpvnudgeimageby}
	\vgrowimage{\photobook@tmpvgrowimageby}
	\imagerightspreadfullbleed[#1]{#2}{#3} }





%----------------------------------------------------------------------
%%% XXX DEBUG...
%%\AtBeginDocument{
%%}


%----------------------------------------------------------------------
%                                                  vim:set ts=4 sw=4 :
