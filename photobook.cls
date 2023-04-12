%----------------------------------------------------------------------
%
% photobook.cls
% -------------
%
% This does the following:
%	- sets up the document/pdf for viewing as a book
%	- sets up page bleeds
%	- defines cells as basic template building blocks
%	- adds basic templates for image pages and spreads
%
%
% This file contains both the code and the reference, but in a slightly 
% more readable format than the traditional LaTeX .dtx format. In general
% there are two main sections:
%	- code
%	- reference
%		lines starting with "%%" or "%X" where X is a section id
% Sections are parts of the reference that are logically ordered differently 
% than the code, e.g. main user tools should have priority in the reference 
% while meta code (identified by "%M") can be described later, while in code
% we strictly need to define macros before they are used thus meta-macros
% and other building blocks and components come before the user tools.
%
% Docs are built by the Makefile, so reference it for more info.
%
% To make the reference use:
%
%	$ make pdf
%
%
% NOTE: in a stripped code install this file may contain only code and 
%		code comments, in this case, to see the docs refer to either the 
%		source or the actual documentation/pdf.
% NOTE: the stripped code file is auto-generated, it is not recommended 
%		to edit it directly, edit the source instead.
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% XXX ASAP might be a good idea to add a generic \bleedcell{..}
%		with options to control which bleeds to include and their size...
%			\bleedcell[top left bottom right]{..}
%			\bleedcell[0mm 10mm 0mm 10mm]{..}
%			\bleedcell[5mm]{..}
%			\bleedcell[5mm 10mm]{..}
%			...
%		...semantics similar to CSS margins...
% XXX ASAP should cover/jacket/endpaper/spread templates/cells account
%		for \bindingoffset (likely no) and/or \gutteroffset ???
%		...especially relevant to endpaper/spread...
% XXX ASAP revise how bleeds are handled by cells...
%
% XXX captions behave in an odd way...
%		the internal (macro) minipage for some reason does not affect text 
%		justification while adding a minipage in the macro argument works
%		as expected -- some odd input mode???
% XXX Q: should \blockwidth include \bindingoffset (current) or not???
% XXX revise \clearcaption / \captionclearpage...
% XXX unify API -- see CellContent env...
% XXX make this loadable both as a class and as a package...
%		\@ifclassloaded{photobook}{<true>}{<false>}
% XXX revise command naming -- should be obvious from name what is what:
%		- meta commands -- ??? (currently same as templates)
%		- general macros -- \usecell{..}
%		- templates --  \ImagePage{..}
% XXX see where we need to \ignorespaces...
% XXX might be a good idea to add a spine calculator (auto)...
%		...i.e. input paper and cover board thickness and auto-calc spine...
% XXX might be fun to add a 'box' layout to build book boxes...
% XXX add a grid cell / image cell (???)
%		make it trivial to define AxB cell layouts and fill them (fully/partially)
% XXX manual / book:
%		- basic usage
%			- setup
%			- templates (copyright, front matter, back matter, acknowledgements, ...)
%			- using templates
%			- pre-print
%		- customizing
%		- extending
% XXX DOC add notes about external libs section:
%		- textpos
%			cell/cell* depend on absolute mode being set globally
%
%
%----------------------------------------------------------------------

%%% NOTE: \def\<module-name>@[A-Z]+ macros will be visible to both the 
%%%		code and the generated docs...
\edef\photobook@FILEVERSION{v0.1.18}
\edef\photobook@FILEDATE{2023-04-11}


%% \documentclass{ltxdoc}
%%
%%% \usepackage{iftex}
%%% \ifluatex
%%% 	\edef\pdfcompresslevel{\pdfvariable compresslevel} 
%%% 	\edef\pdfobjcompresslevel{\pdfvariable objcompresslevel}
%%% \fi
%%% \pdfcompresslevel 0
%%% \pdfobjcompresslevel 0
%% 
%% \usepackage[a4paper,margin=25mm,left=55mm,nohead]{geometry}
%%
%% % NOTE: this needs to load before hyperref or bookmarks will break...
%% % NOTE: loading hyperref here will break it loading later in one of 
%% %		the packages...
%% \usepackage{titlesec}
%%
%% \usepackage[numbered]{hypdoc}
%% \usepackage{doctools}
%% \usepackage{needspace}
%%
%% \usepackage[toc]{multitoc}
%% \renewcommand*{\multicolumntoc}{2}
%% \setlength{\columnseprule}{0.5pt}
%%
%% \usepackage{imakeidx}
%% \makeindex[
%%		columns=1, 
%%		title=Alphabetical Index, 
%%		intoc,
%%		options= -s photobook.ist ]
%%
%%% \newcommand\DescribeGlobal[1]{%
%%%	\DescribeMacro{#1}}
%%
%% \newcommand\LEGACY[1][]{\fbox{LEGACY #1}}
%% \newcommand\EXPERIMENTAL[1][]{\fbox{EXPERIMENTAL #1}}
%%
%%% sections to new pages...
%% \newcommand\sectionbreak{\Needspace{5\baselineskip}}
%%
%% % remove section numbering...
%% \setcounter{secnumdepth}{0}
%%
%% % paragraph configuration...
%% \setlength\parindent{0pt}
%% \setlength\parskip{0.5em}
%% 
%% \newcommand\blankfootnote[1]{%
%% 	\begingroup
%% 		\renewcommand\thefootnote{}%
%% 		\footnote{#1}%
%% 		\addtocounter{footnote}{-1}%
%% 	\endgroup}
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
%%
%% \maketitle
%%
%% \begin{abstract}
%%	The |photobook| \LaTeX\space document class extends the |book| class 
%%	defining a set of parameters, meta-macros, macros and environments 
%%	with reasonable defaults to help typeset, build and print books mainly 
%%	based on visual/image content.
%% \end{abstract}
%%
%% \tableofcontents
%%
%
%%%% Introduction
%
%% \LaTeX\ is great with textual and text-primary content with figures
%% peppered in, as long as pictures/figures flow within, with or as part
%% of text, vanilla \LaTeX\ is fantastic.
%% 
%% One can relatively easily stretch the flow concept to more complex
%% layouts introducing {\it even} and {\it odd} pages (the |book| class is 
%% one example) and flow rules based on them, but the next step, {\it bleeds}, 
%% combining page pairs into {\it spreads} as is often needed when designing 
%% image-oriented books is lacking. Full-bleed images/pages can be implemented 
%% manually, some more effort is needed to split something horizontally 
%% into a page spread, but doing so for whole book's worth of content is 
%% not practical -- automating and experimenting with this process is 
%% how |photobook| began.
%% 
%% |photobook| extends the |book| class adding page layout types, bleeds
%% and other global geometry configuration, introduces the {\it page} and
%% {\it spread} as first-class elements into the document flow. These concepts
%% are generalized as |cell|s. A |cell| is similar to a figure, it can
%% be placed within the document flow, but unlike a figure a |cell| can
%% be aligned relative to a page, it can fill a page, a cell can even be
%% horizontally split to fill several pages (how spreads are implemented).
%% 
%% On top of the |cell|, {\it page}, and {\it spread} concepts, |photobook| 
%% also builds a set of configurable high level macros and templates for 
%% common use cases like full bleed image spreads, foldouts, ... etc.
%
%
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

\edef\photobook@options{\@classoptionslist}

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
%% \DescribeMacro{gutteroffset=<len>}
%% \DescribeMacro{bleed=<len>}
%
%% This is similar to what |geometry| does, but adds bleed support.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   <---> bleed                                   <---> bleed
%%                                                 
%%   + - - - - - - - - - - - - - - - - - - - - - - + - +   ^
%%   .                                             .   .   | bleed
%%   .   +-----------------------------------------+-----  v   .   .  ---
%%   .   |                           ^       .  .  =   .
%%   .   |   .   .   .   .   .   .   |   .   .  .  =   .               ^
%%   .   |<-- blockwidth ------------------------->=   .               |
%%   .   |   .                       |   .   .  .  =   .               |
%%   .   |                           |       .  .  =   .       textheight
%%   .   |   .             Page      |   .   .  .  =   .               |
%%   .   |                      blockheight  .  .  =   .               |
%%   .   |   .                       |   .   .  <--> bindingoffset     |
%%   .   |                           |       .  .  =   .               |
%%   .   |   .   .   .   .   .   .   |   .   <--> gutteroffset         v
%%   .   |                           v       .  .  =   .
%%   .   +-----------------------------------------+-----  ^   .   .  ---
%%   .   .                                         .   .   | bleed
%%   + - - - - - - - - - - - - - - - - - - - - - - + - +   v
%%       .                                         .
%%       |   <-- textwidth -------------->    .    |
%%                                                 ^ gutter
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Note that all macros respect |\bindingoffset| but only some macros 
%% account for |\gutteroffset|, namely macros that do not display content 
%% with bleeds.
%%
% NOTE: if blockwidth/blockheight are set they will force recalculations 
%		and overriding of the paperwidth/paperheight if they were changed
%		by the user code anywhere between \documentclass[..]{photobook}
%		and \begin{document}...
\DeclareStringOption{blockwidth}
\DeclareStringOption{blockheight}
\DeclareStringOption[0pt]{bindingoffset}[0mm]
\DeclareStringOption[0pt]{gutteroffset}[0mm]
\DeclareStringOption[5mm]{bleed}[5mm]

%% \DescribeMacro{flatfold=<len>}
%
%% Sets the clearance set aside for a flat fold, used for foldouts 
%% (see: \nameref{subsec:Foldout page cells} section).
%%
\DeclareStringOption[0pt]{flatfold}[0.2mm]

%% \DescribeMacro{pagefold=<fold>}
%
%% Sets the default fold type.
%%
%% Can be |in| or |out|.
%%
% XXX check values...
\DeclareStringOption{pagefold}

%% \DescribeMacro{foldout=<fold-spec>}
%
%% Sets the default fold specification (i.e. sets |\defaultfoldout|).
%%
%% For more information see: \nameref{subsec:Foldout page cells} section.
%%
\DeclareStringOption[2]{foldout}[2]



%%%%% layout
%
%% \DescribeMacro{layoutmode=<layout>}
%% \DescribeMacro{block}
%% \DescribeMacro{spread}
%% \DescribeMacro{endpaper}
%% \DescribeMacro{cover}
%% \DescribeMacro{jacket}
%%% \DescribeMacro{web}
%
%% Sat page layout mode.
%
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
%% |spread|/|endpaper|:
%%
%%	Spread/endpaper layout.
%%
% XXX should this use \flatfold???
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%       blockwidth 2x
%%   <------------------------------->
%%
%%   +---------------+---------------+
%%   |               .               |
%%   |               .               |
%%   |            spread             |
%%   |               .               |
%%   |               .               |
%%   +---------------+---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%	
%% Note that |endpaper| is simply an alias to |spread|, this helps make
%% the book source to be more semantic and readable.
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
%% Note that for |cover|, |spread|/|endpaper|, and |jacket|, 
%% \href{https://ctan.org/pkg/fancyhdr}{fancyhdr}'s |\pagestyle{..}| is 
%% set to |empty| by default.
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
\@DeclareLiteralOptionTo{layoutmode}{spread}
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
\DeclareStringOption{clearimage}[10mm]


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
%% Sets PDF page display mode.
%%
%% Defaults to |TwoColumnLeft| for |layoutmode=block| and |SinglePage| for
%% other modes.
%%
%% See: 
%% \href{https://ctan.altspu.ru/macros/latex/contrib/hyperref/doc/hyperref-doc.pdf}{hyperref}'s 
%% |pdfpagelayout| for more options.
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
%% \DescribeMacro{nofoldmarks}
%
%% If given disable fold marks.
%%
%% This sets |\iffoldmarks| to false, otherwise it is set to true.
%%
\DeclareBoolOption{nofoldmarks}

%% \DescribeMacro{foldmarksize=<len>}
%
%% Sets the fold mark size (default: 6mm).
%%
\DeclareStringOption[6mm]{foldmarksize}

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
%%%% Packages
%
%% |photobook| adds and uses internally the following packages: 
%
% NOTE: imports are after \LoadClass{ .. } to avoid fighting over macro
%		names...

%% \href{https://ctan.org/pkg/geometry}{geometry},
%% \href{https://ctan.org/pkg/kvoptions}{kvoptions},

%% \href{https://ctan.org/pkg/calc}{calc},
\RequirePackage{calc}
%% \href{https://ctan.org/pkg/xargs}{xargs},
\RequirePackage{xargs}
%% \href{https://ctan.org/pkg/ifthen}{ifthen},
\RequirePackage{ifthen}
%% \href{https://ctan.org/pkg/iftex}{iftex},
\RequirePackage{iftex}
%% \href{https://ctan.org/pkg/pgffor}{pgffor},
\RequirePackage{pgffor}
%% \href{https://ctan.org/pkg/xint}{xint},
\RequirePackage{xint}
%% \href{https://ctan.org/pkg/xinttools}{xinttools},
\RequirePackage{xinttools}
%% \href{https://ctan.org/pkg/listofitems}{listofitems},
\RequirePackage{listofitems}
%% \href{https://ctan.org/pkg/xkeyval}{xkeyval},
\RequirePackage{xkeyval} 
%% \href{https://ctan.org/pkg/etoolbox}{etoolbox},
\RequirePackage{etoolbox}
%% \href{https://ctan.org/pkg/atbegshi}{atbegshi},
\RequirePackage{atbegshi}
%\RequirePackage{afterpage}
%\RequirePackage{changepage}
%% \href{https://ctan.org/pkg/hyperref}{hyperref},
\RequirePackage[unicode]{hyperref}
%\RequirePackage{pdfcomment}
%% \href{https://ctan.org/pkg/eso-pic}{eso-pic},
\RequirePackage{eso-pic}
%% \href{https://ctan.org/pkg/environ}{environ},
\RequirePackage{environ}
%% \href{https://ctan.org/pkg/numprint}{numprint},
\RequirePackage{numprint}
%% \href{https://ctan.org/pkg/trimclip}{trimclip},
\RequirePackage{trimclip}
%% \href{https://ctan.org/pkg/xcolor}{xcolor},
\RequirePackage{xcolor}
%% \href{https://ctan.org/pkg/pagecolor}{pagecolor},
\RequirePackage{pagecolor}
%% \href{https://ctan.org/pkg/colorspace}{colorspace},
\RequirePackage{colorspace}
%% \href{https://ctan.org/pkg/graphicx}{graphicx},
\RequirePackage{graphicx}
%% \href{https://ctan.org/pkg/adjustbox}{adjustbox},
\RequirePackage{adjustbox}
%% \href{https://ctan.org/pkg/adjustbox}{adjustbox},
% XXX BUG TEXTPOS textblock in absolute mode does not behave well with 
%		sbox in absolute mode...
\RequirePackage[absolute]{textpos}
%% \href{https://ctan.org/pkg/fancyvrb}{fancyvrb},
\RequirePackage{fancyvrb}
%% \href{https://ctan.org/pkg/tikz}{tikz},
\RequirePackage{tikz}
%\RequirePackage[linewidth=1pt]{mdframed}
% XXX flow text frames...
% XXX this messes with geometry....
%\RequirePackage{flowfram}
%% \href{https://ctan.org/pkg/rotating}{rotating},
\RequirePackage{rotating}
%% \href{https://ctan.org/pkg/fancyhdr}{fancyhdr}, and
\RequirePackage{fancyhdr}
%% \href{https://ctan.org/pkg/pdfpages}{pdfpages}.
\RequirePackage{pdfpages}


%% \newline
%% Most of these packages can be used by the book author without explicitly
%% importing them.
%%


%----------------------------------------------------------------------
%%%% Globals
% XXX move these out to relevant sections + add a separate globals glossary...
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
\newif\ifspreadlayout
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
\setlength\coverflap{\photobook@coverflap}

\newlength\photobook@coverflap@active

%% \DescribeMacro{\jacketwrap=<len>}
%% \DescribeMacro{\jacketflap=<len>}
%% \DescribeMacro{\jacketflapfront=<len>}
%% \DescribeMacro{\jacketflapback=<len>}
%
%%	Jacker configuration
%%
\newlength\jacketwrap
\setlength\jacketwrap{\photobook@jacketwrap}
\newlength\jacketflap
\setlength\jacketflap{\photobook@jacketflap}
\newlength\jacketflapfront
\setlength\jacketflapfront{\photobook@jacketflapfront}
\newlength\jacketflapback
\setlength\jacketflapback{\photobook@jacketflapback}

\newlength\photobook@jacketwrap@active
\newlength\photobook@jacketflap@active
\newlength\photobook@jacketflapfront@active
\newlength\photobook@jacketflapback@active

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
%% Page bleed size
%%
\newlength\bleed
\setlength\bleed{\photobook@bleed}

%% \DescribeMacro{\bindingoffset=<len>}
%
%% Binding offset
%%
%% Used to offset content to account glue-up/roughing of pages for certain 
%% types of binds like perfect binds.
%%
\newlength\bindingoffset
\setlength\bindingoffset{\photobook@bindingoffset}

%% \DescribeMacro{\gutteroffset=<len>}
%
%% Gutter offsets
%%
%% Mainly used to offset content without bleeds away from or into the 
%% gutter.
%%
\newlength\gutteroffset
\setlength\gutteroffset{\photobook@gutteroffset}

%% \DescribeMacro{\defaultfoldout=<fold-spec>}
%
%% Set the default fold specification.
%%
%% This can be set via the |foldout| class option.
%%
%% For more information see: \nameref{subsec:Foldout page cells} section.
%%
\edef\defaultfoldout{\photobook@foldout}

%% \DescribeMacro{\flatfold=<len>}
%
%% Sets the amount of paper to account for a flat fold.
%%
\newlength\flatfold
\setlength\flatfold{\photobook@flatfold}

%% \DescribeMacro{\pagefold=<fold>}
%
%% Default fold type.
%%
%% This defaults to |out| for |jacket| and |cover| and to |in| for other
%% layouts.
%%
\newcommand\photobook@setpagefold[1]{%
	\edef\pagefold{
		\ifx \photobook@pagefold \empty%
			#1%
		\else%
			\photobook@pagefold\fi}}
\photobook@setpagefold{in}

%% \DescribeMacro{\foldmarkoffset=<len>}
%
%% Sets the offset of fold marks from outside of page edge (default: |0.5\bleed|).
%%
%% Note that this can either be a command or a dimension.
%%
%\def\foldmarkoffset{0.5\bleed}
\def\foldmarkoffset{2mm}

%% \DescribeMacro{\foldmarksize=<len>}
%
%% Sets fold marker size (vertical).
%%
\newlength\photobook@foldmarklen
\setlength\photobook@foldmarklen{\photobook@foldmarksize}

%% \DescribeMacro{\iffoldmarks}
%
%% Disable/enable fold marks.
%%
%% The default is true, to toggle on/off use |\foldmarkstrue| / |\foldmarksfalse|.
%%
%% This can be set globally via the |nofoldmarks| class option.
%%
\newif\iffoldmarks
\ifphotobook@nofoldmarks%
	\foldmarksfalse%
\else%
	\foldmarkstrue\fi%

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
%% The ration by which the image is raised in |\ImagePage{..}| and 
%% derived templates.
%%
\edef\imageblockoffsettop{\photobook@imageblockoffsettop}

%% \DescribeMacro{\clearcaption=<len>}
%
%% Block caption clearance from edge of parent cell.
%%
%% Used as default by |\captionblockcell{..}|
%%
% XXX do we need this???
\newlength\clearcaption
\setlength\clearcaption{0pt}

%% \DescribeMacro{\captioncellspacing=<len>}
%
%% Block caption spacing from parent cell.
%%
%% Used as default by |\captionblockcell{..}|
%%
% XXX should this be used in other caption cells???
\newlength\captioncellspacing
\setlength\captioncellspacing{5pt}


%% \DescribeMacro{\captionclearpage=<len>}
%
%% The distance between a caption block on a template page and page 
%% borders (defaults to: |\clearimage|).
%%
%% This is relevant only in page/spread templates.
%%
\def\captionclearpage{\clearimage}


%% \DescribeMacro{\cellparentwidth=<len>}
%% \DescribeMacro{\cellparentheight=<len>}
%% \DescribeMacro{\cellwidth=<len>}
%% \DescribeMacro{\cellheight=<len>}
%% \DescribeMacro{\celloffsetleft=<len>}
%% \DescribeMacro{\celloffsettop=<len>}
%% \DescribeMacro{\clearance=<len>}
%
%% Cell geometry. 
%%
%% These are set automatically by cells, thus it is not recommended to 
%% edit them manually.
%%
%% For more details see the \nameref{subsec:Cells} section.
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
\newlength\clearance
\setlength\clearance{0pt}


%% \DescribeMacro{\clearfoldoutgutter=<len>}
%% \DescribeMacro{\clearfoldoutfold=<len>}
%% \DescribeMacro{\clearfoldoutedge=<len>}
%
%% Foldout geometry.
%%
%% For more info see \nameref{subsec:Foldout page cells} section.
%%
\newlength\clearfoldoutgutter
\setlength\clearfoldoutgutter{8mm}
\newlength\clearfoldoutfold
\setlength\clearfoldoutfold{5mm}
\newlength\clearfoldoutedge
\setlength\clearfoldoutedge{1mm}



%----------------------------------------------------------------------
%%%% Initialization
%%
%% \DescribeMacro{\InitPages}
%
%% Initialize page dimensions.
%%
%% This is not intended for direct use.
%%
% XXX do we need to document this??
%		...is there a usecase for calling this manually?
\newcommand\InitPages{
	% layout bools/tests...
	\coverlayoutfalse
	\hardcoverlayoutfalse
	\softcoverlayoutfalse
	\endpaperlayoutfalse
	\spreadlayoutfalse
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
	\ifdefstring{\layoutmode}{spread}{ 
		\spreadlayouttrue
		\endpaperlayouttrue }{}
	\ifdefstring{\layoutmode}{endpaper}{ 
		\spreadlayouttrue
		\endpaperlayouttrue }{}
	% pdf layout...
	\ifx\photobook@pdfpagelayout\empty
		\ifblocklayout
			\def\pdfpagelayout{TwoPageRight}
		\else
			\def\pdfpagelayout{SinglePage}\fi
	\else
		\def\pdfpagelayout{\photobook@pdfpagelayout}\fi
	% keep user settings but respect the current layout...
	\ifcoverlayout
		\setlength\photobook@coverflap@active{\coverflap}
	\else
		\setlength\photobook@coverflap@active{0pt}\fi
	\ifjacketlayout
		\setlength\photobook@jacketwrap@active{\jacketwrap}
		\setlength\photobook@jacketflap@active{\jacketflap}
		% flaps...
		\ifdim\jacketflapfront=0pt
			\setlength\photobook@jacketflapfront@active{\photobook@jacketflap@active}
		\else
			\setlength\photobook@jacketflapfront@active{\jacketflapfront}\fi
		\ifdim\jacketflapback=0pt
			\setlength\photobook@jacketflapback@active{\photobook@jacketflap@active}
		\else
			\setlength\photobook@jacketflapback@active{\jacketflapback}\fi
	\else
		\setlength\photobook@jacketwrap@active{0pt}
		\setlength\photobook@jacketflap@active{0pt}
		\setlength\photobook@jacketflapfront@active{0pt}
		\setlength\photobook@jacketflapback@active{0pt}\fi
	% block size...
	\ifdim\blockwidth=0pt
		% layout: block...
		\setlength\blockwidth{
			\ifx\photobook@blockwidth\empty
				\dimexpr 
					\paperwidth 
					- 2\bleed \relax
			\else
				\photobook@blockwidth \fi} 
		\setlength\pageblockwidth{\blockwidth}
		% layout: cover...
		\ifcoverlayout
			\pagestyle{empty}%
			\setsepchar{,}%
			\readlist*\pagefoldpanels{%
				\the\coverflap,
				% board thickness is ignored...
				\the\dimexpr
					\coverboardgrow
					+ \pageblockwidth \relax,
				\the\spinefold,
				\the\spinewidth,
				\the\spinefold,
				\the\dimexpr
					\coverboardgrow
					+ \pageblockwidth \relax,
				% board thickness is ignored...
				\the\coverflap}%
			\photobook@setpagefold{out}
			\setlength\blockwidth{
				\dimexpr 
					2\blockwidth 
					+ \spinewidth 
					+ 2\spinefold
					+ 2\coverboardgrow
					+ 2\coverflap \relax}\fi
		% layout: jacket...
		% XXX this seems to be about 6mm off -- what are we missing here???
		\ifjacketlayout
			\pagestyle{empty}%
			\setsepchar{,}%
			\readlist*\pagefoldpanels{%
				\the\photobook@jacketflapback@active,
				\the\jacketwrap,
				\the\dimexpr
					\coverboardgrow
					+ \pageblockwidth \relax,
				\the\spinefold,
				\the\spinewidth,
				\the\spinefold,
				\the\dimexpr
					\coverboardgrow
					+ \pageblockwidth \relax,
				\the\jacketwrap,
				\the\photobook@jacketflapfront@active}%
			\photobook@setpagefold{out}
			\setlength\blockwidth{
				\dimexpr 
					2\blockwidth 
					+ 2\coverboardgrow
					+ \spinewidth
					+ 2\spinefold
					+ 2\jacketwrap
					+ \photobook@jacketflapfront@active
					+ \photobook@jacketflapback@active \relax}\fi
		% layout: spread/endpaper...
		\ifspreadlayout
			\pagestyle{empty}%
			\readlist*\pagefoldpanels{%
				\the\pageblockwidth,
				\the\pageblockwidth}%
			\photobook@setpagefold{in}
			\setlength\blockwidth{2\blockwidth}\fi\fi
	\ifdim\blockheight=0pt
		% layout: block / spread...
		\setlength\blockheight{
			\ifx\photobook@blockheight\empty
				\dimexpr \paperheight - 2\bleed \relax
			\else
				\photobook@blockheight\fi} 
		\setlength\pageblockheight{\blockheight}
		% layout: cover...
		\ifcoverlayout
			\setlength\blockheight{
				\dimexpr 
					\blockheight
					+ 2\coverboardgrow
					+ 2\coverflap
				\relax}\fi
		% layout: jacket...
		\ifjacketlayout
			\setlength\blockheight{
				\dimexpr 
					\blockheight
					+ 2\coverboardgrow
				\relax}\fi\fi
	% default image clearance...
	\ifdim \clearimage = \maxdimen
		\ifx\photobook@clearimage\empty
			%\setlength\clearimage{-\bleed}
			\setlength\clearimage{10mm}
		\else
			\setlength\clearimage{\photobook@clearimage}\fi\fi
	% page with bleeds...
	% NOTE: this is essentially \paperwidth and \paperheight but we do 
	%		not rely on them being defined -- photobook settings take 
	%		priority over \paperwidth and \paperwidth...
	\setlength\bleedblockwidth{\dimexpr 
			2\bleed 
			+ \blockwidth \relax}
	\setlength\bleedblockheight{\dimexpr 
			2\bleed 
			+ \blockheight \relax} 
	% cells...
	\global\setlength\cellparentwidth{\blockwidth}
	\global\setlength\cellparentheight{\blockheight}
	\global\setlength\cellwidth{\cellparentwidth}
	\global\setlength\cellheight{\cellparentheight}
	% misc...
	\nprounddigits{\photobook@roundprintedlengthsto}}


%% \DescribeMacro{\ReInitPages}
%
%%	Reset and re-initialize page dimentions.
%%
\newcommand\ReInitPages{%
	\setlength\blockwidth{0mm}%
	\setlength\blockheight{0mm}%
	\edef\pdfpagelayout{}%
	%
	\InitPages%
	\ResetFoldMarks}

%% \DescribeMacro{\ChangeLayout}
%
%% Change document layout.
%
%%	>> \ChangeLayout{<layoutmode>}
%
%% This is a shorthand for |\def\layoutmode{<layoutmode>}| and then 
%% |\ReInitPages|, and as this is changing any other parameters that may 
%% affect the layout, this should be done last.
%%
\newcommand\ChangeLayout[1]{%
	\def\layoutmode{#1}%
	\ReInitPages}


%----------------------------------------------------------------------
% Setup...

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% on-import...

% init/update lengths...
\InitPages

% minimal geometry setup...
\RequirePackage[
	% paper size (incl. bleeds)...
	paperwidth=\bleedblockwidth, paperheight=\bleedblockheight,
]{geometry}

% colors...
%
% This prevents \pagecolor from getting drawn over other elements...
\pagecolor{white}
\pagecolor{none}
\color{black}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% pre-document...

\AtEndPreamble{

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
			vcentering, hcentering}\fi

	\setlength\pagetextwidth{\textwidth}
	\setlength\pagetextheight{\textheight}

	% PDF boxes...
	\pdfboxesset[\bleed]{\bleedblockwidth}{\bleedblockheight}}



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
% XXX do we actually need these??
%		...should be simple to replace with calc's: 
%			0pt + \minof{..}
%			0pt + \maxof{..}
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


%% \DescribeMacro{\emptypage\{..\}}
%
%% Create an empty page.
%
%%	>> \emptypage
%%	>> \emptypage[<style>]
% 
%% |<style>| is the style name as defined via |fancyhdr| (default: |empty|).
%% 
\newcommand\emptypage[1][empty]{%
	\begin{page}%
		\ifthenelse{\equal{#1}{}}{}{%
			\thispagestyle{#1}}%
	\end{page}}


%% \DescribeMacro{\cleartoleftpage}
%
%% Forces content to left page.
%%
%% This is a companion to |\cleardoublepage|.
%%
\newcommand*{\cleartoleftpage}{%
	\clearpage
	\if@twoside
		\ifodd\c@page
			\hbox{}\newpage
			\if@twocolumn
				\hbox{}\newpage \fi\fi\fi }


%M \DescribeMacro{\ResettableMacro\{..\}}
%
%M Create a resettable command.
%
%M	>> \ResettableMacro{<name>}{<code>}
%M	>> \ResettableMacro{<name>}[<arg-count>]{<code>}
%M	>> \ResettableMacro{<name>}[<arg-count>][<default>]{<code>}
%
%M This is similar to |\newcommand{..}| but will define two commands:
%M
%M	>> \<name>{..}
%M
%M	>> \reset<name>
%M
%M |\<name>{..}| can be freely redefined or undefined by user.
%M
%M |\reset<name>| will reset |\<name>{..}| to its original state.
%M
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


% XXX EXPERIMENTAL
%	>> \resizedpage[<bleed>]{<width>}{<height>}{<code>}
\newenvironment{resizedpages}[3][\bleed]{
	\begingroup%
		% setup page...
		\setlength\bleed{#1}%
		\setlength\blockwidth{#2}%
		\setlength\blockheight{#3}%
		\setlength\pageblockwidth{\blockwidth}%
		\setlength\pageblockheight{\blockheight}%
		\edef\pdfpagelayout{}%
		%
		\InitPages%
		%
		\setlength\paperwidth{\bleedblockwidth}%
		\setlength\paperheight{\bleedblockheight}%
		%
		\pdfboxesset[\bleed]{\bleedblockwidth}{\bleedblockheight}%
		%
		% NOTE: this prevents some issues with macros racing to place 
		%		stuff at ship-out (possibly)...
		%		...also see cell env...
		%		XXX needs more digging...
		%		XXX do this at beginshipout/beginpage... (???)
		%\null%
		%\hbox{}%
}{%
	\endgroup%
	% reset...
	\pdfboxesset[\bleed]{\bleedblockwidth}{\bleedblockheight}}




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
	% XXX do we need \null here???
	\null%
	\ignorespaces%
}{%
	\clearpage}


%% \DescribeEnv{leftpage}
%
%% \EXPERIMENTAL
%%
% XXX not sure about this...
\newenvironment{leftpage}{%
	\begin{page}%
		\cleartoleftpage%
}{%
	\end{page}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Cells

% meta helpers...

%M \DescribeMacro{\CellContentOptions\{..\}}
%
%M \EXPERIMENTAL
%M
%M Define standard cell options.
%M
% XXX figure out how to align and pad without messing with geometry...
\newcommand\CellContentOptions[1]{%
	%% align...
	%\expandafter\def\csname photobook@#1@align\endcsname{flushleft}%
	%\define@key{#1@args}{align}{%
	%	\expandafter\edef\csname photobook@#1@align\endcsname{##1}}%
	% valign...
	\expandafter\def\csname photobook@#1@valign\endcsname{t}%
	\define@key{#1@args}{valign}{%
		\expandafter\edef\csname photobook@#1@valign\endcsname{##1}}%
	%% margin...
	%\expandafter\def\csname photobook@#1@margin\endcsname{0pt}%
	%\define@key{#1@args}{margin}{%
	%	\expandafter\edef\csname photobook@#1@margin\endcsname{##1}}%
	%% padding...
	%\expandafter\def\csname photobook@#1@padding\endcsname{0pt}%
	%\define@key{#1@args}{padding}{%
	%	\expandafter\edef\csname photobook@#1@padding\endcsname{##1}}%
}

%M \DescribeEnv{CellContent}
%M \DescribeEnv{CellContent*}
%
%M \EXPERIMENTAL
%M
%M Standard cell content wrapper, used by |inlinecell|.
%
%M	>> \begin{CellContent}[<parent-align>]{<name>} ... \end{CellContent}
%M	>> \begin{CellContent*}[<parent-align>]{<name>}{<width>}{<height>} ... \end{CellContent}
%
%M The star version requires width/height to be manually passed while the
%M non-star version will get the values from |\cellwidth| and |\cellheight|
%M respectively.
%
% XXX TEST params...
\newenvironment{CellContent}[2][t]{%
	\begin{CellContent*}[#1]{#2}{\cellwidth}{\cellheight}%
}{%
	\end{CellContent*}}

\newenvironment{CellContent*}[4][t]{%
	\begin{adjustbox}{
			minipage=[#1][#4][\csname photobook@#2@valign\endcsname]{#3},
			valign=#1}%
		\ignorespaces%
}{%
		% NOTE: prevent empty "minipage" from collapsing...
		\hspace{\fill}%
	\end{adjustbox}}


%M \DescribeEnv{MinipageCellContent}
%M \DescribeEnv{MinipageCellContent*}
%
%M \EXPERIMENTAL
%M
%M Like |CellContent| / |CellContent*| but will use |minipage| as the wrapper.
%
%M	>> \begin{MinipageCellContent}[<parent-align>]{<name>} ... \end{MinipageCellContent}
%M	>> \begin{MinipageCellContent*}[<parent-align>]{<name>}{<width>}{<height>} ... \end{MinipageCellContent}
%
% XXX TEST...
% XXX doc...
\newenvironment{MinipageCellContent}[2][t]{%
	\begin{MinipageCellContent*}[#1]{#2}{\cellwidth}{\cellheight}%
}{%
	\end{MinipageCellContent*}}

\newenvironment{MinipageCellContent*}[4][t]{%
	\begin{minipage}[#1][#4][\csname photobook@#2@valign\endcsname]{#3}%
}{%
	\end{minipage}}


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
%% The bare page can be reasonably treated as a cell.
%%
%% Initally, outside of any cells |\cellwidth|, |\cellparentwidth| and 
%% |\cellheight|, |\cellparentheight| are equal to |\paperwidth| and 
%% |\paperheight| respectively, and |\celloffsettop| and |\celloffsetleft|
%% are set to |0pt|.
%%
%% Changing these is not recommended, it likely will not affect the 
%% current cell but can mess up nested cells.
%%
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
% XXX EXPERIMENTAL
\CellContentOptions{inlinecell}

\def\photobook@inlinecell@parentvalign{t}
\define@boolkey{inlinecell@args}{t}[true]{%
	\def\photobook@inlinecell@parentvalign{t}}
\define@boolkey{inlinecell@args}{c}[true]{%
	\def\photobook@inlinecell@parentvalign{c}}
\define@boolkey{inlinecell@args}{b}[true]{%
	\def\photobook@inlinecell@parentvalign{b}}

\newenvironment{inlinecell*}[3][]{%
	\begingroup%
		\setkeys{inlinecell@args}{
			t,
			#1}%
		%
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
		\begin{CellContent}[\photobook@inlinecell@parentvalign]{inlinecell}%
}{%
		\end{CellContent}%
	\endgroup}

\newenvironment{inlinecell}[3][t]{%
	\begin{inlinecell*}[#1]{#2}{#3}%
	\begin{cliptocell}%
}{%
	\end{cliptocell}%
	\end{inlinecell*}}


% XXX EXPERIMENTAL
%% \DescribeEnv{minipagecell}
%% \DescribeEnv{minipagecell*}
%
%% \EXPERIMENTAL
%%
\CellContentOptions{minipagecell}

\def\photobook@minipagecell@parentvalign{t}
\define@boolkey{minipagecell@args}{t}[true]{%
	\def\photobook@minipagecell@parentvalign{t}}
\define@boolkey{minipagecell@args}{c}[true]{%
	\def\photobook@minipagecell@parentvalign{c}}
\define@boolkey{minipagecell@args}{b}[true]{%
	\def\photobook@minipagecell@parentvalign{b}}

\newenvironment{minipagecell*}[3][]{%
	\begingroup%
		\setkeys{minipagecell@args}{
			t,
			#1}%
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
		\setlength\clearance{0pt}%
		%
		\begin{MinipageCellContent}[\photobook@minipagecell@parentvalign]{minipagecell}%
}{%
		\end{MinipageCellContent}%
	\endgroup}

\newenvironment{minipagecell}[3][t]{%
	\begin{minipagecell*}[#1]{#2}{#3}%
	\begin{cliptocell}%
}{%
	\end{cliptocell}%
	\end{minipagecell*}}


% XXX EXPERIMENTAL
% XXX revise docs...
%% \DescribeEnv{zinlinecell}
%% \DescribeEnv{zinlinecell*}
%
%% \EXPERIMENTAL
%%
%% Like |inlinecell| / |inlinecell*| but will take up zero space and 
%% sized to |\cellwidth| x |\cellheight|.
%%
%%	>> \begin{zinlinecell} ... \end{zinlinecell}
%%	>> \begin{zinlinecell}[<valign>] ... \end{zinlinecell}
%%
% XXX need to get rid of the raisebox here...
\NewEnviron{zinlinecell*}[1][]{%
	\smash{\makebox[0pt][l]{%
		% XXX HACK: RAISEBOX -- feels hackish...
		\raisebox{0pt - \totalheightof{O}}{%
			\begin{inlinecell*}[#1]{\cellwidth}{\cellheight}%
				\BODY%
			\end{inlinecell*}}}}}

\NewEnviron{zinlinecell}[1][]{%
	\smash{\makebox[0pt][l]{%
		% XXX HACK: RAISEBOX -- feels hackish...
		\raisebox{0pt - \totalheightof{O}}{%
			\begin{inlinecell}[#1]{\cellwidth}{\cellheight}%
				\BODY%
			\end{inlinecell}}}}}


%% \DescribeEnv{cell}
%% \DescribeEnv{cell*}
%
%% Create a basic absolutely positioned cell.
%
%%	>> \begin{cell}{<left>, <top>}{<width>}{<height>} ... \end{cell}
%
%% Oversized content will be clipped.
%%
%% |cell*| is just like |cell| but will not clip its content.
%
%%	>> \begin{cell*}{<left>, <top>}{<width>}{<height>} ... \end{cell*}
%%
%% |cell| and |cell*| are absolutely positioned either relative to 
%% the current page or to the closest savecell.
%%
% XXX should this have an explicit absolute/relative option???
% XXX handle textpos's absolute option internally (+arg) ???
%		- save external state
%		- set internal state
%		- reset bac to saved
% XXX SYNTAX: place the second arg in braces...
%		\begin{cell*}(<left>, <top>){<width>}{<height>}
%\newenvironment{cell*}[3]{%
\newenvironment{cell*}[3]{%
	\begingroup%
		\setsepchar{,}%
		\readlist*\photobook@cell@offset{#1}%
		% NOTE: if there is no \null before textblock then it can reset the 
		%		non-standard page boxes... 
		%		...not sure yet if this is an issue with how/when foldout env
		%		updates the boxes or with textblock internals, needs 
		%		investigating...
		%		XXX report this as a bug if issue is in textblock...
		%		XXX another place where this is relevant is in the resizedpages
		%			env...
		%\null%
		\begin{textblock*}{#2}(#1)%
		\begin{inlinecell*}{#2}{#3}%
			\setlength\celloffsettop{\photobook@cell@offset[1]}%
			\setlength\celloffsetleft{\photobook@cell@offset[2]}%
			\ignorespaces%
}{%
		\end{inlinecell*}%
		\end{textblock*}%
	\endgroup%
	\ignorespaces}

\newenvironment{cell}[3]{%
	\begin{cell*}{#1}{#2}{#3}%
	\begin{cliptocell}%
		\ignorespaces%
}{%
	\end{cliptocell}%
	\end{cell*}%
	\ignorespaces}


% XXX EXPERIMENTAL
%% \DescribeEnv{adjustcell}
%% \DescribeEnv{adjustcell*}
%
%% \EXPERIMENTAL
%%
%% This a cell wrapper for |adjustbox|.
%%
% XXX DOC
\newenvironment{adjustcell*}[4][t]{%
	\begin{adjustbox}{#2}%
		\vspace{0pt}%
		\begin{minipagecell*}[#1]{#3}{#4}%
}{%
		\end{minipagecell*}%
	\end{adjustbox}}

\newenvironment{adjustcell}[4][t]{%
	\begin{adjustbox}{#2}%
		\vspace{0pt}%
		\begin{minipagecell}[#1]{#3}{#4}%
}{%
		\end{minipagecell}%
	\end{adjustbox}}



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
%% |\gsavecell{..}| is the same as |\savecell{..}| but creates a global 
%% cell.
%%
%% Note that both |\gsavecell{..}| and |\savecell{..}| make the nested
%% |cell| and |cell*| position relative to the cell and not the page.
%% This is done by setting |\TPoptions{absolute=false}| for the cell
%% content which will also affect |textpos|'s macros.
%%
% XXX can/should we make this an env???
% XXX should this be split into \newsavecell{..} and \scell{..} ???
% XXX can we use root cells inside this???
%		...i.e. things using textbox*...
\newcommand\savecell[5][]{%
	% only define a savebox once...
	\@ifundefined{#2}{%
		\expandafter\newsavebox\csname #2\endcsname}{}%
	\expandafter\sbox\csname #2\endcsname{%
		\TPoptions{absolute=false}%
		\begin{inlinecell*}[#1]{#3}{#4}%
			#5%
		\end{inlinecell*}%
		\TPoptions{absolute=true}}%
	\ignorespaces}

\newcommand\gsavecell[5][]{%
	% only define a savebox once...
	\@ifundefined{#2}{%
		\expandafter\newsavebox\csname #2\endcsname}{}%
	\global\expandafter\sbox\csname #2\endcsname{%
		\TPoptions{absolute=false}%
		\begin{inlinecell*}[#1]{#3}{#4}%
			#5%
		\end{inlinecell*}%
		\TPoptions{absolute=true}}%
	\ignorespaces}


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
\def\usecell{\@ifstar{%
	\photobook@usecell%
}{%
	\photobook@usecell@star}}

% cell content...
% NOTE: this is not intended for direct use -- depends closure/context...
\def\photobook@usecell@placecell#1(#2){%
	\setsepchar{,}%
	\readlist*\photobook@usecell@offset{#2}%
	% XXX how we align things feels a bit odd...
	\vspace{-\dimexpr \photobook@usecell@offset[1] \relax}%
	\adjustbox{margin={-\dimexpr \photobook@usecell@offset[2] \relax} 0pt 0pt 0pt}{%
		\expandafter\usebox\csname #1\endcsname}}

% XXX add option to rotate saved cell...
\def\photobook@usecell@star#1(#2)#3#4{
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
%%   +-----------------+ - - caption cell size
%%   .                 .       .
%%   +-----------------+       .
%%   |                 |       . 
%% ..+-----------------+..  .  +
%% . |.caption cell   .| .     |
%% . |    .       .    | .     |
%% . |        .        | .     | 
%% . |    .       .    | .     |
%% . |.               .| .     |
%% ..+-----------------+..  .  +
%%   |                 |    
%%   +-----------------+    
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% |<caption-cell>| occupies the same space as the image clipped by the 
%% containing cell and provides all the cell functionality.
%%
%% If |captionclearparent| is set, the |<caption-cell>| will fit into an 
%% intersection between the image area and the parent cell padded by 
%% |captionclearparent|.
%%
%% This will write image path, page and size to |\jobname|.image-list, 
%% this is useful for final image pre-press. 
%%
%% To disable image list set:
%
%%	>> \writeimagelistfalse
%%
% XXX do we need captionclearparent to be directional (a-la margin in adjustbox)???
% XXX might be a good idea to split this into two parts:
%		- \aligncell{..}
%		- \imagecell{caption}{image}
%			-> size image
%			-> \aligncell{
%					image
%					caption}
% XXX document scale/offsettop/offsetleft...

% helpers...

% image size logging...
\newif\ifwriteimagelist
\writeimagelisttrue

\newwrite\photobook@imagelist
\def\photobook@logimagesize@setup{%
	\immediate\openout\photobook@imagelist=\jobname.image-list%
	\AfterEndDocument{%
		\immediate\closeout\photobook@imagelist}%
	% setup only once per job...
	\global\def\photobook@logimagesize@setup{}}

%	>> \photobook@logimagesize{<path>}{<page>}{<imagebox>}
% XXX for some reason can't use \lenprint[mm]{..} in \write{..}...
\newcommand\photobook@logimagesize[3]{%
	\ifwriteimagelist%
		% first setup...
		\photobook@logimagesize@setup%
		% write...
		\immediate\write\photobook@imagelist{%
			#1: p#2: \the\wd#3\space x \the\ht#3}\fi}%


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
	\ifthenelse{\isodd{\thepage}}{%
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
		\photobook@imagecell@clearance}%
	\def\photobook@imagecell@captiontop{%
		-\dimexpr 
			+\cellheight 
			-\ht\photobook@imagebox \relax}}%
\define@boolkey{imagecell@args}{bottom}[true]{%
	\def\photobook@imagecell@top{%
		\dimexpr 
			+\cellheight 
			-\photobook@imagecell@clearance
			-\ht\photobook@imagebox \relax}%
	\def\photobook@imagecell@captiontop{%
		\dimexpr
			\photobook@imagecell@top 
			+\photobook@imagecell@clearance \relax}}%
% clearance=<len>...
\define@key{imagecell@args}{clearance}{%
	\setlength\photobook@imagecell@clearance{#1}}%

% offsettop=<len> / offsetleft=<len>...
% XXX DOC!!!
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

% captionalign=t|c|b...
\def\photobook@imagecell@captionalign{t}
\define@choicekey{imagecell@args}{captionalign}{t,c,b}[t]{%
	\def\photobook@imagecell@captionalign{#1}}

% captionclearparent=<len>...
% XXX DOC!!!
\newif\ifphotobook@imagecell@captionclearparent
\newlength\photobook@imagecell@captionclearparent
\define@key{imagecell@args}{captionclearparent}[0pt]{%
	\setlength\photobook@imagecell@captionclearparent{#1}%
	\photobook@imagecell@captionclearparenttrue}

% XXX can we make this an env???
\newcommand\imagecell[3][]{%
	\begingroup%
		% args...
		\setkeys{imagecell@args}{%
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
			\sbox{\photobook@imagebox}{\includegraphics{#3}}%
			% constrain minimal dimension of image...
			% NOTE: here we calculate image/cell eccentricity to decide 
			%		to fit to width or heigh of cell...
			% NOTE: did I say that I "love" how LaTeX does basic math??
			\setlength\photobook@imagecell@imgratio{%
				1pt * \ratio{\wd\photobook@imagebox}{\ht\photobook@imagebox}}%
			\setlength\photobook@imagecell@cellratio{%
				1pt * \ratio{\cellwidth}{\cellheight}}%
			\ifdim \photobook@imagecell@imgratio < \photobook@imagecell@cellratio%
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
							- ((\photobook@imagecell@clearance) * 2) \relax]{#3}}%
		\fi\fi\fi%
		%
		\setlength\celloffsetleft{%
			\dimexpr 
				\photobook@imagecell@offsetleft 
				+ \photobook@imagecell@left \relax}%
		\setlength\celloffsettop{%
			\dimexpr 
				\photobook@imagecell@offsettop
				+ \photobook@imagecell@top \relax}%
		%
		%
		% place image box...
		% XXX for some odd reason without this the alignment completely breaks...
		\vspace{0pt}%
		\smash{\makebox[0pt][l]{%
			\adjustbox{%
					margin={\celloffsetleft} 0pt 0pt {\celloffsettop},
					valign=T}{%
				\photobook@logimagesize{#3}{\thepage}{\photobook@imagebox}%
				\usebox\photobook@imagebox}}}%
		% 
		%
		% prepare for caption cell...
		\setlength\cellparentwidth{\cellwidth}%
		\setlength\cellparentheight{\cellheight}%
		\setlength\cellwidth{%
			\mindim{
				\wd\photobook@imagebox
				+ \mindim{\celloffsetleft}{0pt}
			}{
				\cellwidth}}%
		\setlength\cellheight{%
			\mindim{
				\ht\photobook@imagebox
				+ \mindim{\celloffsettop}{0pt}
			}{
				\cellheight}}% 
		\setlength\celloffsetleft{%
			\maxdim{\celloffsetleft}{0pt}}%
		\setlength\celloffsettop{%
			\maxdim{\celloffsettop}{0pt}}%
		\setlength\clearance{\photobook@imagecell@clearance}%
		% clear parent...
		% XXX might be a good idea to put this into a special reusable cell...
		\ifphotobook@imagecell@captionclearparent%
			% trim vertical...
			% XXX this seems overcomplicated...
			\setlength\cellheight{%
				\mindim{
					\cellheight
				% trim from both sides....
				}{\mindim{
					\cellparentheight
					- 2\photobook@imagecell@captionclearparent
				% trim from bottom...
				}{\mindim{
					\cellheight
					+ \celloffsettop
					- \photobook@imagecell@captionclearparent
				% trim from top...
				}{
					\cellparentheight
					- \photobook@imagecell@captionclearparent 
					- \celloffsettop}}}}%
			% offset top...
			\setlength\celloffsettop{
				\maxdim{
					\celloffsettop
						+ (\photobook@imagecell@captionclearparent - \celloffsettop)
				}{
					\celloffsettop}}%
			% trim horizontal...
			% XXX this seems overcomplicated...
			\setlength\cellwidth{%
				\mindim{
					\cellwidth
				% trim from both sides....
				}{\mindim{
					\cellparentwidth
					- 2\photobook@imagecell@captionclearparent
				% trim from right...
				}{\mindim{
					\cellwidth
					+ \celloffsetleft
					- \photobook@imagecell@captionclearparent
				% trim from left...
				}{
					\cellparentwidth
					- \photobook@imagecell@captionclearparent 
					- \celloffsetleft}}}}%
			% offset left...
			\setlength\celloffsetleft{
				\maxdim{
					\celloffsetleft
						+ (\photobook@imagecell@captionclearparent - \celloffsetleft)
				}{
					\celloffsetleft}}\fi%
		%
		%
		% place caption box...
		\smash{\makebox[0pt][l]{%
			\adjustbox{%
					%cfbox=gray 0.5pt 0pt 0pt,
					margin={\celloffsetleft} 0pt 0pt {\celloffsettop},
					minipage=[b][\cellheight][\photobook@imagecell@captionalign]{\cellwidth},
					valign=T}{%
				\ignorespaces%
				#2}}}%
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
%% Note that caption cells currently do not play well with other content
%% in the same cell that takes up space, e.g. text, pictures, ...etc.
%% Captions are mainly suited to play well with image cells.
%%

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
% align=<len>...
\def\photobook@captioncell@align{}
% XXX for some reason \define@choicekey{..} does not expand macros...
%\define@choicekey{captioncell@args}{align}{flushleft,center,flushright}{%
\define@key{captioncell@args}{align}{%
	\def\photobook@captioncell@align{#1}}
% margin=<len>...
\def\photobook@captioncell@margin{0pt}
\define@key{captioncell@args}{margin}{%
	\def\photobook@captioncell@margin{#1}}

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
					% XXX BUG: for some reason the text here will not line-break...
					%		putting it in a minipage here does nothing while the same
					%		minipage on the lient size fixes the issue...
					#3%
				\end{\photobook@captioncell@align}%
			\end{minipage}
		\end{minipage}}}}
% format...
\def\photobook@captioncell@format#1{%
	\photobook@captioncell@formatalign{t}{#1}}

\newcommand\captioncell[2][]{%
	\setkeys{captioncell@args}{
		top, 
		align=flushright, 
		margin=1pt, 
		#1}%
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
	\setkeys{vcaptioncell@args}{
		left, 
		bottomup, 
		align=flushleft, 
		margin=1pt, 
		#1}%
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
				% XXX HACK: RAISEBOX -- need to shift by x-height...
				%		...currently this is set to 1/(golden ratio) would
				%		be nice to make this parametric / font-derived...
				\raisebox{1ex * \real{-0.618033988749855}}{#2}%
			\end{turn}}%
	\ignorespaces}


%% \DescribeMacro{\captionblockcell\{..\}}
%
%% Add caption into a box left/right of current cell.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%    celloffsetleft                celloffsetleft
%%   <------->                     v 
%%   .        <-------------->     .<-------------> cellwidth
%%   <------------------------>    <------------------------> cellparentwidth
%%   .       ..              ..    ..             .         .
%%   +------------------------+    +------------------------+ 
%%   |                        |    |                        | 
%%   |                        |    |                        | 
%%   |+-------++ - - - - - - +|    |+ - - - - - - ++-------+| 
%%   ||       |.             .|    |.             .|       || 
%%   ||       |.             .|    |.             .|       || 
%%   ||  cap. |.     cell    .|    |.    cell     .|  cap. || 
%%   ||       |.             .|    |.             .|       || 
%%   ||       |.             .|    |.             .|       || 
%%   |+-------++ - - - - - - +|    |+ - - - - - - ++-------+| 
%%   |                        |    |                        | 
%%   |                        |    |                        | 
%%   +------------------------+    +------------------------+ 
%%   <> clearcaption                              ..       <> clearcaption
%%            <> spacing                          <> spacing
%%                              
%% \end{verbatim}
%% \end{minipage}
%%                              
% XXX make captions clear top/bottom of page...
% XXX need to do a caption block -- a cell to one side of an image to the 
% 		end of the page...
% XXX can we use the normal caption and simply insert a minipage of the 
%		appropriate width???

\newlength\photobook@captionblockcell@tmplen

% left / right
\define@boolkey{captionblockcell@args}{left}[true]{%
	\KV@captionblockcell@args@rightfalse}
\define@boolkey{captionblockcell@args}{right}[true]{%
	\KV@captionblockcell@args@leftfalse}

% align=flushright|center|flushright
% XXX this should depend on left/right...
\def\photobook@captionblockcell@align{%
	\ifKV@captionblockcell@args@left%
		flushright%
	\else%
		flushleft\fi}
\define@key{captionblockcell@args}{align}{%
	\def\photobook@captionblockcell@align{#1}}

% valign=t|c|b
% XXX should be a boolkey -- t|c|b???
\edef\photobook@captionblockcell@valign{b}
\define@key{captionblockcell@args}{valign}{%
	\edef\photobook@captionblockcell@valign{#1}}

% clearance=<len> (defaults: \clearcaption)
\newlength\photobook@captionblockcell@clearance
\define@key{captionblockcell@args}{clearance}{%
	\setlength\photobook@captionblockcell@clearance{#1}}

% XXX should this clear only top/bottom or all sides???
% XXX doc!!
% XXX do we need this here???
\define@boolkey{captionblockcell@args}{constraintoparent}[true]{}
\newlength\photobook@captionblockcell@clearparent
\setlength\photobook@captionblockcell@clearparent{0pt}
\define@key{captionblockcell@args}{clearparent}{%
	\setlength\photobook@captionblockcell@clearparent{#1}%
	\KV@captionblockcell@args@constraintoparenttrue}

% spacing=<len>
\newlength\photobook@captionblockcell@spacing
\setlength\photobook@captionblockcell@spacing{0pt}
\define@key{captionblockcell@args}{spacing}{%
	\setlength\photobook@captionblockcell@spacing{#1}}

% width=<len>
\newlength\photobook@captionblockcell@width
\setlength\photobook@captionblockcell@width{0pt}
\define@key{captionblockcell@args}{width}{%
	\setlength\photobook@captionblockcell@width{#1}}

% showbox
\define@boolkey{captionblockcell@args}{showbox}[true]{}

\newcommand\photobook@captionblockcell@content[2][0pt]{%
	\hspace{\celloffsetleft}{%
		\begin{adjustbox}{
				% NOTE: we need to draw the border before we set margins 
				%		to show the original box...
				fbox=#1 0pt 0pt,
				margin=0pt 0pt 0pt \celloffsettop,
				minipage=[t][\cellheight][\photobook@captionblockcell@valign]{\cellwidth},
				valign=T}%
		\begin{\photobook@captionblockcell@align}%
			\ignorespaces%
			#2%
		\end{\photobook@captionblockcell@align}%
		\end{adjustbox}}}

% XXX revise how \clearance is handled...
% XXX do we need top/bottom boxes???
%		...if yes do we need lop/left, top/right, bottom/left and bottom/right???
% XXX should we keep within parent cell if imagecell has negative clearance???
% XXX need to auto-place within images via \offsetleft...
% XXX add tweak support...
\newcommand\captionblockcell[2][]{%
	% XXX should this be within the group???
	\setkeys{captionblockcell@args}{%
		left, 
		valign=b,
		clearance=\clearcaption, 
		spacing=\captioncellspacing,
		#1}%
	%
	\smash{\makebox[0pt][l]{%
		\begingroup%
			% setup cell context...
			\setlength\clearcaption{%
				\photobook@captionblockcell@clearance}%
			\setlength\photobook@captionblockcell@tmplen{\cellwidth}%
			\setlength\cellwidth{%
				\ifnum \photobook@captionblockcell@width = 0%
					\dimexpr 
						\cellparentwidth 
						- \photobook@captionblockcell@spacing
						- \cellwidth 
						- \clearcaption 
						% XXX this is only present in images...
						- \clearance \relax%
				\else%
					\photobook@captionblockcell@width\fi}%
			\setlength\cellparentwidth{%
				\photobook@captionblockcell@tmplen}%
			\setlength\celloffsetleft{%
				\ifKV@captionblockcell@args@left%
					\dimexpr
						- \cellwidth%
						- \photobook@captionblockcell@spacing \relax%
				\else%
					\dimexpr
						\cellparentwidth
						+ \photobook@captionblockcell@spacing \relax%
					\fi}%
			% clear parent...
			% XXX do we need this here???
			\ifKV@captionblockcell@args@constraintoparent%
				% offset top...
				\setlength\celloffsettop{%
					\mindim{
						\photobook@captionblockcell@clearparent - \celloffsettop
					}{
						\photobook@captionblockcell@clearparent}}%
				% trim cell top... 
				\ifdim \celloffsettop > 0pt%
					\setlength\cellheight{%
						\cellheight - \celloffsettop}\fi%
				% trim cell bottom...
				\ifdim \dimexpr 
							\cellheight 
							+ \celloffsettop \relax%
						> \dimexpr 
							\cellparentheight 
							- \photobook@captionblockcell@clearparent \relax%
					\setlength\cellheight{%
						\dimexpr
							\cellparentheight 
								- \mindim{
									\cellheight - \cellparentheight
								}{
									2\photobook@captionblockcell@clearparent} \relax}\fi%
			% do not clear parent...
			\else%
				\setlength\celloffsettop{0pt}\fi%
			%
			% place...
			\ifKV@captionblockcell@args@showbox%
				\photobook@captionblockcell@content[0.1pt]{#2}%
			\else%
				\photobook@captionblockcell@content{#2}\fi%
		\endgroup}}%
	\ignorespaces}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Paper cells
%
%% Paper and page cells are very similar but differ in one aspect -- paper
%% cells represent the paper as indicated by |layoutmode=<layout>| while
%% page cells are always the size of the page block, i.e. |layoutmode=block|.
%%

%% \DescribeEnv{papercell}
%
%% Paper cell.
%%
%% This does not include bleeds.
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
	\begin{cell*}{0pt, 0pt}{\bleedblockwidth}{\bleedblockheight}%
}{%
	\end{cell*}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Page cells
%
%% Page cells always correspond to the page block size, i.e. |layoutmode=block| 
%% regardless of the actual |layoutmode| set currently.
%%

%% \DescribeEnv{pagecell}
%% \DescribeEnv{pagecell*}
%
%% Page cell. 
%%
%% This corresponds to the visible page in the |layoutmode=block| and 
%% does not include bleeds.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   <-> bleed         <-> bleed
%%
%%   + - - - - - - - - - +    + bleed
%%   . +---------------+ .    v
%%   . |               | .   
%%   . |               | .   
%%   . |   pagecell    | .   
%%   . |               | .   
%%   . |               | .   
%%   . +---------------+ .    + bleed
%%   + - - - - - - - - - +    v
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% The star version accounts for |\gutteroffset|. 
%%
%% Note that |layoutmode|'s other than block will change the paper size 
%% but will not affect this either in size (block size) or in position 
%% (top-left).
%%
\newenvironment{pagecell}{%
	\begin{cell*}{%
			\bleed + \ifnumodd{\thepage}{\bindingoffset}{0pt},%
			\bleed}%
		{\pageblockwidth - \bindingoffset}%
		{\pageblockheight}%
}{%
	\end{cell*}}

\newenvironment{pagecell*}{%
	\begin{cell*}{%
			\bleed + \ifnumodd{\thepage}{\bindingoffset + \gutteroffset}{0pt},%
			\bleed}%
		{\pageblockwidth - \bindingoffset - \gutteroffset}%
		{\pageblockheight}%
}{%
	\end{cell*}}


%% \DescribeEnv{pagebleedcell}
%
%% Like |page| but includes bleeds.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   <-> bleed         <-> bleed
%%
%%   +-------------------+    + bleed  
%%   | + - - - - - - - + |    v        
%%   | .               . |             
%%   | .               . |             
%%   | . pagebleedcell . |             
%%   | .               . |             
%%   | .               . |             
%%   | + - - - - - - - + |    + bleed  
%%   +-------------------+    v        
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Note that as with |pagecell| this is not affected by |layoutmode|.
%%
\newenvironment{pagebleedcell}{%
	\begin{cell*}{0pt, 0pt}{\bleedblockwidth}{\bleedblockheight}%
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
%% \EXPERIMENTAL
%%
%% A cell taking up the page text block.
%
%%	>> \begin{textcell}{<width>}{<height>} ... \end{textcell}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%      <-----------> \textwidth
%%                          
%%   <-----------------> \pageblockwidth
%%
%%   +-----------------+   ^ \pageblockheight
%%   |                 |   |
%%   |  +-----------+  |   |  ^ \textheight
%%   |  |           |  |   |  |
%%   |  |           |  |   |  |
%%   |  | textcell  |  |   |  |
%%   |  |           |  |   |  |
%%   |  |           |  |   |  |
%%   |  +-----------+  |   |  v
%%   |                 |   | 
%%   +-----------------+   v 
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


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Foldout page cells
%
%% \EXPERIMENTAL
%%
%% A foldout is a special case cell that changes the page format. 
%%
%% In addition to cell lengths a foldout defines a set of additional 
%% lengths and lists within its context.
%%
%% \DescribeMacro{\pagefoldpanels=<list>}
%% \DescribeMacro{\pagefoldpanelfolds=<list>}
%
%% Lists page folded panel widths and fold types respectively.
%%
%% |pagefoldpanels| is set automatically for layouts other than |block| 
%% and for foldout pages, changing this can mess up fold markers and 
%% page cell placement.
%%
%% |pagefoldpanelfolds| is generated when creating a foldout.
%%
%% See:
%% \href{https://ctan.altspu.ru/macros/generic/listofitems/listofitems-en.pdf}{listofitems}
%% for list API.
%%
% XXX add a generic panel constructor..
%		\foldedcell[<height>]{<index>}
% NOTE: these are wrapped in \@ifundefined{..} to prevent overwriting when
%		values are defined in \InitPages...
\@ifundefined{pagefoldpanels}{%
	\def\pagefoldpanels{}}{}
\@ifundefined{pagefoldpanelfolds}{%
	\def\pagefoldpanelfolds{}}{}

%% \DescribeMacro{\foldoutwidth=<len>}
%
%% Total foldout page width, calculated when a foldout page is created.
%%
\newlength\foldoutwidth
\setlength\foldoutwidth{\blockwidth}


%% \DescribeEnv{foldout}
%
%% Create 2 or more pages in foldout mode.
%
%%	>> \begin{foldout}[<fold-spec>] ... \end{foldout}
%
%% |<fold-spec>| can be a number of folds, or contain one or more fold 
%% types (|in| or |out|), two or more panel widths (dimensions) or a
%% sequence of both (i.e. dim fold dim ...) where missing widths are 
%% automatically calculated and missing folds are the same as the previous
%% fold or the default if no folds are specified.
%%
%% If no |<fold-spec>| is given, then the value of |\defaultfoldout| is
%% used (default: |2|).
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                            v    \flatfold    v
%%          
%%       - --=----------------++---------------++--------------+
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =                ..               ..              |
%%           =            (1) ..           (2) ..          (3) |
%%       - --=----------------++---------------++--------------+
%%          
%%  +--------------++---------------++----------------=-- -
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |              ..               ..                =
%%  |          (1) ..           (2) ..            (3) =
%%  +--------------++---------------++----------------=-- -
%%
%%                 ^    \flatfold    ^
%%
%% \end{verbatim}
%% \end{minipage}
%%
%%
%% A foldout always starts on the right/odd page and will always end on 
%% the left/even page. 
%%
%% If |\foldoutpages{..}| is called on an even page, an empty normal 
%% page will be created pushing the foldout to the right page of the 
%% spread. If an odd number of pages is created the set will be padded 
%% with an empty page before |\foldoutpages{..}| exits.
%%
%%
%% Foldout panel numbering
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                 right page
%%           - --=-------+-------+-    --+-------+-------+
%%               =       |       |       |       |       |
%%               =  (1)  |  (2)  |  ...  | (n-1) |  (n)  |
%%               =       |       |       |       |       |
%%           - --=-------+-------+--    -+-------+-------+
%%
%%                                 left page
%%   +-------+-------+-    --+-------+-------=-- -
%%   |       |       |       |       |       =
%%   |  (1)  |  (2)  |  ...  | (n-1) |  (n)  =
%%   |       |       |       |       |       =
%%   +-------+-------+--    -+-------+-------=-- -
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Formal |<fold-spec>| grammar:
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%   <fold-spec> ::
%%       <count>
%%       | <fold>
%%       | <panels>
%%   <panels> ::=
%%       <panel>
%%       | <panel> <panels>
%%   <panel> ::=
%%       <width> <fold>
%%       | <width>
%%       | <fold>
%%   <fold> ::= 
%%      in | out
%% \end{verbatim}
%% \end{minipage}
%%
%
%% \DescribeMacro{\clearfoldoutgutter=<len>}
%% \DescribeMacro{\clearfoldoutedge=<len>}
%% \DescribeMacro{\clearfoldoutfold=<len>}
%
%% Fold panel sizing for similar fold sequence:
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                       \clearfoldoutedge <->
%%                    \clearfoldoutfold <->  
%%   <--> \clearfoldoutgutter
%%                                                    (3)  /\  (2)  
%%      +---------------------------------+               /  \     
%%      +-------------------------------  |                  /     
%%   -------------------------------------+                 /  (1) 
%%   ========================================         =====+=====  
%%   ========================================        
%%                                                 
%% \end{verbatim}                                  
%% \end{minipage}                                  
%%
%% Note that |in in| fold sequence is drawn, |out out| is identical in 
%% sizing but reflectd.
%%
%%
%% Fold panel sizing for dissimilar fold sequence:
%%
%% \begin{minipage}{\textwidth}                    
%% \begin{verbatim}                                
%%                                                 
%%                      \clearfoldoutedge <->                /      
%%   <--> \clearfoldoutgutter                          (3)  /       
%%                                                          \       
%%      +----------------------------------                  \  (2) 
%%      +---------------------------------+                  /      
%%   -------------------------------------+                 /  (1)  
%%   ========================================         =====+=====   
%%   ========================================
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% |in out| is drawn, |out it| is the same but reflected.
%%
%% The size of the paper fold is set by |\flatfold|.
%%

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Fold marks...

% draw in/out fold mark...
%
%	>> \foldinmark[<baseline>]
%	>> \foldoutmark[<baseline>]
%
% NOTE: these should be used in a box.
% NOTE: these are centered in origin.
%
% XXX these can affect the items after -- need to encapsulate better + test...
% XXX do we need to make centering block size dependant on \foldmarksize 
%		or are the two independent??? (test)
% XXX MARKOFFSET for some reason splitting the \vspace{..} into a 
%		arg-dependant and a foldmarklen-dependant parts below yields 
%		wrong results...
%		...not that simply splitting the original into two \vspace{..} 
%		calls works fine...
\newsavebox\photobook@foldinmark
\newsavebox\photobook@foldoutmark
\newcommand\ResetFoldMarks{%
	\sbox{\photobook@foldinmark}{%
		% XXX MARKOFFSET
		%\vspace{0.5\photobook@foldmarklen}%
		\smash{\makebox[0pt][l]{%
			% size-agnostic centering...
			\hspace{-5mm}{\makebox[1cm][c]{%
				\begin{tikzpicture}%
					\draw[white, ultra thick] 
						(-0.3333\photobook@foldmarklen,0.3333\photobook@foldmarklen) 
						-- (0,0) 
						-- (0.3333\photobook@foldmarklen,0.3333\photobook@foldmarklen);
					\draw[white, ultra thick] 
						(0,0.6666\photobook@foldmarklen) 
						-- (0,-0.3333\photobook@foldmarklen);
					\draw[black, thin] 
						(-0.3333\photobook@foldmarklen,0.3333\photobook@foldmarklen) 
						-- (0,0) 
						-- (0.3333\photobook@foldmarklen,0.3333\photobook@foldmarklen);
					\draw[black, thin] 
						(0,0.6666\photobook@foldmarklen) 
						-- (0,-0.3333\photobook@foldmarklen);
				\end{tikzpicture}}}}}}
	\sbox{\photobook@foldoutmark}{%
		% XXX MARKOFFSET
		%\vspace{0.5\photobook@foldmarklen}%
		\smash{\makebox[0pt][l]{%
			% size-agnostic centering...
			\hspace{-5mm}{\makebox[1cm][c]{%
				\begin{tikzpicture}%
					\draw[white, ultra thick] 
						(-0.3333\photobook@foldmarklen,0) 
						-- (0,0.3333\photobook@foldmarklen) 
						-- (0.3333\photobook@foldmarklen,0);
					\draw[white, ultra thick] 
						(0,0.6666\photobook@foldmarklen) 
						-- (0,-0.3333\photobook@foldmarklen);
					\draw[black, thin] 
						(-0.3333\photobook@foldmarklen,0) 
						-- (0,0.3333\photobook@foldmarklen) 
						-- (0.3333\photobook@foldmarklen,0);
					\draw[black, thin] 
						(0,0.6666\photobook@foldmarklen) 
						-- (0,-0.3333\photobook@foldmarklen);
				\end{tikzpicture}}}}}}}
\ResetFoldMarks

% XXX EXPERIMENTAL...
% XXX not sure if this should ever be needed...
%\newcommand\setfoldmarksize[1][6mm]{%
%	\setlength\photobook@foldmarklen{#1}%
%	%\edef\photobook@foldmarklen{#1}%
%	\ResetFoldMarks}

%	>> \foldinmark[<baseline>]
\newcommand\foldinmark[1][0pt]{%
	% XXX MARKOFFSET
	%\vspace{#1}%
	\vspace{\dimexpr 0.5\photobook@foldmarklen + #1 \relax}%
	\usebox\photobook@foldinmark}
%	>> \foldoutmark[<baseline>]
\newcommand\foldoutmark[1][0pt]{
	% XXX MARKOFFSET 
	%\vspace{#1}%
	\vspace{\dimexpr 0.5\photobook@foldmarklen + #1 \relax}%
	\usebox\photobook@foldoutmark}

%	>> \photobook@foldmark[<baseline>]{<type>}{<left>, <top>}
\newif\ifphotobook@foldmark@in
\newcommand\photobook@foldmark[3][0pt]{%
	\begingroup%
		\ifnumodd{\thepage}{%
			\ifthenelse{\equal{#2}{in}}{%
				\photobook@foldmark@intrue}{%
				\photobook@foldmark@infalse}}{%
			\ifthenelse{\equal{#2}{in}}{%
				\photobook@foldmark@infalse}{%
				\photobook@foldmark@intrue}}%
		\begin{textblock*}{0pt}(#3)%
			\ifphotobook@foldmark@in%
				\foldinmark[#1]%
			\else%
				\foldoutmark[#1]\fi%
		\end{textblock*}%
	\endgroup}
\newcommand\photobook@topfoldmark[2][in]{%
	\photobook@foldmark[-0.5\photobook@foldmarklen]{#1}{#2}}
\newcommand\photobook@bottomfoldmark[2][in]{%
	\photobook@foldmark[0.5\photobook@foldmarklen]{#1}{#2}}
%	>> \photobook@markfold[<fold>]{<offset>}
\newcommand\photobook@markfold[2][in]{%
	\photobook@topfoldmark[#1]{
		#2,
		\bleed 
			- \foldmarkoffset}%
	\photobook@bottomfoldmark[#1]{
		#2,
		\blockheight 
			+ \bleed 
			+ \foldmarkoffset}}

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

\newlength\photobook@foldout@panelwidth
\setlength\photobook@foldout@panelwidth{0pt}
\newlength\photobook@foldout@maxpanelwidth
\setlength\photobook@foldout@maxpanelwidth{0pt}
\edef\photobook@foldout@count{}
\edef\photobook@foldout@prevfold{in}

%	>> \photobook@foldout@pushpanel{<width>}{<fold>}
%
% XXX should we set maxpanelwidth when manually setting panel widths???
% XXX might be good to warn the user if the manual fold will not work...
%		after two folds in same direction panels must be strictly smaller...
%		...would be nice to maintain maxpanelwidth and warn if explicit 
%		width is larger...
\newcommand\photobook@foldout@pushpanel[2]{%
	% initial max panel size...
	\ifnum \thephotobook@foldoutpanel = 1%
		\setlength\photobook@foldout@maxpanelwidth{%
			\blockwidth
			- \clearfoldoutedge}\fi%
	% panel #2 -- clear binding...
	\ifnum \thephotobook@foldoutpanel = 2%
		\setlength\photobook@foldout@maxpanelwidth{%
			\photobook@foldout@maxpanelwidth
			- \clearfoldoutgutter}\fi%
	% calculate widths...
	\ifdim #1 = 0pt%
		% first two panels do not need fold compensation...
		\ifnum \thephotobook@foldoutpanel < 3%
			\setlength\photobook@foldout@panelwidth{%
				\photobook@foldout@maxpanelwidth
				+ \flatfold}%
		\else%
			% double fold twice in same direction...
			\ifthenelse{\equal{#2}{\photobook@foldout@prevfold}}{%
				\setlength\photobook@foldout@panelwidth{%
					\photobook@foldout@maxpanelwidth 
					+ \flatfold
					- \clearfoldoutfold}%
			% different fold directions -- no resizing needed here...
			}{%
				\setlength\photobook@foldout@panelwidth{%
					\photobook@foldout@maxpanelwidth
					+ \flatfold}}\fi%
		\setlength\photobook@foldout@maxpanelwidth{%
			\photobook@foldout@panelwidth}%
	% explicit width...
	\else%
		% XXX should we set the maxpanelwidth here too???
		%		...if yes, should we be more thorough and size it to the 
		%		available space (accounting for last two folds)??
		%\setlength\photobook@foldout@maxpanelwidth{#1}%
		\setlength\photobook@foldout@panelwidth{#1}\fi%
	% accumulate width...
	\setlength\foldoutwidth{
		\foldoutwidth
		+ \photobook@foldout@panelwidth}%
	% panel spec lists...
	\edef\pagefoldpanelfolds{%
		\pagefoldpanelfolds,#2}%
	\edef\pagefoldpanels{%
		\pagefoldpanels,\the\photobook@foldout@panelwidth}%
	\stepcounter{photobook@foldoutpanel}}

% XXX also add this to jacket/cover/endpaper...
\newlength\photobook@showmarks@offset
\setlength\photobook@showmarks@offset{0pt}
\newcommand\photobook@showmarks{%
	% XXX make this a list-length check...
	\ifx \pagefoldpanels \empty \else%
		\begingroup%
			\setlength\photobook@showmarks@offset{\bleed}%
			% NOTE: we need to iterate left/right pages in reverse order...
			% NOTE: the below branches are similar but not identical...
			\ifnumodd{\thepage}{%
				\xintFor* ##1 in {\xintSeq{1}{\pagefoldpanelslen - 1}} \do {%
					\setlength\photobook@showmarks@offset{
						\photobook@showmarks@offset
						+ \pagefoldpanels[##1]}%
					% XXX HACK: it appears that we can't expand \pagefoldpanelfolds[##1] in [..]...
					\edef\photobook@showmarks@tmp{\pagefoldpanelfolds[##1]}%
					\photobook@markfold[\photobook@showmarks@tmp]{\photobook@showmarks@offset}}%
			}{
				\xintFor* ##1 in {\xintSeq{\pagefoldpanelslen}{2}} \do {%
					\setlength\photobook@showmarks@offset{
						\photobook@showmarks@offset
						+ \pagefoldpanels[##1]}%
					% XXX HACK: it appears that we can't expand \pagefoldpanelfolds[##1] in [..]...
					\edef\photobook@showmarks@tmp{\pagefoldpanelfolds[##1 - 1]}%
					\photobook@markfold[\photobook@showmarks@tmp]{\photobook@showmarks@offset}}}%
		\endgroup\fi}
\AtBeginShipout{%
	\iffoldmarks%
		\photobook@showmarks\fi}

\newcounter{photobook@foldoutpanel}
\setcounter{photobook@foldoutpanel}{1}

\newenvironment{foldout}[1][\defaultfoldout]{%
	\begingroup%
		\setsepchar{ }%
		\readlist*\photobook@foldout@args{#1}%
		%
		% defaults...
		\setcounter{photobook@foldoutpanel}{1}
		\setlength\foldoutwidth{0pt}%
		\edef\photobook@foldout@prevfold{\pagefold}%
		%
		% panel count...
		\ifnum \photobook@foldout@argslen = 1%
			% in/out...
			\ifthenelse{
					\equal{#1}{in} 
						\OR \equal{#1}{out}}{%
				\edef\photobook@foldout@count{2}%
				\edef\photobook@foldout@prevfold{#1}%
			% count...
			}{%
				\edef\photobook@foldout@count{#1}}%
			%
			% build the panels...
			\xintFor* ##1 in {\xintSeq{1}{\photobook@foldout@count}} \do {%
				\photobook@foldout@pushpanel{%
					0pt}{\photobook@foldout@prevfold}}%
		% fold spec...
		\else%
			\foreachitem \photobook@foldout@opt \in \photobook@foldout@args{%
				% in/out...
				\ifthenelse{
						\equal{\photobook@foldout@opt}{in} 
							\OR \equal{\photobook@foldout@opt}{out}}{%
					\photobook@foldout@pushpanel{%
						\photobook@foldout@panelwidth}{\photobook@foldout@opt}%
					% prep for next panel...
					\edef\photobook@foldout@prevfold{%
						\photobook@foldout@opt}%
					\setlength\photobook@foldout@panelwidth{0pt}%
				% explicit size...
				}{%
					% finalize prev panel...
					\ifdim \photobook@foldout@panelwidth > 0pt%
						\photobook@foldout@pushpanel{%
							\photobook@foldout@panelwidth}{\photobook@foldout@prevfold}\fi%
					%
					\setlength\photobook@foldout@panelwidth{\photobook@foldout@opt}}}%
			% add trailing panel... 
			\photobook@foldout@pushpanel{%
				\photobook@foldout@panelwidth}{\photobook@foldout@prevfold}%
		\fi%
		% prepare data for cells...
		\setsepchar{,}%
		% NOTE: the first element is empty due to how we create these 
		%		i.e. ('' + ',<value>')...
		\ignoreemptyitems%
		\readlist*\pagefoldpanelfolds{\pagefoldpanelfolds}%
		\readlist*\pagefoldpanels{\pagefoldpanels}%
		%
		% pages...
		% NOTE: we'll keep the start of the foldout set at the right page
		%		and end it on the left page.
		\cleardoublepage%
		\begin{resizedpages}{\foldoutwidth}{\blockheight}%
			\ignorespaces%
}{%
			\cleardoublepage%
		\end{resizedpages}%
	\endgroup}


%% \DescribeEnv{foldoutcell}
%% \DescribeEnv{foldoutcell*}
%
%% Create a cell spanning one or more foldout panels.
%
%%	>> \begin{foldoutcell}[<num>] ... \end{foldoutcell}
%%	>> \begin{foldoutcell}[<from>-<to>] ... \end{foldoutcell}
%
%% If no arguments are given this will create a panel at |foldoutpanel| 
%% counter and increment it by one. 
%
%%	>> \begin{foldoutcell} ... \end{foldoutcell}
%
%% This will also auto-advance the page when all panels are filled.
%% 
%% Note that manual panel placement has no effect on the panel counter 
%% thus care must be taken when mixing manual and auto-advanced panels.
%% Also note that |foldoutpanel|'s value is not maintained within manually 
%% placed panels and should be treated as undefined.
%%
%% |foldoutcell*| is the same as the non-star version but creates cells
%% including bleeds.
%%
%% Neither version clips its content, to explicitly clip use the |cliptocell| 
%% environment.
%%
%% These can only be used from within a |foldout| cell.
%%
% XXX should we be able to turn clipping on/off???

\newlength\photobook@foldoutcell@left
\setlength\photobook@foldoutcell@left{0pt}
\newlength\photobook@foldoutcell@width
\setlength\photobook@foldoutcell@width{0pt}

% calculate offset via \pagefoldpanels and write to dimension <name>...
%	>> \photobook@foldoutcell@setfoldoutoffset{<name>}{<from>}{<to>}
%
% NOTE: [<from>, <to>[ -- i.e. <to> is not included...
\newcommand\photobook@foldoutcell@setfoldoutoffset[3]{%
	\expandafter\setlength\csname #1\endcsname{0pt}%
	\ifnum \numexpr #2 \relax < \numexpr #3 \relax%
		\xintFor* ##1 in {%
				\xintSeq{#2}{\xintiiMin{#3}{\pagefoldpanelslen + 1} - 1}} \do {%
			\ifnumodd{\thepage}{%
				\expandafter\setlength\csname #1\endcsname{%
					\csname #1\endcsname%
					+ \pagefoldpanels[##1]}
			}{%
				\expandafter\setlength\csname #1\endcsname{%
					\csname #1\endcsname%
					+ \pagefoldpanels[-\numexpr ##1 \relax]}}}\fi}

% foldout panel auto-advance counter...
\newcounter{foldoutpanel}
\setcounter{foldoutpanel}{0}
\edef\photobook@foldoutcell@from{0}
% reset panel count on each page...
\AtBeginShipout{%
	\setcounter{foldoutpanel}{0}
	\edef\photobook@foldoutcell@from{%
		\thefoldoutpanel}}

% set panel left/width dimensions (helper)...
%	>> \photobook@foldoutcell@setdimensions[<panel-spec>]
%
% NOTE: for <panel-spec> see docs for foldoutcell/foldoutcell*...
\newcommand\photobook@foldoutcell@setdimensions[1][0]{
	% parse args...
	\setsepchar{-}%
	\readlist*\photobook@foldoutcell@panels{#1}%
	%
	% auto advance panel...
	\ifnum \photobook@foldoutcell@panels[1] = 0%
		% auto advance page...
		\ifnum \value{foldoutpanel} = \pagefoldpanelslen%
			% NOTE: this will reset the counter...
			\newpage\fi%
		\stepcounter{foldoutpanel}%
		\global\edef\photobook@foldoutcell@from{%
			\thefoldoutpanel}%
	% explicit panels...
	\else%
		\global\edef\photobook@foldoutcell@from{
			\photobook@foldoutcell@panels[1]}\fi%
	% left offset...
	\photobook@foldoutcell@setfoldoutoffset{photobook@foldoutcell@left}{%
			1
		}{%
			\photobook@foldoutcell@from}%
	% panel from-to width...
	\ifnum \photobook@foldoutcell@panelslen > 1%
		\photobook@foldoutcell@setfoldoutoffset{photobook@foldoutcell@width}{%
				\photobook@foldoutcell@from%
			}{%
				\photobook@foldoutcell@panels[2] + 1}%
	% panel N width...
	\else%
		\ifnumodd{\thepage}{%
			\setlength\photobook@foldoutcell@width{%
				\pagefoldpanels[{\photobook@foldoutcell@from}]}
		}{%
			\setlength\photobook@foldoutcell@width{%
				\pagefoldpanels[-\numexpr \photobook@foldoutcell@from \relax]}}\fi}

\newenvironment{foldoutcell}[1][0]{%
	% XXX check if outside of foldout -> warn...
	\begingroup%
		\photobook@foldoutcell@setdimensions[#1]%
		\begin{cell*}{%
					\bleed 
						+ \photobook@foldoutcell@left,%
					\bleed}%
				{\photobook@foldoutcell@width}%
				{\pageblockheight}%
}{%
		\end{cell*}%
	\endgroup}

\newenvironment{foldoutcell*}[1][0]{%
	% XXX check if outside of foldout -> warn...
	\begingroup%
		\photobook@foldoutcell@setdimensions[#1]%
		% add bleed to first/last panel...
		\ifnum \photobook@foldoutcell@from = 1%
			\setlength\photobook@foldoutcell@width{%
				\bleed
				+ \photobook@foldoutcell@width}
		\else%
			\setlength\photobook@foldoutcell@left{%
				\bleed
				+ \photobook@foldoutcell@left}\fi%
		\ifnum \photobook@foldoutcell@from = \pagefoldpanelslen%
			\setlength\photobook@foldoutcell@width{%
				\bleed
				+ \photobook@foldoutcell@width}\fi%
		\begin{cell*}{%
					\photobook@foldoutcell@left,%
					0pt}%
				{\photobook@foldoutcell@width}%
				{\pageblockheight + 2\bleed}%
}{%
		\end{cell*}%
	\endgroup}



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Multi-page cells
%
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
%% |spreadtopages*| creates a named save cell only allowing the pages 
%% to be placed manually via |\usespreadpage{..}|.
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
%% Page numbers are 1-based.
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
		\setlength\cellwidth{#1\pageblockwidth - #1\bindingoffset}%
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
%%   backflap         spine/vspine           frontflap
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
%% Note that when typesetting a spine with both top-down and bottom-up 
%% text it is recommended to use |topdown|/|bottomup| in |zinlinecell|'s 
%% in a normal |spine| rather than using a |vspine| and trying to rotate 
%% part of the content.
%%
\newenvironment{frontcover}{%
	\begin{cell*}{
				\bleed 
					+ \photobook@jacketflapback@active
					+ \photobook@coverflap@active
					+ \photobook@jacketwrap@active
					+ \coverboardgrow 
					+ \pageblockwidth 
					+ 2\spinefold 
					+ \spinewidth,
				\bleed 
					+ \photobook@coverflap@active }%
			{ \pageblockwidth + \coverboardgrow }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell*}}

\newenvironment{backcover}{%
	\begin{cell*}{
				\bleed 
					+ \photobook@jacketflapback@active
					+ \photobook@coverflap@active
					+ \photobook@jacketwrap@active,
				\bleed 
					+ \photobook@coverflap@active }%
			{ \pageblockwidth + \coverboardgrow }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell*}}


% spines...
%
\newenvironment{spine}{%
	\begin{cell*}{
				\bleed 
					+ \photobook@jacketflapback@active
					+ \photobook@coverflap@active
					+ \photobook@jacketwrap@active
					+ \coverboardgrow 
					+ \pageblockwidth 
					+ \spinefold,
				\bleed 
					+ \photobook@coverflap@active }%
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
					+ \photobook@jacketflapback@active
					+ 2\photobook@jacketwrap@active
					+ 2\coverboardgrow 
					+ 2\pageblockwidth 
					+ 2\spinefold 
					+ \spinewidth,
				\bleed 
					+ \photobook@coverflap@active }%
			{ \photobook@jacketflapfront@active }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell*}}

\newenvironment{backflap}{%
	\begin{cell*}{
				\bleed,
				\bleed 
					+ \photobook@coverflap@active }%
			{ \photobook@jacketflapback@active }%
			{ \pageblockheight + 2\coverboardgrow }%
}{%
	\end{cell*}}



%----------------------------------------------------------------------
%%%% Caption Templates
% XXX need to be able to configure/pass/override:
%		- size / \captionsize...
%		- color...

%% \DescribeMacro{\captionsize\{..\}}
%
%% Defines the caption font.
%%
%% Can be redefined to control caption font/style.
%%
\ResettableMacro{captionsize}{%
	\fontsize{6.5pt}{8pt}\selectfont}


%% \DescribeMacro{\captionformat\{..\}}
%
%% General caption format.
%
%%	>> \captionformat{<code>}
%
%% This can be redefined to control the image caption.
%%
\ResettableMacro{captionformat}[1]{%
	\adjustbox{
			margin=0.1em 0.2em, 
			varwidth=\cellwidth}{%
		\captionsize #1}}



%----------------------------------------------------------------------
%%%% Page Templates
%
%% This section contains a set of predefined configurable single-page
%% templates.
%%
% XXX PRECLEAR this may lead to pages collapsing on each other, test...
%
%% Note that most page templates do not |\clearpage| before expanding, 
%% this enables one to prepend elements (like pdf comments), if clearing 
%% a page is required add |\clearpage| manually before the template.
%%

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Basic book information

% XXX Document metadata -- move to globals...
% XXX Use LaTeX generic metadata...
%% \DescribeMacro{BookTitle=<text>}
\def\BookTitle{}
%% \DescribeMacro{BookVersion=<text>}
\def\BookVersion{}
%% \DescribeMacro{BookAuthors=<text>}
\def\BookAuthors{}
%% \DescribeMacro{BookYear=<text>}
\def\BookYear{%
	\the\year}
%% \DescribeMacro{ByNotice=<text>}
\def\ByNotice{}
%% \DescribeMacro{ThanksTo=<text>}
\def\ThanksTo{}
%% \DescribeMacro{ISBN=<text>}
\def\ISBN{}
%% \DescribeMacro{BookEdition=<text>}
\def\BookEdition{}
%% \DescribeMacro{License=<text>}
\def\License{}
%% \DescribeMacro{CopyrightNotice=<text>}
\def\CopyrightNotice{%
	Copyright \textcopyright \ \BookYear \ \BookAuthors; All Rights Reserved.

	\ifx \License \empty%
		No part of this book may be reproduced in any form without written permission
		of the author except for use for brief quotation in a book review.
	\else%
		\License\fi}

%% \DescribeMacro{OtherSoftware=<text>}
\def\OtherSoftware{}
%% \DescribeMacro{BookFonts=<text>}
\def\BookFonts{}
%% \DescribeMacro{SoftwareNotice=<text>}
\def\SoftwareNotice{%
	This book was designed and laid out using open source 
	\ifx \BookFonts \empty\else
		fonts and\fi 
	software including: 
		\ifx \BookFonts \empty\else%
			\BookFonts, \fi
		\ifx \OtherSoftware \empty\else%
			\OtherSoftware, \fi
		\href{https://ctan.org/pkg/photobook}{photobook} and 
		\href{https://www.latex-project.org/}{\LATEX.}}

%% These provide the default information used by the |\BookInfoPage| and
%% |\BookSoftwareInfoPage|.
%%

%% \DescribeMacro{\BookInfoPage}
%
%% Generate book information page. 
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +---------------+
%%   |               |
%%   |               |
%%   |               |
%%   | copyright     |
%%   | ISBN          |
%%   | info          |
%%   +---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% This page is {\it usually} included near the start of the book, before
%% any of the logical sections of the book start, {\it usually} just after
%% the title pages but before any of the epigraphs, forewords, TOCs and 
%% prefaces. This can also in some cases be pushed to the rear of the book.
%%
% XXX add option to combine this with software info...
\def\BookInfo{%
	\ifx \CopyrightNotice \empty\else%
		{\setlength{\parskip}{0.5em}%
			\CopyrightNotice} \\
		\vspace{1em}
	\fi
	\ifx \ByNotice \empty\else%
		\ByNotice
	
	\fi
	\ifx \ThanksTo \empty\else%
		Special thanks to: \ThanksTo \\ \fi
	\vspace{1em}
	\ifx \ISBN \empty\else%
		ISBN: \ISBN \\
		\vspace{1em}\fi
	\ifx \Edition \empty\else%
		Edition: \Edition

	\fi
	\ifx \BookVersion \empty\else%
		Version: \BookVersion

	\fi}
\newcommand\BookInfoPage[1][]{%
	\begin{page}%
		\vfill
		\begin{flushleft}%
			\footnotesize
			#1

			\BookInfo
		\end{flushleft}%
	\end{page}}


%% \DescribeMacro{\BookSoftwareInfoPage}
%
%% Generate software info page.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +---------------+
%%   |               |
%%   |               |
%%   |               |
%%   |               |
%%   |               |
%%   | notice        |
%%   +---------------+
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% This page if present is usually placed at the very rear of the book.
%%
\def\SoftwareInfo{%
	\ifx \SoftwareNotice \empty\else%
		\SoftwareNotice\fi}
\newcommand\BookSoftwareInfoPage[1][]{%
	\begin{page}%
		\vfill
		\begin{flushleft}%
			\footnotesize
			#1

			\SoftwareInfo
		\end{flushleft}%
	\end{page}}


%% \DescribeMacro{\BookFullInfoPage}
%
%% This page combines the |\BookInfoPage| and |\BookSoftwareInfoPage| 
%% information into a single page.
%%
\newcommand\BookFullInfoPage[1][]{%
	\begin{page}%
		\vfill
		\begin{flushleft}%
			\footnotesize
			#1

			\BookInfo
			\vspace{1em}
			\SoftwareInfo
		\end{flushleft}%
	\end{page}}



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
%% \DescribeMacro{\tweakimageoffsettop\{..\}}
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

%M \DescribeMacro{\ImagePageTemplate\{..\}}
%
%M	>> \ImagePageTemplate{<name>}{<code>}
%
%M This will define two commands:
%
%M	>> \<name>[<options>]{<caption>}{<code>}
%M	>> \<name>*[<options>]{<caption>}{<code>}
%
%M |\<name>{..}| will use |\<name>Caption{..}| template command to typeset 
%M the image caption while |\<name>*{..}| will show the caption as-is.
%M
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
%%%%% General interface
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


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% No bleed

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
	% XXX PRECLEAR do we need clear page here???
	%\clearpage%
	\begin{page}%
	\begin{pagecell*}%
	\begin{minipage}[t][\cellheight][c]{\cellwidth}%
		\vspace{\imageblockoffsettop\pagetextheight}%
		\begin{center}%
			\begin{inlinecell*}%
					{\imageblockwidth\pagetextwidth}%
					{\imageblockheight\pagetextheight}%
				\imagecell[fit,
					scale=\imagescale,
					%captionclearparent=\captionclearpage,
					#1]{#2}{#3}%
			\end{inlinecell*}%
		\end{center}%
	\end{minipage}%
	\end{pagecell*}%
	\end{page}}


%% \DescribeMacro{\ImagePageClear\{..\}}
%% \DescribeMacro{\ImagePageClearCaption\{..\}}
%% \DescribeMacro{\resetImagePageClearCaption}
%% \DescribeMacro{\ImagePageClear*\{..\}}
%
%%	>> \ImagePageClear[<options>]{<caption>}{<image>}
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%    \clearimage      \clearimage
%%    v                v
%%   +-----------------+      +-----------------+  < \clearimage
%%   |                 |      |  +-----------+  |   
%%   |+---------------+|      |  | .       . |  |
%%   || .           . ||      |  |  .     .  |  |
%%   ||    .     .    ||      |  |   .   .   |  |
%%   ||     image     ||      |  |   image   |  |
%%   ||    .     .    ||      |  |   .   .   |  |
%%   || .           . ||      |  |  .     .  |  |
%%   |+---------------+|      |  | .       . |  |
%%   |               c |      |  +-----------+  |
%%   +-----------------+      +-----------------+  < \clearimage
%%
%% \end{verbatim}
%% \end{minipage}
%%
%% Default image clearance is set by |\clearimage| global length.
%%
%% This respects |\bindingoffset|.
%%
% XXX make captions adaptive??? 
\ResettableMacro{ImagePageClearCaption}[1]{%
	\captioncell[under, align=flushright]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageClear}{%
	% XXX PRECLEAR do we need clear page here???
	%\clearpage%
	\begin{page}%
	% NOTE: this accounts for \bindingoffset...
	\begin{pagecell*}%
		\imagecell[%
			center, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			captionclearparent=\captionclearpage,
			#1]{#2}{#3}%
	\end{pagecell*}%
	\end{page}}


%% \DescribeMacro{\ImagePageClear<D>\{..\}}
%% \DescribeMacro{\ImagePageClear<D>Caption\{..\}}
%% \DescribeMacro{\resetImagePageClear<D>Caption}
%% \DescribeMacro{\ImagePageClear<D>*\{..\}}
%
%% |<D>| can be one of T, B, L or R, for top, bottom, left and right 
%% respectively.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   +-----------------+    +-----------------+ 
%%   | +-------------+ |    |                 |   
%%   | | .         . | |    | c               | 
%%   | |   .     .   | |    | +-------------+ | 
%%   | |    image    | |    | | .         . | | 
%%   | |   . (T) .   | |    | |   .     .   | | 
%%   | | .         . | |    | |    image    | | 
%%   | +-------------+ |    | |   . (B) .   | | 
%%   |               c |    | | .         . | | 
%%   |                 |    | +-------------+ | 
%%   +-----------------+    +-----------------+ 
%%
%%   +-----------------+    +-----------------+ 
%%   | +---------+     |    |     +---------+ | 
%%   | |.       .|     |    |     |.       .| | 
%%   | | .     . |     |    |     | .     . | | 
%%   | |  .   .  |     |    |     |  .   .  | | 
%%   | |  image  |     |    |     |  image  | | 
%%   | |  .(L).  |     |    |     |  .(R).  | | 
%%   | | .     . |     |    |     | .     . | | 
%%   | |.       .|     |    |     |.       .| | 
%%   | +---------+ c   |    |   c +---------+ | 
%%   +-----------------+    +-----------------+ 
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX TEST...
\ResettableMacro{ImagePageClearTCaption}[1]{%
	\captioncell[under]{%
		\captionformat{#1}}}
% XXX the image seems to be a line too low...
\ImagePageTemplate{ImagePageClearT}{%
	\ImagePageClear*[%
		top,
		#1]{#2}{#3}}

\ResettableMacro{ImagePageClearBCaption}[1]{%
	\captioncell[over]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageClearB}{%
	\ImagePageClear*[%
		bottom,
		#1]{#2}{#3}}

\ResettableMacro{ImagePageClearLCaption}[1]{%
	\captionblockcell[right, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageClearL}{%
	\ImagePageClear*[%
		left,
		#1]{#2}{#3}}

\ResettableMacro{ImagePageClearRCaption}[1]{%
	\captionblockcell[left, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageClearR}{%
	\ImagePageClear*[%
		right,
		#1]{#2}{#3}}



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Partial bleed

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
%% Default image clearance is set by |\bleed| global length.
%%
%% If centered image fits vertically this will account for |\bindingoffset|.
%%
% XXX make captions adaptive??? 
\ResettableMacro{ImagePageFitCaption}[1]{%
	\captioncell[under, align=flushright]{%
		\captionformat{#1}}}

\newif\ifphotobook@ImagePageFit@centered
\photobook@ImagePageFit@centeredfalse

\newlength\photobook@ImagePageFit@imgratio
\newlength\photobook@ImagePageFit@cellratio
\def\photobook@ImagePageFit@opt{}
\def\photobook@ImagePageFit@args{}

\ImagePageTemplate{ImagePageFit}{%
	\begingroup%
		% see if default alignment is overridden...
		\setsepchar{,}%
		\ignoreemptyitems%
		\readlist*\photobook@ImagePageFit@args{moo, #1}%
		\foreachitem\photobook@ImagePageFit@opt\in\photobook@ImagePageFit@args{%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{fill}}{%
				\photobook@ImagePageFit@centeredtrue}{}%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{inner}}{%
				\photobook@ImagePageFit@centeredtrue}{}%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{outer}}{%
				\photobook@ImagePageFit@centeredtrue}{}%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{top}}{%
				\photobook@ImagePageFit@centeredtrue}{}%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{left}}{%
				\photobook@ImagePageFit@centeredtrue}{}%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{bottom}}{%
				\photobook@ImagePageFit@centeredtrue}{}%
			\ifthenelse{\equal{\photobook@ImagePageFit@opt}{right}}{%
				\photobook@ImagePageFit@centeredtrue}{}}%
		% align center -> check if image fits vertically...
		\ifphotobook@ImagePageFit@centered\else%
			\sbox{\photobook@imagebox}{\includegraphics{#3}}%
			\setlength\photobook@ImagePageFit@imgratio{%
				1pt * \ratio{\wd\photobook@imagebox}{\ht\photobook@imagebox}}%
			% NOTE: subtracting \bindingoffset from \cellwidth here makes sure that
			%		we avoid offsetting images close enough in ratio to the page and
			%		messing up bleeds...
			\setlength\photobook@ImagePageFit@cellratio{%
				1pt * \ratio{\cellwidth - \bindingoffset}{\cellheight}}%
			\ifdim \photobook@ImagePageFit@imgratio > \photobook@ImagePageFit@cellratio%
				\photobook@ImagePageFit@centeredtrue\fi\fi%
		%
		% ignore \bindingoffset -> center the image...
		\ifphotobook@ImagePageFit@centered%
			% XXX PRECLEAR do we need clear page here???
			%\clearpage%
			\begin{page}%
			% NOTE: this does not account for \bindingoffset...
			\begin{pagecell}%
				\imagecell[%
					center, 
					clearance=-\bleed, 
					scale=\imagescale,
					offsettop=\imageoffsettop,
					offsetleft=\imageoffsetleft,
					captionclearparent=\captionclearpage,
					#1]{#2}{#3}%
			\end{pagecell}%
			\end{page}%
		% special case: centered vertical image -> account for \bindingoffset...
		\else%
			\ImagePageClear*[%
				clearance=-\bleed, 
				#1]{#2}{#3}\fi%
	\endgroup}


%% \DescribeMacro{\ImagePageFit<D>\{..\}}
%% \DescribeMacro{\ImagePageFit<D>Caption\{..\}}
%% \DescribeMacro{\resetImagePageFit<D>Caption}
%% \DescribeMacro{\ImagePageFit<D>*\{..\}}
%
%% |<D>| can be one of T, B, L or R, for top, bottom, left and right 
%% respectively.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%   . . . . . . . . . . . .  
%%   . +-----------------+ .    +-----------------+
%%   . |  .           .  | .    |                 |
%%   . |     .     .     | .    |                 |
%%   . |      image      | .    |                 |
%%   . |     . (T) .     | .  . |-----------------| .
%%   . |  .           .  | .  . |  .           .  | .
%%   . |-----------------| .  . |     .     .     | .
%%     |                 |    . |      image      | .
%%     |                 |    . |     . (B) .     | .
%%     |                 |    . |  .           .  | .
%%     +-----------------+    . +-----------------+ .
%%                            . . . . . . . . . . . .
%%   
%%   . . . . . . . .                  . . . . . . . .
%%   . +-----------------+      +-----------------+ .
%%   . |.         .|     |      |     |.         .| .
%%   . | .       . |     |      |     | .       . | .
%%   . |  .     .  |     |      |     |  .     .  | .
%%   . |   .   .   |     |      |     |   .   .   | .
%%   . |   image   |     |      |     |   image   | .
%%   . |   .(L).   |     |      |     |   .(R).   | .
%%   . |  .     .  |     |      |     |  .     .  | .
%%   . | .       . |     |      |     | .       . | .
%%   . |.         .| c   |      |   c |.         .| .
%%   . +-----------------+      +-----------------+ .
%%   . . . . . . . .                  . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
\ResettableMacro{ImagePageFitTCaption}[1]{%
	\captioncell[under]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageFitT}{%
	\ImagePageFit*[%
		top, 
		#1]{#2}{#3}}

\ResettableMacro{ImagePageFitBCaption}[1]{%
	\captioncell[over]{%
		\captionformat{#1}}}
% XXX the image seems a bit too low...
\ImagePageTemplate{ImagePageFitB}{%
	\ImagePageFit*[%
		bottom, 
		#1]{#2}{#3}}

\ResettableMacro{ImagePageFitLCaption}[1]{%
	\captionblockcell[right, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageFitL}{%
	\ImagePageFit*[%
		left, 
		#1]{#2}{#3}}

\ResettableMacro{ImagePageFitRCaption}[1]{%
	\captionblockcell[left, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageFitR}{%
	\ImagePageFit*[%
		right, 
		#1]{#2}{#3}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Full bleed

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
%% Default image clearance is set by |\bleed| global length.
%%
\ResettableMacro{ImagePageFillCaption}[1]{%
	\captioncell[top, align=flushright]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImagePageFill}{%
	\ImagePageFit*[%
		fill, 
		#1]{#2}{#3}}


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
%%  . +-----------------=     
%%  . |   .             =     
%%  . |       .         =     
%%  . |           .     =     
%%  . |               . =     
%%  . |               image
%%  . |               . =     
%%  . |           .     =     
%%  . |       .         =     
%%  . |   .           c =     
%%  . +-----------------=     
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
		\imagecell[%
			fill, 
			clearance=-\bleed,
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			captionclearparent=\captionclearpage,
			#1]{#2}{#3}%
	\end{spreadtopages*}%
	%
	% XXX PRECLEAR do we need clear page here???
	%\clearpage%
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
%%      =-----------------+ .
%%      =             .   | .
%%      =         .       | .
%%      =     .           | .
%%      = .               | .
%%    image               | .
%%      = .               | .
%%      =     .           | .
%%      =         .       | .
%%      =             . c | .
%%      =-----------------+ .
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
		\imagecell[%
			fill, 
			clearance=-\bleed, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			captionclearparent=\captionclearpage,
			#1]{#2}{#3}%
	\end{spreadtopages*}%
	%
	% XXX PRECLEAR do we need clear page here???
	%\clearpage%
	\usespreadpage[2]{photobook@ImageHalfPageR@cell}}



%----------------------------------------------------------------------
%%%% Spread Templates


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% No bleed

% XXX TEST!!
% XXX doc...
% XXX Should we make this just like with pages, i.e. \imagePage{..} and 
%		\ImagePageFit{..}, the first places relative to text and raises 
%		slightly while the second simply centers...
%% \DescribeMacro{\ImageSpread\{..\}}
%% \DescribeMacro{\ImageSpreadCaption\{..\}}
%% \DescribeMacro{\resetImageSpreadCaption}
%% \DescribeMacro{\ImageSpread*\{..\}}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%    +---------------=---------------+ 
%%    | +-------------=-------------+ | 
%%    | |  .          =          .  | | 
%%    | |      .      =      .      | | 
%%    | |          .  =  .          | | 
%%    | |           image           | | 
%%    | |          .  =  .          | | 
%%    | |      .      =      .      | | 
%%    | |  .          =          .  | | 
%%    | +-------------=-------------+ | 
%%    +---------------=---------------+ 
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX do a better default...
%		...adaptive???
\ResettableMacro{ImageSpreadCaption}[1]{%
	\captioncell[under]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpread}{%
	\cleartoleftpage%
	\begin{spreadtopages}[2]%
		\imagecell[%
			fit, 
			clearance=\clearimage, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			captionclearparent=\captionclearpage,
			#1]{#2}{#3}%
	\end{spreadtopages}}


%% \DescribeMacro{\ImageSpread<D>\{..\}}
%% \DescribeMacro{\ImageSpread<D>Caption\{..\}}
%% \DescribeMacro{\resetImageSpread<D>Caption}
%% \DescribeMacro{\ImageSpread<D>*\{..\}}
%
%% |<D>| can be one of T, B, L or R, for top, bottom, left and right 
%% respectively.
%%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%    +---------------=---------------+  +---------------=---------------+   
%%    | +-------------=-------------+ |  |               =               |   
%%    | |  .          =          .  | |  |  c            =               |   
%%    | |       .     =     .       | |  | +-------------=-------------+ |   
%%    | |           image           | |  | |  .          =          .  | |   
%%    | |       .    (T)    .       | |  | |       .     =     .       | |   
%%    | |  .          =          .  | |  | |           image           | |   
%%    | +-------------=-------------+ |  | |       .    (B)    .       | |   
%%    |               =            c  |  | |  .          =          .  | |   
%%    |               =               |  | +-------------=-------------+ |   
%%    +---------------=---------------+  +---------------=---------------+   
%%
%%    +---------------=---------------+  +---------------=---------------+ 
%%    | +-------------=---------+     |  |     +---------=-------------+ | 
%%    | |  .          =      .  |     |  |     |  .      =          .  | | 
%%    | |     .       =   .     |     |  |     |     .   =       .     | | 
%%    | |        .    =.        |     |  |     |        .=    .        | | 
%%    | |         image         |     |  |     |         image         | | 
%%    | |        . (L)=.        |     |  |     |        .=(R) .        | | 
%%    | |     .       =   .     |     |  |     |     .   =       .     | | 
%%    | |  .          =      .  |     |  |     |  .      =          .  | | 
%%    | +-------------=---------+ c   |  |   c +---------=-------------+ | 
%%    +---------------=---------------+  +---------------=---------------+ 
%%
%% \end{verbatim}
%% \end{minipage}
%%
\ResettableMacro{ImageSpreadTCaption}[1]{%
	\captioncell[under]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadT}{%
	\ImageSpread*[%
		top, 
		#1]{#2}{#3}}

\ResettableMacro{ImageSpreadBCaption}[1]{%
	\captioncell[over]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadB}{%
	\ImageSpread*[%
		bottom, 
		#1]{#2}{#3}}

\ResettableMacro{ImageSpreadLCaption}[1]{%
	\captionblockcell[right, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadL}{%
	\ImageSpread*[%
		left, 
		#1]{#2}{#3}}

\ResettableMacro{ImageSpreadRCaption}[1]{%
	\captionblockcell[left, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadR}{%
	\ImageSpread*[%
		right, 
		#1]{#2}{#3}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Partial bleed


%% \DescribeMacro{\ImageSpreadFit\{..\}}
%% \DescribeMacro{\ImageSpreadFitCaption\{..\}}
%% \DescribeMacro{\resetImageSpreadFitCaption}
%% \DescribeMacro{\ImageSpreadFit*\{..\}}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%
%%                                                  . . . . . . . . . . .
%%     +---------------=---------------+      +---------------=---------------+  
%%     |               =               |      |     |.        =        .|.    |  
%%   . |---------------=---------------| .    |     |  .      =      .  |     |  
%%   . |    .          =          .    | .    |     |    .    =    .    |     |  
%%   . |         .     =     .         | .    |     |      .  =  .      |     |  
%%   . |             image             | .    |     |       image       |     |  
%%   . |         .     =     .         | .    |     |      .  =  .      |     |  
%%   . |    .          =          .    | .    |     |    .    =    .    |     |  
%%   . |---------------=---------------| .    |     |  .      =      .  |     |  
%%     |               =             c |      |     |.        =        .| c   |  
%%     +---------------=---------------+      +---------------=---------------+  
%%                                                  . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX TEST...
% XXX make caption adaptive...
\ResettableMacro{ImageSpreadFitCaption}[1]{%
	\captioncell[under]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadFit}{%
	\cleartoleftpage%
	\begin{spreadtopages}[2]%
		\imagecell[%
			fit, 
			clearance=-\bleed, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			captionclearparent=\captionclearpage,
			#1]{#2}{#3}%
	\end{spreadtopages}}


%% \DescribeMacro{\ImageSpread<D>\{..\}}
%% \DescribeMacro{\ImageSpread<D>Caption\{..\}}
%% \DescribeMacro{\resetImageSpread<D>Caption}
%% \DescribeMacro{\ImageSpread<D>*\{..\}}
%
%% Image spread aligned left (with bleed).
%
%% 	>> \ImageSpread<D>[<options>]{<caption>}{<image>}
%
%% \begin{minipage}{\textwidth}
%% \begin{verbatim}
%%                                           
%%  . . . . . . . . . . . . . . . . . . .           
%%  . +---------------=---------------+ .    +---------------=---------------+  
%%  . |   .           =           .   | .    | c             =               |  
%%  . |       .       =       .       | .  . |---------------=---------------| .
%%  . |           .   =   .           | .  . |   .           =           .   | .
%%  . |             image             | .  . |       .       =       .       | .
%%  . |           .  (T)   .          | .  . |           .   =   .           | .
%%  . |       .       =       .       | .  . |             image             | .
%%  . |   .           =           .   | .  . |           .  (B)  .           | .
%%  . |---------------=---------------| .  . |       .       =       .       | .
%%    |               =             c |    . |   .           =           .   | .
%%    +---------------=---------------+    . +---------------=---------------+ .
%%                                         . . . . . . . . . . . . . . . . . . .
%%
%%  . . . . . . . . . . . . . . . .              . . . . . . . . . . . . . . . .
%%  . +---------------=---------------+      +---------------=---------------+ .
%%  . | .             =         . |   |      |   | .         =             . | .
%%  . |    .          =      .    |   |      |   |    .      =          .    | .
%%  . |       .       =   .       |   |      |   |       .   =       .       | .
%%  . |          .    =.          |   |      |   |          .=   .           | .
%%  . |           image           |   |      |   |          image            | .
%%  . |          . (L)=.          |   |      |   |          .(R) .           | .
%%  . |       .       =   .       |   |      |   |       .   =       .       | .
%%  . |    .          =      .    |   |      |   |    .      =          .    | .
%%  . | .             =         . | c |      | c | .         =             . | .
%%  . +---------------=---------------+      +---------------=---------------+ .
%%  . . . . . . . . . . . . . . . .              . . . . . . . . . . . . . . . .
%%
%% \end{verbatim}
%% \end{minipage}
%%
% XXX TEST...
% XXX do a better default...
% XXX need a caption box...
\ResettableMacro{ImageSpreadFitTCaption}[1]{%
	\captioncell[under]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadFitT}{%
	\ImageSpreadFit*[top, #1]{#2}{#3}}

\ResettableMacro{ImageSpreadFitBCaption}[1]{%
	\captioncell[over]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadFitB}{%
	\ImageSpreadFit*[bottom, #1]{#2}{#3}}

\ResettableMacro{ImageSpreadFitLCaption}[1]{%
	\captionblockcell[right, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadFitL}{%
	\ImageSpreadFit*[left, #1]{#2}{#3}}

\ResettableMacro{ImageSpreadFitRCaption}[1]{%
	\captionblockcell[left, clearance=\captionclearpage]{%
		\captionformat{#1}}}
\ImagePageTemplate{ImageSpreadFitR}{%
	\ImageSpreadFit*[right, #1]{#2}{#3}}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%%%% Full bleed

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
%%  . +---------------=---------------+ .
%%  . |   .           =           .   | .
%%  . |      .        =        .      | .
%%  . |         .     =     .         | .
%%  . |            .  =  .            | .
%%  . |             image             | .
%%  . |            .  =  .            | .
%%  . |         .     =     .         | .
%%  . |      .        =        .      | .
%%  . |   .           =           . c | .
%%  . +---------------=---------------+ .
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
		\imagecell[%
			fill, 
			clearance=-\bleed, 
			scale=\imagescale,
			offsettop=\imageoffsettop,
			offsetleft=\imageoffsetleft,
			captionclearparent=\captionclearpage,
			#1]{#2}{#3}%
	\end{spreadtopages}}



%----------------------------------------------------------------------
%%%% Meta Macros / Environments
%
%% These macros and environments are used internally to help define cells
%% and templates and thus can be useful when extending the functionality 
%% of this class both when authoring styles and when creating user 
%% macros/templates.\footnote{%
%% 		Note that in code the relevant meta-macros are defined in the logical 
%% 		locations for each macro, i.e. before first use and at the start of 
%% 		the relevant context. This section in the reference is placed near 
%% 		the end so as to focus the user's attention on the main class interface,
%% 		class internal architecture and extension API being secondary.}
%%
%% \input{\jobname-meta}
%%
%%



%----------------------------------------------------------------------
%%%% Miscellaneous


%% \DescribeMacro{\PageInfo}
%
%% Display basic paper / page / cell geometry.
%%
\newcommand\PageInfo[1][mm]{%
	Layout: \layoutmode
	\par
	paper: \lenprint[#1]{\paperwidth} x \lenprint[#1]{\paperheight} (w. bleeds) \\
	block: \lenprint[#1]{\blockwidth} x \lenprint[#1]{\blockheight} \\
	cell: \lenprint[#1]{\cellparentwidth} x \lenprint[#1]{\cellparentheight} \\
	bleed: \lenprint[#1]{\bleed}}


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

\newcommand\GenerateTemplate[1][mm]{
	\TPoptions{showboxes=true}%
	\begin{page}
		\setlength{\parindent}{0em}
		% NOTE: only the relevant blocks will be visible...
		\ifspreadlayout%
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


% XXX place marks in bleed area...
% XXX do this for all pages... (???)
\newcommand\ShowMarks[1][1pt]{%
	% general...
	% XXX corners / cut marks...
	\ifspreadlayout%
		% XXX fold...
	\fi%
	\ifcoverlikelayout%
		% XXX spine...
		% XXX folds...
	\fi%
	\ifjacketlayout%
		% XXX spine...
		% XXX folds...
	\fi}


% XXX EXPERIMENTAL...
\def\photobook@pdfboxstore@stored{}

% XXX should these be stacked???
% XXX handle slot name...
\newcommand\storepdfboxes[1][stored]{%
	\edef\photobook@pdfboxstore@stored{%
		\photobook@pdfboxes}}

% XXX handle slot name...
\newcommand\restorepdfboxes[1][stored]{%
	\expandafter\pdfpageattr\expandafter{\photobook@pdfboxstore@stored}}


%% \DescribeMacro{\pdfboxesset\{..\}}
%
%%	>> \pdfboxesset[<bleed>]{<bleedblockwidth>}{<bleedblockheight>}
%%
\newcommand\pdfboxesset[3][\bleed]{%
	% calculate pdf box dimensions in pt...
	\edef\photobook@pdfboxesset@w{\strip@pt\dimexpr 
		0.996264009963\dimexpr #2 \relax\relax}%
	\edef\photobook@pdfboxesset@h{\strip@pt\dimexpr 
		0.996264009963\dimexpr #3 \relax\relax}%
	\edef\photobook@pdfboxesset@bleed{\strip@pt\dimexpr 
		0.996264009963\dimexpr #1 \relax\relax}%
	\edef\photobook@pdfboxesset@t{\strip@pt\dimexpr 
		0.996264009963\dimexpr #3 - #1 \relax\relax}%
	\edef\photobook@pdfboxesset@r{\strip@pt\dimexpr 
		0.996264009963\dimexpr #2 - #1 \relax\relax}%
	%
	\edef\photobook@pdfboxes{%
		/MediaBox [0 0 \photobook@pdfboxesset@w\space \photobook@pdfboxesset@h]
		/BleedBox [0 0 \photobook@pdfboxesset@w\space \photobook@pdfboxesset@h]
		/ArtBox [
			\photobook@pdfboxesset@bleed\space \photobook@pdfboxesset@bleed\space 
			\photobook@pdfboxesset@r\space \photobook@pdfboxesset@t]
		/TrimBox [
			\photobook@pdfboxesset@bleed\space \photobook@pdfboxesset@bleed\space 
			\photobook@pdfboxesset@r\space \photobook@pdfboxesset@t]
		/CropBox [
			\photobook@pdfboxesset@bleed\space \photobook@pdfboxesset@bleed\space 
			\photobook@pdfboxesset@r\space \photobook@pdfboxesset@t]}%
	%
	% set the boxes...
	\ifxetex%
		% XXX make this reusable -- currently this will add new boxes per 
		%		call, need to cleanup...
		\AtBeginShipout{\AtBeginShipoutAddToBox{%
			\special{pdf:put @thispage << \photobook@pdfboxes >>}}}%
	\else%
		\expandafter\pdfpageattr\expandafter{\photobook@pdfboxes}\fi}


%% \DescribeMacro{\pdfcommentcell\{..\}}
%
%% Add pdf comment as margin overlay.
%%
%%	>> \pdfcommentcell[<options>]{<comment>}
%%
% XXX BUG: this takes up space...
\newcommand\pdfcommentcell[2][]{%
	\begin{cell*}{
				\ifnumodd{\thepage}{%
					\cellwidth - \marginparwidth - 2\bleed - 1cm
				}{%
					\bleed + 1cm},
				\bleed + 1cm
			}{\marginparwidth}{1pt}%
		\pdfcomment[color=yellow, #1]{#2}%
	\end{cell*}}


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


%% \DescribeMacro{\pdfspreadstopages\{..\}}
%
%% \EXPERIMENTAL
%%
%%	Include spreads from a pdf block as pages
%%
%%	>>	\pdfspreadstopages[<delta>]{<block-pdf>}
%%
%% |\pdfspreadstopages{..}| inserts an empty page before the first page 
%% in the block to push it to the right of the spread.
%%
%% To display other pages consistently it is recommended to set the 
%% block width to |2\blockwidth| and set the |pdfpagelayout| to be 
%% set to |SinglePage|, a simple way to do both is to:
%%
%% >> \ChangeLayout{spread}
%%
% XXX do we need to set the page format to double block width here???
% XXX TEST...
\newcommand\pdfspreadstopages[2][0mm]{%
	\includepdf[pages={{},1-}, nup=2x1, delta=#1 #1]{#2}}


% XXX include the cover with the foldouts removed... 
\newcommand\pdfcover[1]{%
	% XXX crop to frontcover cell..
	\includepdf{#1}}
% XXX include cover cells....
\newcommand\pdfcoverfront[1]{%
	% XXX crop to frontcover cell..
	\includepdf{#1}}
\newcommand\pdfcoverback[1]{%
	% XXX crop to backcover cell..
	\includepdf{#1}}
% XXX do we need this???
%\newcommand\pdfendpaper[1]{%
%	\includepdf{#1}}


% XXX 
% XXX do we include endpapers??:
\newcommand\pdfweb[2]{%
	\pdfcoverfront{#1}%
	\pdfspreadstopages{#2}%
	\pdfcoverback{#1}}




%% \DescribeMacro{\TEX}
%% \DescribeMacro{\LATEX}
%
%% Convenience macros to display \TeX and \LaTeX in the correct font.
%%
\def\TEX{%
	{\fontfamily{lmr}\selectfont \TeX}}
\def\LATEX{%
	{\fontfamily{lmr}\selectfont \LaTeX}}



%----------------------------------------------------------------------
% Index...
%
% XXX this prints trash at this point...
%		...I do not want to build the index manually but it seems that
%		we are slowly moving in that direction...
%%% \printindex


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%%% XXX DEBUG...
%%%\AtBeginDocument{
%%%}


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%% \blankfootnote{%
%%		Why ASCII diagrams instead of normal graphics, you might ask?
%%		Well, for the same reason as photo-books in \LaTeX\ -- I liked 
%%		the idea of it, the simplicity, and thought that it would be fun to 
%%		see how far can I push things before it all	falling apart on me, and... 
%%		We are here, at the end, and it all is still here too :)}



%----------------------------------------------------------------------
%% \end{document} %                         vim:set ts=4 sw=4 nowrap :
