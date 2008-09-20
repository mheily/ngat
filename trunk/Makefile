
SOURCES = 		$(ngat_SOURCES)
bin_PROGRAMS = 	newproject
pkgdata_DATA =	configure Makefile.inc
EXTRA_DIST =	index.html
man_MANS =		newproject.1

newproject_SOURCES = 	main.c
newproject_CFLAGS = 	-g -O2 -Wall -Werror


# FIXME: add t/ to EXTRA_DIST; need to support subdirectories

include Makefile.inc

# Run the unit test suite
#
test:
	cd t ; make

edit:
	$(EDITOR) configure* Makefile* index.html *.[ch]
