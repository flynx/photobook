%----------------------------------------------------------------------
%
%----------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
% XXX set release date...
\ProvidesClass{photobook}[2021/07/28 Photo book Latex class]

% options...
%
% XXX handle options:
%	- page size (w, h)
%	- image block (w, h)
%	- bleed size
%	- 
%	- 
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax

% XXX load defauls...
\LoadClass[9pt,final,openany]{book}


\RequirePackage{etoolbox}
\RequirePackage{atbegshi}

% pdf config...
%
% XXX make this configurable from options...
\RequirePackage[
	pdfpagelayout=TwoPageRight]{hyperref}









%----------------------------------------------------------------------
\AtEndPreamble{

% Geometry... (???)
%
% XXX


% pdf boxes...
%
% calculate pdf box dimensions in pt...
% XXX this depends on:
%		\bleedblockwidth		= \bleedsize + \paperwidth + \bleedbindsize
%		\bleedblockheight		= 2\bleedsize + \paperheight
%		\bleedsize				= 4mm (default)
%		\bleedbindsize			= \bleedsize (default)
%%\edef\pdfW{\strip@pt\dimexpr 0.996264009963\bleedblockwidth \relax}
%%\edef\pdfH{\strip@pt\dimexpr 0.996264009963\bleedblockheight \relax}
%%\edef\pdfBleed{\strip@pt\dimexpr 0.996264009963\bleedsize \relax}
%%\edef\pdfTop{\strip@pt\dimexpr 0.996264009963\dimexpr \bleedblockheight-\bleedsize \relax \relax}
%%\edef\pdfRight{\strip@pt\dimexpr 0.996264009963\dimexpr \bleedblockwidth-\bleedsize \relax \relax}
%%
%%\ifxetex
%%	% XXX not tested...
%%	\AtBeginShipout{\AtBeginShipoutAddToBox{
%%		\special{pdf:put @thispage <<
%%			/MediaBox [0 0 \pdfW\space\pdfH]
%%			/BleedBox [0 0 \pdfW\space\pdfH]
%%			/ArtBox [\pdfBleed\space\pdfBleed\space\pdfRight\space\pdfTop]
%%			/TrimBox [\pdfBleed\space\pdfBleed\space\pdfRight\space\pdfTop]
%%			/CropBox [\pdfBleed\space\pdfBleed\space\pdfRight\space\pdfTop]
%%		>>} }} 
%%
%%\else
%%	\edef\pdfboxes{
%%		/MediaBox [0 0 \pdfW\space\pdfH]
%%		/BleedBox [0 0 \pdfW\space\pdfH]
%%		/ArtBox [\pdfBleed\space\pdfBleed\space\pdfRight\space\pdfTop]
%%		/TrimBox [\pdfBleed\space\pdfBleed\space\pdfRight\space\pdfTop]
%%		/CropBox [\pdfBleed\space\pdfBleed\space\pdfRight\space\pdfTop]
%%	}
%%	\expandafter\pdfpageattr\expandafter{\pdfboxes}
%%\fi



% pdf metadata...
%
% XXX use \@author and \@title instead of \ProjectTitle or \ProjectAuthor
% XXX need an equivalet for pdflatex...
% XXX not tested...
\ifxetex
	%%% PDF/X-3 stuff, necessary for Blurb IF USING pdflatex
	%% \pdfinfo{
	%% /Title (\ProjectTitle)
	%% /Author (\ProjectAuthor, \ProjectEditor)
	%% /Subject (\ProjectTitle)
	%% /Keywords (history, black-and-white, bw, people, photography, USSR, Russia, Moscow, 1991)
	%% }
	%% \pdfminorversion=4
	%% \pdfcatalog{
	%% /OutputIntents [ <<
	%% /Info (none)
	%% /Type /OutputIntent
	%% /OutputConditionIdentifier (Web use)
	%% /RegistryName (http://www.color.org/)
	%% >> ]
	%% }
	\special{pdf:docinfo <<
		/Title (\ProjectTitle)
		/Author (\ProjectAuthor)
		/Subject (\ProjectTitle)
		/Keywords (\ProjectKeywords)
	>>}
\fi
\ifluatex
	% XXX this does not convert encoding...
	\directlua0{
		pdf.setinfo(
			"/Title (\ProjectTitle) "
			.."/Author (\ProjectAuthor) "
			.."/Subject (\ProjectTitle) "
			.."/Keywords (\ProjectKeywords) ") }
\fi

} % \AtEndPreamble{..}



%----------------------------------------------------------------------
%                                                  vim:set ts=4 sw=4 :
