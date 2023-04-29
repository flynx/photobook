photobook
=========

[LaTeX](https://www.latex-project.org/) document class for making photo books.



## Install / Build

The simplest way to install is to use either 
[TeX Live](https://www.tug.org/texlive/)'s or [MiLTeX](https://miktex.org/)'s 
standard way to install modules.

The package is distributed via CTAN: https://ctan.org/pkg/photobook

The source is maintained at GitHub: https://github.com/flynx/photobook


To install from source:
```shell
# get the source...
$ git clone https://github.com/flynx/photobook.git

# if desired, install in the user context...
$ cd ./photobook
$ make install
```

The `photobook` document class requires a set of modules to be installed
for it to function, the full list is included in the docs and can be 
printed by calling:
```shell
$ make depends
```


# Documentation

Pre-built documentation can be found on 
[CTAN](http://mirrors.ctan.org/macros/latex/contrib/photobook/photobook.pdf)
or it can be built from source by:
```shell
$ make pdf 
```

For more info on `make` targets see the: [./Makefile](./Makefile)


### Build requirements for docs

- LaTeX tool chain (including: `lualatex`, `latexmk`, ..)  
  The simplest way to get started is [TeX Live](https://www.tug.org/texlive/), 
  either a full install or for specific modules see the _Packages_ section 
  in [photobook.cls](./photobook.cls),
- Un\*x-like environment (`bash`, GNU Make, coreutils, ...),  
  on Windows systems, either [Cygwin](https://www.cygwin.com/) or 
  [WSL/WSL2](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) 
  should work fine.



## Notes

- The main refetence is inline with the source [photobook.cls](./photobook.cls) 
  thus it is both human-readable next to the code it documents and is 
  used to build the `photobook.pdf`.
  Extracting the documentation source (`photobook*.tex`) is done 
  by [make](./Makefile) via [cls2tex.sh](scripts/README.md#cls2texsh) when 
  building the docs, see them for more info.
- There is a bug in default captions not being typeset correctly if too 
  long, a workaround is to place them in a `minipage` like this:
  ```latex
  \imagecell{%
      \begin{minipage}{\cellwidth}%
          long caption text...
      \end{minipage}%
  }{some-image}
  ```
  (still working on a solution for this).
- `photobook` is mostly used with `lualatex`, other engines are mostly 
  supported but some features may misbehave.


## Authors

[Alex A. Naanou](https://github.com/flynx)



## License

[BSD 3-Clause License](./LICENSE)

Copyright (c) 2021-2023, Alex A. Naanou,
All rights reserved.


<!-- vim:set ts=4 sw=4 nowrap : -->
