
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man

install:
	@install -v -d "$(BINDIR)" && install -v -m 0755 wg-reload.sh "$(BINDIR)/wg-reload"
	@install -v -d "$(MANDIR)/man8" && install -v -m 0755 wg-reload.8 "$(MANDIR)/man8/wg-reload.8"

.PHONY: install
