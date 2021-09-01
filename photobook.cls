%----------------------------------------------------------------------
%
%
% This does the following:
%	- sets up the document/pdf for viewing as a book
%	- adds support for page bleeds
%	- adds basic templates for image pages (XXX)
%
%
% XXX add nudge/grow support -> renamed vars...
%		- add relevant vars -- DONE
%		- API -- DONE (revise)
%		- reset state -- DONE
% XXX revise command naming -- should be obvious from name what is what:
%		- meta commands -- ??? (currently same as templates)
%		- general macros -- \usecell{..}
%		- templates --  \ImagePage{..}
% XXX see where we need to \ignorespaces...
% XXX might be a good idea to add a spine calculator...
% XXX LEGACY BUG: fix \OFFSETFIX
%
%
%----------------------------------------------------------------------

%%% NOTE: \def\<module-name>@[A-Z]+ macros will be visible to both the 
%%%		code and the generated docs...
\edef\photobook@FILEVERSION{v0.1}
\edef\photobook@FILEDATE{2021-07-28}


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
%% \newcommand\EXPERIMENTAL{\fbox{EXPERIMENTAL}}
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
% aggregates...
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


% XXX LEGACY?
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


%% \DescribeMacro{\ResettableMacro\{..\}}
%
%% Create a resettable command.
%
%%	>> \ResettableMacro{<name>}{<code>}
%%	>> \ResettableMacro{<name>}[<arg-count>]{<code>}
%%	>> \ResettableMacro{<name>}[<arg-count>][<default>]{<code>}
%
%% This is similar to |\newcommand{..}| but will define two commands:
%%
%%	>> \<name>{..}
%%
%%	>> \reset<name>
%%
%% |\<name>{..}| can be freely redefined or undefined by user.
%%
%% |\reset<name>| will reset |\<name>{..}| to its original state.
%%
% parse args...
\def\ResettableMacro#1{%
	\@ifnextchar[{%
		\photobook@ResettableMacro@pre{#1}%
	}{%
		\photobook@ResettableMacro{#1}}}
\def\photobook@ResettableMacro@pre#1[#2]{%
	\@ifnextchar[{%
		\photobook@ResettableMacro@args@dfl{#1}[#2]%
	}{%
		\photobook@ResettableMacro@args{#1}[#2]}}
% pre -- main command definition...
\def\photobook@ResettableMacro#1#2{%
	\expandafter\newcommand\csname photobook@ResettableMacro@#1\endcsname{#2}%
	\photobook@ResettableMacro@tail{#1}}
\def\photobook@ResettableMacro@args#1[#2]#3{%
	\expandafter\newcommand\csname photobook@ResettableMacro@#1\endcsname[#2]{#3}%
	\photobook@ResettableMacro@tail{#1}}
\def\photobook@ResettableMacro@args@dfl#1[#2][#3]#4{%
	\expandafter\newcommand\csname photobook@ResettableMacro@#1\endcsname[#2][#3]{#4}%
	\photobook@ResettableMacro@tail{#1}}
% post...
\def\photobook@ResettableMacro@tail#1{%
	% \reset<name>
	\expandafter\newcommand\csname reset#1\endcsname{%
		\expandafter\let\csname #1\expandafter\endcsname\csname photobook@ResettableMacro@#1\endcsname}
	% initialize...
	\csname reset#1\endcsname}


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
%%
%% Note that this may span more than one page if there is enough stuff 
%% packed in.
%%
\newenvironment{page}{%
	\null%
	\ignorespaces%
}{%
	\clearpage}


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
%% \DescribeMacro{\clearance=<len>}
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

% XXX
\newlength\clearance
\setlength\clearance{0pt}


%% \DescribeEnv{inlinecell}
%% \DescribeEnv{inlinecell*}
%
%% Create a basic inline cell.
%
%%	>> \begin{inlinecell}{<width>}{<height>} ... \end{inlinecell}
%%	>> \begin{inlinecell}[<valign>]{<width>}{<height>} ... \end{inlinecell}
%
%% This will clip oversized content.
%%
%% |inlinecell*| is like |inlinecell| but will not clip.
%
%%	>> \begin{inlinecell*}{<width>}{<height>} ... \end{inlinecell*}
%%	>> \begin{inlinecell*}[<valign>]{<width>}{<height>} ... \end{inlinecell*}
%
%% |<valign>| can be one of |t| (default) for top, |c| for center or |b| for bottom.
%%
%% These are just like |minipage| but provide cell mechanics.
%%
\newenvironment{inlinecell*}[3][t]{%
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

\newenvironment{inlinecell}[3][t]{%
	\begin{inlinecell*}[#1]{#2}{#3}%
	\begin{cliptocell}%
}{%
	\end{cliptocell}%
	\end{inlinecell*}}


%% \DescribeEnv{cell}
%% \DescribeEnv{cell*}
%
%% Create a basic absolutely positioned cell.
%
%%	>> \begin{cell}{<top>, <left>}{<width>}{<height>} ... \end{cell}
%
%% Oversized content will be clipped.
%%
%% |cell*| is just like |cell| but will not clip its content.
%
%%	>> \begin{cell*}{<top>, <left>}{<width>}{<height>} ... \end{cell*}
%%
% XXX SYNTAX: place the second arg in braces...
%		\begin{cell*}(<top>, <left>){<width>}{<height>}
\newenvironment{cell*}[3]{%
	\readlist*\photobook@cell@offset{#1}%
	%
	\begin{textblock*}{#2}(#1)%
	\begin{inlinecell*}{#2}{#3}%
		\setlength\celloffsettop{\photobook@cell@offset[1]}%
		\setlength\celloffsetleft{\photobook@cell@offset[2]}%
		\ignorespaces%
}{%
	\end{inlinecell*}%
	\end{textblock*}%
	\ignorespaces}

\newenvironment{cell}[3]{%
	\begin{cell*}{#1}{#2}{#3}%
	\begin{cliptocell}%
		\ignorespaces%
}{%
	\end{cliptocell}%
	\end{cell*}%
	\ignorespaces}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Save cells

%% \DescribeMacro{\savecell\{..\}}
%% \DescribeMacro{\gsavecell\{..\}}
%
%% Create a saved cell.
%
%%	>> \savecell{<name>}{<width>}{<height>}{ .. }
%
%% This is similar to |\newsavebox{..}| and |\sbox{..}| but adds 
%% cell functionality.
%%
%% |\gsavecell{..}| is the same as |\savecell{..}| but greates a global 
%% cell.
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
		\begin{inlinecell*}{#2}{#3}%
			#4%
		\end{inlinecell*}}%
	\ignorespaces}

\newcommand\gsavecell[4]{%
	% only define a savebox once...
	\@ifundefined{#1}{%
		\expandafter\newsavebox\csname #1\endcsname}{}
	\global\expandafter\sbox\csname #1\endcsname{%
		\begin{inlinecell*}{#2}{#3}%
			#4%
		\end{inlinecell*}}%
	\ignorespaces}


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
%% \DescribeMacro{\usecell*\{..\}}
%
%% Use part of a saved cell.
%%
%%	>> \usecell{<name>}(<top>, <left>){<width>}{<height>}
%%
%% This will clip the content to cell.
%%
%% |\usecell*{..}| is similar to |\usecell{..}| but will not clip the 
%% cell content.
%%
%%	>> \usecell*{<name>}(<top>, <left>){<width>}{<height>}
%%
%% These are similar to |\usebox{..}|.
%%
% XXX add option to rotate saved cell...
\def\photobook@usecell@clipped#1(#2)#3#4{
	\begin{inlinecell}{#3}{#4}%
		\photobook@usecell@placecell{#1}(#2)%
	\end{inlinecell}}

% XXX add option to rotate saved cell...
\def\photobook@usecell#1(#2)#3#4{
	\begin{inlinecell*}{#3}{#4}%
		\photobook@usecell@placecell{#1}(#2)%
	\end{inlinecell*}}


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
	\begin{inlinecell*}[#1]{\cellheight}{\cellwidth}%
}{%
	\end{inlinecell*}%
	\end{turn}%
	\end{flushright}}

\newenvironment{bottomup}[1][t]{%
	\begin{turn}{90}%
	\begin{inlinecell*}[#1]{\cellheight}{\cellwidth}%
}{%
	\end{inlinecell*}%
	\end{turn}}


%% \DescribeEnv{cliptocell}
%
%% Clip content to parent cell.
%%
\newenvironment{cliptocell}{%
	\begin{clipbox*}{0cm {\height - \cellheight} {\cellwidth} {\height}}%
	\begin{minipage}[t][\cellheight][t]{\cellwidth}% 
		\ignorespaces%
}{%
	\end{minipage}%
	\end{clipbox*}}


%% \DescribeMacro{\imagecell\{..\}}
%
%% Place image in cell.
%
%%	>> \imagecell{<caption-cell>}{<image>}
%%	>> \imagecell[<key>=<value>, ..]{<caption-cell>}{<image>}
%%
%%	>> \imagecell[fit]{}{<image>}
%%	>> \imagecell[fill]{}{<image>}
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
%%	>> \imagecell{}{<image>}
%%	>> \imagecell[center]{}{<image>}
%%
%% Vertical alignment
%%
%%	>> \imagecell[top]{}{<image>}
%%	>> \imagecell[bottom]{}{<image>}
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
%% Horizontal alignment
%%
%%	>> \imagecell[left]{}{<image>}
%%	>> \imagecell[right]{}{<image>}
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
%%	>> \imagecell[clearance=-4mm]{}{<image>}
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
% XXX document scale/offsettop/offsetleft...

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

% offsettop=<len> / offsetleft=<len>...
\newlength\photobook@imagecell@offsettop%
\setlength\photobook@imagecell@offsettop{0pt}%
\define@key{imagecell@args}{offsettop}[0pt]{%
	\setlength\photobook@imagecell@offsettop{#1}}%
\newlength\photobook@imagecell@offsetleft%
\setlength\photobook@imagecell@offsetleft{0pt}%
\define@key{imagecell@args}{offsetleft}[0pt]{%
	\setlength\photobook@imagecell@offsetleft{#1}}%

% scale=<num>...
\edef\photobook@imagecell@scale{1}%
\define@key{imagecell@args}{scale}[1]{%
	\edef\photobook@imagecell@scale{#1}}%

\def\photobook@imagecell@captionalign{t}
\define@choicekey{imagecell@args}{caption-align}{t,c,b}[t]{%
	\def\photobook@imagecell@captionalign{#1}}%

% XXX add offset support...
%		...i.e. an argument that will shift the image v/h from base position.
%		also need to shift the caption box accordingly but still keep it 
%		within the cell...
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
					width=\photobook@imagecell@scale\dimexpr 
						\cellwidth 
						- ((\photobook@imagecell@clearance) * 2) \relax,
					height=\photobook@imagecell@scale\dimexpr 
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
						width=\photobook@imagecell@scale\dimexpr 
							+ \cellwidth
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}%
			\else%
				\sbox{\photobook@imagebox}{%
					\includegraphics[%
						keepaspectratio, 
						height=\photobook@imagecell@scale\dimexpr 
							+ \cellheight 
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}
			\fi\fi\fi%
		% place image box...
		% XXX for some odd reason without this the alignment completely breaks...
		\vspace{0pt}%
		\adjustbox{%
				%margin={\photobook@imagecell@left} 0pt 0pt {\photobook@imagecell@top}}{%
				margin=
					{\dimexpr 
						\photobook@imagecell@offsetleft 
						+ \photobook@imagecell@left \relax} 
					0pt 0pt 
					{\dimexpr 
						\photobook@imagecell@offsettop
						+ \photobook@imagecell@top \relax}}{%
			% image....
			\usebox\photobook@imagebox%
			%
			% caption cell...
			% XXX make this conditional -- if caption is not empty...
			\begingroup%
				% setup the cell env...
				\setlength\clearance{\photobook@imagecell@clearance}%
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
							\ignorespaces%
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
%% Note that a caption cell does not take up any space in the parent cell
%% so multiple captions can be used in combination with other elements.
%%

% helpers...
% XXX set minipage height to available cell height (???)
\newcommand\photobook@captioncell@formatalign[3][0pt]{%
	\smash{\makebox[0pt][l]{%
		\begin{minipage}[t][\cellheight][t]{\cellwidth}%
			% XXX for some reason without this things get misaligned...
			\vspace{#1}%
			% XXX HACK: for some magical reason setting the above minipage to 'b' 
			%		will make \vspace{..} above break...
			%		...adding another nested minipage seems to fix the issue...
			\begin{minipage}[t][\cellheight][#2]{\cellwidth}%
				\begin{\photobook@captioncell@align}%
					\ignorespaces%
					#3%
				\end{\photobook@captioncell@align}%
			\end{minipage}
		\end{minipage}}}}
% format...
\def\photobook@captioncell@format#1{%
	\photobook@captioncell@formatalign{t}{#1}}

% over / top / center / bottom / under...
\define@boolkey{captioncell@args}{over}[true]{%
	\def\photobook@captioncell@format##1{%
		\photobook@captioncell@formatalign[-\cellheight]{b}{##1}}}
\define@boolkey{captioncell@args}{top}[true]{%
	\def\photobook@captioncell@format##1{%
		\photobook@captioncell@formatalign{t}{##1}}}
\define@boolkey{captioncell@args}{center}[true]{%
	\def\photobook@captioncell@format##1{%
		\smash{\makebox[0pt][l]{%
			\begin{minipage}[t][\cellheight][c]{\cellwidth}%
			\begin{\photobook@captioncell@align}%
				\ignorespaces%
				##1%
			\end{\photobook@captioncell@align}%
			\end{minipage}}}}}
\define@boolkey{captioncell@args}{bottom}[true]{%
	\def\photobook@captioncell@format##1{%
		\photobook@captioncell@formatalign{b}{##1}}}
\define@boolkey{captioncell@args}{under}[true]{%
	\def\photobook@captioncell@format##1{%
		\photobook@captioncell@formatalign[\cellheight]{t}{##1}}}
% align...
\def\photobook@captioncell@align{}
% XXX for some reason \define@choicekey{..} does not expand macros...
%\define@choicekey{captioncell@args}{align}{flushleft,center,flushright}{%
\define@key{captioncell@args}{align}{%
	\def\photobook@captioncell@align{#1}}
% margin...
\def\photobook@captioncell@margin{0pt}
\define@key{captioncell@args}{margin}{%
	\def\photobook@captioncell@margin{#1}}

\newcommand\captioncell[2][]{%
	\setkeys{captioncell@args}{top, align=flushright, margin=1pt, #1}%
	\photobook@captioncell@format{%
		\adjustbox{margin=\photobook@captioncell@margin}{#2}}%
	\ignorespaces}


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
	\KV@vcaptioncell@args@topdownfalse%
	\def\photobook@vcaptioncell@orientation{bottomup}}
\define@boolkey{vcaptioncell@args}{topdown}[true]{%
	\KV@vcaptioncell@args@bottomupfalse%
	\def\photobook@vcaptioncell@orientation{topdown}}

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
\define@key{vcaptioncell@args}{margin}{%
	\def\photobook@vcaptioncell@margin{#1}}

% valign
\def\photobook@vcaptioncell@valign{%
	\ifKV@vcaptioncell@args@bottomup%
		b%
	\else%
		t\fi}

\newcommand\vcaptioncell[2][]{%
	\setkeys{vcaptioncell@args}{left, bottomup, align=flushleft, margin=1pt, #1}%
	%
	\smash{\makebox[0pt][l]{%
		\begin{minipage}[t][\cellheight][\photobook@vcaptioncell@valign]{\cellwidth}%
		\begin{\photobook@vcaptioncell@orientation}%
			\captioncell[%
					\photobook@vcaptioncell@position,
					align=\photobook@vcaptioncell@align,
					margin=\photobook@vcaptioncell@margin]{#2}%
		\end{\photobook@vcaptioncell@orientation}%
		\end{minipage}}}%
	\ignorespaces}


%% \DescribeMacro{\rcaptioncell\{..\}}
%
%% \EXPERIMENTAL
%%
%% Upside-down caption cell.
%%
% XXX a bit off...
\newcommand\rcaptioncell[2][]{%
		\captioncell[align=flushleft, #1]{%
			\begin{turn}{180}%
				% XXX this is hackish -- need to shift by x-height...
				%		...currently this is set to 1/(golden ratio) would
				%		be nice to make this parametric / font-derived...
				\raisebox{\heightof{a} * \real{-0.618033988749855}}{#2}%
			\end{turn}}%
	\ignorespaces}


%% \DescribeMacro{\captionblockcell\{..\}}
%
%% \EXPERIMENTAL
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%    celloffsetleft              celloffsetleft
%%   <------>                    v 
%%   .       <-------------->    <--------------> cellwidth
%%   <---------------------->    <----------------------> cellparentwidth
%%   .       .              .    ..             .       .
%%   +----------------------+    +----------------------+ 
%%   |                      |    |                      | 
%%   |                      |    |                      | 
%%   +-------+ - - - - - - +|    |+ - - - - - - +-------+ 
%%   |       |             .|    |.             |       | 
%%   |       |             .|    |.             |       | 
%%   |  cap. |     cell    .|    |.    cell     |  cap. | 
%%   |       |             .|    |.             |       | 
%%   |       |             .|    |.             |       | 
%%   +-------+ - - - - - - +|    |+ - - - - - - +-------+ 
%%   |                      |    |                      | 
%%   |                      |    |                      | 
%%   +----------------------+    +----------------------+ 
%%                              
%% \end{verbatim}
%% \end{minipage}
%%                              
% XXX need to do a caption block -- a cell to one side of an image to the 
% 		end of the page...
% XXX can we use the normal caption and simply insert a minipage of the 
%		appropriate width???

\newlength\photobook@captionblockcell@tmplen



\define@boolkey{captionblockcell@args}{left}[true]{%
	\KV@captionblockcell@args@rightfalse}
\define@boolkey{captionblockcell@args}{right}[true]{%
	\KV@captionblockcell@args@leftfalse}

% XXX this should depend on left/right...
\def\photobook@captionblockcell@align{flushright}
\define@key{captionblockcell@args}{align}{%
	\edef\photobook@captionblockcell@align{#1}}

% XXX should be a boolkey -- t|c|b???
\edef\photobook@captionblockcell@valign{b}
\define@key{captionblockcell@args}{valign}{%
	\edef\photobook@captionblockcell@valign{#1}}

% XXX clearance=.., 
\newlength\clearcaption
\setlength\clearcaption{0pt}
\newlength\photobook@captionblockcell@clearance
\define@key{captionblockcell@args}{clearance}{%
	\setlength\photobook@captionblockcell@clearance{#1}}

\newlength\photobook@captionblockcell@width
\setlength\photobook@captionblockcell@width{0pt}
\define@key{captionblockcell@args}{width}{%
	\setlength\photobook@captionblockcell@width{#1}}

% XXX padding... ???

% XXX do we need top/bottom boxes???
%		...if yes do we need lop/left, top/right, bottom/left and bottom/right???
% XXX should we keep within parent cell if imagecell has negative clearance???
% XXX need to auto-place within images via \offsetleft...
% XXX add tweak support...
\newcommand\captionblockcell[2][]{%
	% XXX should this be within the group???
	\setkeys{captionblockcell@args}{
		left, 
		align=flushright, 
		valign=b,
		clearance=\clearcaption, 
		#1}%
	%
	\smash{\makebox[0pt][l]{%
		\begingroup%
			% setup cell context...
			\setlength\clearcaption{\photobook@captionblockcell@clearance}%
			\setlength\photobook@captionblockcell@tmplen{\cellwidth}%
			\setlength\cellwidth{%
				\ifnum \photobook@captionblockcell@width = 0%
					\dimexpr 
					\cellparentwidth 
					- \cellwidth 
					- \clearcaption 
					% XXX this is only present in images...
					- \clearance \relax%
				\else%
					\photobook@captionblockcell@width\fi}%
			\setlength\cellparentwidth{\photobook@captionblockcell@tmplen}%
			\setlength\celloffsetleft{%
				\ifKV@captionblockcell@args@left%
					-\cellwidth%
				\else%
					\cellparentwidth\fi}%
			%
			\hspace{\celloffsetleft}{%
				\begin{minipage}[t][\cellheight][\photobook@captionblockcell@valign]{\cellwidth}%
				\begin{\photobook@captionblockcell@align}%
					\ignorespaces%
					#2%
				\end{\photobook@captionblockcell@align}%
				\end{minipage}}%
		\endgroup}}%
	\ignorespaces}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Paper cells

%% \DescribeEnv{papercell}
%
%% Paper cell.
%%
%% This does not include bleeds and is independent of |layoutmode|.
%%
\newenvironment{papercell}{%
	\begin{cell*}{\bleed, \bleed}{\blockwidth}{\blockheight}%
}{%
	\end{cell*}}


%% \DescribeEnv{paperbleedcell}
%
%% Paper bleed cell.
%%
%% Like |papercell| but includes bleeds.
%%
\newenvironment{paperbleedcell}{%
	\begin{cell*}{0, 0}{\bleedblockwidth}{\bleedblockheight}%
}{%
	\end{cell*}}


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
\newenvironment{pagecell}{%
	\begin{cell*}{\bleed,\bleed}{\pageblockwidth}{\pageblockheight}%
}{%
	\end{cell*}}


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
\newenvironment{pagebleedcell}{%
	\begin{cell*}{0mm, 0mm}{\bleedblockwidth}{\bleedblockheight}%
}{%
	\end{cell*}}



% XXX EXPERIMENTAL / TEST...
\NewEnviron{shipoutbgcell}{%
	\AddToShipoutPictureBG*{%
		\begin{pagecell}%
			\BODY%
		\end{pagecell}}%
	\ignorespaces}



% XXX EXPERIMENTAL / TEST...
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
\newenvironment{textcell}{%
	\begin{inlinecell*}{\textwidth}{\textheight}%
}{%
	\end{inlinecell*}}


%% \DescribeEnv{spreadtopages}
%% \DescribeEnv{spreadtopages*}
%% \DescribeMacro{\usespreadpage\{..\}}
%% \DescribeMacro{\usespreadpage*\{..\}}
%
%% Spread cell into pages.
%%
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
%% |spreadtopages| creates a cell and spreads it into pages right away.
%%
%%	>> \begin{spreadtopages} .. \end{spreadtopages}
%%	>> \begin{spreadtopages}[<page-count>] .. \end{spreadtopages}
%%
%% |spreadtopages*| creates a named save cell.
%%
%%	>> \begin{spreadtopages*}{<name>} .. \end{spreadtopages*}
%%	>> \begin{spreadtopages*}[<page-count>]{<name>} .. \end{spreadtopages*}
%%
%% |\usespreadpage{..}| places a page from a saved cell.
%%
%%	>> \usespreadpage{<name>}
%%	>> \usespreadpage[<page-num>]{<name>}
%%
%% |\usespreadpage*{..}| is the same as the non-star version but will 
%%	not use a |page| environment, enabling the user to populate the page
%%	with other elements.
%%
%% Page numbers a re 1-based.
%%
%% Note that the cell created by |spreadtopages*| env is a normal save 
%% cell and can be manipulated via |\usecell{..}| and |\usecell*{..}|.
%%
% XXX add nudge/grow support...

\NewEnviron{spreadtopages*}[2][2]{%
	% setup page count...
	\@ifundefined{thespreadtopages#2page}{%
		\newcounter{spreadtopages#2page}}{}
	\setcounter{spreadtopages#2page}{1}
	%
	\begingroup%
		% create the actual cell...
		\setlength\cellparentwidth{\cellwidth}%
		\setlength\cellparentheight{\cellheight}%
		\setlength\cellwidth{#1\pageblockwidth}%
		\setlength\cellheight{\pageblockheight}%
		%
		\gsavecell{#2}{\cellwidth}{\cellheight}{\BODY}%
	\endgroup%
	\ignorespaces}

% NOTE: this essentially counts pages, \usecell{..} / \usecell*{..} are 
%		better suited for custom stuff...
% NOTE: page is a 1 based offset in pages and can be fractional...
% NOTE: \usecell*{..} takes care of all the bleed calculations...
\def\usespreadpage{\@ifstar{%
		\photobook@usespreadpage@star%
	}{%
		\photobook@usespreadpage}}
\newcommand\photobook@usespreadpage@star[2][]{%
	\begin{pagecell}%
		% auto advance pages...
		\ifthenelse{\equal{#1}{}}{%
			\usecell*{#2}%
				(0pt, \numexpr \value{spreadtopages#2page} - 1 \relax\cellwidth)%
				{\cellwidth}{\cellheight}%
			\stepcounter{spreadtopages#2page}%
		% manual page selected...
		}{%
			\usecell*{#2}%
				(0pt, \numexpr #1 - 1 \relax\cellwidth)%
				{\cellwidth}{\cellheight}}%
	\end{pagecell}}
\newcommand\photobook@usespreadpage[2][]{%
	\begin{page}%
		\usespreadpage*[#1]{#2}%
	\end{page}}

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
		% place the pages...
		\foreach \photobook@spreadtopages@page in {1, ..., #1}{%
			\usespreadpage[\photobook@spreadtopages@page]{photobook@spreadtopages}}%
	\endgroup%
	\ignorespaces}


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

% XXX for some reason naming these anything starting with endpaper will
%		make LaTeX complain that that is already defined...
%		...collision with bools???
\newenvironment{leftside}{%
	\begin{pagecell}%
}{%
	\end{pagecell}}

\newenvironment{rightside}{%
	\begin{cell*}%
			{\bleed + \pageblockwidth, \bleed}%
			{\pageblockwidth}{\pageblockheight}%
}{%
	\end{cell*}}


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
	\begin{cell*}{
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
	\end{cell*}}

\newenvironment{backcover}{%
	\begin{cell*}{
				\bleed 
					+ \jacketflapback 
					+ \coverflap 
					+ \jacketwrap,
				\bleed 
					+ \coverflap }%
			{ \pageblockwidth + \coverboardgrow }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell*}}


% spines...
%
\newenvironment{spine}{%
	\begin{cell*}{
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
	\end{cell*}}

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
	\begin{cell*}{
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
	\end{cell*}}

\newenvironment{backflap}{%
	\begin{cell*}{
				\bleed,
				\bleed 
					+ \coverflap }%
			{ \jacketflapback }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell*}}



%----------------------------------------------------------------------
%%%% Caption Templates
% XXX need to be able to configure/pass/override:
%		- size / \captionsize...
%		- color...
% XXX captions seem not to account for \imageblockoffsettop...

%% \DescribeMacro{\captionsize\{..\}}
%
%% Defines the caption font setup macro
%%
\ResettableMacro{captionsize}{%
	\fontsize{6.5pt}{8pt}\selectfont}


%% \DescribeMacro{\captionformat\{..\}}
%
%%
%%
% XXX move to a better location... (???)
\ResettableMacro{captionformat}[1]{%
	\adjustbox{margin=0.1em 0.2em}{%
		\captionsize #1}}



%----------------------------------------------------------------------
%%%% Page Templates
%
%% This section contains a set of predefined configurable single-page
%% templates.
%%

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Tweaking
%
%% Most page/spread templates provide an ability to externally "tweak" 
%% some image proportions.
%%
%% This is an alternative means to setting template properties, e.g:
%
%% \begin{verbatim}
%%		\tweakimagescale{0.8}
%%		\ImagePage{image}
%% \end{verbatim}
%
%% Is equivalent to:
%
%%	>> \ImagePage[scale=0.8]{image}
%
%% Tweaks get reset after each template.
%%


%% \DescribeMacro{\imagescale=<num>}
%% \DescribeMacro{\imageoffsettop=<len>}
%% \DescribeMacro{\imageoffsetleft=<len>}
%
%% Tweak next image templates scale/offsettop/offsetleft
%%
%% Note that |\imagescale| is not a length.
%
%%	>> \edef\imagescale{<scale>}
%%	>> \setlength\imageoffsettop{<len>}
%%	>> \setlength\imageoffsetleft{<len>}
%%
\edef\imagescale{1}
% NOTE: these are initialized later by \resetimagetweaks...
\newlength\imageoffsettop
\newlength\imageoffsetleft

%% \DescribeMacro{\tweakimagescale\{..\}}
%% \DescribeMacro{\tweakimageoffsetleft\{..\}}
%% \DescribeMacro{\tweakimageoffsetleft\{..\}}
%
%% Convenience commands
%%
%% These provide a uniform interface for tweaking.
%
%%	>> \tweakimagescale{<scale>}
%%	>> \tweakimageoffsettop{<len>}
%%	>> \tweakimageoffsetleft{<len>}
%%
\newcommand\tweakimagescale[1]{%
	\edef\imagescale{#1}}
\newcommand\tweakimageoffsettop[1]{%
	\setlength\imageoffsettop{#1}}
\newcommand\tweakimageoffsetleft[1]{%
	\setlength\imageoffsetleft{#1}}

%% \DescribeMacro{\resetimagetweaks\{..\}}
%
%% Reset tweaked values.
%%
\newcommand\resetimagetweaks{%
	\edef\imagescale{1}%
	\setlength\imageoffsettop{0pt}%
	\setlength\imageoffsetleft{0pt}}

% setup initial state...
\resetimagetweaks


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% meta-commands...

% \DescribeMacro{\ImagePageTemplate\{..\}}
%
%	>> \ImagePageTemplate{<name>}{<code>}
%
% This will define two commands:
%
%	>> \<name>[<options>]{<caption>}{<code>}
%
%	>> \<name>*[<options>]{<caption>}{<code>}
%
% |\<name>{..}| will use |\<name>Caption{..}| template command to typeset 
% the image caption while |\<name>*{..}| will show the caption as-is.
%
\def\ImagePageTemplate#1#2{%
	% handle <macro>* version...
	\expandafter\def\csname #1\endcsname{\@ifstar{%
		\csname photobook@ImagePageTemplate@#1@star\endcsname%
	}{%
		\csname photobook@ImagePageTemplate@#1\endcsname}}%
	% main implementation (raw caption)...
	\expandafter\newcommand\csname photobook@ImagePageTemplate@#1@star\endcsname[3][]{%
		#2%
		\resetimagetweaks}%
	% main implementation with caption template...
	\expandafter\newcommand\csname photobook@ImagePageTemplate@#1\endcsname[3][]{%
		\csname photobook@ImagePageTemplate@#1@star\endcsname[##1]{%
			\@ifundefined{#1Caption}{%
				##2%
			}{%
				\csname #1Caption\endcsname{##2}}}{##3}}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

\newsavebox\photobook@imagebox



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Templates
%
%% A templates provide a uniform interface consisting of several commands:
%%
%% Base template command:
%
%%	>> \<template-name>{<caption>}{<image>}
%%	>> \<template-name>[<options>]{<caption>}{<image>}
%
%% |<options>| is the same as for |\imagecell{..}|.
%%
%% Template-specific caption command:
%
%%	>> \<template-name>Caption{<caption>}
%
%% This can be redefined to control typesetting the caption for all 
%% consecutive templates.
%%
%% Reset template caption to default:
%
%%	>> \reset<template-name>Caption
%
%% An equivalent to the non-star version but use the caption as-is:
%
%%	>> \<template-name>*{<caption>}{<image>}
%%	>> \<template-name>*[<options>]{<caption>}{<image>}
%
%% Note that thogh some template versions differ only in |<options>| 
%% defaults passed to |\imagecell{..}|, they are split to provide ability 
%% to configure the template defaults separately.
%%

%% \DescribeMacro{\ImagePage\{..\}}
%% \DescribeMacro{\ImagePageCaption\{..\}}
%% \DescribeMacro{\resetImagePageCaption}
%% \DescribeMacro{\ImagePage*\{..\}}
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
%%
%% Note that |\ImagePage{..}| only supports tweaking |scale|, this is 
%% intentional ad tweaking offset will mess up page alignment relative 
%% to other pages in a book.
%%
\ResettableMacro{ImagePageCaption}[1]{%
	\captioncell[under, align=flushright]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImagePage}{%
	\begin{page}%
	\begin{pagecell}%
	\begin{minipage}[t][\cellheight][c]{\cellwidth}%
		\vspace{\imageblockoffsettop\pagetextheight}%
		\begin{center}%
			% compensate for \bindingoffset...
			\hspace{\ifnumodd{\thepage}{\bindingoffset}{-\bindingoffset}}{%
				\begin{inlinecell*}%
						{\imageblockwidth\pagetextwidth}%
						{\imageblockheight\pagetextheight}%
					\imagecell[fit,
						scale=\imagescale,
						#1]{#2}{#3}%
				\end{inlinecell*}}%
		\end{center}%
	\end{minipage}%
	\end{pagecell}%
	\end{page}}


%% \DescribeMacro{\ImagePageFit\{..\}}
%% \DescribeMacro{\ImagePageFitCaption\{..\}}
%% \DescribeMacro{\resetImagePageFitCaption}
%% \DescribeMacro{\ImagePageFit*\{..\}}
%
%% Fit image into page...
%
%%	>> \ImagePageFit[<options>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                               . . . . . . .
%%   +-----------------+      +-----------------+
%%   |                 |      |  |.         .|  |
%% . +-----------------+ .    |  | .       . |  |
%% . | .             . | .    |  |  .     .  |  |
%% . |    .       .    | .    |  |   .   .   |  |
%% . |      image      | .    |  |   image   |  |
%% . |    .       .    | .    |  |   .   .   |  |
%% . | .             . | .    |  |  .     .  |  |
%% . +-----------------+ .    |  | .       . |  |
%%   |               c |      |  |.        c.|  |
%%   +-----------------+      +-----------------+
%%                               . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Default image clearence (|clearimage| option value in |\imagecell{..}|) 
%% is set by |\clearimage| global length.
%%
% XXX make captions adaptive??? 
\ResettableMacro{ImagePageFitCaption}[1]{%
	\captioncell[under, align=flushright]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImagePageFit}{%
	\begin{page}%
	\begin{pagecell}%
		\imagecell[center, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			#1]{#2}{#3}%
	\end{pagecell}%
	\end{page}}


%% \DescribeMacro{\ImagePageFill\{..\}}
%% \DescribeMacro{\ImagePageFillCaption\{..\}}
%% \DescribeMacro{\resetImagePageFillCaption}
%% \DescribeMacro{\ImagePageFill*\{..\}}
%
%%	Like |\ImagePage| but will fill page with image.
%
%%	>> \ImagePageFill[<options>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   . . . . . . . . . . . . . . . . . . .
%%   . .      +-----------------+      . .
%%   .    .   |              c  |   .    .
%%   .       .|                 |.       .
%%   .        | .             . |        .
%%   .        |    .       .    |        .
%%   .        |      image      |        .
%%   .        |    .       .    |        .
%%   .        | .             . |        .
%%   .       .|                 |.       .
%%   .    .   |                 |   .    .
%%   . .      +-----------------+      . .
%%   . . . . . . . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Default image clearence (|clearimage| option value in |\imagecell{..}|) 
%% is set by |\clearimage| global length.
%%
\ResettableMacro{ImagePageFillCaption}[1]{%
	\captioncell[top, align=flushright]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImagePageFill}{%
	\ImagePageFit*[fill, #1]{#2}{#3}}


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
%%   . +-----------------+
%%   . |.         .|     |
%%   . | .       . |     |
%%   . |  .     .  |     |
%%   . |   .   .   |     |
%%   . |   image   |     |
%%   . |   .   .   |     |
%%   . |  .     .  |     |
%%   . | .       . |     |
%%   . |.         .| c   |
%%   . +-----------------+
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
	%\captionboxright[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr \OFFSETFIX + #1 \relax}{
			\raisebox{\dimexpr #1 + \bleed \relax}{
				\usebox\photobook@imagebox}}}}
	\newpage}


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
%%   +-----------------+ .
%%   |     |.         .| .
%%   |     | .       . | .
%%   |     |  .     .  | .
%%   |     |   .   .   | .
%%   |     |   image   | .
%%   |     |   .   .   | .
%%   |     |  .     .  | .
%%   |     | .       . | .
%%   |   c |.         .| .
%%   +-----------------+ .
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
	%\captionboxleft[-#1]{\photobook@imagebox}{#2}
	\ShipoutPicture{
		\AtPageLowerLeft{
			\hspace*{\dimexpr 
				-#1 
				+\blockwidth 
				-\wd\photobook@imagebox \relax}{
			\raisebox{\dimexpr #1 + \bleed \relax}{
				\usebox\photobook@imagebox } } } }
	\newpage }


%% \DescribeMacro{\ImageHalfPageL\{..\}}
%% \DescribeMacro{\ImageHalfPageLCaption\{..\}}
%% \DescribeMacro{\resetImageHalfPageLCaption}
%% \DescribeMacro{\ImageHalfPageL*\{..\}}
%
%% Left half of image filling page with full bleed.
%
%%	>> \imageleftspreadfullbleed[<vertical-offset>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%  . . . . . . . . . . . . . 
%%  . +-----------------+     
%%  . |   .             |     
%%  . |       .         |     
%%  . |           .     |     
%%  . |               . |     
%%  . |               image
%%  . |               . |     
%%  . |           .     |     
%%  . |       .         |     
%%  . |   .           c |     
%%  . +-----------------+     
%%  . . . . . . . . . . . . . 
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX TEST...
% XXX do a better default...
\ResettableMacro{ImageHalfPageLCaption}[1]{%
	\captioncell[bottom, align=flushright]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImageHalfPageL}{%
	\begin{spreadtopages*}[2]{photobook@ImageHalfPageL@cell}%
		\imagecell[fill, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			#1]{#2}{#3}%
	\end{spreadtopages*}%
	%
	\cleartoleftpage%
	\usespreadpage[1]{photobook@ImageHalfPageL@cell}}



%% \DescribeMacro{\ImageHalfPageR\{..\}}
%% \DescribeMacro{\ImageHalfPageRCaption\{..\}}
%% \DescribeMacro{\resetImageHalfPageRCaption}
%% \DescribeMacro{\ImageHalfPageR*\{..\}}
%
%% Right half of image filling page with full bleed.
%
%%	>> \imagerightspreadfullbleed[<vertical-offset>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%  . . . . . . . . . . . . .
%%      +-----------------+ .
%%      |             .   | .
%%      |         .       | .
%%      |     .           | .
%%      | .               | .
%%    image               | .
%%      | .               | .
%%      |     .           | .
%%      |         .       | .
%%      |             . c | .
%%      +-----------------+ .
%%  . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX TEST...
% XXX do a better default...
\ResettableMacro{ImageHalfPageRCaption}[1]{%
	\captioncell[bottom, align=flushright]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImageHalfPageR}{%
	\begin{spreadtopages*}[2]{photobook@ImageHalfPageR@cell}%
		\imagecell[fill, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			#1]{#2}{#3}%
	\end{spreadtopages*}%
	%
	\cleartoleftpage%
	\usespreadpage[2]{photobook@ImageHalfPageR@cell}}



%----------------------------------------------------------------------
%%%% Spread Templates

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


%% \DescribeMacro{\ImageSpreadLeft\{..\}}
%% \DescribeMacro{\ImageSpreadLeftCaption\{..\}}
%% \DescribeMacro{\resetImageSpreadLeftCaption}
%% \DescribeMacro{\ImageSpreadLeft*\{..\}}
%
%% Image spread aligned left (with bleed).
%
%% 	>> \ImageSpreadLeft[<options>]{<caption>}{<image>}
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
% XXX do a better default...
% XXX need a caption box...
\ResettableMacro{ImageSpreadLeftCaption}[1]{%
	\vcaptioncell[after, align=flushleft]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImageSpreadLeft}{%
	\cleartoleftpage%
	\begin{spreadtopages}[2]%
		\imagecell[fit, 
			left, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			#1]{#2}{#3}%
	\end{spreadtopages}}


% XXX
%% \DescribeMacro{\ImageSpreadRight\{..\}}
%% \DescribeMacro{\ImageSpreadRightCaption\{..\}}
%% \DescribeMacro{\resetImageSpreadRightCaption}
%% \DescribeMacro{\ImageSpreadRight*\{..\}}
%
%% Image spread aligned right (with bleed).
%
%%	>> \ImageSpreadRight[<options>]{<caption>}{<image>}
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
% XXX need a caption box...
% XXX do a better default...
\ResettableMacro{ImageSpreadRightCaption}[1]{%
	\vcaptioncell[before, align=flushleft]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImageSpreadRight}{%
	\cleartoleftpage%
	\begin{spreadtopages}[2]%
		\imagecell[fit, 
			right, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			#1]{#2}{#3}%
	\end{spreadtopages}}


%% \DescribeMacro{\ImageSpreadFill\{..\}}
%% \DescribeMacro{\ImageSpreadFillCaption\{..\}}
%% \DescribeMacro{\resetImageSpreadFillCaption}
%% \DescribeMacro{\ImageSpreadFill*\{..\}}
%
%% Image spread with full bleed.
%
%%	>> \ImageSpreadFill[<options>]{<caption>}{<image>}
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

% XXX do a better default...
\ResettableMacro{ImageSpreadFillCaption}[1]{%
	\captioncell[bottom, align=flushright]{%
		\captionformat{#1}}}

\ImagePageTemplate{ImageSpreadFill}{%
	\cleartoleftpage%
	\begin{spreadtopages}[2]%
		\imagecell[fill, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			#1]{#2}{#3}%
	\end{spreadtopages}}



%----------------------------------------------------------------------
%%%% Miscellaneous macros

% XXX should digits/rounding be configurable???
\newcommand\photobook@TemplateCell[2][mm]{
	\begin{center}
		\vfill%
		#2 \\
		(\lenprint[#1]{\cellwidth} \space x \lenprint[#1]{\cellheight})
		\vfill%
		\vspace{0pt}%
	\end{center}%
	\ignorespaces}


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
	\TPoptions{showboxes=true}%
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
				\photobook@TemplateCell[#1]{FRONT FLAP}
			\end{frontflap}
			\begin{backflap}%
				\photobook@TemplateCell[#1]{BACK FLAP}
			\end{backflap}\fi%
	\end{page}}


%% \DescribeMacro{\pdfpagecount\{..\}}
%
%%	Get pdf page count
%%
%%	>>	\pdfpagecount{<file.pdf>}
%%
\newcommand\pdfpagecount[1]{%
	\ifpdftex%
		\pdfximage{#1}%
    	\number\pdflastximagepages%
	\else\ifxetex%
		\number\XeTeXpdfpagecount"#1"%
	\else\ifluatex%
		\number\directlua{%
			local pages = 0
			local doc = pdfe.open("\luaescapestring{#1}")
			if doc then
				pages = pdfe.getnofpages(doc)
				pdfe.close(doc)
			end
			tex.write(pages) }\fi\fi}


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
		\relax}}



%----------------------------------------------------------------------
%%% XXX DEBUG...
%%%\AtBeginDocument{
%%%}



%----------------------------------------------------------------------
%% \end{document} %                                 im:set ts=4 sw=4 :
