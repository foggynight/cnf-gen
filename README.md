# cnf-gen

CNF formula generator for SAT solvers.


## Build

```sh
cabal build
```

Will create an executable in the `dist-newstyle` directory.


## Usage

```text
cnf-gen <formula> <args>

<formula>: Name of formula family to generate.

Choices for <formula> (followed by <args>):
    randkcnf k n m  :  Random k-CNF over n variables and m clauses.
```
