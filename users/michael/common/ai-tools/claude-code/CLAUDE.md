# Development Partnership

We build production code together. I handle implementation details while you guide architecture and catch complexity early.

## Core Workflow: Research → Plan → Implement → Validate

**Start every feature with:** "Let me research the codebase and create a plan before implementing."

1. **Research** - Understand existing patterns and architecture
2. **Plan** - Propose approach and verify with you
3. **Implement** - Build with tests and error handling
4. **Validate** - ALWAYS run formatters, linters, and tests after implementation

## Available Tools

### Agents

Specialized workers you can explicitly invoke:

- **code-reviewer** - Systematic code review with security analysis
- **debugger** - Scientific debugging methodology
- **security-auditor** - OWASP & infrastructure security scanning
- **refactoring-planner** - Safe, incremental refactoring plans
- **documentation-writer** - Technical writing for all audiences
- **software-engineering-expert** - General implementation & architecture

### Commands

Quick workflows via slash commands:

- `/validate [--fix]` - Run quality checks (lint, format, test, type-check)
- `/commit [--dry-run] [--interactive]` - Create atomic commits following conventions
- `/review` - Comprehensive code review
- `/debug [description]` - Systematic debugging
- `/docs [type] [target]` - Generate documentation
- `/security-audit [scope]` - Security analysis
- `/refactor [target]` - Plan refactoring

### Skills (Auto-Activate)

Context-aware knowledge that loads automatically based on file paths and keywords:

**Web Development**:
- nextjs-15 (App Router, RSC, Server Actions)
- react-patterns (Server Components, Suspense, hooks)
- prisma (Schema design, migrations)
- typescript (Advanced types, strict mode)
- storybook (Component dev, visual testing)

**Infrastructure**:
- docker (Multi-stage builds, security)
- kubernetes (Modern patterns, resource management)
- api-design (REST, GraphQL, tRPC)

**Process**:
- git-workflow (Conventional commits, PR practices)

## Environment Configuration

### GitHub CLI (1Password Integration)

**IMPORTANT:** GitHub CLI is integrated with 1Password shell plugin for secure authentication.

**Always use:**
```bash
op plugin run -- gh <command>
```

**Examples:**
```bash
# Create pull request
op plugin run -- gh pr create --title "..." --body "..."

# View PR
op plugin run -- gh pr view 123

# Create issue
op plugin run -- gh issue create --title "..." --body "..."

# View issues
op plugin run -- gh issue list
```

**Never use:**
```bash
gh pr create   # ❌ Will fail - missing auth
```

This applies to ALL `gh` commands including:
- `gh pr` (pull requests)
- `gh issue` (issues)
- `gh repo` (repository operations)
- `gh workflow` (GitHub Actions)
- `gh api` (GitHub API calls)

## Code Organization

**Keep functions small and focused:**
- If you need comments to explain sections, split into functions
- Group related functionality into clear modules
- Prefer many small files over few large ones

## Architecture Principles

**This is always a feature branch:**
- Delete old code completely - no deprecation needed
- No versioned names (processV2, handleNew, ClientOld)
- No migration code unless explicitly requested
- No "removed code" comments - just delete it

**Prefer explicit over implicit:**
- Clear function names over clever abstractions
- Obvious data flow over hidden magic
- Direct dependencies over service locators

## Maximize Efficiency

**Parallel operations:** Run multiple searches, reads, and greps in single messages
**Multiple agents:** Split complex tasks - one for tests, one for implementation
**Batch similar work:** Group related file edits together

## Web Development Standards

### TypeScript
- **Strict mode always** - Enable all strict type checking
- **No any** - Use unknown and type guards instead
- **Type imports** - Use `import type` for type-only imports
- **Explicit return types** - Document function contracts

### React/Next.js
- **Server Components by default** - Only use 'use client' when necessary
- **Server Actions** for mutations - Type-safe form handling
- **Streaming with Suspense** - Progressive loading UX
- **No useEffect for data fetching** - Use Server Components or SWR/TanStack Query

### Security
- **Validate all inputs** - Use Zod or similar for runtime validation
- **Never trust client data** - Validate on server
- **Environment variables** - Never commit .env files
- **SQL injection** - Use Prisma or prepared statements
- **XSS protection** - Sanitize user content

## Problem Solving

**When stuck:** Stop. The simple solution is usually correct.

**When uncertain:** "Let me ultrathink about this architecture."

**When choosing:** "I see approach A (simple) vs B (flexible). Which do you prefer?"

Your redirects prevent over-engineering. When uncertain about implementation, stop and ask for guidance.

## Testing Strategy

**Match testing approach to code complexity:**
- Complex business logic: Write tests first (TDD)
- Simple CRUD operations: Write code first, then tests
- Critical paths: Add integration tests

**Always keep security in mind:**
- Test authentication and authorization
- Test input validation edge cases
- Test error handling paths

**Performance rule:** Measure before optimizing. No guessing.

## Progress Tracking

- **TodoWrite** for task management
- **Clear naming** in all code
- **Conventional commits** for git history

Focus on maintainable solutions over clever abstractions.

## Workflow Framework Choice

This dotfiles setup is **framework-agnostic**. For project-specific workflows:

- **No framework** - Use simple dev-docs pattern
- **spec-workflow-mcp** - Sequential gating with approval gates
- **BMAD** - Full PM framework with multi-agent workflows
- **Custom** - Build your own

Choose per-project based on team size and complexity.
