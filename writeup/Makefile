LATEX = pdflatex
BIBTEX = bibtex

ALL_FILES = $(wildcard *.tex)

all: writeup.pdf

%.pdf: %.tex %.bib $(ALL_FILES)
	$(LATEX) $(patsubst %.pdf,%.tex,$@);
	$(BIBTEX) $(patsubst %.pdf,%,$@);
	$(LATEX) $(patsubst %.pdf,%.tex,$@);
	$(BIBTEX) $(patsubst %.pdf,%,$@);
	$(LATEX) $(patsubst %.pdf,%.tex,$@);

clean:
	rm -rf *.aux *.log *.bbl *.pdf *.out *.blg;
