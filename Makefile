SHELL:=/bin/bash
ifndef GO
GO:=go
endif

.PHONY: all install deps clean fmt vet lint help

all: mc

mc: *.go
	@$(GO) build

deps:
	git submodule init
	git submodule update

test: mc
	@memcached -p 11289 & echo $$! > test.pids
	@GOPATH=$(CURDIR)/deps $(GO) test -test.short -v; ST=$?; \
	cd $(CURDIR); cat test.pids | xargs kill; rm test.pids
	@exit ${ST}

test-full: mc
	@memcached -p 11289 & echo $$! > test.pids
	@GOPATH=$(CURDIR)/deps $(GO) test -v; ST=$?; \
	cd $(CURDIR); cat test.pids | xargs kill; rm test.pids
	@exit ${ST}

clean:
	@$(GO) clean

fmt:
	@$(GO) fmt

vet:
	@$(GO) vet

lint:
	@command -v golint >/dev/null 2>&1 \
		|| { echo >&2 "The 'golint' tool is required, please install"; exit 1;  }
	@golint

help:
	@echo "Build Targets"
	@echo "   all        - Build mc"
	@echo "   deps       - Git checkout dependencies"
	@echo "   test       - Quick test of mc"
	@echo "   test-full  - Longer test of mc against a real memcached process"
	@echo "   clean      - Remove built sources"
	@echo "   fmt        - Format the source code using 'go fmt'"
	@echo "   vet        - Analyze the source code for potential errors"
	@echo "   lint       - Analyze the source code for style mistakes"
	@echo ""

