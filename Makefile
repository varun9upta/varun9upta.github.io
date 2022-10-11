DOCS=index bio publications talks teaching

HDOCS=$(addsuffix .html, $(DOCS))
#PHDOCS=$(addprefix html/, $(HDOCS))
PHDOCS=$(HDOCS)

.PHONY : docs
docs : $(PHDOCS)

.PHONY : update
update : $(PHDOCS)
	@echo -n 'Copying to server...'
	# insert code for copying to server here.
	@echo ' done.'

#html/%.html : %.jemdoc MENU
%.html : %.jemdoc MENU
	jemdoc -o $@ $<

.PHONY : clean
clean :
	-rm -f *.html
#	-rm -f html/*.html
