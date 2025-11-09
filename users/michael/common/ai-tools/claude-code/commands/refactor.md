---
allowed-tools: Read, Grep, Bash
argument-hint: "[target]"
description: Refactoring planning using refactoring-planner agent
---

# Refactor Command

Invokes the refactoring-planner agent for safe, incremental refactoring.

## Usage

```bash
/refactor src/auth.ts              # Refactor specific file
/refactor src/components/user      # Refactor directory
/refactor "extract user logic"     # Describe refactoring goal
```

## Process

1. **Analyze current state** - Understand pain points and structure
2. **Design target** - Sketch ideal organization
3. **Create migration plan** - Incremental, safe steps
4. **Invoke refactoring-planner agent** with context
5. **Present plan** with phases, risks, and rollback steps

## What You'll Get

A detailed refactoring plan:

```markdown
# Refactoring Plan: [Name]

## Problem Statement
[Current pain points]

## Target Design
[Improved structure]

## Migration Steps
Step 1: [Description]
- Changes: [...]
- Files affected: [...]
- Tests needed: [...]
- Risk: Low/Medium/High
- Time: [hours]
- Rollback: [...]

[... more steps ...]

## Risks & Mitigations
[What could go wrong, how to handle]

## Success Metrics
[How to measure improvement]
```

## Refactoring Patterns

- Extract Function
- Extract Module
- Introduce Parameter Object
- Replace Conditional with Polymorphism
- Extract Interface

## Principles

- **Working code at every step** - Never break main branch
- **Small commits** - Each step independently reviewable
- **Test coverage first** - Add tests before risky refactoring
- **Measure improvement** - Define metrics upfront

## Integration with Skills

Uses framework-specific patterns:
- React → Component composition, custom hooks
- TypeScript → Advanced type patterns
- Next.js → App Router organization
- Prisma → Repository pattern for data access
