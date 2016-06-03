# SymbolicSQL

## How to use?

### Install dependencies

1. You need to install [Racket](https://racket-lang.org/download/).
2. Install rosette `raco pkg install rosette`.

### Write and verify your own rewriting rules

Examples can be find in `./src/tests`, like `./src/tests/simpleRA.rkt`. 
You need to write two SQL queries in our DSL and call `(verify (same q1 q2))`.

### Run the scalability benchmark

Run `./src/run-tests.sh`.


## Reference
1. [Query Reformulation with Constraints](http://homepages.inf.ed.ac.uk/libkin/dbtheory/alinlucianval.pdf). Alin Deutsch, et al.
2. [Qex: Symbolic SQL Query Explorer](http://research.microsoft.com/pubs/131320/qex.pdf). Margus Veanes, et al.
3. [A Direct Symbolic Execution of SQL Code for Testing of Data-Oriented Applications](http://arxiv.org/pdf/1501.05265v1.pdf). Michael Marcozzi, et al.
4. [Equivalence of SQL queries in presence of embedded dependencies](http://dl.acm.org/citation.cfm?id=1559829). 	Rada Chirkova	and Michael R. Genesereth.
5. [Symbolic Query Exploration](http://research.microsoft.com/pubs/80959/qex.pdf). Margus Veanes, et al.

