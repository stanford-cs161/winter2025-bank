%.svg : %.tex
	lualatex --output-format=dvi $<
	dvisvgm --bbox=papersize --font-format=woff2 $*.dvi

%.pdf : %.tex
	lualatex --output-format=pdf $<

.PHONY: clean
clean:
	rm -f *.svg *.pdf *.aux *.bcf *.log *.out *.dvi *.run.xml
	rm -rf public/

.PHONY: publish
publish:
	mkdir -p public/
	cp *.svg public/
	cp *.pdf public/

