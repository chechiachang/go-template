SHELL := /bin/sh

GOLANGCI_LINT_VERSION ?= v2.7.2
GOBIN ?= $(shell go env GOBIN)
ifeq ($(GOBIN),)
GOBIN := $(shell go env GOPATH)/bin
endif
GOLANGCI_LINT_BIN ?= $(GOBIN)/golangci-lint

.PHONY: fmt vet lint lint-install ensure-golangci-lint test tidy check coverage all

fmt:
	gofmt -w .

vet:
	go vet ./...

lint: ensure-golangci-lint
	@echo "Running golangci-lint $(GOLANGCI_LINT_VERSION)"
	$(GOLANGCI_LINT_BIN) run

lint-install: ensure-golangci-lint

ensure-golangci-lint:
	@installed=""; \
	if [ -x $(GOLANGCI_LINT_BIN) ]; then \
		installed=$$($(GOLANGCI_LINT_BIN) --version 2>/dev/null | awk 'NR==1{print $$4}'); \
	fi; \
	if [ "$$installed" != "$(GOLANGCI_LINT_VERSION)" ]; then \
		echo "Installing golangci-lint $(GOLANGCI_LINT_VERSION) to $(GOBIN) (was $$installed)"; \
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(GOBIN) $(GOLANGCI_LINT_VERSION); \
	else \
		echo "golangci-lint $(GOLANGCI_LINT_VERSION) already installed at $(GOLANGCI_LINT_BIN)"; \
	fi

test:
	go test ./...

tidy:
	go mod tidy

check: fmt vet lint test

coverage:
	go test -coverprofile=cover.out ./...
	go tool cover -func=cover.out | tee cover.txt
	@awk '/total:/ {if ($$3+0 < 85) {print "Coverage below 85%"; exit 1}}' cover.txt

all: check
