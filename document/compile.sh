#! /bin/bash
xelatex -shell-escape dissertation.tex
bibtex dissertation.aux
xelatex -shell-escape dissertation.tex
xelatex -shell-escape dissertation.tex
xelatex -shell-escape dissertation.tex
