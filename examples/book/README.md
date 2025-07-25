Full book example
=================

This directory contains a full book example.

```
book/
├── templates/  . . . . . . . . . . . . Templates used to buld spreads
│   └── ...                             (used by: make-spreads.sh)
├── spreads/  . . . . . . . . . . . . . Spread layout
│   └── ...                             (used by: make-spreads.sh)
├── captions/ . . . . . . . . . . . . . Image captions
│   └── ...                             (used by: make-spreads.sh)
├── hi-res/ . . . . . . . . . . . . . . High resolution graphics
│   └── ...                             (used by: make-spreads.sh)
├── Makefile
├── setup.tex . . . . . . . . . . . . . Book setup and configuration
│                                       This file contains all the book
│                                       geometry, colors and other 
│                                       settings common to all comoponents 
│                                       of the book.
├── block.tex . . . . . . . . . . . . . General page block layout.
├── spreads.tex . . . . . . . . . . . . Book spereads
│                                       (generated by: make-spreads.sh)
├── cover.tex
├── endpaper.tex 
├── jacket.tex
└── ... 
```

Note that this is by no means the only or most optomal project 
structure, but it is a good enough starting point that evolved through 
several, big and small project to start the next one from (at least 
for me, subjectively).



Building
--------

To build all components:
```shell
$ make all
```

To build a specific component:
```shell
$ make block.pdf
``` 

`block.pdf` in this case.

<!-- XXX add basic introspection to Makefike??? -->


Structure
---------

### `setup.tex`

### `spreads.tex`

### `cover.tex` / `jacket.tex` / `endpaper.tex` / ..

### `web.tex`

<!-- XXX this is quite generic, can we generate it? -->



Workflow
--------

XXX


For information about building spreads see: 
[make-spreads.sh](../../scripts/README.md)


<!-- vim:set ts=4 sw=4 nowrap : -->
