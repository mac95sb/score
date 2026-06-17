# Score Framework — Developer Makefile
#
# Targets:
#   build          Build all targets in release configuration
#   build-debug    Build all targets in debug configuration
#   test           Run all test suites
#   format         Format all sources with swift format
#   format-check   Check formatting without writing changes
#   clean          Remove .build directory
#   docs           Build DocC documentation
#   release        Full quality gate: format-check + test + release build
#   ks-build       Build the score CLI into an isolated build path for kitchen-sink
#   ks-dev         Run the kitchen-sink template via score dev (hot-reload)
#
# Configuration via environment variables:
#   SWIFT          Path to the swift binary (default: swift)
#   DOCS_PORT      Starting port for docs-preview (default: 8080)
#   KS_BUILD_PATH  Isolated build dir for ks-dev (default: .build/ks)
#                  Using a separate directory lets ks-dev run alongside docs-preview,
#                  which holds the main .build lock for its entire session.

SWIFT ?= swift
DOCS_PORT ?= 8080
KS_BUILD_PATH ?= .build/ks

.DEFAULT_GOAL := build

# ─── Build ────────────────────────────────────────────────────────────────────

.PHONY: build
build:
	$(SWIFT) build -c release

.PHONY: build-debug
build-debug:
	$(SWIFT) build -c debug

# ─── Test ─────────────────────────────────────────────────────────────────────

.PHONY: test
test:
	$(SWIFT) test --parallel

.PHONY: test-verbose
test-verbose:
	$(SWIFT) test --verbose

# ─── Format & Lint ────────────────────────────────────────────────────────────

.PHONY: format
format:
	$(SWIFT) format --recursive Sources Tests Package.swift

.PHONY: format-check
format-check:
	$(SWIFT) format lint --recursive Sources Tests Package.swift

# ─── Documentation ────────────────────────────────────────────────────────────

.PHONY: docs
docs:
	$(SWIFT) package --allow-writing-to-directory .build/docs generate-documentation \
		--target Score \
		--disable-indexing \
		--transform-for-static-hosting \
		--output-path .build/docs

.PHONY: docs-preview
docs-preview:
	@PORT="$(DOCS_PORT)"; \
	if command -v lsof >/dev/null 2>&1; then \
		while lsof -iTCP:$$PORT -sTCP:LISTEN -Pn >/dev/null 2>&1; do \
			PORT=$$((PORT + 1)); \
		done; \
	fi; \
	echo "Previewing DocC at http://localhost:$$PORT/documentation/score"; \
	echo "Tutorials will be at http://localhost:$$PORT/tutorials/score"; \
	$(SWIFT) package --disable-sandbox preview-documentation --target Score --port $$PORT

# ─── Clean ────────────────────────────────────────────────────────────────────

.PHONY: clean
clean:
	$(SWIFT) package clean
	rm -rf .build

# ─── Release gate ─────────────────────────────────────────────────────────────

.PHONY: release
release: format-check test build
	@echo ""
	@echo "✓ Release gate passed"

# ─── Package utilities ────────────────────────────────────────────────────────

.PHONY: resolve
resolve:
	$(SWIFT) package resolve

.PHONY: update
update:
	$(SWIFT) package update

.PHONY: show-deps
show-deps:
	$(SWIFT) package show-dependencies

.PHONY: reset
reset:
	$(SWIFT) package reset

# ─── Kitchen Sink ─────────────────────────────────────────────────────────────

.PHONY: ks-build
ks-build:
	$(SWIFT) build -c debug --build-path $(KS_BUILD_PATH)

.PHONY: ks-dev
ks-dev: ks-build
	cd Templates/kitchen-sink && ../../$(KS_BUILD_PATH)/debug/score dev

# ─── Help ─────────────────────────────────────────────────────────────────────

.PHONY: help
help:
	@echo "Score Framework — available targets:"
	@echo ""
	@echo "  Build:"
	@echo "    build           Release build (all targets)"
	@echo "    build-debug     Debug build"
	@echo "    clean           Remove .build directory"
	@echo ""
	@echo "  Test:"
	@echo "    test            Run all tests in parallel"
	@echo "    test-verbose    Run tests with verbose output"
	@echo ""
	@echo "  Code quality:"
	@echo "    format          Format all Swift sources (swift format)"
	@echo "    format-check    Lint formatting without writing changes (swift format lint)"
	@echo "    release         Full gate: format-check + test + release build"
	@echo ""
	@echo "  Documentation:"
	@echo "    docs            Build DocC static site to .build/docs"
	@echo "    docs-preview    Preview DocC in browser"
	@echo ""
	@echo "  Kitchen Sink:"
	@echo "    ks-build        Build score CLI into .build/ks (isolated from docs-preview)"
	@echo "    ks-dev          score dev with hot-reload (uses .build/ks, runs alongside docs-preview)"
	@echo ""
	@echo "  Maintenance:"
	@echo "    update          Update all Swift package dependencies"
	@echo "    resolve         Resolve/re-pin package dependencies"
	@echo "    show-deps       Print dependency tree"
	@echo "    reset           Reset package caches"
