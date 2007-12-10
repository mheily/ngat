
SOURCES           = $(ngat_SOURCES)
bin_PROGRAMS      = ngat
pkgdata_DATA      = Makefile configure

ngat_SOURCES      = main.c
ngat_CFLAGS       = -g -O2 -Wall -Werror

EXTRA_DIST        = config.mk

# A custom Makefile target

testme:
	rm -rf tmp ; mkdir tmp ; ./configure --prefix=./tmp ; \
	make install && find ./tmp
