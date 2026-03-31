---
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(cp:*), Bash(mkdir:*), Bash(date:*), Bash(find:*), Read, Write, Edit, Glob, Grep, AskUserQuestion
argument-hint: "<file-or-glob> [--type <type>] [--dry-run]"
description: Publish a document to the Obsidian vault with proper type, frontmatter, and wiki-links
---

# Vault Publish

Publish a local document to the Nova Obsidian vault at `~/Vaults/Nova/`. Classifies the document, generates typed frontmatter, resolves entity wiki-links, and writes to the correct vault folder.

## Constants

```
VAULT_ROOT=~/Vaults/Nova
SCHEMAS_DIR=$VAULT_ROOT/_schemas
TEMPLATES_DIR=$VAULT_ROOT/_templates
```

## Vault Types

| Type | Folder | When to use |
|------|--------|-------------|
| note | Knowledge/Notes | General knowledge, research, reference material |
| meeting | Knowledge/Meetings | Meeting notes with attendees and action items |
| decision | Knowledge/Decisions | Architectural or business decisions with context |
| idea | Knowledge/Ideas | Raw ideas, concepts, proposals |
| capture | Knowledge/Inbox | Unstructured content for later triage |
| article | Content/Articles | Long-form written content with a source URL |
| bookmark | Content/Bookmarks | Saved links with description |
| book | Content/Books | Book notes or summaries |
| tool | Content/Tools | Software tools, services, products |
| video | Content/Videos | Video references |
| person | Entities/People | People you know or work with |
| company | Entities/Companies | Companies, organizations |
| project | Entities/Projects | Projects you're working on or tracking |
| commitment | Entities/Commitments | Promises, obligations, follow-ups |
| recipe | Content/Recipes | Recipes |

## Workflow

### Step 1: Resolve Input

Parse `$ARGUMENTS` for:
- **File path(s):** Can be a single file, glob, or directory
- **`--type <type>`:** Override auto-classification
- **`--dry-run`:** Show what would happen without writing

If no file specified, ask the user what to publish.

### Step 2: Extract Directory Context

**The working directory carries semantic meaning.** Parse the full path of the file being published for context clues:

```
Example: /Projects/lucent/customers/muse/proposal-v2.md

Segments to extract:
- Project directories: lucent -> likely a project or company the user owns
- Relationship directories: customers/, partners/, vendors/, internal/, personal/
- Entity directories: the segment after a relationship -> muse = a customer
- Nested context: customers/muse = "Muse is a customer of Lucent"
```

**Common relationship directory patterns:**
| Directory | Inferred relationship |
|-----------|----------------------|
| customers/ | Customer/client |
| clients/ | Customer/client |
| partners/ | Partner |
| vendors/ | Vendor/supplier |
| internal/ | Internal/own company |
| personal/ | Personal |
| consulting/ | Consulting client |

Store extracted context as `directory_context` for use in classification and frontmatter.

### Step 3: Check Vault Availability

```bash
if [ -d ~/Vaults/Nova ]; then
    VAULT_MODE="local"
else
    VAULT_MODE="mcp"
fi
```

**Local mode (preferred):** Read schemas, scan entities, write files directly to `~/Vaults/Nova/`.

**MCP fallback mode:** If local vault is unavailable (e.g., Syncthing not running, different machine):
- Use `qmd.qmd_deep_search` to find existing entities
- Use `vault.write_note` MCP tool to write files
- Note: MCP tools are only available if the Nova gateway is reachable

If neither is available, error with: "Vault not found locally at ~/Vaults/Nova and no MCP connection available."

### Step 4: Read the Document

Read the file to publish. If it already has YAML frontmatter, parse it -- some fields may be reusable.

### Step 5: Classify Document Type

**If `--type` flag provided:** Use that type directly.

**Otherwise, classify using these signals (in priority order):**

1. **Existing frontmatter** -- if file has a `type:` field, use it
2. **Directory context** -- meeting notes in a `meetings/` dir, proposals near customer dirs
3. **Filename patterns** -- `meeting-*.md`, `decision-*.md`, `*-proposal.md`
4. **Content analysis** -- attendee lists suggest meeting, pros/cons suggest decision, URLs suggest bookmark/article

**Present classification to user for confirmation:**
```
Classified as: meeting
Confidence: high (filename pattern + attendee list detected)
```

If confidence is low or ambiguous, ask the user to choose.

### Step 6: Resolve Entities

Scan the vault for existing entities that match the directory context and document content.

**Local mode:**
```bash
ls ~/Vaults/Nova/Entities/Companies/
ls ~/Vaults/Nova/Entities/People/
ls ~/Vaults/Nova/Entities/Projects/
```

**MCP fallback:**
```
qmd.qmd_deep_search("entity name")
```

**For each entity mention (from directory context + document content):**
1. Search vault for existing match
2. If found -> use its path for wiki-link: `[[Entities/Companies/Muse]]`
3. If not found -> offer to create it:
   ```
   "Muse" not found in vault. Create as:
   1. Company entity (Entities/Companies/muse.md)
   2. Skip -- just mention by name
   3. Other type
   ```

**When creating new entities**, use directory context to pre-fill fields:
- Company from `customers/muse` -> infer as customer relationship
- Person mentioned in meeting notes -> infer relationship from company context

### Step 7: Generate Frontmatter

Read the schema for the classified type:
```bash
cat ~/Vaults/Nova/_schemas/schema-{type}.yaml
```

Generate frontmatter with:
- All **required** fields filled (from document content + directory context)
- **Optional** fields filled where inferable
- **Wiki-links** for entity references: `"[[Entities/Companies/Muse]]"`
- **Tags** inferred from directory context + content
- **Date** from filename pattern, file modified date, or today

### Step 8: Compose Vault File

Combine:
1. YAML frontmatter (from step 7)
2. Document body (cleaned up -- strip any existing non-vault frontmatter, normalize headings)

**Filename:** Follow the schema's `filename_pattern`:
- Notes/meetings/decisions: `YYYY-MM-DD-{slugified-title}.md`
- Entities: `{slugified-name}.md`

### Step 9: Preview and Confirm

Show the user what will be written:

```
Source: /Projects/lucent/customers/muse/proposal-v2.md
Target: ~/Vaults/Nova/Knowledge/Notes/2026-03-29-muse-proposal-v2.md
Type:   note

Frontmatter:
  type: note
  title: Muse Proposal v2
  date: 2026-03-29
  tags: [lucent, muse, customer, proposal]
  related:
    - "[[Entities/Companies/Muse]]"
    - "[[Entities/Projects/Lucent]]"

New entities to create:
  - Entities/Companies/muse.md (customer)

Wiki-links added: 2
```

Use AskUserQuestion to confirm publish or allow edits.

**If `--dry-run`:** Show preview and stop.

### Step 10: Write to Vault

**Local mode:**

Create any new entities first (link targets must exist before references). Then write the main document to `~/Vaults/Nova/{folder}/{filename}.md`.

**MCP fallback:**
Use `vault.write_note` for each file.

### Step 11: Confirm

```
Published: Knowledge/Notes/2026-03-29-muse-proposal-v2.md
Created:  Entities/Companies/muse.md
2 wiki-links resolved

Syncthing will sync to Zenith. QMD will index on next reindex cycle.
```

## Multiple Files

If a glob or directory is provided, process each file:
1. Classify all files first, show summary table
2. Confirm batch
3. Create entities once (deduplicate across files)
4. Write all files

## Error Handling

- **Schema not found for type:** List available types, ask user to choose
- **Entity name ambiguous:** Show candidates from vault, ask user to pick
- **File already exists in vault:** Show diff, ask to overwrite or rename
- **Vault not writable:** Check Syncthing status, suggest troubleshooting
