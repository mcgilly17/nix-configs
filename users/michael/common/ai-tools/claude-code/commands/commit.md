---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Read, Grep
argument-hint: "[--all] [--amend] [--dry-run] [--interactive]"
description: Create atomic commits following repository conventions
---

# Commit Command

Systematically analyzes changes, detects repository conventions, and creates **atomic commits**.

## Core Principle: Atomic Commits

**Every commit must be atomic:**
- Represents **one logical change** (one idea, one fix, one feature)
- Contains **all related files** needed for that change to work
- Can be **reverted independently** without breaking other features
- Passes tests and maintains a **working codebase** state
- Has a **clear, single purpose** that's easy to describe

**Why atomic commits matter:**
- Easier code review (reviewers understand one change at a time)
- Safer reverts (undo specific changes without affecting others)
- Cleaner history (git log tells a clear story)
- Better debugging (git bisect works effectively)
- Simpler cherry-picking (port specific features across branches)

**Anti-patterns to avoid:**
- ❌ Mixing unrelated changes (bug fix + new feature in one commit)
- ❌ Partial implementations (commit half a feature)
- ❌ Breaking the build (commit leaves codebase in broken state)
- ❌ "WIP" or "misc fixes" commits (unclear purpose)

## Workflow Overview

Four-phase systematic approach:
1. **Analysis** - Examine repository conventions and current changes
2. **Grouping** - Organize changes into logical, atomic commit groups
3. **Message Generation** - Create conventional commit messages
4. **Execution** - Stage and commit each group systematically

## Phase 1: Repository Analysis

### Step 1.1: Repository State Assessment

**Current state analysis:**
```bash
# Understand current repository state
git status --porcelain
git diff --name-status
git diff --cached --name-only  # Preserve existing staged changes
```

### Step 1.2: Convention Detection

**Analyze recent commit history to detect patterns:**
```bash
git log --oneline -20
git log --pretty=format:"%s" -50
```

**Pattern recognition - Look for:**

**CONVENTIONAL COMMITS:**
- Pattern: `type(scope): description`
- Types: `feat, fix, docs, style, refactor, test, chore, build, ci, perf`
- Example: `feat(auth): add OAuth2 integration`

**GITMOJI:**
- Pattern: `:emoji: description` OR `emoji description`
- Example: `:bug: fix memory leak` or `🐛 fix memory leak`

**SEMANTIC RELEASE:**
- Pattern: `type: description` OR `type(scope): description`
- Example: `fix: resolve authentication timeout`

**ACTION-BASED:**
- Pattern: `Verb Object`
- Example: `Add user authentication`, `Fix memory leak`

**ISSUE-BASED:**
- Pattern: `[#123] description` OR `fixes #123: description`
- Example: `[#456] implement dark mode toggle`

**Convention scoring:**
```
FOR each pattern:
    Count matches in recent commits
    Calculate confidence score (matches / total commits)
    Identify most prevalent pattern (highest score)
```

### Step 1.3: Project Context

**Check for commit guidelines:**
- Read `CONTRIBUTING.md` if present
- Read `.gitmessage` if present
- Check `README.md` for commit guidelines
- Look for `.commitlintrc` or similar config files

## Phase 2: Change Analysis and Atomic Grouping

**CRITICAL: Ensure each group represents ONE atomic change**

### Step 2.1: Change Categorization

**Systematic file analysis:**
```
FOR each modified file:
    Categorize by change type:
      - NEW: newly added files
      - MODIFIED: existing files with changes
      - DELETED: removed files
      - RENAMED: moved or renamed files

    Categorize by functional area:
      - FEATURES: new functionality
      - FIXES: bug corrections
      - DOCS: documentation changes
      - TESTS: test additions/modifications
      - CONFIG: configuration file changes
      - REFACTOR: code restructuring
      - STYLE: formatting/style changes
```

**Detailed change analysis:**
```bash
# For each file, analyze changes
git diff <file>
```

### Step 2.2: Atomic Grouping Strategy

**Primary grouping criteria:**
1. **Single Purpose** - Each group has ONE clear purpose
2. **Feature Cohesion** - Group files implementing a single feature together
3. **Functional Area** - Group changes within same module/component
4. **Dependency Relationships** - Group interdependent changes
5. **Completeness** - Ensure each group is complete and working

**Atomic grouping rules:**

**SEPARATE into different commits (maintain atomicity):**
- Breaking changes (always isolated)
- Feature additions vs bug fixes (different purposes)
- Different functional areas (unless tightly coupled)
- Independent documentation updates (unless directly related to code change)
- Independent configuration changes (unless required for a feature)

**COMBINE into same commits (preserve atomicity):**
- Related test additions with feature code (feature isn't complete without tests)
- Documentation updates with the feature they document (feature includes docs)
- Configuration changes required for a feature (feature depends on config)
- Multiple files implementing the same feature (all needed for one logical change)

### Step 2.3: Atomic Validation

**For each proposed group, validate atomicity:**

```
Atomicity checklist:
  ✓ Does this represent ONE logical change?
  ✓ Can I describe this change in one sentence?
  ✓ Would the codebase be in a working state after this commit?
  ✓ Are all dependencies for this change included?
  ✓ Could this commit be reverted without breaking unrelated features?
  ✓ Is the change too large? (>10 files often suggests splitting needed)
```

**If a group fails validation:**
- Split into smaller atomic commits
- Move unrelated changes to separate commits
- Ensure each resulting commit passes all validation checks

## Phase 3: Commit Message Generation

### Step 3.1: Message Structure

**Apply detected convention following repository patterns**

**For Conventional Commits:**
```
Determine type: feat|fix|docs|style|refactor|test|chore|build|ci|perf
Determine scope: component/module affected (optional)
Write description: imperative mood, lowercase, no period
Format: "type(scope): description"
```

**Message quality criteria:**
- Describes the ONE thing this commit does
- Follows repository conventions exactly
- Imperative mood ("add feature" not "added feature")
- Appropriate length (~50 chars for subject)
- Specific enough to understand without seeing diff

### Step 3.2: Type and Scope Determination

**Type classification:**
```
feat: new features or enhancements
fix: bug fixes and corrections
docs: documentation only changes
style: formatting, missing semi-colons (no code change)
refactor: code change that neither fixes bug nor adds feature
test: adding missing tests or correcting existing tests
chore: changes to build process or auxiliary tools
build: changes affecting build system or dependencies
ci: changes to CI configuration files and scripts
perf: code change that improves performance
```

**Scope identification:**
```
Determine from file paths and changes:
  - Module/component names from directory structure
  - Service/feature names from file names
  - Functional area names (auth, api, ui, config, etc.)
  - Keep scopes consistent with repository patterns
```

## Phase 4: Systematic Commit Execution

### Step 4.1: Pre-commit Validation

```bash
# If --dry-run flag
echo "Would commit: <message>"
echo "Files: <file1> <file2> ..."
```

### Step 4.2: Atomic Commit Execution

```bash
# For each atomic commit group:
git add <file1> <file2> ...
git diff --cached --name-only  # Verify staging
git commit -m "<generated-message>"
git log -1 --oneline  # Verify success
```

### Step 4.3: Progress Reporting

```
After each commit:
    ✓ Committed: <message>
    Files: <file-list>

Final summary:
    Total commits created: N
    All changes successfully committed
```

## Command Flags

```bash
# Process all unstaged changes with automatic atomic grouping
/commit

# Include all tracked files with changes
/commit --all

# Amend the last commit instead of creating new ones
/commit --amend

# Show what would be done without making changes
/commit --dry-run

# Prompt for confirmation on each commit group
/commit --interactive
```

## Error Handling

**Handle common scenarios:**
- No changes to commit (clean working directory)
- Merge conflicts preventing commit
- Failed commit due to pre-commit hooks
- Ambiguous convention detection (multiple patterns)
- Large changesets requiring special handling

**Recovery strategies:**
- Offer to split large commits into smaller atomic ones
- Provide manual override for convention detection
- Handle pre-commit hook failures gracefully
- Preserve partial progress if some commits succeed

## Integration with Workflow

**Recommended workflow:**
```bash
# 1. Fix code quality issues
/validate --fix

# 2. Review changes if needed
/review

# 3. Create atomic commits
/commit

# 4. Verify commits are atomic
git log --oneline -5
```

**Remember:** Each commit should tell one clear story. If you struggle to write a commit message without using "and", the commit likely isn't atomic.

**References:**
- Git workflow skill for Conventional Commits guidance
- Repository history analyzed for local patterns
- Project documentation checked for guidelines
