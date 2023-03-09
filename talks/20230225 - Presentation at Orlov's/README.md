2023.02.25: `photobook` talk
============================

These are the "slides" for a talk given on the 25th of Feb 2023.

Since the topic of the talk is making photo books in LaTeX, the slides are
built as a photo book.


## Building

To build:
```shell
$ make all sweep
```

Generated pdf's:
- `photobook-slides-en.pdf` / `photobook-slides-ru.pdf`  
  The actual slides used for the talk. These require a pdf viewer that
  supports "book mode" and the "two-page view", and preferably good enough 
  maners not to ignore the settings set in the file.
- `photobook-web-en.pdf` / `photobook-web-ru.pdf`  
  Compatibility version that sets one spread per page. This should work
  on any pdf viewer.


To explisictly build the component pages used in the slides:
```shell
$ make components
```

## Licensing:
- All _photographs_ are by Alex A. Naanou, and licenced under 
  the Creative Commons, Attribution-NonCommercial-NoDerivatives 4.0
  (CC BY-NC-ND 4.0)  
  https://creativecommons.org/licenses/by-nc-nd/4.0/
- The _source code_ of this book/slides is licensed under the New BSD License 
  (BSD-3-clause)  
  https://opensource.org/license/bsd-3-clause/
- The _code listed in this book_ can be treated as _Public Domain_  
  https://en.wikipedia.org/wiki/Public_domain


