# Claude Code Hooks Guide

## Recommended Plugins

Install these plugins for notifications and prompt enhancement:

### Notifications (claude-notifications-go)

Smart desktop notifications with click-to-focus, git branch display, and webhook support:

```
/plugin marketplace add 777genius/claude-notifications-go
/plugin install claude-notifications-go@claude-notifications-go
/claude-notifications-go:init
```

Features: Task complete, review complete, questions, plan ready, session limit, API errors.

### Prompt Enhancer (prompt-improver)

Intelligent prompt clarification that only intervenes on vague prompts:

```
/plugin marketplace add severity1/claude-code-prompt-improver
/plugin install claude-code-prompt-improver@claude-code-prompt-improver
```

Use `*` prefix to bypass enhancement for any prompt.

---

## Global Hooks (installed via dotfiles)

These are managed in `users/michael/common/ai-tools/claude-code/hooks/`:

- **session-start.nix** - Shows git status and recent commits on session start
- **dependency-audit.nix** - Checks for vulnerabilities when package.json/requirements.txt/Cargo.toml changes

---

## Project-Local Hook Templates

These hooks are NOT installed globally. Copy them to your project's `.claude/settings.json` as needed.

## TypeScript/Node Projects

Type-check after file writes:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // .tool_input.path'); if [[ \"$file\" == *.ts || \"$file\" == *.tsx ]]; then npx tsc --noEmit 2>&1 | head -20; fi",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Biome (Linting/Formatting)

Auto-fix with Biome after writes:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // .tool_input.path'); if [[ \"$file\" == *.ts || \"$file\" == *.tsx || \"$file\" == *.js || \"$file\" == *.jsx ]]; then npx biome check --fix \"$file\" 2>&1 | tail -5; fi",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Nix Projects

Format with `nix fmt` after writes (async to avoid blocking):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // .tool_input.path'); if [[ \"$file\" == *.nix ]]; then nix fmt \"$file\" 2>&1 | tail -5; fi",
            "async": true,
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

## Test Runner (Async)

Run tests in background after significant changes:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // .tool_input.path'); if [[ \"$file\" == *.test.* || \"$file\" == *.spec.* || \"$file\" == *_test.* ]]; then npm test 2>&1 | tail -20; fi",
            "async": true,
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

## Combining Multiple Hooks

You can combine hooks in a single settings file:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // .tool_input.path'); [[ \"$file\" == *.ts ]] && npx tsc --noEmit 2>&1 | head -10 || true",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "file=$(cat | jq -r '.tool_input.file_path // .tool_input.path'); [[ \"$file\" == *.ts || \"$file\" == *.js ]] && npx biome check --fix \"$file\" 2>&1 | tail -5 || true",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

