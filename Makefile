# publications.html is NOT built by jemdoc any more -- it is generated from
# publications.toml by build_pubs.py.
DOCS=index bio talks teaching

HDOCS=$(addsuffix .html, $(DOCS))
PHDOCS=$(HDOCS)

.PHONY : docs
docs : $(PHDOCS) publications.html

publications.html : publications.toml build_pubs.py MENU
	python build_pubs.py

%.html : %.jemdoc MENU
	python jemdoc -o $@ $<

.PHONY : clean
clean :
	-rm -f *.html

# OLD MAKEFILE
#DOCS=index bio publications talks teaching
#
#HDOCS=$(addsuffix .html, $(DOCS))
#PHDOCS=$(addprefix html/, $(HDOCS))
#PHDOCS=$(HDOCS)

#.PHONY : docs
#docs : $(PHDOCS)

#.PHONY : update
#update : $(PHDOCS)
#	@echo -n 'Copying to server...'
#	# insert code for copying to server here.
#	@echo ' done.'
#
##html/%.html : %.jemdoc MENU
#%.html : %.jemdoc MENU
#	jemdoc -o $@ $<
#
#.PHONY : clean
#clean :
#	-rm -f *.html
##	-rm -f html/*.html
