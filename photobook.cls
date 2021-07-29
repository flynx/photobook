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
\RequirePackage{iftex}
\RequirePackage{kvoptions}
\RequirePackage{etoolbox}
\RequirePackage{atbegshi}
\RequirePackage[unicode]{hyperref}
\RequirePackage{graphicx}
\RequirePackage{geometry}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% options...

% pdf layout...
%
% see: hyperref's pdfpagelayout for more options...
\DeclareStringOption[TwoPageRight]{pdfpagelayout}


% page geometry...
%
%	<---> bleed 								<---> innerbleed
%
%	+ - - - - - - - - - - - - - - - - - - - - - + - +	^
%	.  											.	.	| bleed
%	.	+---------------------------------------+	.	v	.	.  ---
%	.	|							^		.	|	.
%	.	|	.	.	.	.	.	.	|	.	.	|	.   			^
%	.	|<-- pagewidth ------------------------>|	.				|
%	.	|	.						|	.	.	|	.				|
%	.	|	 						|		.	|	.		textheight
%	.	|	.						|	.	.	|	.				|
%	.	|	 					pageheight	.	|	.				|
%	.	|	.						|	.	.	|	.				|
%	.	|	 						|		<---> bindingoffset		|
%	.	|	.	.	.	.	.	.	|	.	.	|	.				v
%	.	|							v		.	|	.
%	.	+---------------------------------------+	.	^	.	.  ---
%	.	.										.	.	| bleed
%	+ - - - - - - - - - - - - - - - - - - - - - + - +	v
%		.										.
%		|	<-- textwidth -------------->	.	|
%												^ binding line
%
% NOTE: if pagewidth/pageheight are set they will force recalculations 
%		and overriding of the paperwidth/paperheight if they were changed
%		by the user code anywhere between \documentclass[..]{photobook}
%		and \begin{document}...
\DeclareStringOption[5mm]{bleed}[5mm]
\DeclareStringOption{innerbleed}
\DeclareStringOption{pagewidth}
\DeclareStringOption{pageheight}
\DeclareStringOption[0]{bindingoffset}[10mm]

% XXX handle options:
%	- image block (w, h)
%		...should this be a global setting or a template thing???

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



%----------------------------------------------------------------------
% Commands...

\newcommand\Keywords[1]{%
	\def\@keywords{#1}}


\newcommand\Subject[1]{%
	\def\@subject{#1}}


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
% page / spread templates...

% XXX




%----------------------------------------------------------------------
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
	vcentering, hcentering, }


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
%                                                  vim:set ts=4 sw=4 :
