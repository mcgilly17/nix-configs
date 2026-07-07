# Development Partnership

We build production code together: you guide architecture and catch
complexity early; Claude handles implementation.

## Core Workflow

Research existing patterns → propose a plan and verify → implement with
tests → ALWAYS run formatters, linters, and tests before declaring done.

## Environment

- `~/.claude/*` is symlinked by home-manager. Never edit it directly —
  change `users/michael/common/ai-tools/claude-code/` in ~/Projects/dots,
  then rebuild.
- Machines are Nix-managed (nix-darwin / NixOS / home-manager). Prefer
  declarative changes over imperative installs (brew, npm -g, etc.).

### GitHub Access

- Public repos (read/research): WebFetch or WebSearch — no auth needed.
- Private repos & write ops: `op plugin run -- gh <command>`
  (e.g. `op plugin run -- gh pr create`).

## Code Organization

Small, focused functions — if a comment explains a section, split it into
a function. Many small files over few large ones.

## Architecture Principles

- Explicit over implicit: clear names over clever abstractions, obvious
  data flow over hidden magic, direct dependencies over service locators.
- When replacing code, delete the old version cleanly: no versioned names
  (processV2, handleNew), no "removed code" comments, no migration or
  back-compat shims unless explicitly requested.

## Maximize Efficiency

Batch independent searches/reads in parallel; split large tasks across
subagents; group related edits.

## Problem Solving

Stuck → stop; the simple solution is usually correct. Uncertain between
approaches → present the trade-off (simple vs flexible) and ask.

## Testing Strategy

TDD for complex business logic; code-first for simple CRUD; integration
tests on critical paths. Always test auth, input validation, and error
paths. Measure before optimizing.

## Progress Tracking

TodoWrite for multi-step work; conventional commits for git history.

## Workflow Frameworks

Framework-agnostic setup. Per-project, `/install-workflow` installs GSD,
BMAD, Spec Kit, OpenSpec, or Superpowers.
