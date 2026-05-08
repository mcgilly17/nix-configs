---
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git diff:*), Write, AskUserQuestion, Agent
argument-hint: "[scope] [--output path]"
description: Extract user stories from code, detail them, and synthesize into E2E happy-path and GWT integration test cases
---

# Extract Stories Command

Analyzes code to extract implicit user stories, details them with acceptance criteria, then synthesizes structured test cases — E2E happy paths for Playwright and Given-When-Then integration tests.

## Usage

```bash
/extract-stories                           # Auto-detect scope from project structure
/extract-stories server/claims             # Extract stories from a specific domain
/extract-stories app/(protected)/profile   # Extract from a route group
/extract-stories --output docs/stories.md  # Custom output path
```

## Process

### Phase 1: Scope Discovery

**If argument provided**: Use that path as the scope.

**If no argument**: Auto-detect the project's domains by scanning for:
- `server/*/` domain directories (tRPC routers, services)
- `app/*/` route groups and pages
- `pages/` or `src/` directories
- API route handlers

Then use **AskUserQuestion** to let the user pick which domain(s) to analyze:
- Present discovered domains as options
- Allow multi-select
- Include an "All domains" option

### Phase 2: Code Analysis

For each scoped area, read and analyze:

**Backend signals** (strongest story indicators):
- **Service functions** (`service.ts`) — each exported function often maps to a user capability
- **Router procedures** (`router.ts`) — tRPC/API endpoints reveal what users can do
- **Validations** (`validations.ts`) — input schemas reveal what data users provide
- **Middleware/guards** — reveal authorization stories ("As an admin...", "As an authenticated user...")

**Frontend signals** (UI flow indicators):
- **Page components** (`page.tsx`) — each page is a user-facing capability
- **Form components** — reveal data entry stories
- **Client components with mutations** — reveal write operations
- **Navigation/sidebar** — reveals the user's mental model of the app
- **Error/empty states** — reveal edge case stories

**Cross-cutting signals**:
- **Email templates** — reveal notification stories
- **Middleware** — reveal auth/access stories
- **i18n message keys** — reveal user-facing labels and flows

For each signal, extract:
```
WHO:    The actor (user role, auth state)
WHAT:   The capability (create, view, update, delete, verify, etc.)
WHY:    The business value (inferred from context, naming, comments)
INPUT:  What data the user provides (from Zod schemas, form fields)
OUTPUT: What the user sees/gets back (from return types, UI components)
GUARDS: What conditions must be met (auth, ownership, status checks)
```

### Phase 3: Story Synthesis

Organize extracted signals into structured user stories:

```markdown
## US-{N}: {Title}

**As a** {actor}
**I want to** {capability}
**So that** {business value}

### Acceptance Criteria
- [ ] AC-1: {criterion derived from validation/guards}
- [ ] AC-2: {criterion derived from service logic}
- [ ] AC-3: {criterion derived from UI states}

### Source Evidence
- Service: `server/{domain}/service.ts` → `{functionName}()`
- Router: `server/{domain}/router.ts` → `{procedureName}`
- UI: `app/{route}/page.tsx`
- Validation: `{schema}.pick({fields})`
```

### Phase 4: Interactive Review

**CRITICAL: Use AskUserQuestion for ALL review interactions.**

Present stories to the user in batches (3-5 at a time) using AskUserQuestion:

**Step 4a — Story accuracy check:**
Ask the user to review each batch:
- Are these stories accurate?
- Any stories missing?
- Any stories that should be merged or split?
- Any business context to add?

Use AskUserQuestion with options like:
- "Stories look good, continue"
- "Need to adjust some stories" (then ask which ones)
- "Missing stories — let me describe them"
- "Skip review, generate all test cases"

**Step 4b — Priority selection:**
Use AskUserQuestion to ask which stories should get test cases:
- "All stories" 
- "Critical path only" (let user select)
- "Let me pick specific stories"

### Phase 5: Test Case Generation

For each approved story, generate two types of test cases:

#### 5a: E2E Happy Path Tests (Playwright)

Generate test specifications following the project's E2E patterns:

```markdown
### E2E: US-{N} — {Story Title}

**Test file:** `tests/e2e/{domain}.spec.ts`

**Prerequisites:**
- Authenticated as: {role}
- Test data: {what needs to exist}
- Setup: {any fixture/helper calls}

**Happy Path Steps:**
1. Navigate to {route}
2. {User action} → Expect {visible result}
3. {User action} → Expect {visible result}
4. Verify {final state}

**Playwright Skeleton:**
```typescript
test('{story title}', async ({ page }) => {
  // ARRANGE
  {setup steps — navigate, ensure preconditions}

  // ACT
  {user interactions — clicks, fills, submits}

  // ASSERT
  {verify visible outcomes — text, navigation, toasts}
});
```
```

#### 5b: Integration Tests (Given-When-Then)

Generate test specifications following GWT structure:

```markdown
### Integration: US-{N} — {Story Title}

**Test file:** `server/{domain}/tests/{operation}.integration.test.ts`

**Scenario: {Happy path description}**
- **Given** {precondition — database state, auth context}
- **When** {action — service call or tRPC procedure}
- **Then** {expected outcome — return value, database state, side effects}

**Scenario: {Guard/validation scenario}**
- **Given** {precondition that triggers guard}
- **When** {same action attempted}
- **Then** {expected rejection — error code, message}

**Scenario: {Edge case}**
- **Given** {edge condition}
- **When** {action}
- **Then** {expected behavior}

**Vitest Skeleton:**
```typescript
describe('{domain}.{operation}', () => {
  it('{happy path}', async () => {
    // GIVEN
    {arrange — create test data via builders}

    // WHEN
    {act — call service/procedure}

    // THEN
    {assert — verify result and side effects}
  });

  it('{rejects when guard fails}', async () => {
    // GIVEN
    {arrange — setup failing precondition}

    // WHEN + THEN
    {assert throws expected error}
  });
});
```
```

### Phase 6: Output

Write the complete analysis to a markdown file:

**Default path:** `USER-STORIES.md` in the current working directory.
**Custom path:** If `--output` flag provided, use that path.

**File structure:**
```markdown
# User Stories & Test Cases

> Generated from code analysis on {date}
> Scope: {analyzed paths}

## Summary
- {N} user stories extracted
- {M} E2E happy-path test cases
- {K} GWT integration test scenarios

## Stories

{All user stories with acceptance criteria}

## Test Cases

### E2E Happy Paths
{All E2E test specifications}

### Integration Tests (Given-When-Then)
{All GWT test specifications}

## Coverage Matrix

| Story | E2E | Integration | Notes |
|-------|-----|-------------|-------|
| US-1  | ✅  | ✅          |       |
| US-2  | ✅  | ⬚           | UI-only, no service logic |
```

After writing, use **AskUserQuestion** to ask:
- "Generate test files from these specs?" (writes actual .spec.ts and .test.ts files)
- "Refine specific stories or test cases?"
- "Done — I'll review the output file"

## Adaptation Rules

This skill adapts to the project it runs in:

- **Detect test framework**: Look for `vitest.config.*`, `jest.config.*`, `playwright.config.*`
- **Detect patterns**: Scan existing tests for naming conventions, helper usage, builder patterns
- **Detect architecture**: Domain-driven (`server/*/`), feature-based (`src/features/`), flat (`src/`)
- **Match conventions**: Generated test skeletons should mirror the style of existing tests in the project

## Best Used When

- Starting a new feature and want to document expected behavior first
- Auditing test coverage against actual user capabilities
- Onboarding — understanding what the app does from the code
- Before a refactor — capturing current behavior as test specs
- Sprint planning — extracting stories from a prototype or MVP
