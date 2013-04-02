#! /bin/bash
xelatex -shell-escape dissertation.tex
bibtex8 dissertation.aux
xelatex -shell-escape dissertation.tex
xelatex -shell-escape dissertation.tex
xelatex -shell-escape dissertation.tex
