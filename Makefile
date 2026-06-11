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
#   update-sqlite  Download and embed the latest SQLite amalgamation
#   release        Full quality gate: format-check + test + release build
#
# Configuration via environment variables:
#   SWIFT          Path to the swift binary (default: swift)

SWIFT ?= swift

SQLITE_VERSION    ?= 3.53.2
SQLITE_YEAR       ?= 2025
SQLITE_VER_NODOT  ?= $(shell echo "$(SQLITE_VERSION)" | tr -d '.')
SQLITE_URL        ?= https://www.sqlite.org/$(SQLITE_YEAR)/sqlite-amalgamation-$(SQLITE_VER_NODOT)00.zip

CSQLITE_DIR  = Sources/CSQLite
CSQLITE_INC  = $(CSQLITE_DIR)/include

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
	$(SWIFT) format --recursive Sources Tests

.PHONY: format-check
format-check:
	$(SWIFT) format lint --recursive Sources Tests

# ─── Documentation ────────────────────────────────────────────────────────────

.PHONY: docs
docs:
	$(SWIFT) package generate-documentation \
		--target Score \
		--disable-indexing \
		--transform-for-static-hosting \
		--output-path .build/docs

.PHONY: docs-preview
docs-preview:
	$(SWIFT) package preview-documentation --target Score

# ─── SQLite Update ────────────────────────────────────────────────────────────

.PHONY: update-sqlite
update-sqlite:
	@echo "→ Fetching SQLite amalgamation $(SQLITE_VERSION)…"
	@mkdir -p /tmp/sqlite-update
	@if curl -fsSL "$(SQLITE_URL)" -o /tmp/sqlite-update/sqlite.zip; then \
		unzip -o /tmp/sqlite-update/sqlite.zip -d /tmp/sqlite-update/; \
		ADIR=$$(find /tmp/sqlite-update -maxdepth 1 -name "sqlite-amalgamation-*" -type d | head -1); \
		if [ -d "$$ADIR" ]; then \
			cp "$$ADIR/sqlite3.c" $(CSQLITE_DIR)/sqlite3.c; \
			cp "$$ADIR/sqlite3.h" $(CSQLITE_INC)/sqlite3.h; \
			echo "→ Updated to SQLite $$(grep 'SQLITE_VERSION ' $(CSQLITE_INC)/sqlite3.h | head -1)"; \
		else \
			echo "ERROR: Could not find amalgamation directory in zip"; exit 1; \
		fi; \
		rm -rf /tmp/sqlite-update; \
	else \
		echo ""; \
		echo "sqlite.org is unreachable. Fetching from rusqlite mirror on GitHub…"; \
		BASE=https://raw.githubusercontent.com/rusqlite/rusqlite/master/libsqlite3-sys/sqlite3; \
		curl -fsSL "$$BASE/sqlite3.c" -o $(CSQLITE_DIR)/sqlite3.c; \
		curl -fsSL "$$BASE/sqlite3.h" -o $(CSQLITE_INC)/sqlite3.h; \
		echo "→ Updated to SQLite $$(grep 'SQLITE_VERSION ' $(CSQLITE_INC)/sqlite3.h | head -1)"; \
		rm -rf /tmp/sqlite-update; \
	fi

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
	@echo "  Maintenance:"
	@echo "    update-sqlite   Embed latest SQLite amalgamation"
	@echo "    update          Update all Swift package dependencies"
	@echo "    resolve         Resolve/re-pin package dependencies"
	@echo "    show-deps       Print dependency tree"
	@echo "    reset           Reset package caches"
