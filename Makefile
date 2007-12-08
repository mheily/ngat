#
# Copyright (c) 2007 Mark Heily <mark@heily.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

# Differences btwn Automake and mconf:
#   - man_MANS are considered source and included in `make dist'
#   - Use CFLAGS instead of AM_CFLAGS

default: build

config.mk:
	./configure

include config.mk

# Default values for standard variables
#
CC ?=		cc
LD ?=		ld

MANIFEST =	config.lst
FILES = 	$(EXTRA_DIST) $(dist_man_MANS) $(man_MANS) \
		$(data_DATA) $(pkgdata_DATA) \
		configure configure.in Makefile.am Makefile
MAJOR = 	`echo $(VERSION) | awk -F. '{ $$1 }'`
LDFLAGS = 	-shared -soname=lib$@.so.$(MAJOR)
DISTDIR = 	$(PACKAGE)-$(VERSION)

# Prepend the 'DESTDIR' variable to all installation paths
#
LIBDIR := $(DESTDIR)$(LIBDIR)
BINDIR := $(DESTDIR)$(BINDIR)
SBINDIR := $(DESTDIR)$(SBINDIR)
INCLUDEDIR := $(DESTDIR)$(INCLUDEDIR)
DATADIR := $(DESTDIR)$(DATADIR)
PKGDATADIR := $(DESTDIR)$(PKGDATADIR)
MANDIR := $(DESTDIR)$(MANDIR)

include Makefile.am

build: $(lib_LIBRARIES) $(bin_PROGRAMS) $(sbin_PROGRAMS) $(data_DATA) $(pkgdata_DATA)
	@true

$(bin_PROGRAMS) $(sbin_PROGRAMS) $(check_PROGRAMS) : 
	$(CC) -DHAVE_CONFIG_H $(CFLAGS) $($(@)_CFLAGS) -o $@ $($(@)_SOURCES)
	@echo $($(@)_SOURCES) >> $(MANIFEST)

$(lib_LIBRARIES) : 
	$(CC) -DHAVE_CONFIG_H $(CFLAGS) $($(@)_CFLAGS) -fPIC -c $($(@)_SOURCES)
	$(LD) $(LDFLAGS) $($(@)_LDFLAGS) -o lib$@.so.$(VERSION)	\
		`echo $($(@)_SOURCES) | sed 's/\.c/\.o/g'`
	ar rs lib$(@).a *.o
	@echo $($(@)_SOURCES) >> $(MANIFEST)

clean:
	rm -f $(bin_PROGRAMS) $(sbin_PROGRAMS) *.o $(MANIFEST)

distclean: clean
	rm -f config.mk config.sym config.h

check: $(check_PROGRAMS)
	for prog in $(TESTS) ; do $$prog ; done

dist: $(MANIFEST)
	if [ -d $(DISTDIR) ] ; then \
		cd $(DISTDIR) && rm -f $(FILES) && cd .. && rmdir $(DISTDIR) ; \
	fi
	mkdir $(DISTDIR)
	cp $(FILES) $(DISTDIR)
	tar zcvf $(PACKAGE)-$(VERSION).tar.gz $(DISTDIR)
	cd $(DISTDIR) && rm -f $(FILES)
	rmdir $(DISTDIR)

install: build
	for lib in $(lib_LIBRARIES) 				; \
	do 							  \
	  library=lib$$lib.so.$(VERSION)			; \
	  install -Ds -m 644 $$library $(LIBDIR)/$$library 	; \
	  ln -s $$library $(LIBDIR)/lib$$lib.so.$(MAJOR)	; \
	done
	for bin in $(bin_PROGRAMS) 				; \
	  do install -D -m 755 $$bin $(BINDIR)/$$bin		; \
	done
	for sbin in $(sbin_PROGRAMS) 				; \
	  do install -D -m 755 $$sbin $(SBINDIR)/$$sbin		; \
	done
	for hdr in $(include_HEADERS) 				; \
	  do install -D -m 644 $$hdr $(INCLUDEDIR)/$$hdr	; \
	done
	for man in $(man_MANS) 					; \
	do 							  \
	  section=`echo $$man | awk -F. '{ $$2 }'`		; \
	  install -D -m 644 $$man $(MANDIR)/man$$section/$$man	; \
	  gzip $(MANDIR)/man$$section/$$man			; \
	done
	for data in $(data_DATA) 				; \
	  do install -D -m 644 $$data $(DATADIR)/$$data		; \
	done
	for data in $(pkgdata_DATA) 				; \
	  do install -D -m 644 $$data $(PKGDATADIR)/$$data	; \
	done
	if [ `id -u` -eq '0' ] ; then ldconfig ; fi

$(MANIFEST) : build
