
Support scripts
===============

Scripts:
- [`make-images.sh`](#make-imagessh)
- [`cls2tex.sh`](#cls2texsh)


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
├── pages/  . . . . . . . . . . . . . . Main block layout.
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

XXX spreads vs. pages

The system is designed to minimize the effort in laying out pages, so
when designing a book the focus should be on global templates and on
helping `make-images.sh` build them rather than trying to layout each
spread individually.

Here there are several ways to arrive at a book layout starting from the
concept, through the edit, sequencing, structuring and the graphic
design, we here will focus on the stage of the process where a body of
work is starting to look like a book.

When starting work on a book layout it is good to at least have a basic
understanding of it's:
- book structure and how it may change,
- core templates,
- exceptions from the above.

In most cases all of the above will change, and the main goal of this
stage is to make this change as simple as possible, the less effort is
needed to prove the need for change the simpler and more effortless this
change will be -- it's all about providing the freedom to make changes
instead of locking oneself into the work/time already invested.

The first question is what is the _structure_ of the book we are making?
Will it have chapters? How many? Text, how much, how should it be 
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

There are two ways to approach this:
- Page templates  
  These are typical pages that makeup a spread template, usually an
  image page (`imagepage.tex`) and a text page (`textpage.tex`),
  `make-images.sh` can combine them to build spreads automatically.
- Spread templates
  These typeset a spread and can be either automatically inferred from
  the structure or manually selected.

Note that `photobook` provides a set of ready high level templates
specifically designed for this approach.


#### Automatic template inference

#### Manual template selection

#### Template tweaking

#### Individual spread layouts 



### Templates

```bnf
templates/
├── <template-name>.tex
└── ...
```


### Layout

```bnf
pages/
├── <spread>/
│   ├── tweaks.tex
│   ├── layout.tex
│   ├── <template-name>.tpl
│   ├── 00-<image-name>.<ext>
│   ├── 01-<text>.txt
│   └── ...
└── ...
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


### Environment variables




`cls2tex.sh`
------------

Extract the documentation from photobook.cls which is used to build the 
photobook.pdf reference manual.



