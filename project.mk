#		$Id$
#
# Copyright (c) 2007-2008 Mark Heily <mark@heily.com>
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

default: build

include config.mk

# Default values for standard variables
#
CC ?=		cc
LD ?=		ld
INSTALL ?=  /usr/bin/install
PKGDATADIR ?= $(DATADIR)/$(PACKAGE)
CFLAGS ?=   -g -O0 -Wall -Werror

FILES = 	$(SOURCES) $(EXTRA_DIST) $(man_MANS) \
		$(data_DATA) $(pkgdata_DATA) \
		configure config.mk Makefile
MAJOR = 	`echo $(VERSION) | awk -F. '{ $$1 }'`
DISTDIR = 	$(PACKAGE)-$(VERSION)

# Prepend the 'DESTDIR' variable to all installation paths
#
LIBDIR := $(DESTDIR)$(LIBDIR)
BINDIR := $(DESTDIR)$(BINDIR)
SBINDIR := $(DESTDIR)$(SBINDIR)
INCLUDEDIR := $(DESTDIR)$(INCLUDEDIR)
DATADIR := $(DESTDIR)$(DATADIR)
PKGDATADIR := $(DESTDIR)$(PKGDATADIR)
LOCALSTATEDIR := $(DESTDIR)$(LOCALSTATEDIR)
PKGLOCALSTATEDIR := $(DESTDIR)$(PKGLOCALSTATEDIR)
MANDIR := $(DESTDIR)$(MANDIR)

build: config.h subdir-stamp $(lib_LIBRARIES) $(bin_PROGRAMS) $(sbin_PROGRAMS) $(data_DATA) $(pkgdata_DATA)
	@true

subdir-stamp:
	@for subdir in $(SUBDIRS) ; do \
	   cd $$subdir ; \
	   if [ -x ./configure ] ; then echo "Running ./configure in $$subdir.." ; ./configure ; fi ; \
	   make ; \
	done
	@touch subdir-stamp

config.h:
	@./configure

config.var:
	@echo "# Automatically generated -- do not edit" > config.var
	@echo "PACKAGE=\"$(PACKAGE)\"" >> config.var
	@echo "VERSION=\"$(VERSION)\"" >> config.var
	@echo "TEST_SYMBOLS=\"$(TEST_SYMBOLS)\"" >> config.var
	@echo "TEST_HEADERS=\"$(TEST_HEADERS)\"" >> config.var

# Build a program
# 
$(bin_PROGRAMS) $(sbin_PROGRAMS) $(check_PROGRAMS) : $(SOURCES)
	$(CC) -o $@ $(CFLAGS) $($(@)_CFLAGS) -include config.h $($(@)_SOURCES) $(LDADD) $($(@)_LDADD)

# Build a shared library
# 
$(lib_LIBRARIES) : $(SOURCES)
	$(CC) $(CFLAGS) $($(@)_CFLAGS) -fPIC -c \
		$($(@)_SOURCES) $($(@)_LDADD)
	$(LD) -shared -soname=lib$@.so.$(MAJOR) 			\
		$(LDFLAGS) $($(@)_LDFLAGS) -o lib$@.so.$(VERSION) 	\
		`echo $($(@)_SOURCES) | sed 's/\.c/\.o/g'`
	ar rs lib$(@).a *.o

clean:
	rm -f $(bin_PROGRAMS) $(sbin_PROGRAMS) $(lib_LIBRARIES) subdir-stamp *.o 

distclean: clean
	rm -f config.var config.h

check: $(check_PROGRAMS)
	for prog in $(TESTS) ; do ./$$prog ; done

dist: 
	@if [ -d $(DISTDIR) ] ; then \
		cd $(DISTDIR) && rm -f $(FILES) && cd .. && rmdir $(DISTDIR) ; \
	fi
	mkdir $(DISTDIR)
	cp $(FILES) $(DISTDIR)
	tar zcvf $(PACKAGE)-$(VERSION).tar.gz $(DISTDIR)
	cd $(DISTDIR) && rm -f $(FILES)
	rmdir $(DISTDIR)

install: build
	for lib in $(lib_LIBRARIES) ; do                          \
	  library=lib$$lib.so.$(VERSION)			            ; \
	  $(INSTALL) -Ds -m 644 $$library $(LIBDIR)/$$library 	; \
	  ln -s $$library $(LIBDIR)/lib$$lib.so.$(MAJOR)	    ; \
	done
	for bin in $(bin_PROGRAMS) ; do                           \
	  $(INSTALL) -D -m 755 $$bin $(BINDIR)/$$bin		    ; \
	done
	for sbin in $(sbin_PROGRAMS) ; do                         \
	  $(INSTALL) -D -m 755 $$sbin $(SBINDIR)/$$sbin		    ; \
	done
	for hdr in $(include_HEADERS) ; do                        \
	  $(INSTALL) -D -m 644 $$hdr $(INCLUDEDIR)/$$hdr	    ; \
	done
	for man in $(man_MANS) $(dist_man_MANS) ; do	          \
	  section=`echo $$man | sed 's,.*\\.,,'` ; \
	  install -D -m 644 $$man $(MANDIR)/man$$section/$$man ; \
	  gzip -f $(MANDIR)/man$$section/$$man ; \
	done
	for data in $(data_DATA) ; do 				              \
      $(INSTALL) -D -m 644 $$data $(DATADIR)/$$data		    ; \
	done
	for data in $(pkgdata_DATA) ; do 	        			  \
	  $(INSTALL) -D -m 644 $$data $(PKGDATADIR)/$$data	    ; \
	done
	for dir in $(CREATE_DIRS) ; do 	        			  	  \
	  $(INSTALL) -d -m 755 $$dir							; \
	done
	if [ `id -u` -eq '0' ] ; then ldconfig ; fi

uninstall:
	for lib in $(lib_LIBRARIES) ; do                          \
	  library=lib$$lib.so.$(VERSION)			            ; \
	  rm $(LIBDIR)/$$library                                ; \
	  rm $(LIBDIR)/lib$$lib.so.$(MAJOR)	                    ; \
	done
	for bin in $(bin_PROGRAMS) ; do rm $(BINDIR)/$$bin ; done
	for bin in $(sbin_PROGRAMS) ; do rm $(SBINDIR)/$$bin ; done
	for hdr in $(include_HEADERS) ; do rm $(SBINDIR)/$hdr ; done
	for man in $(man_MANS) $(dist_man_MANS); do               \
        section=`echo $$man | awk -F. '{ $$2 }'`		    ; \
        rm $(MANDIR)/man$$section/$$man.gz                  ; \
    done
	for dat in $(data_DATA) ; do rm $(DATADIR)/$$dat ; done
	for dat in $(pkgdata_DATA) ; do rm $(PKGDATADIR)/$$dat ; done
	if [ `id -u` -eq '0' ] ; then ldconfig ; fi

purge: uninstall
	test -d "$(PKGDATADIR)" != "" && rm -rf $(PKGDATADIR)
	test -d "$(PKGLOCALSTATEDIR)" != "" && rm -rf $(PKGLOCALSTATEDIR)
	for dir in $(CREATE_DIRS) ; do rm -rf $$dir || true ; done
# todo -- pkgconfig dir
	
