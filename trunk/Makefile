PACKAGE=		ngat
VERSION=		0.4

TEST_SYMBOLS =	strlcpy asprintf crypt getspnam
TEST_HEADERS =  event.h regex.h 

CREATE_DIRS =   $(PKGLOCALSTATEDIR)

SOURCES = 		$(newproject_SOURCES)
bin_PROGRAMS = 	newproject
pkgdata_DATA =	configure project.mk
EXTRA_DIST =	index.html
man_MANS =		newproject.1

newproject_SOURCES = main.c

# FIXME: add t/ to EXTRA_DIST; need to support subdirectories

include project.mk

# Run the unit test suite
#
test:
	cd t ; make

edit:
	gvim configure* Makefile* index.html *.[ch]
