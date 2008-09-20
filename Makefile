
SOURCES = 		$(newproject_SOURCES)
bin_PROGRAMS = 	newproject
pkgdata_DATA =	configure Makefile.inc
EXTRA_DIST =	index.html
man_MANS =		newproject.1

newproject_SOURCES = main.c

# FIXME: add t/ to EXTRA_DIST; need to support subdirectories

include Makefile.inc

# Run the unit test suite
#
test:
	cd t ; make

edit:
	$(EDITOR) configure* Makefile* index.html *.[ch]
