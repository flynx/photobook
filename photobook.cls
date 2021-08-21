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
%%   .   +---------------------------------------+-----  v   .   .  ---
%%   .   |                           ^       .   =   .
%%   .   |   .   .   .   .   .   .   |   .   .   =   .               ^
%%   .   |<-- blockwidth ----------------------->=   .               |
%%   .   |   .                       |   .   .   =   .               |
%%   .   |                           |       .   =   .       textheight
%%   .   |   .                       |   .   .   =   .               |
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
%%   |               |
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
%%   |               .               |
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
% XXX also need a way to:
%			- setup front-cover
%			- setup pine
%			- setup back-cover
%		...envs??
% XXX do we need to implement cover fold over???
% XXX not yet sure how to go about this -- should we update \blockwidth 
%		or should we define a new length and let some templates 
%		use one and some use the other???
%		...I'm leaning towards the later...
% XXX fold/cut marks???
% XXX write all the dimensions to pdf comment...
% XXX EXPERIMENTAL...
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
%
% XXX better name...
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

% XXX argument processing -- use one of the following two...
%\RequirePackage{pgfkeys}
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
\RequirePackage[overlay,absolute]{textpos}
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


%% \DescribeMacro{\ResetPages}
%
%%	Reset and re-initialize page dimentions.
%%
\newcommand\ResetPages{
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
		\dimexpr #2 \relax%
	\fi }

\newcommand\maxdim[2]{
	\ifdim \dimexpr #1 \relax > \dimexpr #2 \relax%
		\dimexpr #1 \relax%
	\else%
		\dimexpr #2 \relax%
	\fi }


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

% XXX for some reason we are pushed away from the left edge...
\newlength{\OFFSETFIX}
\setlength{\OFFSETFIX}{-4mm}

% This compensates for caption width being miscalcualted for right 
% alingned captions...
\newlength{\CAPTIONWIDTHFIX}
\setlength{\CAPTIONWIDTHFIX}{-5mm}



%----------------------------------------------------------------------
%%%% Environments and Cells
%
% XXX need a way to place images / templates into these...
% XXX should these only be visible in respective modes or for non-zero widths???


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
\newenvironment{page}{}{%
	\null
	\clearpage }


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cells
%
%% A cell environments is a box of specified size placed at a specific 
%% location in a page.
%%
%% Cells are implemented via |textpos|'s |textblock*| environment.
%%
%% A cell defines |\cellwidth| and |\cellheight| within it's body that 
%% store the initial cell dimentions.
%%
\newlength\cellwidth
\newlength\cellheight

% XXX should we treat the page as a cell???
\setlength\cellwidth{\textwidth}
\setlength\cellheight{\textheight}


% \DescribeMacro{\begin\{inlinecell\}\{..\} ...}
%% \DescribeEnv{inlinecell}
%
%% Create a basic inline cell.
%
%%	>> \begin{inline}<width>}{<height>} ... \end{inlinecell}
%
%% This is just like |minipage| but provides cell mechanics.
%%
% XXX
\newenvironment{inlinecell}[2]{%
	\begingroup%
		\setlength\cellwidth{\dimexpr #1 \relax}%
		\setlength\cellheight{\dimexpr #2 \relax}%
		%
		\begin{minipage}[t][\cellheight][t]{\cellwidth}% 
		\ignorespaces%
}{%
		\end{minipage}%
	\endgroup}


% \DescribeMacro{\begin\{cell\}\{..\} ...}
%% \DescribeEnv{cell}
%
%% Create a basic absolutely positioned cell.
%
%%	>> \begin{cell}{<top>, <left>}{<width>}{<height>} ... \end{cell}
%
% XXX cells can not be nested -- they will mess up the \cellwidth and 
%		\cellheight for parents...
% XXX SYNTAX: place the second arg in braces...
%		\begin{cell}(<top>, <left>){<width>}{<height>}
\newenvironment{cell}[3]{%
	\begingroup%
	\setlength\parindent{0em}%
	\begin{textblock*}{#2}(#1)%
	\begin{inlinecell}{#2}{#3}%
}{%
	\end{inlinecell}%
	\end{textblock*}%
	\endgroup}


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
\newenvironment{clipcell}[3]{%
	\begin{cell}{#1}{#2}{#3}%
	\begin{cliptocell}%
	\ignorespaces%
}{%
	\end{cliptocell}%
	\end{cell}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cell macros
%
%% Cell macros require a cell environment to function correctly.
%%

% XXX
\newcommand\captionformat[1]{%
	\begin{flushright}%
		\captionsize #1%
	\end{flushright}}



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

% XXX TODO:
%		- offset fix for fill mode...
%		- caption cell in fill mode...
%		- do we need to reverse left/right for fill? (feels counter-intuitive)
% XXX HACK -- need to track down where is this coming from and either 
%		set it to zero or account for it correctly....
% XXX RENAME -- make this global...
\newlength\photobook@HOFFSETFIX
\setlength\photobook@HOFFSETFIX{1.5pt}

% XXX should these be lengths or macros???
\def\photobook@imagecell@top{0pt}
\def\photobook@imagecell@left{0pt}
\def\photobook@imagecell@clearance{0pt}

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
		+\photobook@HOFFSETFIX
		+0.5\cellwidth 
		-0.5\wd\photobook@imagebox \relax}}%
% left/right...
% shortdands...
\newcommand\photobook@imagecell@LEFT{%
	\def\photobook@imagecell@left{\dimexpr%
		+\photobook@HOFFSETFIX
		+\photobook@imagecell@clearance \relax}}%
\newcommand\photobook@imagecell@RIGHT{%
	\def\photobook@imagecell@left{\dimexpr 
		+\photobook@HOFFSETFIX
		+\cellwidth 
		-\photobook@imagecell@clearance
		-\wd\photobook@imagebox \relax}}%
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
		\photobook@imagecell@clearance}}%
\define@boolkey{imagecell@args}{bottom}[true]{%
	\def\photobook@imagecell@top{\dimexpr 
		+\cellheight 
		-\photobook@imagecell@clearance
		-\ht\photobook@imagebox \relax}}%
% clearance=<len>...
\define@key{imagecell@args}{clearance}{%
	\def\photobook@imagecell@clearance{#1}}%

\def\photobook@imagecell@captionalign{t}
\define@choicekey{imagecell@args}{caption-align}{t,c,b}[t]{%
	\def\photobook@imagecell@captionalign{#1}}%

% XXX can't seem to get rid of small placement errors...
%		...feels like we've still got a stray space someplace...
%		see: \photobook@HOFFSETFIX
% XXX can we make this an env???
\newcommand\imagecell[3][]{%
	\begingroup%
		% args...
		\setkeys{imagecell@args}{fit,center,clearance=0pt,#1}%
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
			\ifdim \wd\photobook@imagebox < \ht\photobook@imagebox%
				\sbox{\photobook@imagebox}{%
					\includegraphics[%
						keepaspectratio, 
						width=\dimexpr 
							+\cellwidth 
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}%
			\else%
				\sbox{\photobook@imagebox}{%
					\includegraphics[%
						keepaspectratio, 
						height=\dimexpr 
							+\cellheight 
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}\fi\fi\fi%
		% place image box...
		% XXX for some odd reason without this the alignment completely breaks...
		\vspace{0pt}%
		\adjustbox{%
			margin=
				{\photobook@imagecell@left - \photobook@HOFFSETFIX}
				0pt 0pt 
				{\photobook@imagecell@top}}{%
			% image....
			\usebox\photobook@imagebox%
			% caption cell...
			\ifx #2 \empty \else%
				\begingroup%
					% XXX broken for fill...
					% XXX test for portrait images...
					\hspace{-\mindim{%
								\wd\photobook@imagebox
							}{%
								\cellwidth - \photobook@imagecell@clearance}}{%
						\setlength\cellwidth{\dimexpr%
							-2\photobook@HOFFSETFIX
							+\mindim{\wd\photobook@imagebox}{\cellwidth} \relax}%
						\setlength\cellheight{%
							\mindim{\ht\photobook@imagebox}{\cellheight}}% 
						\setlength\fboxsep{0pt}%
						\begin{minipage}[b][\cellheight][\photobook@imagecell@captionalign]{\cellwidth}%
							#2%
						\end{minipage}}%
				\endgroup\fi}%
	\endgroup}


%% \DescribeMacro{\captioncell\{..\}}
%
%% \fbox{XXX EXPERIMENTAL}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%    [ above         ]
%%   +-----------------+
%%   |[ top           ]|
%%   |                 |
%%   |                 |
%%   |                 |
%%   |                 |
%%   |                 |
%%   |                 |
%%   |[ bottom        ]|
%%   +-----------------+
%%    [ below         ]
%%
%% \end{verbatim}
%% \end{minipage}
%%

% XXX revise keywords...
\define@boolkey{captioncell@args}{above}[true]{}
\define@boolkey{captioncell@args}{top}[true]{}
\define@boolkey{captioncell@args}{bottom}[true]{}
\define@boolkey{captioncell@args}{below}[true]{}

% XXX add fields: before/left/right/after... (vertical???)
% XXX add vertical fields direction: up/down

% XXX expand choices...
\define@choicekey{captioncell@args}{align}{flushleft,center,flushright}{}


\newcommand\captioncell[2][]{%
	\setkeys{captioncell@args}{top, align=flushleft,#1}%
	% XXX
}

% XXX HACK -- make over/under/... an argument...
\newcommand\captioncellunder[1]{
	\vspace{\cellheight}%
	\begin{flushright}%
		\captionformat{%
			\adjustbox{margin=0pt 0.5em}{#1}}%
	\end{flushright}}


%% \DescribeMacro{\cimagetocellfit\{..\}}
%
%% Fit an image to cell (centered).
%
%%	>> \cimagetocellfit[<clearence>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +-----------------+
%%   |                 |
%%   +-----------------+ 
%%   | .             . | 
%%   |    .       .    | 
%%   |      image      | 
%%   |    .       .    | 
%%   | .             . | 
%%   +-----------------+ 
%%   |               c |
%%   +-----------------+ 
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Image position can be tweaked via |\vspace{..}| or |\hspace{..}|
%
% XXX do we need this???
% XXX revise caption for vertical images...
\newcommand\cimagetocellfit[3][0mm]{%
	\imagecell[center, clearance=#1]{\captioncellunder{#2}}{#3}}


% XXX like fill but trim to cell...
% XXX do we need this???
\newcommand\imagetocellclip[3][0pt]{%
	\begin{cliptocell}%
		\imagecell[clearance=#1,fill]{#2}{#3}%
	\end{cliptocell}}


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

\NewEnviron{leftside}{%
	\ifendpaperlayout%
		\begin{pagecell}%
			\BODY%
		\end{pagecell} \fi }

\NewEnviron{rightside}{%
	\ifendpaperlayout%
		\begin{cell}%
				{\bleed + \pageblockwidth, \bleed}%
				{\pageblockwidth}{\pageblockheight}%
			\BODY%
		\end{cell} \fi }


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
\NewEnviron{frontcover}{%
	\ifcoverlikelayout%
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
			\BODY%
		\end{cell} \fi }

\NewEnviron{backcover}{%
	\ifcoverlikelayout%
		\begin{cell}{
					\bleed 
						+ \jacketflapback 
						+ \coverflap 
						+ \jacketwrap,
					\bleed 
						+ \coverflap }%
				{ \pageblockwidth + \coverboardgrow }%
				{ \pageblockheight + 2\coverboardgrow }%
			\BODY%
		\end{cell} \fi }


% spines...
%
\NewEnviron{spine}{%
	\ifcoverlikelayout
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
				{ \pageblockheight + 2\coverboardgrow }
			\BODY%
		\end{cell} \fi }

\NewEnviron{vspine}[1][270]{%
	\ifcoverlikelayout
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
				{ \pageblockheight + 2\coverboardgrow }
			\begin{turn}{#1}%
			\begin{minipage}[t][\cellwidth][t]{\cellheight}% 
				\BODY%
			\end{minipage}%
			\end{turn}%
		\end{cell} \fi }


% jackets flaps...
%
\NewEnviron{frontflap}{%
	\ifjacketlayout
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
			\BODY%
		\end{cell} \fi }

\NewEnviron{backflap}{%
	\ifjacketlayout
		\begin{cell}{
					\bleed,
					\bleed 
						+ \coverflap }%
				{ \jacketflapback }%
				{ \pageblockheight + 2\coverboardgrow }%
			\BODY%
		\end{cell} \fi }


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cell helper macros

% XXX should digits/rounding be configurable???
\newcommand\photobook@TemplateCell[2][mm]{
	% XXX this seems to be bigger than the size given...
	%\fbox{\parbox[t][\cellheight][t]{\cellwidth}{%
	\begin{center}
		\vfill
		#2 \\
		(\lenprint[#1]{\cellwidth} \space x \lenprint[#1]{\cellheight})
		\vfill
	\end{center} }
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
		\begin{leftside}
			\photobook@TemplateCell[#1]{ENDPAPER LEFT}
		\end{leftside}
		\begin{rightside}
			\photobook@TemplateCell[#1]{ENDPAPER RIGHT}
		\end{rightside}
		\begin{frontcover}
			\photobook@TemplateCell[#1]{FRONT COVER}
		\end{frontcover}
		%\begin{vspine}[90]
		%\begin{vspine}[down]
		\begin{vspine}
			\photobook@TemplateCell[#1]{SPINE}
		\end{vspine}
		\begin{backcover}
			\photobook@TemplateCell[#1]{BACK COVER}
		\end{backcover}
		\begin{frontflap}
			\photobook@TemplateCell[#1]{FRONT FLAP}
		\end{frontflap}
		\begin{backflap}
			\photobook@TemplateCell[#1]{BACK FLAP}
		\end{backflap}
	\end{page} }


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% pages...

% XXX



%----------------------------------------------------------------------
%%%% Captions
% XXX need to be able to configure/pass/override:
%		- size / \captionsize...
%		- color...
% XXX captions seem not to account for \imageblockoffsettop...

%\newcommand\captionsize{\scriptsize}
\newcommand\captionsize{\fontsize{6.5pt}{8pt}\selectfont}


%% \DescribeMacro{\imagecaption\{..\}}
%
%%	>> \imagecaption{<caption>}{<location-date>}
%%
\newcommand\imagecaption[2]{
	{\captionsize%
		#1 %
		\par\vspace{-\parskip}%
		#2}}


%% \DescribeMacro{\overlaycaption\{..\}}
%
%%	>> \overlaycaption{<caption>}{<location-date>}
%%
\newcommand\overlaycaption[2]{
	\begin{flushright}
		\captionsize%
		\color{black}{%
			\colorbox{white}{ #1 }%
			\par\vspace{-\parskip}%
			\colorbox{white}{ #2 }}
	\end{flushright}}


%% \DescribeMacro{\captionsidebox\{..\}}
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


% XXX \CAPTIONWIDTHFIX
%% \DescribeMacro{\captionbottombox\{..\}}
%
%%	>> \captionbottombox[<offset>]{<imagebox>}{<text>}
%%
% XXX for some reason the width is wrong here...
\newcommand\captionbottombox[3][0mm]{
	\hspace{ #1 }{
		% XXX the \CAPTIONWIDTHFIX factor is compensating for an odd alignment error...
		\begin{minipage}{\dimexpr \CAPTIONWIDTHFIX + \wd#2 \relax}
			{ \captionsize #3 }
		\end{minipage}}}


%% \DescribeMacro{\graycaptionpage\{..\}}
%
%%	>> \graycaptionpage{<text>}
%%
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
%%%% Page Templates

\newsavebox\photobook@imagebox


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%% \DescribeMacro{\imagepagefitWH\{..\}}
%
%%	>> \imagepagefitWH{<width>}{<height>}{<caption>}{<image>}
%%
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
% XXX BUG: vertical alignment falls apart if page head is changed...
% XXX replace \ifthenelse\isodd .. with etoolbox equivalent.... (???)
\newcommand\imagepagefitWH[4]{
	\sbox{\photobook@imagebox}{
		\includegraphics[
			keepaspectratio=true, 
			width=#1\textwidth, 
			height=#2\textheight,]{#4} }
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
		% XXX for some magical reason \vfill here makes latex err 
		%		"Missing } inserted", removing it fixes the error but breaks
		%		captions...
		%		...also adding a '}' here does not break things...
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


%% \DescribeMacro{\imagepagefitW\{..\}}
%% \DescribeMacro{\imagepagefitH\{..\}}
%
%%	Shorthands to |\imagepagefitWH|
%
%%	>> \imagepagefitH[<height>]{<caption>}{<image>}
%%	>> \imagepagefitW[<width>]{<caption>}{<image>}
%%
\newcommand\imagepagefitH[3][\imageblockheight]{
	\imagepagefitWH{\imageblockwidth}{#1}{#2}{#3} }
\newcommand\imagepagefitW[3][\imageblockwidth]{
	\imagepagefitWH{#1}{\imageblockheight}{#2}{#3} }


%% \DescribeMacro{\imagepage\{..\}}
%
%%	Basic image page
%
%%	>> \imagepage{<caption>}{<path>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +---------------+
%%   |               |
%%   | +-----------+ |
%%   | |.         .| |
%%   | |  .     .  | |
%%   | |   image   | |
%%   | |  .     .  | |
%%   | |.         .| |
%%   | +-----------+ |
%%   |             c |
%%   |               |
%%   +---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\imagepageO[2]{
	\imagepagefitWH{\imageblockwidth}{\imageblockheight}{#1}{#2} }


% XXX this is not yet 100% the same as \imagepage{..}
%		- vertical offset seems not to match (not sure who's fault is it)...
% XXX needs caption...
\newcommand\imagepage[2]{%
	\begin{page}%
		\begin{pagecell}%
			\begin{minipage}[t][\cellheight][c]{\cellwidth}%
				\vspace{\imageblockoffsettop\pagetextheight}%
				\begin{center}%
					\hspace{\ifnumodd{\thepage}{\bindingoffset}{-\bindingoffset}}{%
						\begin{inlinecell}%
								{\imageblockwidth\pagetextwidth}%
								{\imageblockheight\pagetextheight}%
							\imagecell[fit]{\captioncellunder{#1}}{#2}%
						\end{inlinecell}}%
				\end{center}%
			\end{minipage}%
		\end{pagecell}%
	\end{page}}



% XXX
% XXX captions wrong... 
%% \DescribeMacro{\imagepagefit\{..\}}
%
%% Similar to |\imagepage| but will fit an image into page...
%
%%	>> \imagepagefit[<clearence>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%     . . . . . . .
%%   +---------------+
%%   | |.         .| |
%%   | | .       . | |
%%   | |  .     .  | |
%%   | |   .   .   | |
%%   | |   image   | |
%%   | |   .   .   | |
%%   | |  .     .  | |
%%   | | .       . | |
%%   | |.         .| |
%%   +---------------+
%%     . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
\newcommand\imagepagefit[3][\clearimage]{%
	\null%
	\begin{pagecell}%
		\cimagetocellfit[#1]{#2}{#3}%
	\end{pagecell}%
	\clearpage }


%% \DescribeMacro{\imagepagefill\{..\}}
%
%%	Like |\imagepage| but will fill page with image.
%
%%	>> \imagepagefill[<clearence>]{<caption>}{<image>}
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
% XXX add nudge/grow support...
\newcommand\imagepagefill[3][\clearimage]{
	\null%
	\begin{pagecell}%
		\imagecell[clearance=#1,fill]{#2}{#3}%
	\end{pagecell}%
	\clearpage }


% XXX
% XXX \OFFSETFIX
%% \DescribeMacro{\portraitimagepageleft\{..\}}
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
%%% XXX DEBUG...
%%%\AtBeginDocument{
%%%}



%----------------------------------------------------------------------
%% \end{document} %                                 im:set ts=4 sw=4 :
