---
allowed-tools: Bash, Read
argument-hint: "[--fix]"
description: Run all quality checks (lint, format, test, type-check)
---

# Validate Command

Runs comprehensive quality validation on the project.

## Usage

```bash
/validate           # Run all checks
/validate --fix     # Run checks and auto-fix where possible
```

## Process

1. **Detect project type** - Check for package.json, tsconfig.json, etc.
2. **Run appropriate checks** based on detected tools
3. **Report results** with actionable fixes
4. **Auto-fix** if --fix flag provided

## Checks Performed

### TypeScript/JavaScript Projects

**Linting**:
```bash
# ESLint
npm run lint
# or
eslint .
```

**Formatting**:
```bash
# Prettier
npm run format:check
# or
prettier --check .
```

**Type Checking**:
```bash
# TypeScript
npm run type-check
# or
tsc --noEmit
```

**Tests**:
```bash
# Jest, Vitest, etc.
npm test
```

**Build**:
```bash
# Next.js, Vite, etc.
npm run build
```

### Nix Projects

```bash
# Format
nix fmt

# Build
nix build

# Checks
nix flake check
```

## Output Format

```
✅ Lint: Passed
✅ Format: Passed
❌ Type Check: 3 errors found
  - src/auth.ts:42 - Type 'string' is not assignable to type 'number'
  - src/user.ts:15 - Property 'email' does not exist
  - src/api.ts:8 - Argument of type 'null' not assignable
✅ Tests: 45/45 passed
⚠️  Build: Warning - Bundle size exceeds 200KB

Summary: 2 issues require attention
```

## With --fix Flag

Automatically fixes:
- Linting issues (ESLint --fix)
- Formatting (Prettier --write)
- Auto-fixable type errors (where safe)

Cannot auto-fix:
- Test failures (requires manual investigation)
- Complex type errors
- Build errors

## Best Used When

- Before committing code
- Before creating a PR
- After refactoring
- Continuous integration locally
- Before deployment

## Integration Detected

Automatically detects and runs:
- Next.js build
- React/TypeScript checks
- Prisma validation
- Docker image builds
- Kubernetes manifest validation
