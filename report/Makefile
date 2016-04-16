LATEX = pdflatex
BIBTEX = bibtex

all: proposal.pdf

%.pdf: %.tex %.bib
	$(LATEX) $(patsubst %.pdf,%.tex,$@);
	$(BIBTEX) $(patsubst %.pdf,%,$@);
	$(LATEX) $(patsubst %.pdf,%.tex,$@);

clean:
	rm -rf *.aux *.log *.bbl *.pdf *.out *.blg;
