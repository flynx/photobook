%----------------------------------------------------------------------
%
%
% This does the following:
%	- sets up the document/pdf for viewing as a book
%	- adds support for page bleeds
%	- adds basic templates for image pages (XXX)
%
%
% XXX see where we need to \ignorespaces...
%
% XXX BUG: fix \OFFSETFIX
%
% XXX might be a good idea to add a spine calculator...
%
%----------------------------------------------------------------------

%%% NOTE: \def\<module-name>@[A-Z]+ macros will be visible to both the 
%%%		code and the generated docs...
\def\photobook@FILEVERSION{v0.1}
\def\photobook@FILEDATE{2021-07-28}


%% \documentclass{ltxdoc}
%%
%% \usepackage[a4paper,margin=25mm,left=55mm,nohead]{geometry}
%% \usepackage[numbered]{hypdoc}
%% \usepackage{doctools}
%%
%%% \newcommand\DescribeGlobal[1]{%
%%%	\DescribeMacro{#1}}
%%
%% \newcommand\LEGACY{\fbox{LEGACY}}
%%
%% \setlength\parindent{0pt}
%% \setlength\parskip{0.5em}
%%
%% \begin{document}
%%
%% \title{\textsf{photobook} --- Document class for building photo-books
%%		\thanks{This file describes version \FILEVERSION, 
%%			last revised \FILEDATE.}}
%%
%% \author{Alex A. Naanou\thanks{E-mail: alex.nanou@gmail.com}}
%%
%% \date{Released \FILEDATE}
%%
%% \maketitle
%%
%% \fbox{\bf%
%%		Note: all older templates/commnads/macros will get reworked soon! }
%%
%%%% Usage
%
%%	>> \documentclass[<options>]{photobook}
%%
%
%----------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}

\ProvidesClass{photobook}
	[\photobook@FILEDATE \space \photobook@FILEVERSION Photo book document class]


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%% Options
%%

\RequirePackage{kvoptions}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Helpers...

\newcommand\@DeclareLiteralOptionTo[2]{%
	\DeclareVoidOption{#2}{%
		\expandafter\edef\csname photobook@#1\endcsname{#2}}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Page geometry
%
%% \DescribeMacro{blockwidth=<len>}
%% \DescribeMacro{blockheight=<len>}
%% \DescribeMacro{bindingoffset=<len>}
%% \DescribeMacro{bleed=<len>}
%
%% This is similar to what |geometry| does, but adds bleed support.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   <---> bleed                                 <---> bleed
%%
%%   + - - - - - - - - - - - - - - - - - - - - - + - +   ^
%%   .                                           .   .   | bleed
%%   .   +--------------------------------------+-----  v   .   .  ---
%%   .   |                           ^       .   =   .
%%   .   |   .   .   .   .   .   .   |   .   .   =   .               ^
%%   .   |<-- blockwidth ----------------------->=   .               |
%%   .   |   .                       |   .   .   =   .               |
%%   .   |                           |       .   =   .       textheight
%%   .   |   .             Page      |   .   .   =   .               |
%%   .   |                      blockheight  .   =   .               |
%%   .   |   .                       |   .   .   =   .               |
%%   .   |                           |       <---> bindingoffset     |
%%   .   |   .   .   .   .   .   .   |   .   .   =   .               v
%%   .   |                           v       .   =   .
%%   .   +---------------------------------------+-----  ^   .   .  ---
%%   .   .                                       .   .   | bleed
%%   + - - - - - - - - - - - - - - - - - - - - - + - +   v
%%       .                                       .
%%       |   <-- textwidth -------------->   .   |
%%                                               ^ binding line
%%
%% \end{verbatim}
%% \end{minipage}
%%
%
% NOTE: if blockwidth/blockheight are set they will force recalculations 
%		and overriding of the paperwidth/paperheight if they were changed
%		by the user code anywhere between \documentclass[..]{photobook}
%		and \begin{document}...
\DeclareStringOption{blockwidth}
\DeclareStringOption{blockheight}
\DeclareStringOption[0pt]{bindingoffset}[10mm]
\DeclareStringOption[5mm]{bleed}[5mm]


%%%%% layout
%
%% \DescribeMacro{layoutmode=<layout>}
%% \DescribeMacro{block}
%% \DescribeMacro{endpaper}
%% \DescribeMacro{cover}
%% \DescribeMacro{jacket}
%%
%%	>> layoutmode=<option>
%%
%% |block| (default)
%%
%%	Basic page layout.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%       blockwidth
%%   <--------------->
%%
%%   +---------------+
%%   |               |
%%   |               |
%%   |     page      |
%%   |               |
%%   |               |
%%   +---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%%
%% |endpaper|:
%%
%%	Endpaper layout.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%       blockwidth 2x
%%   <------------------------------->
%%
%%   +---------------+---------------+
%%   |               .               |
%%   |               .               |
%%   |           endpaper            |
%%   |               .               |
%%   |               .               |
%%   +---------------+---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%	
%%
%% |cover|
%%
%%	Book cover layout
%%
%% \DescribeMacro{coverboardgrow=<len>}
%% \DescribeMacro{coverflap=<len>}
%% \DescribeMacro{spinewidth=<len>}
%% \DescribeMacro{spinewidth=<len>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%          blockwidth            blockwidth
%%       <--------------->     <--------------->
%%     <-> coverboardgrow                      <-> coverboardgrow
%%   <-> coverflap                             . <-> coverflap
%%   . . .                                     . . .
%%   +-------------------++---++-------------------+    ---
%%   | + - - - - - - - - ++ - ++ - - - - - - - - + |    --^ coverflap                
%%   | . + - - - - - - - ++ - ++ - - - - - - - + . |    --^ coverboardgrow  
%%   | . .               ..   ..               . . |     ^                  
%%   | . .               ..   ..               . . |     | blockheight      
%%   | . .     Back      ..   ..     Front     . . |     |                  
%%   | . .               ..   ..               . . |     |                  
%%   | . .               ..   ..               . . |     v                  
%%   | . + - - - - - - - ++ - ++ - - - - - - - + . |    --v coverboardgrow  
%%   | + - - - - - - - - ++ - ++ - - - - - - - - + |    --v coverflap                 
%%   +-------------------++---++-------------------+    ---
%%                        .   .
%%                       ^.   .^ spinefold
%%                        .   .
%%                        <---> spinewidth
%%
%% \end{verbatim}
%% \end{minipage}
%%
%%
%% |jacket|
%%
%%	Dust jacket layout
%%
%% \DescribeMacro{jacketwrap=<len>}
%% \DescribeMacro{jacketflap=<len>}
%% \DescribeMacro{jacketflapfront=<len>}
%% \DescribeMacro{jacketflapback=<len>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   <---> jaketflap/jacketflapback                  <---> jaketflap/jacketflapfront
%%   .   .                                           .   .
%%   .   .     blockwidth            blockwidth      .   .
%%   .   .  <--------------->     <--------------->  .   .
%%   .   .<-> coverboardgrow                      <-> coverboardgrow
%%   .   .  .                                     .  .   .
%%   +---++-----------------++---++-----------------++---+    ---
%%   |   .. + - - - - - - - ++ - ++ - - - - - - - + ..   |    --^ coverboardgrow
%%   |   .. .               ..   ..               . ..   |     ^
%%   |   .. .               ..   ..               . ..   |     | blockheight
%%   |   .. .     Back      ..   ..     Front     . ..   |     |
%%   |   .. .               ..   ..               . ..   |     |
%%   |   .. .               ..   ..               . ..   |     v
%%   |   .. + - - - - - - - ++ - ++ - - - - - - - + ..   |    --v coverboardgrow
%%   +---++-----------------++---++-----------------++---+    --- 
%%       ..                  .   .                  ..
%%       ^ jacketwrap        .   .                  ^ jacketwrap
%%                          ^.   .^ spinefold
%%                           .   .
%%                           <---> spinewidth
%%
%% \end{verbatim}
%% \end{minipage}
%%
%
% XXX in cover layout setup pdf boxes in a way to use \bleed as foldover...
% 		...see hyperref docs to set pdf view/print area (???)
%		.....should also set \bleed default to something like 17mm
% XXX do we need to implement cover fold over???
% XXX fold/cut marks???
\DeclareStringOption[block]{layoutmode}[block]
\@DeclareLiteralOptionTo{layoutmode}{block}
%\@DeclareLiteralOptionTo{layoutmode}{web}
\@DeclareLiteralOptionTo{layoutmode}{endpaper}
% XXX add overhang...
% XXX minght be a good idea to add cover types as separate values and 
%		preset defeaults per type, e.g:
%			layoutmode=		hardcover	softcover
%		should also set: 
%			spinefold=		5mm			5mm
%			coverflap=		17mm		0mm
%			bleed=			0mm			5mm
\@DeclareLiteralOptionTo{layoutmode}{cover}
%\@DeclareLiteralOptionTo{layoutmode}{hardcover}
%\@DeclareLiteralOptionTo{layoutmode}{softcover}
% XXX add flap sizes...
% XXX not implemented...
\@DeclareLiteralOptionTo{layoutmode}{jacket}


% NOTE: this is only used when layoutmode=cover
% NOTE: these are documented inline with layoutmode=.. docs...
\DeclareStringOption[0pt]{spinewidth}[0pt]
\DeclareStringOption[0pt]{spinefold}[7mm]
\DeclareStringOption[0pt]{coverboardgrow}[3mm]
% XXX defaults should depend on cover type...
\DeclareStringOption[0pt]{coverflap}[17mm]
\DeclareStringOption[0pt]{jacketwrap}[2mm]
\DeclareStringOption[0pt]{jacketflap}[50mm]
\DeclareStringOption[0pt]{jacketflapfront}[50mm]
\DeclareStringOption[0pt]{jacketflapback}[50mm]



%%%%% Image clearance
%
%% \DescribeMacro{clearimage=<len>}
%
%% Distance from image to paper border (clearance) for full-page images.
%%
%% this can be:
%% - negative value set image bleed, 
%% - positive value set distance from paper edge to image.
%%
%
\DeclareStringOption{clearimage}[-5mm]


%%%%% Image block layout
%
%% \DescribeMacro{imageblockwidth=<len>}
%% \DescribeMacro{imageblockheight=<len>}
%% \DescribeMacro{imageblockoffsettop=<len>}
%
%% Image block size relative to text block.
%%
\DeclareStringOption[0.85]{imageblockwidth}[1]
\DeclareStringOption[0.85]{imageblockheight}[1]
\DeclareStringOption[-0.05]{imageblockoffsettop}[0]

%%%%% PDF Viewer layout
%
%% \DescribeMacro{pdfpagelayout=<mode>}
%% \DescribeMacro{SinglePage}
%% \DescribeMacro{OneColumn}
%% \DescribeMacro{TwoColumnLeft}
%% \DescribeMacro{TwoColumnRight}
%% \DescribeMacro{TwoPageLeft}
%% \DescribeMacro{TwoPageRight}
%
% defaults:
%	- TwoColumnLeft (for layoutmode=block)
%	- SinglePage
%
% XXX make this a proper link...
%% See: hyperref's pdfpagelayout for more options.
%%
\DeclareStringOption{pdfpagelayout}
\@DeclareLiteralOptionTo{pdfpagelayout}{SinglePage}
\@DeclareLiteralOptionTo{pdfpagelayout}{OneColumn}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoColumnRight}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoColumnLeft}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoPageRight}
\@DeclareLiteralOptionTo{pdfpagelayout}{TwoPageLeft}


%%%%% Other options
%
%% \DescribeMacro{geometrynodefaults}
%
%% let the user set geometry defaults.
%%
%%	If this is not set |photobook| will override some user settings when
%%	initializing geometry.
%%
%%	If set |photobook| will only set override:
%%	\begin{verbatim}
%%		paperwidth=\bleedblockwidth
%%		paperheight=\bleedblockheight
%%		bindingoffset=\bindingoffset
%%	\end{verbatim}
%%
%
% XXX better name..
\DeclareBoolOption{geometrynodefaults}


%% \DescribeMacro{roundprintedlengthsto=<num>}
%
%% Number of digits to round printed lengths to (default: 1).
%%
%% This is a shorthand to |numprint|'s |\nprounddigits{..}|, us it to 
%% change values mid-document if needed.
%%
%% This is mostly used for |\GenerateTemplate|.
%%
\DeclareStringOption[1]{roundprintedlengthsto}[1]


\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessKeyvalOptions*


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Parent class...
%
\LoadClass[9pt, final, openany]{book}


%----------------------------------------------------------------------
% Packages...
%
% NOTE: imports are after \LoadClass{ .. } to avoid figting over macro
%		names...

\RequirePackage{calc}
\RequirePackage{xargs}
\RequirePackage{ifthen}
\RequirePackage{iftex}
\RequirePackage{pgffor}
\RequirePackage{listofitems}
\RequirePackage{xkeyval} 
\RequirePackage{etoolbox}
\RequirePackage{atbegshi}
%\RequirePackage{afterpage}
%\RequirePackage{changepage}
\RequirePackage[unicode]{hyperref}
%\RequirePackage{pdfcomment}
\RequirePackage{eso-pic}
\RequirePackage{environ}
\RequirePackage{numprint}
\RequirePackage{trimclip}
\RequirePackage{xcolor}
\RequirePackage{colorspace}
\RequirePackage{graphicx}
\RequirePackage{adjustbox}
\RequirePackage[absolute]{textpos}
\RequirePackage[linewidth=1pt]{mdframed}
\RequirePackage{rotating}
% XXX flow text frames...
% XXX this messes with geometry....
%\RequirePackage{flowfram}



%----------------------------------------------------------------------
%%%% Globals
%
% NOTE: most of these are setup in \InitPages...

%%% \DescribeGlobal{layoutmode}
%% \DescribeMacro{\layoutmode=<mode>}
%
%%	Layout mode
%%
\edef\layoutmode{\photobook@layoutmode}

% layout mode tests...
\newif\ifcoverlayout
\newif\ifhardcoverlayout
\newif\ifsoftcoverlayout
\newif\ifendpaperlayout
\newif\ifjacketlayout
% agrigates...
\newif\ifcoverlikelayout
\newif\ifblocklayout

%% \DescribeMacro{\pdfpagelayout=<mode>}
%
%%	Controls the default layout in the pdf viewer.
%%
\edef\pdfpagelayout{\photobook@pdfpagelayout}

%% \DescribeMacro{\spinewidth=<len>}
%
%%	Spine width
%%
\newlength\spinewidth
\setlength\spinewidth{\photobook@spinewidth}

%% \DescribeMacro{\spinefold=<len>}
%
%%	Spine fold width
%%
\newlength\spinefold
\setlength\spinefold{\photobook@spinefold}

%% \DescribeMacro{\coverboardgrow=<len>}
%
%%	Controls how much biger the cover board is than the page block
%%
\newlength\coverboardgrow
\setlength\coverboardgrow{\photobook@coverboardgrow}

%% \DescribeMacro{\coverflap=<len>}
%
%%	Cover flap
%%
\newlength\coverflap

%% \DescribeMacro{\jacketwrap=<len>}
%% \DescribeMacro{\jacketflap=<len>}
%% \DescribeMacro{\jacketflapfront=<len>}
%% \DescribeMacro{\jacketflapback=<len>}
%
%%	Jacker configuration
%%
\newlength\jacketwrap
\newlength\jacketflap
\newlength\jacketflapfront
\newlength\jacketflapback

%% \DescribeMacro{\blockwidth=<len>}
%% \DescribeMacro{\blockheight=<len>}
%
%%	Page block size
%%
% NOTE: page and bleed block sizes are set via \InitPages
\newlength\blockwidth
\newlength\blockheight

%% \DescribeMacro{\bleedblockwidth=<len>}
%% \DescribeMacro{\bleedblockheight=<len>}
%
%%	Page block size with bleeds
%%
%%	These are equivalent to |\paperwidth| and |\paperheight| but are 
%%	independent of them...
%%
\newlength\bleedblockwidth
\newlength\bleedblockheight

%% \DescribeMacro{\pageblockwidth=<len>}
%% \DescribeMacro{\pageblockheight=<len>}
%
%% Original page block size
%%
%% for the block layout these are the same as |\blockwidth| and |\blockheight|
%% for other layouts these are the original page layout size while the 
%% |\blockwidth| are set tho the current layout visible size.
%%
\newlength\pageblockwidth
\newlength\pageblockheight

%% \DescribeMacro{\bleed=<len>}
%
%%	Page bleed size
%%
\newlength\bleed
\setlength\bleed{\photobook@bleed}

%% \DescribeMacro{\bindingoffset=<len>}
%
%%	Binding offset
%%
\newlength\bindingoffset
\setlength\bindingoffset{\photobook@bindingoffset}

%% \DescribeMacro{\clearimage=<len>}
%
%%	Image clearance
%%
% NOTE: since this can be any number but we need to detect if it was set 
%		manually we'll set it to \maxdimen and hope noe will print 
%		something big enough and dare to use it as image clearance...
\newlength{\clearimage}
\setlength\clearimage{\maxdimen}

%% \DescribeMacro{\imageblockwidth=<ratio>}
%% \DescribeMacro{\imageblockheight=<ratio>}
%
%%	Image block width relative to |\textwidth|
%%
\edef\imageblockwidth{\photobook@imageblockwidth}
\edef\imageblockheight{\photobook@imageblockheight}

%% \DescribeMacro{\pagetextwidth=<len>}
%% \DescribeMacro{\pagetextheight=<len>}
%
%% Root page text width/height.
%%
\newlength\pagetextwidth
\setlength\pagetextwidth{\textwidth}
\newlength\pagetextheight
\setlength\pagetextheight{\textheight}


%% \DescribeMacro{\imageblockoffsettop=<ratio>}
%
%%
%%
\edef\imageblockoffsettop{\photobook@imageblockoffsettop}



%----------------------------------------------------------------------
%%%% Initialization
%%
%% \DescribeMacro{\InitPages}
%
%%	Initialize page dimensions.
%%
\newcommand\InitPages{
	% layout bools/tests...
	\coverlayoutfalse
	\hardcoverlayoutfalse
	\softcoverlayoutfalse
	\endpaperlayoutfalse
	\jacketlayoutfalse
	\coverlikelayoutfalse
	\blocklayoutfalse
	\ifdefstring{\layoutmode}{block}{
		\blocklayouttrue }{}
	\ifdefstring{\layoutmode}{cover}{ 
		\coverlayouttrue
		\coverlikelayouttrue }{}
	\ifdefstring{\layoutmode}{hardcover}{ 
		\hardcoverlayouttrue
		\coverlikelayouttrue }{}
	\ifdefstring{\layoutmode}{softcover}{ 
		\softcoverlayouttrue
		\coverlikelayouttrue }{}
	\ifdefstring{\layoutmode}{jacket}{%
		\jacketlayouttrue
		\coverlikelayouttrue }{}
	\ifdefstring{\layoutmode}{endpaper}{ 
		\endpaperlayouttrue }{}
	% pdf layout...
	\ifx\photobook@pdfpagelayout\empty
		\ifblocklayout
			\def\pdfpagelayout{TwoPageRight}
		\else
			\def\pdfpagelayout{SinglePage}
		\fi
	\else
		\def\pdfpagelayout{\photobook@pdfpagelayout}
	\fi
	% items to ignore in different layouts...
	% XXX is this the correct way to go???
	\ifcoverlayout
		\setlength\coverflap{\photobook@coverflap}
	\else
		\setlength\coverflap{0pt}
	\fi
	\ifjacketlayout
		\setlength\jacketwrap{\photobook@jacketwrap}
		\setlength\jacketflap{\photobook@jacketflap}
	\else
		\setlength\jacketwrap{0pt}
		\setlength\jacketflap{0pt}
	\fi
	% flaps...
	\ifdim\jacketflapfront=0pt
		\setlength\jacketflapfront{\jacketflap}
	\fi
	\ifdim\jacketflapback=0pt
		\setlength\jacketflapback{\jacketflap}
	\fi
	% block size...
	\ifdim\blockwidth=0pt
		% layout: block...
		\setlength\blockwidth{
			\ifx\photobook@blockwidth\empty
				\dimexpr 
					\paperwidth 
					- 2\bleed 
				\relax
			\else
				\photobook@blockwidth
			\fi} 
		\setlength\pageblockwidth{\blockwidth}
		% layout: cover...
		\ifcoverlayout
			\setlength\blockwidth{
				\dimexpr 
					2\blockwidth 
					+ \spinewidth 
					+ 2\spinefold
					+ 2\coverboardgrow
					+ 2\coverflap
				\relax } \fi
		% layout: jacket...
		% XXX this seems to be about 6mm off -- what are we missing here???
		\ifjacketlayout
			\setlength\blockwidth{
				\dimexpr 
					2\blockwidth 
					+ \spinewidth
					+ 2\spinefold
					+ 2\jacketwrap
					+ \jacketflapfront
					+ \jacketflapback
				\relax } \fi
		% layout: endpaper...
		\ifendpaperlayout
			\setlength\blockwidth{ 2\blockwidth } \fi
	\fi
	\ifdim\blockheight=0pt
		% layout: block / endpaper...
		\setlength\blockheight{
			\ifx\photobook@blockheight\empty
				\dimexpr \paperheight - 2\bleed \relax
			\else
				\photobook@blockheight
			\fi} 
		\setlength\pageblockheight{\blockheight}
		% layout: cover...
		\ifcoverlayout
			\setlength\blockheight{
				\dimexpr 
					\blockheight
					+ 2\coverboardgrow
					+ 2\coverflap
				\relax } \fi
		% layout: jacket...
		\ifjacketlayout
			\setlength\blockheight{
				\dimexpr 
					\blockheight
					+ 2\coverboardgrow
				\relax } \fi
	\fi
	% default image clearance...
	\ifdim\clearimage=\maxdimen
		\ifx\photobook@clearimage\empty
			\setlength\clearimage{-\bleed}
		\else
			\setlength\clearimage{\photobook@clearimage}
		\fi
	\fi
	% page with bleeds...
	% NOTE: this is essentially \paperwidth and \paperheight but we do 
	%		not rely on them being defined -- photobook settings take 
	%		priority over \paperwidth and \paperwidth...
	\setlength\bleedblockwidth{\dimexpr 
			2\bleed + \blockwidth 
		\relax}
	\setlength\bleedblockheight{\dimexpr 
			2\bleed + \blockheight 
		\relax} 
	% misc...
	\nprounddigits{\photobook@roundprintedlengthsto} }


%% \DescribeMacro{\ReInitPages}
%
%%	Reset and re-initialize page dimentions.
%%
\newcommand\ReInitPages{
	\setlength\blockwidth{0mm}
	\setlength\blockheight{0mm}
	\edef\pdfpagelayout{}
	%
	\InitPages}



%----------------------------------------------------------------------
% Setup...

% init/update lengths...
\InitPages

% minimal geometry setup...
\RequirePackage[
	% paper size (incl. bleeds)...
	paperwidth=\bleedblockwidth, paperheight=\bleedblockheight,
]{geometry}



%----------------------------------------------------------------------
% Setup (pre-document)...

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
		pdfpagelayout=\pdfpagelayout,
	}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Geometry...

	\InitPages

	% no-defaults -- the user is expected to set things up...
	\ifphotobook@geometrynodefaults
		\geometry{
			% paper size (incl. bleeds)...
			paperwidth=\bleedblockwidth, paperheight=\bleedblockheight,
			bindingoffset=\bindingoffset}
	% normal mode...
	\else
		\geometry{
			% paper size (incl. bleeds)...
			paperwidth=\bleedblockwidth, paperheight=\bleedblockheight,
			bindingoffset=\bindingoffset,
			% include header/footer/margin notes in printed area
			twoside, includeall, nomarginpar,
			ignorehead=false, ignorefoot=false, ignoremp=false,
			% center printed area on page
			vcentering, hcentering}
	\fi

	\setlength\pagetextwidth{\textwidth}
	\setlength\pagetextheight{\textheight}


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
%%%% Generic commands
%%


%% \DescribeMacro{\mindim\{..\}}
%% \DescribeMacro{\maxdim\{..\}}
%
%% Get min/max dimension.
%
%%	>> \mindim{A}{B}
%
%%	>> \maxdim{A}{B}
%%
\newcommand\mindim[2]{
	\ifdim \dimexpr #1 \relax < \dimexpr #2 \relax%
		\dimexpr #1 \relax%
	\else%
		\dimexpr #2 \relax\fi}

\newcommand\maxdim[2]{
	\ifdim \dimexpr #1 \relax > \dimexpr #2 \relax%
		\dimexpr #1 \relax%
	\else%
		\dimexpr #2 \relax\fi}


%% \DescribeMacro{\keywords\{..\}}
%
%%	Set pdf metadata keywords
%%
%%	>>	\keywords{<keywords>}
%%
\def\@keywords{}

\newcommand\keywords[1]{%
	\def\@keywords{#1}}


%% \DescribeMacro{\subject\{..\}}
%
%%	Set pdf metadata subject
%%
%%	>>	\subject{<subject>}
%%
\def\@subject{}

\newcommand\subject[1]{%
	\def\@subject{#1}}


%% \DescribeMacro{\cleartoleftpage}
%
%%	Forces content to left page
%%
\newcommand*{\cleartoleftpage}{%
	\clearpage
	\if@twoside
		\ifodd\c@page
			\hbox{}\newpage
			\if@twocolumn
				\hbox{}\newpage \fi\fi\fi }


% XXX workaround a problem with xelatex vs. lualatex...
\ifxetex
	\newcommand\ShipoutPicture[1]{%
		\AddToShipoutPicture*{#1}}

\else
	% XXX for some reason in pdflatex and lualatex \pagecolor{..} and 
	%		\AddToShipoutPicture*{..} start fighting over space...
	% XXX this draws over page numbers...
	\newcommand\ShipoutPicture[1]{%
		\AddToShipoutPictureFG*{#1}}
\fi



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% XXX HACKS...

\newlength{\OFFSETFIX}
\setlength{\OFFSETFIX}{-4mm}



%----------------------------------------------------------------------
%%%% Environments and Cells

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Generic

%% \DescribeEnv{page}
%
%% Page environment.
%%
%% This is mainly designed to wrap other cell environment described later.
%
% XXX this may span more than one page if there is enoug stuff packed 
%		into it...
\newenvironment{page}{%
	\null
}{%
	\clearpage }


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cells
%
%% A cell environment is a box of specified size.
%%
%% Cells can be both placed inline relative to other content or in an 
%% absolute location.
%%
%% Note that absolute cells are placed relative to the page and currently 
%% can not be placed relative to other absolute cells (this might change
%% in the future).
%%
%% \DescribeMacro{\cellwidth=<len>}
%% \DescribeMacro{\cellheight=<len>}
%% \DescribeMacro{\cellparentwidth=<len>}
%% \DescribeMacro{\cellparentheight=<len>}
%% \DescribeMacro{\celloffsettop=<len>}
%% \DescribeMacro{\celloffsetleft=<len>}
%%
%% A cell defines a set of contextual lengths:
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   <--> celloffsetleft
%%   .   <--------------> cellwidth
%%   <----------------------> cellparentwidth
%%   .   .              .   .
%%   +----------------------+ . . . . . . .
%%   |   .              .   |     ^       ^ celloffsettop
%%   |   .              .   |     |       |
%%   |   +--------------+ . | . . | . . . v 
%%   |   |              |   |     |   ^
%%   |   |              |   |     |   | cellheight
%%   |   |     cell     |   |     |   |
%%   |   |              |   |     |   |
%%   |   |              |   |     |   |
%%   |   +--------------+ . | . . | . v
%%   |                      |     |
%%   |                      |     | cellparentheight
%%   +----------------------+ . . v
%%                              
%% \end{verbatim}
%% \end{minipage}
%%
%% For absolutely positioned cells these define the cell offset from 
%% parent.
%%
%% The bare page can be reasonably be treated as a cell.
%%
%% Initally, outside of any cells |\cellwidth|, |\cellparentwidth| and 
%% |\cellheight|, |\cellparentheight| are equal to |\paperwidth| and 
%% |\paperheight| respectively, and |\celloffsettop| and |\celloffsetleft|
%% are set to |0pt|.
%%
%% Changing these is not recommended, it likely will not affect the 
%% current cell but can mess up nested cells.
%%
\newlength\cellparentwidth
\setlength\cellparentwidth{\paperwidth}

\newlength\cellparentheight
\setlength\cellparentheight{\paperheight}

\newlength\cellwidth
\setlength\cellwidth{\cellparentwidth}

\newlength\cellheight
\setlength\cellheight{\cellparentheight}

\newlength\celloffsetleft
\setlength\celloffsetleft{0pt}

\newlength\celloffsettop
\setlength\celloffsettop{0pt}



% \DescribeMacro{\begin\{inlinecell\}\{..\} ...}
%% \DescribeEnv{inlinecell}
%
%% Create a basic inline cell.
%
%%	>> \begin{inlinecell}{<width>}{<height>} ... \end{inlinecell}
%%	>> \begin{inlinecell}[<valign>]{<width>}{<height>} ... \end{inlinecell}
%
%% This is just like |minipage| but provides cell mechanics.
%%
% XXX
\newenvironment{inlinecell}[3][t]{%
	\begingroup%
		% get args by value...
		\edef\photobook@protect@w{\the\dimexpr #2 \relax}%
		\edef\photobook@protect@h{\the\dimexpr #3 \relax}%
		%
		\setlength\cellparentwidth{\cellwidth}%
		\setlength\cellparentheight{\cellheight}%
		\setlength\cellwidth{\photobook@protect@w}%
		\setlength\cellheight{\photobook@protect@h}%
		\setlength\celloffsettop{0pt}%
		\setlength\celloffsetleft{0pt}%
		%
		\begin{minipage}[t][\cellheight][#1]{\cellwidth}% 
			\ignorespaces%
}{%
		\end{minipage}%
	\endgroup}


%% \DescribeEnv{cell}
%
%% Create a basic absolutely positioned cell.
%
%%	>> \begin{cell}{<top>, <left>}{<width>}{<height>} ... \end{cell}
%%
% XXX SYNTAX: place the second arg in braces...
%		\begin{cell}(<top>, <left>){<width>}{<height>}
\newenvironment{cell}[3]{%
	\readlist*\photobook@cell@offset{#1}%
	%
	\begin{textblock*}{#2}(#1)%
	\begin{inlinecell}{#2}{#3}%
		\setlength\celloffsettop{\photobook@cell@offset[1]}%
		\setlength\celloffsetleft{\photobook@cell@offset[2]}%
		\ignorespaces%
}{%
	\end{inlinecell}%
	\end{textblock*}}


% \DescribeMacro{\begin\{clipcell\}\{..\} ...}
%% \DescribeEnv{clipcell}
%
%% Create a clipped cell.
%
%%	>> \begin{clipcell}{<top>, <left>}{<width>}{<height>} ... \end{clipcell}
%
%% This is like the |cell| environment but will clip everything not in the 
%% the cell.
%%
%% Note that this uses |clip| and |cliptocell| environments internally.
%%
\newenvironment{clipcell}[3]{%
	\begin{cell}{#1}{#2}{#3}%
	\begin{cliptocell}%
		\ignorespaces%
}{%
	\end{cliptocell}%
	\end{cell}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Save cells

%% \DescribeMacro{\savecell\{..\}}
%
%% Create a saved cell.
%
%%	>> \savecell{<name>}{<width>}{<height>}{ .. }
%
%% This is similar to |\newsavebox{..}| and |\sbox{..}| but adds 
%% cell functionality.
%%
% XXX can we make this an env???
% XXX should this be split into \newsavecell{..} and \scell{..} ???
% XXX can we use root cells inside this???
%		...i.e. things using textbox*...
\newcommand\savecell[4]{%
	% only define a savebox once...
	\@ifundefined{#1}{%
		\expandafter\newsavebox\csname #1\endcsname}{}
	\expandafter\sbox\csname #1\endcsname{%
		\begin{inlinecell}{#2}{#3}%
			#4%
		\end{inlinecell}}}


% \usecell{..} variants...
%
\def\usecell{\@ifstar{%
	\photobook@usecell%
}{%
	\photobook@usecell@clipped}}

% reuse cell content...
% NOTE: this is not intended for direct use -- depends closure/context...
\def\photobook@usecell@placecell#1(#2){%
	\readlist*\photobook@usecell@offset{#2}%
	% XXX how we align things feels a bit odd...
	\vspace{-\dimexpr \photobook@usecell@offset[1] \relax}%
	\adjustbox{margin={-\dimexpr \photobook@usecell@offset[2] \relax} 0pt 0pt 0pt}{%
		\expandafter\usebox\csname #1\endcsname}}

%% \DescribeMacro{\usecell\{..\}}
%
%% Use part of a saved cell.
%%
%%	>> \usecell{<name>}(<top>, <left>){<width>}{<height>}
%%
%% This will clip the content to cell.
%%
%% This is similar to |\usebox{..}| but defines a box and aligns the 
%% content to it.
%%
% XXX add option to rotate saved cell...
\def\photobook@usecell@clipped#1(#2)#3#4{
	\begin{inlinecell}{#3}{#4}%
	\begin{cliptocell}%
		\photobook@usecell@placecell{#1}(#2)%
	\end{cliptocell}%
	\end{inlinecell}}

%% \DescribeMacro{\usecell*\{..\}}
%
%% Like |\usecell{..}| but will not clip the cell content.
%%
%%	>> \usecell*{<name>}(<top>, <left>){<width>}{<height>}
%%
% XXX add option to rotate saved cell...
\def\photobook@usecell#1(#2)#3#4{
	\begin{inlinecell}{#3}{#4}%
		\photobook@usecell@placecell{#1}(#2)%
	\end{inlinecell}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cell macros
%
%% Cell macros require a cell environment to function correctly.
%%

%% \DescribeEnv{topdown}
%% \DescribeEnv{bottomup}
%
%% Rotate cell content vertically, orienting it top-down or bottom-up.
%
%%	>> \begin{topdown} ... \end{topdown}
%%	>> \begin{bottomup} ... \end{bottomup}
%%
\newenvironment{topdown}[1][t]{%
	\begin{flushright}%
	\begin{turn}{270}%
	\begin{inlinecell}[#1]{\cellheight}{\cellwidth}%
}{%
	\end{inlinecell}%
	\end{turn}
	\end{flushright}}

\newenvironment{bottomup}[1][t]{%
	\begin{turn}{90}%
	\begin{inlinecell}[#1]{\cellheight}{\cellwidth}%
}{%
	\end{inlinecell}%
	\end{turn}}


%% \DescribeEnv{cliptocell}
%
%% Clip content to cell env.
%%
\newenvironment{cliptocell}{%
	\begin{clipbox*}{0cm {\height - \cellheight} {\cellwidth} {\height}}%
	\begin{minipage}[t][\cellheight][t]{\cellwidth}% 
}{%
	\end{minipage}%
	\end{clipbox*}}


%% \DescribeMacro{\imagecell\{..\}}
%
%% Fit image to cell.
%
%%	>> \imagecell{<caption-cell>}{<image>}
%%	>> \imagecell[<key>=<value>, ..]{<caption-cell>}{<image>}
%%
%%	>> \imagecell[fit]{}{landscape-image}
%%	>> \imagecell[fill]{}{landscape-image}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   fit (default)                fill
%%   +-----------------+    . . . +-----------------+ . . .
%%   |                 |    .  .  |                 |  .  .
%%   +-----------------+    .     |                 |     .
%%   | .             . |    .     |  .           .  |     .
%%   |    .       .    |    .     |     .     .     |     .
%%   |      image      |    .     |      image      |     .
%%   |    .       .    |    .     |     .     .     |     .
%%   | .             . |    .     |  .           .  |     .
%%   +-----------------+    .     |                 |     .
%%   |                 |    .  .  |                 |  .  .
%%   +-----------------+    . . . +-----------------+ . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Centering. The image will be centered by default.
%%
%%	>> \imagecell{}{landscape-image}
%%	>> \imagecell[center]{}{landscape-image}
%%
%% Vertical alignment for landscape images.
%%
%%	>> \imagecell[top]{}{landscape-image}
%%	>> \imagecell[bottom]{}{landscape-image}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   top                    center (default)       bottom
%%   +-----------------+    +-----------------+    +-----------------+ 
%%   | .             . |    |                 |    |                 |
%%   |    .       .    |    +-----------------+    |                 |
%%   |      image      |    | .             . |    |                 |
%%   |    .       .    |    |    .       .    |    +-----------------+ 
%%   | .             . |    |      image      |    | .             . | 
%%   +-----------------+    |    .       .    |    |    .       .    | 
%%   |                 |    | .             . |    |      image      | 
%%   |                 |    +-----------------+    |    .       .    | 
%%   |                 |    |                 |    | .             . | 
%%   +-----------------+    +-----------------+    +-----------------+ 
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Horizontal alignment for portrait images.
%%
%%	>> \imagecell[left]{}{portrait-image}
%%	>> \imagecell[right]{}{portrait-image}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   left                   center (default)       right
%%   +-------------+---+    +-+-------------+-+    +---+-------------+
%%   | .         . |   |    | | .         . | |    |   | .         . |
%%   |  .       .  |   |    | |  .       .  | |    |   |  .       .  |
%%   |   .     .   |   |    | |   .     .   | |    |   |   .     .   |
%%   |    .   .    |   |    | |    .   .    | |    |   |    .   .    |
%%   |    image    |   |    | |    image    | |    |   |    image    |
%%   |    .   .    |   |    | |    .   .    | |    |   |    .   .    |
%%   |   .     .   |   |    | |   .     .   | |    |   |   .     .   |
%%   |  .       .  |   |    | |  .       .  | |    |   |  .       .  |
%%   | .         . |   |    | | .         . | |    |   | .         . |
%%   +-------------+---+    +-+-------------+-+    +---+-------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Horizontal and vertical alignment can be combined to control alignment 
%% of both vertical and horizontal images at the same time.
%%
%% Image |clearance|. This sets the amount of clearance around an image 
%% (default: |0pt|).
%%
%%	>> \imagecell[clearance=-4mm]{}{landscape-image}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   clearance > 0pt        clearance = 0pt          clearance < 0pt
%%                                  (default)     
%%   +--------v--------+    +-----------------+    +--------^--------+    
%%   |                 |    |                 |    |                 |    
%%   |+---------------+|    +-----------------+  ..+-----------------+..  
%%   || .           . ||    | .             . |  . |.               .| .  
%%   ||   .       .   ||    |    .       .    |  . |    .       .    | .  
%%   |>     image     <|    |      image      |  < |      image      | >  
%%   ||   .       .   ||    |    .       .    |  . |    .       .    | .  
%%   || .           . ||    | .             . |  . |.               .| .  
%%   |+---------------+|    +-----------------+  ..+-----------------+..  
%%   |                 |    |                 |    |                 |    
%%   +--------^--------+    +-----------------+    +--------v--------+    
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Note that if |clearance| is less than 0, the image will take up more
%% space than the containing cell, |\imagecell{..}| will not clip 
%% its content and the whole image surface will be shown. If clipping is 
%% needed then use |clipcell| environment as a container.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%     +-----------------+ - - caption cell size
%%     .                 .       .
%%     +-----------------+       .
%%     |                 |       . 
%%   ..+-----------------+..  .  +
%%   . |.caption cell   .| .     |
%%   . |    .       .    | .     |
%%   . |        .        | .     | 
%%   . |    .       .    | .     |
%%   . |.               .| .     |
%%   ..+-----------------+..  .  +
%%     |                 |    
%%     +-----------------+    
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% |<caption-cell>| occupies the same space as the image clipped by the 
%% containing cell and provides all the cell functionality.
%%

% NOTE: these are macros and not lengths as we need to "resolve" these 
%		as late as possible, i.e. after all the arguments have been 
%		processed.
\def\photobook@imagecell@top{0pt}
\def\photobook@imagecell@left{0pt}
\def\photobook@imagecell@captiontop{0pt}
\def\photobook@imagecell@captionleft{0pt}

\newlength\photobook@imagecell@clearance
\setlength\photobook@imagecell@clearance{0pt}

% NOTE: these feel like a hack...
\newlength\photobook@imagecell@imgratio
\newlength\photobook@imagecell@cellratio

% fit/fill...
\define@boolkey{imagecell@args}{fit}[true]{%
	\KV@imagecell@args@fillfalse}
\define@boolkey{imagecell@args}{fill}[true]{%
	\KV@imagecell@args@fitfalse}
% center...
\define@boolkey{imagecell@args}{center}[true]{%
	\def\photobook@imagecell@top{\dimexpr 
		+0.5\cellheight 
		-0.5\ht\photobook@imagebox \relax}%
	\def\photobook@imagecell@left{\dimexpr 
		+0.5\cellwidth 
		-0.5\wd\photobook@imagebox \relax}}%
% left/right...
% shortdands...
\newcommand\photobook@imagecell@LEFT{%
	\def\photobook@imagecell@left{\dimexpr%
		+\photobook@imagecell@clearance \relax}%
	\def\photobook@imagecell@captionleft{
		% XXX not sure why this branch is needed...
		\ifKV@imagecell@args@fit
			0pt
		\else%
			\dimexpr%
				+\cellwidth 
				-\photobook@imagecell@clearance
				-\wd\photobook@imagebox \relax\fi}}%
\newcommand\photobook@imagecell@RIGHT{%
	\def\photobook@imagecell@left{\dimexpr 
		+\cellwidth 
		-\photobook@imagecell@clearance
		-\wd\photobook@imagebox \relax}
	% XXX not sure why 0.5 but it seems to work...
	\def\photobook@imagecell@captionleft{%
		-0.5\photobook@imagecell@left}}%
% args...
\define@boolkey{imagecell@args}{left}[true]{%
	\photobook@imagecell@LEFT}
\define@boolkey{imagecell@args}{right}[true]{%
	\photobook@imagecell@RIGHT}
% inside/outside...
\define@boolkey{imagecell@args}{inside}[true]{%
	\ifthenelse{\isodd{\thepage}}{
		\photobook@imagecell@LEFT%
	}{%
		\photobook@imagecell@RIGHT}}%
\define@boolkey{imagecell@args}{outside}[true]{%
	\ifthenelse{\isodd{\thepage}}{%
		\photobook@imagecell@RIGHT%
	}{%
		\photobook@imagecell@LEFT}}%
% top/bottom...
\define@boolkey{imagecell@args}{top}[true]{%
	\def\photobook@imagecell@top{%
		\photobook@imagecell@clearance}
	\def\photobook@imagecell@captiontop{
		-\dimexpr 
			+\cellheight 
			-\photobook@imagecell@clearance
			-\ht\photobook@imagebox \relax}}%
\define@boolkey{imagecell@args}{bottom}[true]{%
	\def\photobook@imagecell@top{\dimexpr 
		+\cellheight 
		-\photobook@imagecell@clearance
		-\ht\photobook@imagebox \relax}
	\def\photobook@imagecell@captiontop{%
		\photobook@imagecell@top}}%
% clearance=<len>...
\define@key{imagecell@args}{clearance}{%
	\setlength\photobook@imagecell@clearance{#1}}%

\def\photobook@imagecell@captionalign{t}
\define@choicekey{imagecell@args}{caption-align}{t,c,b}[t]{%
	\def\photobook@imagecell@captionalign{#1}}%

% XXX add offset support...
%		...i.e. an argument that will shift the image v/h from base position.
%		also need to shift the caption box accordingly but still keep it 
%		within the cell...
% XXX need to help caption-cell be able to create new cells to left/right/top/left 
%		of image...
% XXX can we make this an env???
\newcommand\imagecell[3][]{%
	\begingroup%
		% args...
		\setkeys{imagecell@args}{
			fit,
			center,
			clearance=0pt,
			#1}%
		% preload image...
		% fit...
		\ifKV@imagecell@args@fit%
			\sbox{\photobook@imagebox}{%
				\includegraphics[%
					keepaspectratio, 
					width=\dimexpr 
						\cellwidth 
						- ((\photobook@imagecell@clearance) * 2) \relax,
					height=\dimexpr 
						\cellheight 
						- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}%
		% fill...
		\else\ifKV@imagecell@args@fill%
			% preload image to get its proportions...
			\sbox{\photobook@imagebox}{\includegraphics{#3}}
			% constrain minimal dimension of image...
			% NOTE: here we calculate image/cell eccentricity to decide 
			%		to fit to width or heigh of cell...
			% NOTE: did I say that I "love" how LaTeX does basic math??
			\setlength\photobook@imagecell@imgratio{1pt
				* \ratio{\wd\photobook@imagebox}{\ht\photobook@imagebox}}
			\setlength\photobook@imagecell@cellratio{1pt
				* \ratio{\cellwidth}{\cellheight}}
			\ifdim \photobook@imagecell@imgratio < \photobook@imagecell@cellratio
				\sbox{\photobook@imagebox}{%
					\includegraphics[%
						keepaspectratio, 
						width=\dimexpr 
							+ \cellwidth
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}%
			\else%
				\sbox{\photobook@imagebox}{%
					\includegraphics[%
						keepaspectratio, 
						height=\dimexpr 
							+ \cellheight 
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}
			\fi\fi\fi%
		% place image box...
		% XXX for some odd reason without this the alignment completely breaks...
		\vspace{0pt}%
		\adjustbox{%
				margin={\photobook@imagecell@left} 0pt 0pt {\photobook@imagecell@top}}{%
			% image....
			\usebox\photobook@imagebox%
			%
			% caption cell...
			% XXX do not do this if no caption is given... 
			\begingroup%
				% setup the cell env...
				% NOTE: this needs the original \cellwidth...
				\setlength\celloffsetleft{%
					\mindim{%
							\wd\photobook@imagebox
						}{%
							+\cellwidth 
							-\photobook@imagecell@captionleft
							-0.5\dimexpr 
								+\cellwidth 
								-\wd\photobook@imagebox \relax}}%
				\setlength\cellparentwidth{\cellwidth}%
				\setlength\cellparentheight{\cellheight}%
				\setlength\cellwidth{%
					\mindim{\wd\photobook@imagebox}{\cellwidth}}%
				\setlength\cellheight{%
					\mindim{\ht\photobook@imagebox}{\cellheight}}% 
				% NOTE: this needs the new \cellheight...
				\setlength\celloffsettop{%
					\mindim{%
							0pt
						}{%
							+ 0.5\dimexpr 
								+\cellheight 
								-\ht\photobook@imagebox 
							-\photobook@imagecell@captiontop \relax}}%
				%
				% place the caption cell...
				\hspace{-\celloffsetleft}{%
					\setlength\fboxsep{0pt}%
					% adjust top if image is taller than cell...
					\raisebox{-\celloffsettop}{%
						\begin{minipage}[b][\cellheight][\photobook@imagecell@captionalign]{\cellwidth}%
							#2%
						\end{minipage}}}
			\endgroup}%
	\endgroup}


%% \DescribeMacro{\captioncell\{..\}}
%
%% Caption cell
%%
%% Placement:
%
%%	>> \captioncell[<position>]{<caption>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%     over            
%%   +-----------------+
%%   | top             |
%%   |                 |
%%   |                 |
%%   |                 |
%%   | center          |
%%   |                 |
%%   |                 |
%%   |                 |
%%   | bottom          |
%%   +-----------------+
%%     under           
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Default:
%%	>> \captioncell{<caption>}
%%	>> \captioncell[top]{<caption>}
%%
%%	>> \captioncell[center]{<caption>}
%%	>> \captioncell[bottom]{<caption>}
%%
%%	>> \captioncell[over]{<caption>}
%%	>> \captioncell[under]{<caption>}
%%
%% Horizontal alignment
%
%%	>> \captioncell[align=<mode>]{<caption>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +-----------------+    +-----------------+    +-----------------+
%%   |flushleft        |    |     center      |    |       flushright|
%%   |                 |    |                 |    |                 |
%%   |                 |    |                 |    |                 |
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Default:
%%	>> \captioncell{<caption>}
%%	>> \captioncell[align=flushleft]{<caption>}
%%
%%	>> \captioncell[align=center]{<caption>}
%%	>> \captioncell[align=flushright]{<caption>}
%%
% XXX would be nice to create cells above/below/left/right of image...

% helpers...
% XXX set minipage height to available cell height...
\newcommand\photobook@captioncell@formatTopAlign[1]{%
	% XXX for some reason without this things are misaligned...
	\vspace{0pt}%
	\begin{\photobook@captioncell@align}%
		#1%
	\end{\photobook@captioncell@align}}
% XXX set minipage height to available cell height...
\newcommand\photobook@captioncell@formatBottomAlign[1]{%
	\begin{minipage}[t][\cellheight][b]{\cellwidth}%
		\begin{\photobook@captioncell@align}%
			#1%
		\end{\photobook@captioncell@align}%
	\end{minipage}}
% format...
\def\photobook@captioncell@format#1{%
	\photobook@captioncell@formatTopAlign{#1}}

% over / top / center / bottom / under...
\define@boolkey{captioncell@args}{over}[true]{%
	\def\photobook@captioncell@format##1{%
		\vspace{-\dimexpr \cellheight + 2\fboxsep \relax}%
		\photobook@captioncell@formatBottomAlign{##1}}}
\define@boolkey{captioncell@args}{top}[true]{%
	\def\photobook@captioncell@format##1{%
		\photobook@captioncell@formatTopAlign{##1}}}
\define@boolkey{captioncell@args}{center}[true]{%
	\def\photobook@captioncell@format##1{%
		\begin{minipage}[t][\cellheight][c]{\cellwidth}%
		\begin{\photobook@captioncell@align}%
			##1%
		\end{\photobook@captioncell@align}%
		\end{minipage}}}
\define@boolkey{captioncell@args}{bottom}[true]{%
	\def\photobook@captioncell@format##1{%
		\photobook@captioncell@formatBottomAlign{##1}}}
\define@boolkey{captioncell@args}{under}[true]{%
	\def\photobook@captioncell@format##1{%
		\vspace{\dimexpr \cellheight + 2\fboxsep \relax}%
		\photobook@captioncell@formatTopAlign{##1}}}
% align...
\def\photobook@captioncell@align{}
% XXX for some reason \define@choicekey{..} does not expand macros...
%\define@choicekey{captioncell@args}{align}{flushleft,center,flushright}{%
\define@key{captioncell@args}{align}{%
	\def\photobook@captioncell@align{#1}}
% margin...
\def\photobook@captioncell@margin{0pt}
\define@key{captioncell@args}{margin}{
	\def\photobook@captioncell@margin{#1}}

\newcommand\captioncell[2][]{%
	\setkeys{captioncell@args}{top, align=flushright, margin=1pt, #1}%
	%
	\photobook@captioncell@format{%
		\adjustbox{margin=\photobook@captioncell@margin}{#2}}}


%% \DescribeMacro{\vcaptioncell\{..\}}
%
%% Vertical caption cell
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   (topdown)                   (bottomup)
%%     +-----------------+         +-----------------+
%%   b | l      c      r | a       |                 |
%%   e | e      e      i | f       |                 |
%%   f | f      n      g | t       |                 |
%%   o | t      t      h | e     e |        r        |
%%   r |        e      t | r     r |        e      t | r
%%   e |        r        |       o | t      t      h | e
%%     |                 |       f | f      n      g | t
%%     |                 |       e | e      e      i | f
%%     |                 |       b | l      c      r | a
%%     +-----------------+         +-----------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% See samples for better illustration.
%%
% bottomup / topdown...
\def\photobook@vcaptioncell@orientation{bottomup}
\define@boolkey{vcaptioncell@args}{bottomup}[true]{%
	\KV@vcaptioncell@args@topdownfalse
	\def\photobook@vcaptioncell@orientation{bottomup}}
\define@boolkey{vcaptioncell@args}{topdown}[true]{%
	\KV@vcaptioncell@args@bottomupfalse
	\def\photobook@vcaptioncell@orientation{topdown}}

\def\photobook@vcaptioncell@nested#1{%
	\captioncell[%
			\photobook@vcaptioncell@position,
			align=\photobook@vcaptioncell@align,
			margin=\photobook@vcaptioncell@margin]{#1}}

% before / left / center / right / after...
\def\photobook@vcaptioncell@position{top}
\define@boolkey{vcaptioncell@args}{before}[true]{%
	\def\photobook@vcaptioncell@position{%
		\ifKV@vcaptioncell@args@bottomup%
			over%
		\else%
			under\fi}}
\define@boolkey{vcaptioncell@args}{left}[true]{%
	\def\photobook@vcaptioncell@position{%
		\ifKV@vcaptioncell@args@bottomup%
			top%
		\else%
			bottom\fi}}
\define@boolkey{vcaptioncell@args}{center}[true]{%
	\def\photobook@vcaptioncell@position{center}}
\define@boolkey{vcaptioncell@args}{right}[true]{%
	\def\photobook@vcaptioncell@position{%
		\ifKV@vcaptioncell@args@bottomup%
			bottom%
		\else%
			top\fi}}
\define@boolkey{vcaptioncell@args}{after}[true]{%
	\def\photobook@vcaptioncell@position{%
		\ifKV@vcaptioncell@args@bottomup%
			under%
		\else%
			over\fi}}
% align...
\def\photobook@vcaptioncell@align{}
% XXX for some reason \define@choicekey{..} does not expand macros...
%\define@choicekey{vcaptioncell@args}{align}{flushleft,center,flushright}{%
\define@key{vcaptioncell@args}{align}{%
	\def\photobook@vcaptioncell@align{#1}}
% margin...
\def\photobook@vcaptioncell@margin{0pt}
\define@key{vcaptioncell@args}{margin}{
	\def\photobook@vcaptioncell@margin{#1}}

\newcommand\vcaptioncell[2][]{%
	\setkeys{vcaptioncell@args}{left, bottomup, align=flushleft, margin=1pt, #1}%
	%
	%% XXX for some reason this errs with:
	%%			"LaTeX Error: \begin{bottomup} on input line 432 ended by \end{bottomup}"
	%\begin{\photobook@vcaptioncell@orientation}%
	%	\captioncell[%
	%			\photobook@vcaptioncell@position,
	%			align=\photobook@vcaptioncell@align,
	%			margin=\photobook@vcaptioncell@margin]{#2}%
	%\end{\photobook@vcaptioncell@orientation}}
	\ifKV@vcaptioncell@args@bottomup%
		\begin{bottomup}%
			\photobook@vcaptioncell@nested{#2}
		\end{bottomup}%
	\else
		\begin{topdown}%
			\photobook@vcaptioncell@nested{#2}
		\end{topdown}%
	\fi}


% XXX need to do a caption block -- a cell to one side of an image to the 
% 		end of the page...


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Paper cells

%% \DescribeEnv{papercell}
%
%% Paper cell.
%%
%% This does not include bleeds and is independent of |layoutmode|.
%%
\newenvironment{papercell}{%
	\begin{cell}{\bleed, \bleed}{\blockwidth}{\blockheight}%
}{%
	\end{cell}}


%% \DescribeEnv{paperbleedcell}
%
%% Paper bleed cell.
%%
%% Like |papercell| but includes bleeds.
%%
\newenvironment{paperbleedcell}{%
	\begin{cell}{0, 0}{\bleedblockwidth}{\bleedblockheight}%
}{%
	\end{cell}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Page cells

%% \DescribeEnv{pagecell}
%
%% Page cell. 
%%
%% This corresponds to the visible page in the |layoutmode=block| and 
%% does not include bleeds.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   + - - - - - - - - - +
%%   . +---------------+ .
%%   . |               | .
%%   . |               | .
%%   . |   pagecell    | .
%%   . |               | .
%%   . |               | .
%%   . +---------------+ .
%%   + - - - - - - - - - +
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Note that |layoutmode|'s other than block will change the paper size 
%% but will not affect this.
%%
% XXX
\newenvironment{pagecell}{%
	\begin{cell}{\bleed,\bleed}{\pageblockwidth}{\pageblockheight}%
}{%
	\end{cell}}


%% \DescribeEnv{pagebleedcell}
%
%% Like |page| but includes bleeds.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +-------------------+
%%   | + - - - - - - - + |
%%   | .               . |
%%   | .               . |
%%   | . pagebleedcell . |
%%   | .               . |
%%   | .               . |
%%   | + - - - - - - - + |
%%   +-------------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Note that |layoutmode|'s other than block will change the paper size 
%% but will not affect this.
%%
% XXX
\newenvironment{pagebleedcell}{%
	\begin{cell}{0mm, 0mm}{\bleedblockwidth}{\bleedblockheight}%
}{%
	\end{cell}}



% XXX EXPERIMENTAL
\NewEnviron{shipoutbgcell}{%
	\AddToShipoutPictureBG*{%
		\begin{pagecell}%
			\BODY%
		\end{pagecell}}}



% XXX EXPERIMENTAL
%% \DescribeEnv{textcell}
%
%% A cell taking up the page text block.
%
%%	>> \begin{textcell}{<width>}{<height>} ... \end{textcell}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%     <-----------> \textwidth
%%   +---------------+
%%   | +-----------+ |  ^
%%   | |           | |  | \textheight
%%   | | textcell  | |  |
%%   | |           | |  |
%%   | +-----------+ |  v
%%   +---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Note that this is an inline cell and if something is on the page it 
%% may not be centered properly.
%%
% XXX test...
\newenvironment{textcell}{%
	\begin{inlinecell}{\textwidth}{\textheight}%
}{%
	\end{inlinecell}}


%% \DescribeMacro{spreadtopages}
%
%% Spread cell into pages.
%%
%%	>> \begin{spreadtopages} .. \end{spreadtopages}
%%	>> \begin{spreadtopages}[<pagecount>] .. \end{spreadtopages}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +----------------------------------- -                 
%%   |                                                      <-- input cell
%%   |          .          .          .                     
%%   |     Oversized content cell...                        
%%   |          .          .          .                     
%%   |                                                      
%%   +----------.----------.----------.-- -                 
%%   .          . .         . .         .  .
%%   .          .   .         .   .         .    .         
%%   +----------+    +----------+    +----------+    +-- -  
%%   |          |    |          |    |          |    |      <-- output pages
%%   |          |    |          |    |          |    |      
%%   |     Overs|    |ized conte|    |nt cell...|    |      
%%   |          |    |          |    |          |    |      
%%   |          |    |          |    |          |    |    
%%   +----------+    +----------+    +----------+    +-- -
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX add a manual version of this...
%		...i.e. name + use...
% XXX add nudge/grow support...
% XXX revise name...
\NewEnviron{spreadtopages}[1][2]{%
	\begingroup%
		% create the actual cell...
		\setlength\cellparentwidth{\cellwidth}%
		\setlength\cellparentheight{\cellheight}%
		\setlength\cellwidth{#1\pageblockwidth}%
		\setlength\cellheight{\pageblockheight}%
		%
		\savecell{photobook@spreadtopages}{\cellwidth}{\cellheight}{\BODY}%
		%
		% generate pages...
		\foreach \photobook@spreadtopages@page in {0, ...,\numexpr #1 - 1 \relax}{%
			\null
			\begin{pagecell}%
				% NOTE: \cellwidth and \cellheight here are for a single page...
				\usecell*{photobook@spreadtopages}%
					(0pt, \photobook@spreadtopages@page\cellwidth)%
					{\cellwidth}{\cellheight}%
			\end{pagecell}%
			\clearpage}%
	\endgroup}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Endpaper cells
%
%% \DescribeEnv{leftside}
%% \DescribeEnv{rightside}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +---------------+---------------+
%%   |               |               |
%%   |               |               |
%%   |   leftside    |   rightside   |
%%   |               |               |
%%   |               |               |
%%   +---------------+---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%
% XXX for some reason naming this anything starting with endpaper will
%		make LaTeX complain that that is already defined...

\newenvironment{leftside}{%
	\begin{pagecell}%
}{%
	\end{pagecell}}

\newenvironment{rightside}{%
	\begin{cell}%
			{\bleed + \pageblockwidth, \bleed}%
			{\pageblockwidth}{\pageblockheight}%
}{%
	\end{cell}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cover and dust jacket cells
%
%% \DescribeEnv{frontcover}
%% \DescribeEnv{backcover}
%
%% \DescribeEnv{spine}
%% \DescribeEnv{vspine}
%
%% \DescribeEnv{frontflap}
%% \DescribeEnv{backflap}
%
%% Covers and dust jackets differ only in that covers do not {usually} 
%% have flaps.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   backflap        spline/vspine           frontflap
%%     .    backcover      .   frontcover      .
%%     v     v             v     v             v
%%   +---+---------------+---+---------------+---+               
%%   |   |               |   |               |   |
%%   |   |               |   |               |   |
%%   |   |     Back      |   |     Front     |   |
%%   |   |               |   |               |   |
%%   |   |               |   |               |   |
%%   +---+---------------+---+---------------+---+               
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newenvironment{frontcover}{%
	\begin{cell}{
				\bleed 
					+ \jacketflapback 
					+ \coverflap 
					+ \jacketwrap 
					+ \coverboardgrow 
					+ \pageblockwidth 
					+ 2\spinefold 
					+ \spinewidth,
				\bleed 
					+ \coverflap }%
			{ \pageblockwidth + \coverboardgrow }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell}}

\newenvironment{backcover}{%
	\begin{cell}{
				\bleed 
					+ \jacketflapback 
					+ \coverflap 
					+ \jacketwrap,
				\bleed 
					+ \coverflap }%
			{ \pageblockwidth + \coverboardgrow }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell}}


% spines...
%
\newenvironment{spine}{%
	\begin{cell}{
				\bleed 
					+ \jacketflapback 
					+ \coverflap 
					+ \jacketwrap 
					+ \coverboardgrow 
					+ \pageblockwidth 
					+ \spinefold,
				\bleed 
					+ \coverflap }%
			{ \spinewidth }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell}}

\newenvironment{vspine}[1][topdown]{%
	\def\photobook@vspine@orientation{#1}%
	%
	\begin{spine}%
	\begin{\photobook@vspine@orientation}%
}{%
	\end{\photobook@vspine@orientation}%
	\end{spine}}


% jackets flaps...
%
\newenvironment{frontflap}{%
	\begin{cell}{
				\bleed 
					+ \jacketflapback 
					+ 2\jacketwrap 
					+ 2\coverboardgrow 
					+ 2\pageblockwidth 
					+ 2\spinefold 
					+ \spinewidth,
				\bleed 
					+ \coverflap }% 
			{ \jacketflapfront }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell}}

\newenvironment{backflap}{%
	\begin{cell}{
				\bleed,
				\bleed 
					+ \coverflap }%
			{ \jacketflapback }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell}}



%----------------------------------------------------------------------
%%%% Caption Templates
% XXX need to be able to configure/pass/override:
%		- size / \captionsize...
%		- color...
% XXX captions seem not to account for \imageblockoffsettop...

%\newcommand\captionsize{\scriptsize}
\newcommand\captionsize{%
	\fontsize{6.5pt}{8pt}\selectfont}


% XXX move to a better location... (???)
\newcommand\captionformat[1]{%
	\adjustbox{margin=0.1em 0.2em}{%
		\captionsize #1}}


%% \DescribeMacro{\captionsidebox\{..\}}
%
%% \LEGACY
%
%%	>> \captionsidebox[<offset>]{<imagebox>}{<text>}
%%
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


%% \DescribeMacro{\captionboxleft\{..\}}
%% \DescribeMacro{\captionboxright\{..\}}
%
%% \LEGACY
%
%%	>> \captionboxleft[<offset>]{<imagebox>}{<text>}
%%	>> \captionboxright[<offset>]{<imagebox>}{<text>}
%%
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





%----------------------------------------------------------------------
%%%% Page Templates

\newsavebox\photobook@imagebox


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%% \DescribeMacro{\imagepage\{..\}}
%% \DescribeMacro{\imagepagecaption\{..\}}
%% \DescribeMacro{\resetimagepagecaption}
%% \DescribeMacro{\imagepage*\{..\}}
%
%%	Basic image page
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +-----------------+
%%   |                 |
%%   | +-------------+ |
%%   | | .         . | |
%%   | |   .     .   | |
%%   | |    image    | |
%%   | |   .     .   | |
%%   | | .         . | |
%%   | +-------------+ |
%%   |               c |
%%   |                 |
%%   +-----------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Create an image page:
%
%%	>> \imagepage{<caption>}{<path>}
%
%% Image caption template used by |\imagepage{..}|, this can be redefined
%% to change the way |\imagepage{..}| behaves:
%
%%	>> \imagepagecaption{<caption>}{<path>}
%
%% Create image page with a custom caption, this will not use any caption 
%% templates:
%
%%	>> \imagepage*{<caption>}{<path>}
%
%% Reset image caption to default:
%
%%	>> \resetimagepagecaption
%%
% XXX
%\def\ResettableCommand#1[#2]#3{%
%	\expandafter\newcommand\csname photobook@#1\endcsname[#2]{#3}%
%	\expandafter\newcommand\csname reset#1\endcsname{%
%		\expandafter\let\csname #1\endcsname = \csname photobook@#1\endcsname}
%	\csname reset#1\endcsname}

%\ResettableCommand{imagepagecaption}[1]{
%	\captioncell[under, align=flushright]{%
%		\captionformat{#1}}}
\newcommand\photobook@imagepagecaption[1]{%
	\captioncell[under, align=flushright]{%
		\captionformat{#1}}}
\newcommand\resetimagepagecaption{%
	\let\imagepagecaption = \photobook@imagepagecaption}
\resetimagepagecaption

\def\imagepage{\@ifstar{%
	\photobook@imagepage
}{%
	\photobook@imagepage@captiontpl}}
% XXX should we reduce width by bindingoffset???
\newcommand\photobook@imagepage[2]{%
	\begin{page}%
	\begin{pagecell}%
	% XXX should we reduce width by bindingoffset???
	\begin{minipage}[t][\cellheight][c]{\cellwidth}%
		\vspace{\imageblockoffsettop\pagetextheight}%
		\begin{center}%
			% compensate for \bindingoffset...
			\hspace{\ifnumodd{\thepage}{\bindingoffset}{-\bindingoffset}}{%
				\begin{inlinecell}%
						{\imageblockwidth\pagetextwidth}%
						{\imageblockheight\pagetextheight}%
					\imagecell[fit]{#1}{#2}%
				\end{inlinecell}}%
		\end{center}%
	\end{minipage}%
	\end{pagecell}%
	\end{page}}
\newcommand\photobook@imagepage@captiontpl[2]{%
	\photobook@imagepage{%
		\@ifundefined{imagepagecaption}{%
			#1%
		}{%
			\imagepagecaption{#1}}}{#2}}


%% \DescribeMacro{\imagepagefit\{..\}}
%% \DescribeMacro{\imagepagefitcaption\{..\}}
%% \DescribeMacro{\resetimagepagefitcaption}
%% \DescribeMacro{\imagepagefit*\{..\}}
%
%% Similar to |\imagepage| but will fit an image into page...
%
%%	>> \imagepagefit[<options>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                              . . . . . . .
%%   +-----------------+      +---------------+
%%   |                 |      | |.         .| |
%% . +-----------------+ .    | | .       . | |
%% . | .             . | .    | |  .     .  | |
%% . |    .       .    | .    | |   .   .   | |
%% . |      image      | .    | |   image   | |
%% . |    .       .    | .    | |   .   .   | |
%% . | .             . | .    | |  .     .  | |
%% . +-----------------+ .    | | .       . | |
%%   |               c |      | |.        c.| |
%%   +-----------------+      +---------------+
%%                              . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% |<options>| is the same as for |\imagecell{..}|.
%%
% XXX add a way to set this for one image...
% XXX add options to better control caption...
\newcommand\photobook@imagepagefitcaption[1]{%
	\captioncell[under, align=flushright]{%
		\captionformat{#1}}}
\newcommand\resetimagepagefitcaption{%
	\let\imagepagefitcaption = \photobook@imagepagefitcaption}
\resetimagepagefitcaption

\def\imagepagefit{\@ifstar{%
	\photobook@imagepagefit
}{%
	\photobook@imagepagefit@captiontpl}}
% XXX add nudge/grow support...
\newcommand\photobook@imagepagefit[3][]{%
	\begin{page}%
	\begin{pagecell}%
		\imagecell[center, clearance=\clearimage, #1]{#2}{#3}%
	\end{pagecell}%
	\end{page}}
\newcommand\photobook@imagepagefit@captiontpl[3][]{%
	\photobook@imagepagefit[#1]{%
		\@ifundefined{imagepagefitcaption}{%
			#2%
		}{%
			\imagepagefitcaption{#2}}}{#3}}


%% \DescribeMacro{\imagepagefill\{..\}}
%% \DescribeMacro{\imagepagefillcaption\{..\}}
%% \DescribeMacro{\resetimagepagefillcaption}
%% \DescribeMacro{\imagepagefill*\{..\}}
%
%%	Like |\imagepage| but will fill page with image.
%
%%	>> \imagepagefill[<options>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   . . . . . . . . . . . . . . . . . . .
%%   . .       +---------------+       . .
%%   .    .    |             c |    .    .
%%   .       . |               | .       .
%%   .         |.             .|         .
%%   .         |   .       .   |         .
%%   .         |     image     |         .
%%   .         |   .       .   |         .
%%   .         |.             .|         .
%%   .       . |               | .       .
%%   .    .    |               |    .    .
%%   . .       +---------------+       . .
%%   . . . . . . . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% |<options>| is the same as for |\imagecell{..}|.
%%
% XXX add a way to set this for one image...
\newcommand\photobook@imagepagefillcaption[1]{
	\captioncell[top, align=flushright]{%
		\captionformat{#1}}}
\newcommand\resetimagepagefillcaption{%
	\let\imagepagefillcaption = \photobook@imagepagefillcaption}
\resetimagepagefillcaption

\def\imagepagefill{\@ifstar{%
	\photobook@imagepagefill
}{%
	\photobook@imagepagefill@captiontpl}}
% XXX add nudge/grow support...
\newcommand\photobook@imagepagefill[3][]{
	\begin{page}%
	\begin{pagecell}%
		\imagecell[fill, clearance=\clearimage, #1]{#2}{#3}%
	\end{pagecell}%
	\end{page}}
\newcommand\photobook@imagepagefill@captiontpl[3][]{%
	\photobook@imagepagefill[#1]{%
		\@ifundefined{imagepagefillcaption}{%
			#2%
		}{%
			\imagepagefillcaption{#2}}}{#3}}


% XXX
% XXX \OFFSETFIX
%% \DescribeMacro{\portraitimagepageleft\{..\}}
%
%% \LEGACY
%
%%  >> portraitimagepageleft[<clearence>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   . . . . . . . .
%%   . +---------------+
%%   . |.         .|   |
%%   . | .       . |   |
%%   . |  .     .  |   |
%%   . |   .   .   |   |
%%   . |   image   |   |
%%   . |   .   .   |   |
%%   . |  .     .  |   |
%%   . | .       . |   |
%%   . |.         .| c |
%%   . +---------------+
%%   . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\portraitimagepageleft[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) \relax,]{#3} }
	\clearpage
	\captionboxright[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr \OFFSETFIX + #1 \relax}{
			\raisebox{\dimexpr #1 + \bleed \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }


% XXX
%% \DescribeMacro{\portraitimagepageright\{..\}}
%
%% \LEGACY
%
%%	>> portraitimagepageright{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%       . . . . . . . .
%%   +---------------+ .
%%   |   |.         .| .
%%   |   | .       . | .
%%   |   |  .     .  | .
%%   |   |   .   .   | .
%%   |   |   image   | .
%%   |   |   .   .   | .
%%   |   |  .     .  | .
%%   |   | .       . | .
%%   | c |.         .| .
%%   +---------------+ .
%%       . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\portraitimagepageright[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) \relax,]{#3} }
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


% XXX
% XXX \OFFSETFIX
%% \DescribeMacro{\imageleftspreadfullbleed\{..\}}
%
%% \LEGACY
%%
%% Image left page spread with full bleed.
%
%%	>> \imageleftspreadfullbleed[<vertical-offset>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%  . . . . . . . . . . . . 
%%  . +---------------+     
%%  . |   .           |     
%%  . |      .        |     
%%  . |         .     |     
%%  . |            .  |     
%%  . |             image
%%  . |            .  |     
%%  . |         .     |     
%%  . |      .        |     
%%  . |   .         c |     
%%  . +---------------+     
%%  . . . . . . . . . . . . 
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\imageleftspreadfullbleed[3][0mm]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr 
				2\blockwidth - 2\clearimage + \vgrowimageby \relax,]{#3} }
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
%% \DescribeMacro{\imagerightspreadfullbleed\{..\}}
%
%% \LEGACY
%%
%% Image spread right page with full bleed.
%
%%	>> \imagerightspreadfullbleed[<vertical-offset>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%  . . . . . . . . . . . .
%%      +---------------+ .
%%      |           .   | .
%%      |        .      | .
%%      |     .         | .
%%      |  .            | .
%%    image             | .
%%      |  .            | .
%%      |     .         | .
%%      |        .      | .
%%      |           . c | .
%%      +---------------+ .
%%  . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\imagerightspreadfullbleed[3][0mm]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			width=\dimexpr 
				2\blockwidth - 2\clearimage + \vgrowimageby \relax,]{#3} }
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



%----------------------------------------------------------------------
%%%% Spread Templates

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

%% \DescribeMacro{\nudgeimage\{..\}}
%
%% Nudge an image horizontally within bleeds. Positive values nudge/move 
%% to the right negative values nudge left.
%
%%	>> \nudgeimage{<amount>}
%
%% in addition to spread commands below this is also used by |\captionsidebox{..}|
%%
\newcommand\nudgeimage[1]{%
	\setlength{\nudgeimageby}{#1}}

%% \DescribeMacro{\vnudgeimage\{..\}}
%
%% Like |\nudgeimage{..}| but nudges vertically.
%
%%	>> \vnudgeimage{<amount>}
%%
%
% NOTE: this should not be used in conjunction with \vgrowimage{..} and 
%		should not exceed 1/2 of the amount given to \vgrowimage{..}
\newcommand\vnudgeimage[1]{%
	\setlength{\vnudgeimageby}{#1}}

%% \DescribeMacro{\vgrowimage\{..\}}
%
%% Grow an image within bleeds. 
%
%%	>> \vgrowimage{<amount>}
%
%% This sizes the image relative to its center this adding 1/2 the 
%% amount to the top and 1/2 to the bottom.
%%
\newcommand\vgrowimage[1]{%
	\setlength{\vgrowimageby}{#1}}


%% \DescribeMacro{\resetnudgeimage}
%
%% Reset the effects of nudging and growing back to 0.
%
%%	>> \resetnudgeimage
%
%% When working with shipout place this after |\newpage| as when 
%% placed before this will reset the |\nudgeimageby{..}| BEFORE the image
%% placing commands have a chance to execute.
%%
% XXX rename
\newcommand\resetnudgeimage{%
	\setlength{\vgrowimageby}{0mm}%
	\setlength{\vnudgeimageby}{0mm}%
	\setlength{\nudgeimageby}{0mm}}



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% XXX
%% \DescribeMacro{\portraitspreadbleedleft\{..\}}
%
%% \LEGACY
%%
%%	>> \portraitspreadbleedleft[<clearence>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%       . . . . . . . .
%%   +---------------+---------------+
%%   |   |.         .|               |
%%   |   | .       . |               |
%%   |   |  .     .  |               |
%%   |   |   .   .   |               |
%%   |   |   image   |               |
%%   |   |   .   .   |               |
%%   |   |  .     .  |               |
%%   |   | .       . |               |
%%   |   |.         .| c             |
%%   +---------------+---------------+
%%       . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
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
%% \DescribeMacro{\portraitspreadbleedright\{..\}}
%
%% \LEGACY
%%
%%	>> \portraitspreadbleedright[<clearence>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                 . . . . . . . .
%%   +---------------+---------------+
%%   |               |.         .|   |
%%   |               | .       . |   |
%%   |               |  .     .  |   |
%%   |               |   .   .   |   |
%%   |               |   image   |   |
%%   |               |   .   .   |   |
%%   |               |  .     .  |   |
%%   |               | .       . |   |
%%   |             c |.         .|   |
%%   +---------------+---------------+
%%                 . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
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
%% \DescribeMacro{\imagespreadleft\{..\}}
%
%% \LEGACY
%%
%% Image spread aligned left (with bleed).
%
%% 	>> \imagespreadleft[<clearence>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   . . . . . . . . . . . . . . . .
%%   . +---------------+---------------+
%%   . | .             .         . |   |
%%   . |    .          .      .    |   |
%%   . |       .       .   .       |   |
%%   . |          .    ..          |   |
%%   . |           image           |   |
%%   . |          .    ..          |   |
%%   . |       .       .   .       |   |
%%   . |    .          .      .    |   |
%%   . | .             .         . | c |
%%   . +---------------+---------------+
%%   . . . . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX might be a good idea to do a version of this with min/max width of 
%		the caption block...
\newcommand\imagespreadleft[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) + \vgrowimageby \relax,]{#3} }
	% left page...
	% XXX BUG: this in some cases creates an extra empty spread before this...
	%		...appears to be a problem where we have a tweak.tex
	\cleartoleftpage
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
	\resetnudgeimage }


% XXX
%% \DescribeMacro{\imagespreadright\{..\}}
%
%% \LEGACY
%%
%% Image spread aligned right (with bleed).
%
%%	>> \imagespreadright[<clearence>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%       . . . . . . . . . . . . . . . .
%%   +---------------+---------------+ .
%%   |   | .         .             . | .
%%   |   |    .      .          .    | .
%%   |   |       .   .       .       | .
%%   |   |          ..   .           | .
%%   |   |          image            | .
%%   |   |          ..   .           | .
%%   |   |       .   .       .       | .
%%   |   |    .      .          .    | .
%%   | c | .         .             . | .
%%   +---------------+---------------+ .
%%       . . . . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\imagespreadright[3][\clearimage]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio, 
			height=\dimexpr \blockheight - ((#1) * 2) + \vgrowimageby \relax,]{#3} }
	% left page...
	\cleartoleftpage
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
				+\bleed
				-\wd\photobook@imagebox \relax}{
			\raisebox{\dimexpr 
					#1 + \bleed 
					- 0.5\vgrowimageby - \vnudgeimageby \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage 
	\resetnudgeimage }


% XXX BUG?: this is not centered vertically...
% XXX
%% \DescribeMacro{\imagespreadfullbleed\{..\}}
%
%% \LEGACY
%%
%% Image spread with full bleed.
%
%%	>> \imagespreadfullbleed[<vertical-offset>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%  . . . . . . . . . . . . . . . . . . .
%%  . +---------------+---------------+ .
%%  . |   .           .           .   | .
%%  . |      .        .        .      | .
%%  . |         .     .     .         | .
%%  . |            .  .  .            | .
%%  . |             image             | .
%%  . |            .  .  .            | .
%%  . |         .     .     .         | .
%%  . |      .        .        .      | .
%%  . |   .           .           . c | .
%%  . +---------------+---------------+ .
%%  . . . . . . . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
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
%%%% Miscellaneous macros

% XXX should digits/rounding be configurable???
\newcommand\photobook@TemplateCell[2][mm]{
	% XXX this seems to be bigger than the size given...
	%\fbox{\parbox[t][\cellheight][t]{\cellwidth}{%
	\begin{center}
		\vfill%
		#2 \\
		(\lenprint[#1]{\cellwidth} \space x \lenprint[#1]{\cellheight})
		\vfill%
		\vspace{0pt}%
	\end{center}}
	%\end{center} }} }


%% \DescribeMacro{\GenerateTemplate\{..\}}
%
%% Generate template page for current |layoutmode|.
%
%%	>> \GenerateTemplate
%
%% Cell size can be printed in |mm| (default) or in any explicit unit 
%% supported by \LaTeX.
%
%%	>> \GenerateTemplate{<unit>}
%
%% This can be useful if one needs to make the cover/jacket/... in either a 
%% different software package or by hand.
%%
%% This is a no-op for |layoutmode=block|.
%%
\newcommand\GenerateTemplate[1][mm]{
	% XXX undo this after...
	\TPoptions{showboxes=true}
	\begin{page}
		\setlength{\parindent}{0em}
		% NOTE: only the relevant blocks will be visible...
		\ifendpaperlayout%
			\begin{leftside}
				\photobook@TemplateCell[#1]{ENDPAPER LEFT}
			\end{leftside}
			\begin{rightside}
				\photobook@TemplateCell[#1]{ENDPAPER RIGHT}
			\end{rightside}\fi%
		\ifcoverlikelayout%
			\begin{frontcover}
				\photobook@TemplateCell[#1]{FRONT COVER}
			\end{frontcover}
			\begin{vspine}%
				\photobook@TemplateCell[#1]{SPINE}%
			\end{vspine}
			\begin{backcover}
				\photobook@TemplateCell[#1]{BACK COVER}
			\end{backcover}\fi%
		\ifjacketlayout%
			\begin{frontflap}%
				\photobook@TemplateCell[#1]{FRONT FLAP}%
			\end{frontflap}
			\begin{backflap}%
				\photobook@TemplateCell[#1]{BACK FLAP}
			\end{backflap}\fi%
	\end{page} }


%% \DescribeMacro{\pdfpagecount\{..\}}
%
%%	Get pdf page count
%%
%%	>>	\pdfpagecount{<file.pdf>}
%%
\newcommand\pdfpagecount[1]{
	\ifpdftex
		\pdfximage{#1}
    	\number\pdflastximagepages%
	\else\ifxetex
		\number\XeTeXpdfpagecount"#1"%
	\else\ifluatex
		\number\directlua{%
			local pages = 0
			local doc = pdfe.open("\luaescapestring{#1}")
			if doc then
				pages = pdfe.getnofpages(doc)
				pdfe.close(doc)
			end
			tex.write(pages) } \fi\fi }


%% \DescribeMacro{\pdfspinewidth\{..\}}
%
%%	Calculate spine thickness
%%
%%	>>	\pdfspinewidth{<paper-thikness>}{<cover-thikness>}{<block-pdf>}
%%
% NOTE: really "like" how LaTeX overcomplicats simple math...
\newcommand\pdfspinewidth[3]{%
	\setlength\spinewidth{\dimexpr
			(#1 mm) * \numexpr \pdfpagecount{#3} / 2 \relax
			+ ((#2 mm) * 2) 
		\relax} }



%----------------------------------------------------------------------
%%% XXX DEBUG...
%%%\AtBeginDocument{
%%%}



%----------------------------------------------------------------------
%% \end{document} %                                 im:set ts=4 sw=4 :
