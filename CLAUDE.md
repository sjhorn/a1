# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
dart test                        # Run all tests
dart test test/a1_test.dart      # Run a single test file
dart test --name "test name"     # Run tests matching a name
dart analyze                     # Static analysis (uses package:lints/recommended)
dart format .                    # Format all code
```

## Architecture

This is a Dart library for spreadsheet A1 notation parsing and manipulation, published to pub.dev as `a1`. It uses `petitparser` for grammar-based parsing.

### Core Classes (dependency order)

- **A1** (`lib/src/a1.dart`) — Single cell reference (e.g. `B2`). Immutable value object with 0-based column/row integers. Supports parsing, navigation (up/down/left/right/pageUp/pageDown), comparison, and arithmetic operators. Max: 16,384 columns × 1,048,576 rows.

- **A1Partial** (`lib/src/a1_partial.dart`) — Cell reference with optional column/row. Nullable fields represent "all" — `A` means whole column A, `1` means whole row 1, empty string means entire sheet.

- **A1Range** (`lib/src/a1_range.dart`) — Rectangular range between two A1Partial endpoints (e.g. `A1:Z26`, `A:B`, `1:3`). Supports intersection, subtraction, overlay, border extraction, containment checks, and area calculation.

- **A1Reference** (`lib/src/a1_reference.dart`) — External reference with URI/file/worksheet components plus an embedded A1Range. Parses formats like `'C:\path\[file]Sheet'!A1:Z26` and SharePoint URLs.

- **A1RangeSearch** (`lib/src/a1_range_search.dart`) — Generic spatial search map (`MapMixin<A1Range, T>`). Uses a quadtree for O(log n) lookups. Key methods: `valueOf(A1)`, `rangeOf(A1)`, `rangesIn(A1Range)`, and directional cell navigation that respects merged ranges.

### Helpers

- **Quadtree** (`lib/src/helpers/quadtree.dart`) — 2D spatial index for efficient range overlap queries.
- **SimpleCache** (`lib/src/helpers/simple_cache.dart`) — FIFO cache (10K entries) with 10% eviction on overflow.

### Grammar

- **A1Notation** (`lib/src/grammer/a1_notation.dart`) — PetitParser grammar defining the A1 notation syntax.
- **A1Uri** (`lib/src/grammer/a1_uri.dart`) — URI component parsing.

### Key Patterns

- All core types are **immutable value objects** with equality/hashCode.
- String extensions (`.a1`, `.a1Range`, `.a1Ref`) provide convenient parsing from strings.
- A1Partial uses **null to mean "all"** — a null column means the entire column dimension is unbounded.
- The public API is exported from `lib/a1.dart`.
