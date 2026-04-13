---
allowed-tools: Read, AskUserQuestion, mcp__plugin_claude-code-home-manager_vault-librarian__resolve_entity, mcp__plugin_claude-code-home-manager_vault-librarian__resolve_links, mcp__plugin_claude-code-home-manager_vault-librarian__validate, mcp__plugin_claude-code-home-manager_vault-librarian__create, mcp__plugin_claude-code-home-manager_vault-librarian__create_entity, mcp__plugin_claude-code-home-manager_vault-librarian__update, mcp__plugin_claude-code-home-manager_vault-librarian__read_note, mcp__plugin_claude-code-home-manager_vault-librarian__list_schemas
argument-hint: "<natural language description of what to save> [--type <type>] [--dry-run]"
description: Publish a document to the Obsidian vault with proper type, frontmatter, and wiki-links
---

# Vault Publish

Publish content to the Nova Obsidian vault via vault-librarian. Content is typically synthesized from the current conversation, but can also come from a local file.

## Input Modes

**Primary — natural language intent (most common):**
```
/vault-publish save the decision we made about TypeScript migration
/vault-publish new company entity for Acme from this conversation
/vault-publish meeting notes from this call
/vault-publish capture the recipe we discussed
```

**Secondary — local file path:**
```
/vault-publish ~/Documents/proposal.md
/vault-publish ./meeting-notes.md --type meeting
```

**No arguments:** Ask the user what they'd like to save from the conversation.

## Flags

- **`--type <type>`:** Override auto-classification (see vault types below)
- **`--dry-run`:** Preview what would be written without creating anything

## Vault Types

| Type | When to use |
|------|-------------|
| note | General knowledge, research, reference material |
| meeting | Meeting notes with attendees and action items |
| decision | Architectural or business decisions with context |
| idea | Raw ideas, concepts, proposals |
| capture | Unstructured content for later triage |
| article | Long-form written content with a source URL |
| bookmark | Saved links with description |
| book | Book notes or summaries |
| tool | Software tools, services, products |
| video | Video references |
| person | People you know or work with |
| company | Companies, organizations |
| project | Projects you're working on or tracking |
| commitment | Promises, obligations, follow-ups |
| recipe | Recipes |

If unsure about types, call `vault-librarian/list-schemas` for the current set.

## Workflow

### Step 1: Parse Intent

Parse `$ARGUMENTS` for:
- **Natural language description** of what to save and why
- **File path** (if provided — detected by path-like patterns)
- **`--type`** and **`--dry-run`** flags

### Step 2: Gather Content

**If file path provided:** Read the file with the `Read` tool. Parse any existing frontmatter — some fields may be reusable.

**If natural language intent:** Synthesize the document content from the current conversation context. Focus on:
- What the user explicitly asked to save
- Relevant context from the conversation that supports it
- Structured formatting appropriate to the document type

### Step 3: Classify Document Type

**If `--type` flag provided:** Use that type directly.

**Otherwise, classify using these signals (in priority order):**
1. **Explicit mention in intent** — "meeting notes", "decision about", "new company"
2. **Existing frontmatter** — if source file has a `type:` field
3. **Content shape** — attendee lists suggest meeting, pros/cons suggest decision, URLs suggest bookmark/article

Present classification to user for confirmation:
```
Classified as: decision
Confidence: high (intent mentions "decision", content has context/alternatives structure)
```

If confidence is low or ambiguous, ask the user to choose.

### Step 4: Resolve Entities

Extract entity mentions from the intent and content (people, companies, projects).

For each entity, call `vault-librarian/resolve-entity` to find existing matches. For batch resolution, use `vault-librarian/resolve-links`.

**If entity found:** Use the resolved wiki-link in frontmatter.

**If entity not found:** Offer to create it:
```
"Acme" not found in vault. Create as:
1. Company entity
2. Skip — just mention by name
3. Other type
```

### Step 5: Build and Validate

Compose the document with frontmatter and body content. Call `vault-librarian/validate` to dry-run the document against the type schema.

If validation fails, fix the issues and re-validate. Common fixes:
- Missing required frontmatter fields
- Invalid field values
- Malformed wiki-links

### Step 6: Preview and Confirm

Show the user what will be written:

```
Type:   decision
Title:  TypeScript Migration Approach
Target: Knowledge/Decisions/2026-04-06-typescript-migration-approach.md

Frontmatter:
  type: decision
  title: TypeScript Migration Approach
  date: 2026-04-06
  tags: [typescript, migration, architecture]
  related:
    - "[[Entities/Projects/Nova]]"

New entities to create:
  (none)

Wiki-links resolved: 1
```

Use AskUserQuestion to confirm or allow edits.

**If `--dry-run`:** Show preview and stop.

### Step 7: Write to Vault

Create any new entities first with `vault-librarian/create-entity` (link targets must exist before references).

Then write the main document with `vault-librarian/create`.

### Step 8: Confirm

```
Published: Knowledge/Decisions/2026-04-06-typescript-migration-approach.md
Created:  (no new entities)
1 wiki-link resolved
```

## Multiple Items

If the user's intent implies multiple documents (e.g., "save the meeting notes and create entities for everyone mentioned"), process them in order:
1. Create entities first (they're link targets)
2. Create the main document last

## Updating Existing Notes

If the user's intent is to update an existing note rather than create a new one (e.g., "update the Acme company entity with their new address", "add today's decisions to the migration note"):

1. Use `vault-librarian/resolve-entity` or `vault-librarian/read-note` to find the existing note
2. Show the user what will change (diff-style: fields being added/modified)
3. Call `vault-librarian/update` with the path and updated frontmatter/body
   - Frontmatter is a **partial merge** — only fields you pass are updated, others are preserved
   - Body **replaces** the existing content — include the full body if modifying it

## Error Handling

- **Schema not found for type:** Call `vault-librarian/list-schemas`, show available types, ask user to choose
- **Entity name ambiguous:** Show candidates from `vault-librarian/resolve-entity`, ask user to pick
- **Document already exists:** Use `vault-librarian/read-note` to check, show existing content, ask to overwrite or rename
- **vault-librarian unreachable:** Error with "vault-librarian MCP server not available. Check Tailscale connection."
