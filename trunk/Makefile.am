pkgdata_DATA =	Makefile configure
EXTRA_DIST = config.mk

testme:
	rm -rf tmp ; mkdir tmp ; ./configure --prefix=./tmp ; make install && find ./tmp
