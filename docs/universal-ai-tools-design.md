# Universal AI Tools - Design Document

**Created**: 2025-01-08
**Status**: Design Phase
**Target**: Universal agents, skills, and commands for Claude Code

---

## Overview

Create a comprehensive, universal AI development toolkit for Claude Code that works across all projects, regardless of workflow framework choice (BMAD, spec-workflow-mcp, etc.). These tools provide consistent code quality, debugging support, and development best practices while remaining framework-agnostic.

## Goals

1. **Eliminate AI amnesia** - Persistent conventions and patterns across sessions
2. **Prevent repeated mistakes** - Enforce best practices automatically
3. **Accelerate web development** - Modern 2025 patterns for React, Next.js, Node.js, Prisma
4. **Framework agnostic** - Works with or without BMAD, spec-workflow-mcp, etc.
5. **Nix-native** - Fully integrated with home-manager, declarative, reproducible

## Architecture Decisions

### 1. Organization: Flat Structure

```
users/michael/common/ai-tools/claude-code/
├── default.nix              # Auto-discovers and deploys .md files
├── settings.json            # Claude Code settings
├── skill-rules.json         # Auto-activation triggers
├── CLAUDE.md               # Universal development guide
├── agents/
│   ├── code-reviewer.md
│   ├── debugger.md
│   ├── security-auditor.md
│   ├── refactoring-planner.md
│   ├── documentation-writer.md
│   └── software-engineering-expert.md
├── commands/
│   ├── review.md
│   ├── debug.md
│   ├── docs.md
│   ├── security-audit.md
│   ├── refactor.md
│   └── validate.md
└── skills/
    ├── nextjs-15/
    │   ├── SKILL.md         # <500 lines overview
    │   └── resources/       # Detailed patterns
    ├── prisma/
    ├── react-patterns/
    ├── typescript/
    ├── storybook/
    ├── docker/
    ├── kubernetes/
    ├── git-workflow/
    └── api-design/
```

**Rationale**: Flat structure is intuitive, easy to navigate, and simple to discover tools.

### 2. Implementation: Veraticus Pattern

**Markdown files with auto-discovery** (not Nix attrsets)

**Benefits**:
- Lower friction for creating new agents/skills/commands
- Just drop `.md` file and rebuild - no explicit registration needed
- Easier to iterate and edit (markdown vs Nix multi-line strings)
- Portable - can share with non-Nix users
- Cleaner git diffs

**Pattern**:
```nix
# default.nix discovers all .md files in subdirectories
# Copies to ~/.claude/{agents,commands,skills}/
# Fully declarative through home-manager
```

**Inspired by**: `github.com/Veraticus/nix-config/tree/main/home-manager/claude-code`

### 3. Scope: Universal + Web Stack

**Universal tools** (work in any project):
- Code review
- Debugging
- Documentation
- Security auditing
- Refactoring
- Git workflow

**Web stack tools** (2025 best practices):
- Next.js 15+ (App Router, RSC, Server Actions)
- React patterns (Server Components, Suspense, modern hooks)
- Prisma (schema design, migrations, relations)
- Storybook (component development, visual testing)
- TypeScript (strict mode, advanced patterns)
- Docker (multi-stage builds, security)
- Kubernetes (modern patterns, not deprecated APIs)
- API design (REST, GraphQL, tRPC)

**Philosophy**: Generic patterns with modern best practices, not project-specific opinions.

### 4. Skills vs Agents Architecture

**Skills** = Passive knowledge that auto-loads
- Reference documentation (patterns, conventions, best practices)
- Auto-activate based on context (file paths, keywords)
- Single source of truth for framework knowledge
- Compose together (Next.js + React + TypeScript all load at once)

**Agents** = Active workers that DO things
- Perform specific tasks (review, debug, document)
- Use whatever skills are currently loaded
- Specialized roles, informed by context
- Explicitly invoked (via commands or Task tool)

**Example flow**:
1. Editing `app/components/UserProfile.tsx`
2. Skills auto-load: `nextjs-15`, `react-patterns`, `typescript`, `storybook`
3. Run `/review`
4. `code-reviewer` agent uses all loaded skills for context-aware review
5. Get Next.js + React + TypeScript + Storybook aware feedback

**Benefits**:
- No duplication (Next.js knowledge in ONE place)
- Maintainable (update skill once, all agents benefit)
- Composable (skills combine naturally)
- Scalable (add new skill without touching agents)

### 5. Auto-Activation: Universal Rules in Dotfiles

**File**: `skill-rules.json` lives in dotfiles, deployed globally

**Trigger types**:
1. **Keywords** in user prompts
2. **File paths** (glob patterns)
3. **Content patterns** (regex in files)
4. **Commands** being used

**Example**:
```json
{
  "skills": [
    {
      "name": "nextjs-15",
      "triggers": {
        "keywords": ["next.js", "app router", "server component"],
        "filePaths": ["**/app/**/*.tsx", "**/app/**/*.ts"],
        "contentPatterns": ["'use client'", "'use server'"]
      }
    },
    {
      "name": "prisma",
      "triggers": {
        "keywords": ["prisma", "schema", "migration"],
        "filePaths": ["**/prisma/**/*.prisma", "**/prisma/**/*.ts"],
        "contentPatterns": ["model ", "@prisma/client"]
      }
    }
  ]
}
```

### 6. Nix Module Structure: Consolidate Under ai-tools/

**Current**: `users/michael/common/core/claude-code.nix` (settings only)

**New structure**:
```
users/michael/common/
├── core/
│   └── (other core tools)
└── ai-tools/
    └── claude-code/
        ├── default.nix          # Main module
        ├── settings.json        # Claude settings
        ├── skill-rules.json     # Auto-activation
        ├── CLAUDE.md           # Development guide
        ├── agents/
        ├── commands/
        └── skills/
```

**Migration**: Move `core/claude-code.nix` → `ai-tools/claude-code/`, consolidate everything AI-related.

### 7. Superpowers Plugin: Remove from Global, Extract Patterns

**Decision**: Remove superpowers from global dotfiles
- Superpowers is workflow methodology (BMAD-like)
- Should be project-specific choice
- Not universal tooling

**Extract valuable patterns**:

| Superpowers Skill | Extract Into | Our Implementation |
|-------------------|--------------|-------------------|
| systematic-debugging | debugger agent | 4-phase investigation (reproduce → gather → hypothesize → test → fix) |
| verification-before-completion | validate command + all agents | Never claim done without evidence |
| test-driven-development | TDD guidance in skills | Red-Green-Refactor workflow |
| defense-in-depth | security-auditor + code-reviewer | Validate at multiple layers |
| code-reviewer | code-reviewer agent | Review against specs, devil's advocate |
| root-cause-tracing | debugger agent | Trace errors backward through call stack |

**Rewrite in our style**: Take concepts, not copy content. Adapt to our architecture.

### 8. Stack Specificity: Generic with 2025 Best Practices

**Not opinionated about**:
- Specific libraries (any state manager, any API library)
- Project structure (where files live)
- Build tools (Vite vs webpack)

**Opinionated about**:
- Modern patterns (2025 best practices)
- Security (current standards)
- Performance (Core Web Vitals, optimization)
- Accessibility (WCAG compliance)
- Testing (modern tools: Vitest, Playwright)

**Examples**:
- React: Server Components, Suspense (not class components)
- Node: ESM modules, async/await (not callbacks)
- Docker: Multi-stage builds, non-root users (not legacy patterns)
- K8s: Current APIs (not deprecated v1beta1)

---

## Component Specifications

### Agents (6 core + expansion)

**Core Universal Agents**:

1. **code-reviewer.md**
   - Systematic code review methodology
   - Reviews: correctness, quality, security, architecture fit
   - Output: strengths, questions, concerns (critical/moderate/minor), suggestions
   - Incorporates: superpowers code-reviewer + defense-in-depth patterns

2. **debugger.md**
   - Systematic debugging using scientific method
   - Phases: reproduction → data gathering → hypothesis generation → testing → fix
   - Incorporates: superpowers systematic-debugging + root-cause-tracing

3. **security-auditor.md**
   - OWASP Top 10 scanning
   - Code-level security (input validation, auth, data protection)
   - Infrastructure security (containers, network, secrets)
   - Dependency scanning (CVEs, licenses)
   - Incorporates: superpowers defense-in-depth patterns

4. **refactoring-planner.md**
   - Creates safe, incremental refactoring plans
   - Analysis → target design → migration strategy → implementation steps
   - Each step leaves code working
   - Ensures test coverage before refactoring

5. **documentation-writer.md**
   - Technical documentation (README, API docs, architecture, code comments)
   - Quality standards: max line limits, readability scores, freshness checks
   - Context-aware: adjusts style for audience

6. **software-engineering-expert.md**
   - General implementation and architecture decisions
   - Uses loaded skills for framework-specific guidance
   - Handles tasks beyond specialized agents

**Future expansion**: Can add more specialized agents as needed (performance-optimizer, test-architect, etc.)

### Skills (9 core domains)

**Progressive disclosure pattern**: Main SKILL.md <500 lines, detailed resources in subdirectories

1. **nextjs-15/**
   - App Router patterns
   - Server vs Client Components
   - Server Actions
   - Routing and layouts
   - Data fetching
   - Performance optimization
   - **Triggers**: `**/app/**/*.tsx`, keywords: "next.js", "app router"

2. **prisma/**
   - Schema design patterns
   - Relation patterns (one-to-many, many-to-many)
   - Migration workflows
   - Query optimization
   - Seeding and testing
   - **Triggers**: `**/prisma/**/*.prisma`, keywords: "prisma", "migration"

3. **react-patterns/**
   - Modern hooks (useState, useEffect, useCallback, useMemo)
   - Server Components vs Client Components
   - Suspense and Error Boundaries
   - Performance optimization
   - Testing with RTL
   - **Triggers**: `**/*.tsx` files, keywords: "react", "component", "hook"

4. **typescript/**
   - Advanced types (generics, utility types, branded types)
   - Strict mode patterns
   - Type narrowing
   - Module patterns
   - **Triggers**: `**/*.ts`, `**/*.tsx`, keywords: "typescript", "type"

5. **storybook/**
   - Story writing patterns
   - Args and controls
   - Component documentation
   - Interaction testing
   - Visual regression testing
   - **Triggers**: `**/*.stories.tsx`, keywords: "storybook", "story"

6. **docker/**
   - Multi-stage builds
   - Security patterns (non-root user, minimal images)
   - Layer optimization
   - .dockerignore patterns
   - **Triggers**: `**/Dockerfile*`, keywords: "docker", "container"

7. **kubernetes/**
   - Deployment patterns
   - Service configuration
   - ConfigMaps and Secrets
   - Resource limits and health checks
   - Security (RBAC, NetworkPolicies)
   - **Triggers**: `**/k8s/**/*.yaml`, keywords: "kubernetes", "k8s"

8. **git-workflow/**
   - Branch naming conventions
   - Conventional commits
   - PR best practices (size limits, descriptions)
   - Common workflows
   - **Triggers**: git commands, keywords: "commit", "pr", "branch"

9. **api-design/**
   - REST patterns
   - GraphQL patterns
   - tRPC patterns
   - Versioning strategies
   - Error handling
   - **Triggers**: `**/routes/**`, `**/api/**`, keywords: "api", "endpoint"

### Commands (6 core workflows)

Commands invoke agents with specific workflows:

1. **/review** - Comprehensive code review
   - Invokes: code-reviewer agent
   - Uses: all loaded skills
   - Validates: correctness, quality, security, architecture

2. **/debug [description]** - Systematic debugging
   - Invokes: debugger agent
   - Workflow: reproduce → gather → hypothesize → test → fix

3. **/docs [type] [target]** - Generate documentation
   - Invokes: documentation-writer agent
   - Types: README, API, architecture, code comments

4. **/security-audit [scope]** - Security analysis
   - Invokes: security-auditor agent
   - Scans: code, infrastructure, dependencies

5. **/refactor [target]** - Plan refactoring
   - Invokes: refactoring-planner agent
   - Creates: incremental, safe migration plan

6. **/validate [--fix]** - Quality validation
   - Runs all quality checks
   - Linting, formatting, type checking, tests, security
   - Auto-detects project type (npm, cargo, go, nix)
   - Incorporates: superpowers verification-before-completion pattern

---

## Implementation Approach

### Phase 1: Foundation
1. Create directory structure under `users/michael/common/ai-tools/claude-code/`
2. Build `default.nix` with auto-discovery (inspired by Veraticus pattern)
3. Create `CLAUDE.md` with universal development guide
4. Set up `skill-rules.json` with auto-activation triggers

### Phase 2: Core Agents
1. code-reviewer (extract best from superpowers code-reviewer)
2. debugger (extract from systematic-debugging + root-cause-tracing)
3. documentation-writer
4. security-auditor (incorporate defense-in-depth)
5. refactoring-planner
6. software-engineering-expert

### Phase 3: Web Stack Skills
1. nextjs-15
2. prisma
3. react-patterns
4. typescript
5. storybook

### Phase 4: Infrastructure Skills
1. docker
2. kubernetes
3. git-workflow
4. api-design

### Phase 5: Commands
1. /review
2. /debug
3. /docs
4. /security-audit
5. /refactor
6. /validate (incorporate verification-before-completion)

### Phase 6: Integration
1. Update home-manager configuration
2. Remove superpowers from global (move to project-specific)
3. Test auto-activation triggers
4. Validate skills load correctly
5. Iterate based on real usage

---

## File Structure Detail

```
users/michael/common/ai-tools/claude-code/
├── default.nix                  # Home-manager module
│   # - Auto-discovers .md files in agents/, commands/, skills/
│   # - Copies to ~/.claude/
│   # - Sets up symlinks
│   # - Activation hooks for permissions
│
├── settings.json                # Claude Code settings
│   # - Permissions (allow/ask/deny)
│   # - Statusline configuration
│   # - MCP server configs (if any)
│
├── skill-rules.json             # Auto-activation rules
│   # - Trigger patterns for each skill
│   # - Keywords, file paths, content patterns
│
├── CLAUDE.md                    # Universal development guide
│   # - Scale-adaptive planning (Quick/Standard/Major)
│   # - Development decision framework
│   # - Links to skills and agents
│
├── agents/
│   ├── code-reviewer.md
│   ├── debugger.md
│   ├── security-auditor.md
│   ├── refactoring-planner.md
│   ├── documentation-writer.md
│   └── software-engineering-expert.md
│
├── commands/
│   ├── review.md
│   ├── debug.md
│   ├── docs.md
│   ├── security-audit.md
│   ├── refactor.md
│   └── validate.md
│
└── skills/
    ├── nextjs-15/
    │   ├── SKILL.md             # <500 lines
    │   └── resources/
    │       ├── app-router.md
    │       ├── server-components.md
    │       ├── server-actions.md
    │       └── data-fetching.md
    │
    ├── prisma/
    │   ├── SKILL.md
    │   └── resources/
    │       ├── schema-design.md
    │       ├── relations.md
    │       ├── migrations.md
    │       └── optimization.md
    │
    ├── react-patterns/
    │   ├── SKILL.md
    │   └── resources/
    │       ├── hooks.md
    │       ├── server-client.md
    │       ├── suspense.md
    │       └── testing.md
    │
    ├── typescript/
    │   ├── SKILL.md
    │   └── resources/
    │
    ├── storybook/
    │   ├── SKILL.md
    │   └── resources/
    │
    ├── docker/
    │   ├── SKILL.md
    │   └── resources/
    │
    ├── kubernetes/
    │   ├── SKILL.md
    │   └── resources/
    │
    ├── git-workflow/
    │   ├── SKILL.md
    │   └── resources/
    │
    └── api-design/
        ├── SKILL.md
        └── resources/
```

---

## Success Metrics

1. **AI remembers conventions** - No need to re-explain "use op plugin, check tsx first"
2. **Automatic enforcement** - Skills auto-activate, provide right context
3. **Consistent quality** - Code reviews catch issues before merge
4. **Faster debugging** - Systematic process finds root causes
5. **Better documentation** - Standards enforced, templates available
6. **Reduced iterations** - First pass is higher quality

---

## Design Validation

**Proven patterns from research**:
- ✅ Flat structure (Veraticus, khanelinix)
- ✅ Auto-discovery (Veraticus)
- ✅ Skills auto-activation (Infrastructure Showcase)
- ✅ Progressive disclosure (BMAD, ClaudeGlobalCommands)
- ✅ Agents + Skills separation (Infrastructure Showcase)
- ✅ Extract superpowers patterns (multiple sources)

**Addresses original problems**:
- ✅ AI amnesia → Persistent skills, auto-activation
- ✅ Repeated mistakes → Enforcement through skills and agents
- ✅ No consistency → Standardized patterns in skills
- ✅ Endless iterations → Quality gates (code review, validation)

---

## Next Steps

1. **Create detailed implementation plan** - Task breakdown with file paths, complete code, verification steps
2. **Build Phase 1 (Foundation)** - Directory structure, default.nix, CLAUDE.md
3. **Implement Core Agents** - Starting with code-reviewer and debugger
4. **Add Web Skills** - Next.js, React, Prisma first (highest value)
5. **Test and Iterate** - Use in real projects, refine based on experience

---

## Appendices

### A. Superpowers Pattern Extraction Map

| Pattern | Source Skill | Target Component | Implementation Notes |
|---------|--------------|------------------|---------------------|
| Systematic debugging | systematic-debugging | debugger agent | 4-phase methodology |
| Root cause tracing | root-cause-tracing | debugger agent | Backward call stack analysis |
| Verification | verification-before-completion | validate command | Run commands, show evidence |
| TDD workflow | test-driven-development | testing guidance in skills | Red-Green-Refactor |
| Defense in depth | defense-in-depth | security-auditor + code-reviewer | Multi-layer validation |
| Code review rigor | code-reviewer | code-reviewer agent | Review against specs |

### B. Skill Auto-Activation Examples

**Scenario 1**: Editing Next.js route
- File: `app/api/users/route.ts`
- Auto-loads: `nextjs-15`, `typescript`, `api-design`
- Run `/review` → code-reviewer uses all three skills

**Scenario 2**: Working on Prisma schema
- File: `prisma/schema.prisma`
- Auto-loads: `prisma`
- Run `/review` → code-reviewer validates schema patterns

**Scenario 3**: Building React component with Storybook
- Files: `UserProfile.tsx`, `UserProfile.stories.tsx`
- Auto-loads: `react-patterns`, `typescript`, `storybook`
- Run `/docs` → documentation-writer generates component docs

### C. References

- Veraticus nix-config: `github.com/Veraticus/nix-config/tree/main/home-manager/claude-code`
- khanelinix ai-tools: `examples/khanelinix-main/modules/common/ai-tools/`
- Infrastructure Showcase: `github.com/diet103/claude-code-infrastructure-showcase`
- ClaudeGlobalCommands: `github.com/GGPrompts/ClaudeGlobalCommands`
- BMAD Method: `github.com/bmad-code-org/BMAD-METHOD`
- Superpowers: Existing plugin (to be removed from global, patterns extracted)

---

**End of Design Document**
