# photobook

LaTeX class for making photo books.


## Build requirements

- LaTeX tool chain (including: `lualatex`, `latexmk`, ..)  
  The simplest way to get started is [TeX Live](https://www.tug.org/texlive/), 
  either a full install or for specific modules see the _Packages_ section 
  in [photobook.cls](./photobook.cls),
- U\*ix-like environment (`bash`, GNU Make, coreutils, ...),  
  on Windows systems either [Cygwin](https://www.cygwin.com/) or 
  [WSL/WSL2](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) 
  should work fine.


## Build / Install

```shell
# get the source...
$ git clone https://github.com/flynx/photobook.git

# if desired, install in the user context...
$ cd ./photobook
$ make install
```

If only building the docs is required without installing:
```shell
$ make doc 
```

For more info on `make` targets see the: [./Makefile](./Makefile)


<!-- 
XXX ToDo:
- manual
- workflow
-->

