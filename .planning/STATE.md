# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-08)

**Core value:** Windows app configs generated declaratively in Nix and auto-synced to the Windows side — reproducible, version-controlled Windows desktop
**Current focus:** Phase 1 - Activation Scaffold

## Current Position

Phase: 1 of 4 (Activation Scaffold)
Plan: 0 of TBD in current phase
Status: Ready to plan
Last activity: 2026-03-08 — Roadmap created, requirements defined, research completed

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: -
- Total execution time: 0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**
- Last 5 plans: -
- Trend: -

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Setup]: Use file copy (not symlinks) — Windows apps cannot follow WSL LX symlinks (komorebi #854)
- [Setup]: Guard all Windows modules on `hostSpec.isWSL` — applies automatically to ocelot and mantis
- [Setup]: Mirror `users/michael/linux/` module pattern for consistency

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 2]: komorebi `applications.json` v2 schema (float/manage rules format in v0.1.40) should be verified during Phase 2 planning before writing
- [Phase 4]: Windows Terminal Fragment path discovery — confirm whether `Fragments/dots/` directory must pre-exist on the Windows side before first Terminal launch

## Session Continuity

Last session: 2026-03-08
Stopped at: Roadmap created — ready to plan Phase 1
Resume file: None
