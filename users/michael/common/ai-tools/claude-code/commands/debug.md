---
allowed-tools: All
argument-hint: "[description]"
description: Systematic debugging using debugger agent
---

# Debug Command

Invokes the debugger agent for systematic bug investigation.

## Usage

```bash
/debug "API returns 500 on user login"
/debug "Memory leak in data processing"
/debug "Component re-renders infinitely"
```

## Process

The debugger agent follows a 5-phase methodology:

### Phase 1: Reproduction
- Gather exact steps to reproduce
- Determine expected vs. actual behavior
- Create minimal test case
- Check reproduction reliability

### Phase 2: Data Gathering
- Collect error messages and stack traces
- Review relevant logs
- Document environment details
- Establish timeline and scope

### Phase 3: Hypothesis Generation
- Generate 3-5 ranked hypotheses
- Base on evidence, not guesses
- For each: "If true, we should see X"

### Phase 4: Hypothesis Testing
- Design tests for each hypothesis
- Run tests systematically
- Record results
- Eliminate or confirm

### Phase 5: Root Cause & Fix
- Explain root cause
- Propose fix with rationale
- Suggest regression tests
- Identify related issues

## What You'll Get

A structured debugging report:
```markdown
# Debugging Report: [Issue Description]

## Reproduction
- Steps: [...]
- Reliability: [X%]
- Minimal case: [...]

## Evidence
- Errors: [...]
- Logs: [...]
- Environment: [...]
- Timeline: [...]

## Hypotheses
1. [Most likely] - [Test approach]
2. [Second] - [Test approach]
3. [Less likely] - [Test approach]

## Test Results
[Systematic testing of each hypothesis]

## Root Cause
[What actually happened and why]

## Proposed Fix
[Code changes with rationale]

## Regression Tests
[Tests to prevent recurrence]

## Related Concerns
[Similar code that might have same issue]
```

## Best Used When

- Hit a bug you can't figure out
- Intermittent failures
- Performance issues
- Memory leaks
- Race conditions
- Need systematic approach

## Root Cause Tracing

For errors deep in call stack:
- Traces backward to find origin
- Identifies where validation should have caught issue
- Suggests instrumentation if needed

## Integration with Skills

Uses framework-specific debugging:
- Next.js → App Router cache issues, RSC hydration
- React → Hook rules, render cycles, state updates
- Prisma → N+1 queries, connection pooling
- Docker → Container logs, networking
- Kubernetes → Pod logs, resource constraints

## Tips

- Be specific in description: "Login fails with 500" better than "it's broken"
- Include error messages if you have them
- Mention what you've already tried
- Note when the bug started appearing
