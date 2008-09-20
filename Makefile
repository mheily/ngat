
SOURCES           = $(ngat_SOURCES)
bin_PROGRAMS      = ngat
pkgdata_DATA      = Makefile configure

ngat_SOURCES      = main.c
ngat_CFLAGS       = -g -O2 -Wall -Werror

EXTRA_DIST        = index.html
# FIXME: add t/ to EXTRA_DIST; need to support subdirectories

include Makefile.inc

# Run the unit test suite
#
test:
	cd t ; make

