# __NAME__ — Developer Makefile
#
# Targets:
#   dev            Start the live-reload development server
#   build          Production static build
#   format         Format all Swift sources
#   format-check   Check formatting without writing changes
#   clean          Remove .build and .score/build
#
# Configuration via environment variables:
#   SWIFT          Path to the swift binary (default: swift)
#   SCORE          Path to the score binary (default: score)

SWIFT ?= swift
SCORE ?= score

.DEFAULT_GOAL := dev

# ─── Development ──────────────────────────────────────────────────────────────

.PHONY: dev
dev:
	$(SCORE) dev

# ─── Build ────────────────────────────────────────────────────────────────────

.PHONY: build
build:
	$(SCORE) build

# ─── Format & Lint ────────────────────────────────────────────────────────────

.PHONY: format
format:
	$(SWIFT) format --recursive Sources Package.swift

.PHONY: format-check
format-check:
	$(SWIFT) format lint --recursive Sources Package.swift

# ─── Clean ────────────────────────────────────────────────────────────────────

.PHONY: clean
clean:
	$(SWIFT) package clean
	rm -rf .build .score/build

# ─── Help ─────────────────────────────────────────────────────────────────────

.PHONY: help
help:
	@echo "__NAME__ — available targets:"
	@echo ""
	@echo "  dev             Start dev server with hot-reload"
	@echo "  build           Production static build"
	@echo "  format          Format all Swift sources (swift format)"
	@echo "  format-check    Lint formatting without changes (swift format lint)"
	@echo "  clean           Remove build artifacts"
