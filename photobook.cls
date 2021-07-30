%----------------------------------------------------------------------
%
%
% This does the following:
%	- sets up the document/pdf for viewing as a book
%	- adds support for page bleeds
%	- adds basic templates for image pages (XXX)
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
%   .   |<-- pagewidth ------------------------>=   .               |
%   .   |   .                       |   .   .   =   .               |
%   .   |                           |       .   =   .       textheight
%   .   |   .                       |   .   .   =   .               |
%   .   |                       pageheight  .   =   .               |
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
% NOTE: if pagewidth/pageheight are set they will force recalculations 
%		and overriding of the paperwidth/paperheight if they were changed
%		by the user code anywhere between \documentclass[..]{photobook}
%		and \begin{document}...
\DeclareStringOption[5mm]{bleed}[5mm]
\DeclareStringOption{innerbleed}
% XXX do we need to rename these??? (used by lualatex??)
\DeclareStringOption{pagewidth}
\DeclareStringOption{pageheight}
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
\newlength\pagewidth
\newlength\pageheight
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
	\setlength\pagewidth{
		\ifx\photobook@pagewidth\empty
			\dimexpr \paperwidth - \bleed - \innerbleed \relax
		\else
			\photobook@pagewidth
		\fi}
	\setlength\pageheight{
		\ifx\photobook@pageheight\empty
			\dimexpr \paperheight - 2\bleed \relax
		\else
			\photobook@pageheight
		\fi }
	% page with bleeds...
	% NOTE: this is essentially \paperwidth and \paperheight but we do 
	%		not rely on them being defined -- photobook settings take 
	%		priority over \paperwidth and \paperwidth...
	\setlength\bleedblockwidth{\dimexpr 
		\bleed + \pagewidth + \innerbleed 
		\relax}
	\setlength\bleedblockheight{\dimexpr 
		2\bleed + \pageheight 
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


% XXX \pagewidth
% XXX \nudgeimageby
% \captionsidebox[offset]{imagebox}{text}
%
\newcommand\captionsidebox[3][0mm]{
	\begin{minipage}{\dimexpr 
			% caption-image distance...
			-1em
			-\clearimage 
			+\pagewidth
			-(\wd#2 - #1)
			+(\nudgeimageby)
			-(0.5\pagewidth - 0.5\textwidth) \relax}
		{ \captionsize #3 }
	\end{minipage}}


% \captionboxleft[offset]{imagebox}{text}
% \captionboxright[offset]{imagebox}{text}
%
\newcommand\captionboxleft[3][0mm]{
	\null
	\vfill
	\begin{flushleft}
	\captionsidebox[#1]{#2}{
		\begin{flushright}
			#3
		\end{flushright}}
	\end{flushleft}}
\newcommand\captionboxright[3][0mm]{
	\null
	\vfill
	\begin{flushright}
	\captionsidebox[#1]{#2}{
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
% XXX \OFFSETFIX
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
% XXX captions untested... 
\newcommand\imagepagefit[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr \pagewidth - ((#1) * 2) \relax,
			height=\dimexpr \pageheight - ((#1) * 2) \relax]{#3} }
	%\clearpage
	\null
	\captionboxright[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
					+0.5\pagewidth 
					-0.5\wd\photobook@imagebox 
					-\bleed
					% XXX
					-0.5\OFFSETFIX 
				\relax}{
			% XXX this is not correct...
			\raisebox{\dimexpr 
					+0.5\pageheight 
					-0.5\ht\photobook@imagebox 
					%+#1 
					%-\bleed 
				\relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }


% XXX
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
			width=\dimexpr \pagewidth - ((#1) * 2) \relax,
			% XXX make this use the minumum dimention and not width...
			%height=\dimexpr \pageheight - ((#1) * 2) \relax
			]{#3} }
	\clearpage
	\captionboxright[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
					+0.5\pagewidth 
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
			height=\dimexpr \pageheight - ((#1) * 2) \relax]{#3} }
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
			height=\dimexpr \pageheight - ((#1) * 2) \relax]{#3} }
	\clearpage
	\captionboxleft[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
				-#1 
				+\pagewidth 
				-\wd\photobook@imagebox \relax}{
			\raisebox{\dimexpr #1 + \bleed \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }



%----------------------------------------------------------------------
% Spread Templates...







%----------------------------------------------------------------------
%%% XXX DEBUG...
%%\AtBeginDocument{
%%}


%----------------------------------------------------------------------
%                                                  vim:set ts=4 sw=4 :
