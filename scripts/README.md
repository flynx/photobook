
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



