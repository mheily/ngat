/*		$Id$		*/

/*
 * Copyright (c) 2007 Mark Heily <devel@heily.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <err.h>
#include <unistd.h>
#include <sys/param.h>

char * readvar(const char *, const char *);

void
usage(void)
{
	puts("usage:\n  ngat init\n");
	exit(1);
}

char *
readvar(const char * prompt, const char *_default)
{
    char buf[1024];
    char *p;

    memset(buf, 0, sizeof(buf));
    if (_default != NULL) {
        printf("%s [%s]: ", prompt, _default);
    } else {
        printf("%s: ", prompt);
    }
    if ((fgets(buf, sizeof(buf), stdin)) == NULL)
        err(1, "fgets(): invalid response");
    if ((p = strchr(buf, '\n')) != NULL)
        *p = '\0';
    if (buf[0] == '\0')
        return strdup(_default);
    else
        return strdup(buf);
}

int
main(int argc, char **argv)
{
    char buf[4096];
    FILE *f;
    struct {
        char *pr_name,
             *pr_version;
    } proj;

	if (argc > 1) 
        errx(1, "ERROR: This program does not accept command line options.");

    if (access("configure", F_OK) == 0 
            || access("project.mk", F_OK) == 0 
            || access("Makefile", F_OK) == 0) 
        errx(1, "ERROR: A project already exists in this directory.");

    proj.pr_name = readvar("Enter the name of the project", NULL);
    proj.pr_version = readvar("Enter the starting version number", "0.1");

    /* FIXME: check return value of commands */

    /* Copy the 'configure' file */
    snprintf(buf, sizeof(buf) - 1, "/bin/cp %s/configure .",  PKGDATADIR); 
    system(buf); 

    /* Copy the 'project.mk' file */
    snprintf(buf, sizeof(buf) - 1, "/bin/cp %s/project.mk .",  PKGDATADIR); 
    system(buf);

    /* Create the Makefile */
    if ((f = fopen("Makefile", "w")) == NULL)
        err(1, "fopen(2) of Makefile");
    fprintf(f, "PACKAGE=%s\n", proj.pr_name);
    fprintf(f, "VERSION=%s\n", proj.pr_version);
    fprintf(f, "# All source code files in the project\nSOURCES=\n\n");
    fprintf(f, "# Programs to install under /usr/bin\n# bin_PROGRAMS=\n\n");
    fprintf(f, "# Programs to install under /usr/sbin\n# sbin_PROGRAMS=\n\n");
    fprintf(f, "# Datafiles to install under /usr/share\n# data_DATA=\n\n");
    fprintf(f, "# Datafiles to install under /usr/share/$(PACKAGE)\n# pkgdata_DATA=\n\n");
    fprintf(f, "# Symbols in the C library to test for\n# TEST_SYMBOLS=\n\n");
    fprintf(f, "# Header files in /usr/include to test for\n# TEST_HEADERS=\n\n");
    fprintf(f, "\n\ninclude project.mk\n\n# Add any custom targets here\n");
    fclose(f);

	exit(EXIT_SUCCESS);
}
