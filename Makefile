
NAME     ?= wg-reload
VERSION  ?= 1.0
PREFIX   ?= /usr/local
BINDIR   ?= $(PREFIX)/bin
SHAREDIR ?= $(PREFIX)/share/$(NAME)
MANDIR   ?= $(PREFIX)/share/man/man8

install:
	@install -v -d "$(BINDIR)" && install -v -m 0755 wg-reload.sh "$(BINDIR)/wg-reload"
	@install -v -d "$(MANDIR)" && install -v -m 0755 wg-reload.8 "$(MANDIR)/wg-reload.8"

deb:
	export PACKAGE_NAME=$(NAME) \
	&& export PACKAGE_VERSION=$(VERSION) \
	&& export PACKAGE_BINDIR=$(BINDIR:/%=%) \
	&& export PACKAGE_MANDIR=$(MANDIR:/%=%) \
	&& export PACKAGE_SHAREDIR=$(SHAREDIR:/%=%) \
	&& scripts/build_deb.sh

.PHONY: install deb
