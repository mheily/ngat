
SOURCES           = $(ngat_SOURCES)
bin_PROGRAMS      = ngat
pkgdata_DATA      = Makefile configure

ngat_SOURCES      = main.c
ngat_CFLAGS       = -g -O2 -Wall -Werror

EXTRA_DIST        = config.mk t/

# Run the unit test suite
#
test:
	cd t ; make
