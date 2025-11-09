---
allowed-tools: Read, Write, Grep
argument-hint: "[type] [target]"
description: Generate documentation using documentation-writer agent
---

# Docs Command

Invokes the documentation-writer agent to create or update documentation.

## Usage

```bash
/docs readme                  # Generate README.md
/docs api src/api/users.ts   # Document API endpoint
/docs architecture           # Create architecture docs
/docs comments src/auth.ts   # Add code comments
```

## Process

1. **Clarify scope** - What type of docs? (README, API, architecture, comments)
2. **Identify audience** - New developers? API consumers? Operators?
3. **Gather context** - Read relevant code, existing docs
4. **Invoke documentation-writer agent** with context
5. **Present draft** for review
6. **Iterate** based on feedback

## Documentation Types

- **README**: Getting started guide (< 500 lines)
- **API**: Endpoint/function documentation with examples
- **Architecture**: System design, component interactions, ADRs
- **Comments**: Code-level explanations (why, not what)

## Integration with Skills

Uses loaded skills for framework-specific conventions:
- Next.js → App Router conventions, RSC patterns
- React → Component prop types, hooks usage
- Prisma → Schema documentation, migration notes
- TypeScript → Type definitions in docs
- API patterns → REST/GraphQL conventions
