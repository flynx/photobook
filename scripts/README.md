
Support scripts
===============

<!-- TOC depthfrom:2 -->

- [make-images.sh](#make-imagessh)
	- [The process](#the-process)
		- [Automatic template inferenceing](#automatic-template-inferenceing)
		- [Manual template selection](#manual-template-selection)
		- [Template tweaking](#template-tweaking)
		- [Manual spread layouts](#manual-spread-layouts)
	- [Templates](#templates)
	- [Image captions](#image-captions)
	- [Environment variables and configuration](#environment-variables-and-configuration)
- [cls2tex.sh](#cls2texsh)

<!-- /TOC -->


---

`make-images.sh`
----------------

Generate LaTeX block of pages from a directory tree.

This was initially intended as a means to convert the exported directory 
tree from an image viewer where image/text sequencing was done, but it 
can also be used standalone.

Goals:
- Decouple layout, sequencing, images, processing and different texts 
  to enable different people to work on them independently and in 
  parallel,
- Simplify editing the page/spread sequence,
- Automate the build process.


A typical project tree:
```
book/
├── templates/  . . . . . . . . . . . . Global templates.
│   ├── imagepage.tex . . . . . . . . . Single page image template,
│   ├── textpage.tex  . . . . . . . . . Single page text template,
│   │                                   These are used to build spreads 
│   │                                   when no explicit template matches.
│   ├── blank-image.tex
│   ├── image-blank.tex
│   ├── image-image.tex
│   ├── fullbleed.tex
│   └── ...
├── spreads/  . . . . . . . . . . . . . . Main block layout.
│   ├── 00/ . . . . . . . . . . . . . . A basic spread.
│   │   ├── tweaks.tex                  The spread template is built
│   │   └── 0-DSC02432.jpg              automatically with tweaks.tex
│   │                                   prepended.
│   ├── 01/
│   │   ├── 0-DSC02439.jpg
│   │   └── 1-intro.txt
│   ├── 02/
│   │   ├── fullbleed.tpl . . . . . . . Explicitly use a global template.
│   │   └── 1-DSC02511.jpg
│   ├── 03/
│   │   ├── 0-DSC02509-0.jpg
│   │   └── 1-DSC02506-0.jpg
│   └── ...
├── captions/ . . . . . . . . . . . . . Image captions.
│   ├── DSC02432.txt
│   ├── DSC02439.txt
│   ├── DSC02511.txt
│   └── ...
├── setup.tex . . . . . . . . . . . . . Book block setup.
│                                       This is included by all top level
│                                       .tex files like block.tex, 
│                                       cover.tex, ...etc.
├── block.tex . . . . . . . . . . . . . Block skeletal layout.
│                                       This usually includes the titles, 
│                                       technical pages and sources the
│                                       ./block-pages.tex.
├── block-pages.tex . . . . . . . . . . The generated block content.
├── cover.tex . . . . . . . . . . . . . Cover layout.
├── jacket.tex  . . . . . . . . . . . . Dust jacket layout.
└── ...
```

Generate the block:
```shell
$ make-images.sh ./pages > block-pages.tex
```

Note that `make-images.sh` does not force a specific layout outside of 
the `pages` directory, all paths are configurable. The way the root 
files are structured in this example is just one way to organize a 
book's source code with minimal code duplication.


For runtime help see:
```shell
$ make-images.sh --help
```


### The process

<!-- XXX spreads vs. pages -->

The system is designed to minimize the effort in laying out pages, so
when designing a book the focus should be on global templates and on
helping `make-images.sh` build them rather than trying to layout each
spread individually.

There are several ways to arrive at a book layout starting from the
concept, through the edit, sequencing, structuring and the graphic
design, we here will focus on the stage of the process where a body of
work is starting to look like a book.

When starting work on a layout it is good to at least have a basic
understanding of the book's:
- structure and how it may change,
- core templates,
- exceptions from the above.

In most cases all of the above will change in one way or another during
the project's lifespan, and the main goal of this stage is to make this 
change as simple as possible -- it's all about providing the freedom to 
make changes instead of growing work invested and thus making change 
more and more expensive.

The first question is what is the _structure_ of the book we are making?
Will it have chapters? How many? Text? how much, how should it be 
structured? How are we going to deal with the title? How are we going 
to present the images, full bleed, no bleeds, small, big, one per page 
or multiple images, ...etc.? At this stage this is about the presentation 
the flow of the work and not about the actual design. How many typical 
spreads (i.e. spread templates) should it have? A good number should be 
small-ish, for example 3-4 spread templates is a good number, if you 
count 10+ then you might be overcomplicating tings, but note, there are 
no rules, a book where each spread is individually and manually layed out 
may work as well as a book with just a single template spread, but in 
general for a photo book the focus is on the project and the layout 
should work with it without overwhelming it.

Have answers, good, now it's time to build those mock layouts and make
them into basic templates.

It would be simplest to start work with the basic templates provided by
`photobook` (see: ../examples/spread templates/templates/) and rework 
them when or if needed.

The templates are split into two levels:
- Page templates  
  These are typical pages that makeup a spread, usually an
  image page (`imagepage.tex`), a text page (`textpage.tex`), and an
  optional empty page (`emptypage.tex`), `make-images.sh` can combine 
  them to build spreads automatically.
- Spread templates  
  These typeset a spread and can be either automatically inferred from
  the structure or manually selected.


#### Automatic template inferencing

If no explicit template is defined (see next section) `make-images.sh` 
will try and infer a template based on the number of images in the 
spread directory, if that is not possible the it will build a spread
from page templates based on the sequence of first two image/text files.

For example with the default settings and the templates defined above:

```
├── 01/
│   ├── 0-DSC02439.jpg
│   └── 1-intro.txt
```

Will use `imagepage.tex` and `textpage.tex` templates to build the spread,
while the following:

```
├── 03/
│   ├── 0-DSC02509-0.jpg
│   └── 1-DSC02506-0.jpg
```

Will use `image-image.tex`.

Note that if a spread template is not found `make-images.sh` fallback to 
page templates, e.g. if we delete `image-image.tex` then `imagepage.tex` 
will be used for both pages of the spread instead.

If only one image/text file is provided then `make-images.sh` will set it
on the right page of the spread using the appropriate page template and
leave the left page blank.

<!-- XXX do we need a `blankpage.tex` template??? -->


#### Manual template selection

A template can be selected manually by providing a file in the form:

```bnf
<template-name>.tpl
```

The content of this file is ignored and `templates/<template-name>.tex`
will be used for that spread.

Example:
```
├── 02/
│   ├── fullbleed.tpl
│   └── 1-DSC02511.jpg
```

Here `templates/fullbleed.tex` will be used.


#### Template tweaking

If the file `tweaks.tex` is present in the spread directory its contents
are included in the built block at the start of that spread.

This can be useful to _tweak_ the spread, for example to set page/font 
color, tweak image positioning in some of the `photobook`'s template 
spread macros (see: tweaking section in photobook.pdf).

Example:
```
├── 00/
│   ├── tweaks.tex
│   └── 0-DSC02432.jpg
```

Note that this can both apply to a single spread as well as a set of 
spreads, of example page or text colors are not reset automatically
and will affect all subsequent spreads until manually reset (in a 
different spread's `tweaks.tex` file), while `photobook`'s tweaks apply 
only to a single page.


#### Manual spread layouts 

If `layout.tex` is present it will be included as the page layout/template.

Any paths in the `layout.tex` should be relative to the location the
built block .tex file will be located, usually to the project root.


### Templates

A template is a LaTeX file with zero or more special fields defined.

Field types:
- `${IMAGE}` / `${IMAGE<number>}`  
  Filled with image path.
- `${CAPTION}` / `${CAPTION<number>}`  
  Filled with caption file content
- `${TEXT}` / `${TEXT<number>}`  
  Filled with text file content

Each field can be used more than once, the field value will be copied to
each instance.

Multiple fields of the same type can be provided and each will be filled
with corresponding data in order, e.g. the third image filed will get
the third image path. Note that we are talking of field order and not
field number, this removes the need to constantly keep the field/file
numbers matched when adding and removing files/fields, all one needs to
do is keep the order the same.

If a field is not filled it will be empty in the resulting `.tex`.

Example template `templates/fullbleed.tex`:
```
\ImageSpreadFill{${CAPTION}}{${IMAGE0}}
```


### Image captions

In general image captions are decoupled from the main layout to enable
writers and editors to work on them externally.

```bnf
captions/
├── <image-name>.txt
└── ...
```

The captions folder name/location is controlled by the `$CAPTION_DIR` 
environment variable.


Inline captions are also supported:
```bnf
pages/
├── <spread>/
│   ├── ...
│   ├── 00-<image-name>.<ext>
│   ├── 00-<image-name>.txt . . . . . . Local image caption
│   └── ...
└── ...
```
An inline caption must have the same filename as the corresponding image
but with a .txt extension.


### Environment variables and configuration

All the configuration options can be given in a configuration file as
well as environment variables.

<!-- XXX this is not true at the moment, not sure if this is a bug or a feature...
Environment variables take precedence over the configuration file. -->

The default `make-images.cfg` would look something like:
```shell
# if non-empty make-images.sh will add image paths to pdf notes...
ANOTATE_IMAGE_PATHS=

# file extensions to treat as text (separated with "|")
TEXT_FORMATS=txt

# file extensions to treat as images (separated with "|")
IMAGE_FORMATS=jpeg|jpg|png|pdf|svg|eps

# default directory spread definitions are located in...
SPREADS_DIR=spreads/

# if non-empty link link images to matching ones from this directory...
IMAGE_HIRES_DIR=

# directory where external captions are stored...
CAPTION_DIR=captions/

# root template directory...
TEMPLATE_DIR=templates/

# empty page template...
EMPTY_PAGE=emptypage

# text page template...
TEXT_PAGE=textpage

# image page template...
IMAGE_PAGE=imagepage

# spread templates...
IMAGE_SPREAD=(
        #
        #   +------- number of found images
        #  /     +-- template name
        # /     /
        [0]=text-spread
        [2]=image-image
)
```


---

`cls2tex.sh`
------------

Extract the documentation from photobook.cls which is used to build the 
photobook.pdf reference manual.

```shell
$ cls2tex.sh --help
```

The `--help` says it all:
```
Generate docs from latex package/class

Usage:
  cls2tex.sh [OPTIONS] [[INPUT] OUTPUT]

Options:
  -h | --help         Show this message and exit
  -p | --prefix PREFIX
                      Set the doc comment PREFIX (default: "%")
  -s | --strip        Strip docs out
  -n | --no-msg       Don't add the "generated with" message to output

This will:
  - read the INPUT
  - keep lines starting with \def\<module-name>@[A-Z]\+
  - keep lines starting with '%%'
  - %%%%% Text -> \subsection(Text)
  - %%%% Text -> \section(Text)
  - %% >> code -> \begin{verbatim}code\end{verbatim}
  - write the result to OUTPUT

If no OUTPUT is given cls2tex.sh will write to stdout. If no INPUT
is given cls2tex.sh will read stdin.

PREFIX can replace the second "%" in the above patterns to make it
possible to integrate multiple layers of documentation in one file
and to integrate them in various ways, for example, in the photobook
document class documentation "M" prefix is used to indicate
meta-command docs, this enables us to document them in the relevant
location (i.e. at the implementation) in source but move the docs to
a unified location in docs, effectively decoupling the source and doc
structure when needed.

Strip mode is the reverse of of the default, it will strip out docs
and empty lines, keeping only the actual code and code comments.

NOTE: stripping will not remove non-doc comments.
NOTE: the idea of keeping latex docs in a latex file is far simpler
      than all the stuff crammed into .dtx, at least for my needs:
          - keep the code readable
          - keep the docs readable
      in both the repo and in installed form, so .dtx is not used.
```




