---
allowed-tools: All
argument-hint: "[files or commit]"
description: Comprehensive code review using code-reviewer agent
---

# Code Review Command

Invokes the code-reviewer agent for systematic code review.

## Usage

```bash
/review                     # Review staged changes
/review src/auth.ts        # Review specific file
/review HEAD~3..HEAD       # Review last 3 commits
/review --full             # Review entire project
```

## Process

### 1. Determine Scope

**If no arguments**: Review staged git changes
```bash
git diff --cached
```

**If file path provided**: Review that file
```bash
# Read the specified file
```

**If commit range**: Review changes in that range
```bash
git diff <range>
```

**If --full flag**: Review entire codebase (use with caution on large projects)

### 2. Load Context

- Check which skills are loaded (framework context)
- Read relevant files
- Understand project patterns

### 3. Invoke code-reviewer Agent

Use the code-reviewer agent with:
- Files/changes to review
- Loaded skill context (Next.js, React, Prisma, etc.)
- Project conventions from CLAUDE.md

### 4. Present Review

The code-reviewer agent will provide:
- ✅ Strengths
- 🔍 Questions
- ⚠️ Concerns (Critical/Moderate/Minor)
- 💡 Suggestions
- 🎯 Recommendation

## What Gets Reviewed

- **Correctness**: Logic, edge cases, error handling
- **Quality**: Clarity, naming, structure
- **Security**: Input validation, auth, data protection
- **Performance**: Obvious inefficiencies
- **Architecture**: Consistency with codebase
- **Framework Patterns**: Uses loaded skills (React, Next.js, etc.)

## Best Used When

- Before creating a PR
- After implementing a feature
- When code feels "off" but not sure why
- Learning codebase patterns
- Onboarding new patterns/frameworks

## Integration with Skills

Review automatically uses loaded skills:
- Next.js code → checks App Router patterns
- React components → validates hooks rules
- Prisma schema → checks relation design
- TypeScript → verifies type safety
- Docker → validates security patterns

## Expected Output Time

- Single file: ~2 minutes
- Small PR (< 200 lines): ~3-5 minutes
- Medium PR (200-400 lines): ~5-10 minutes
- Large PR (400-800 lines): ~10-15 minutes
