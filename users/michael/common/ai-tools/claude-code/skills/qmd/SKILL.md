---
name: qmd
description: Search Michael's Obsidian vault and markdown knowledge bases using QMD. Use when users ask to search notes, find documents, look up information, or ask about projects/work/people/companies.
license: MIT
allowed-tools: mcp__*vault-search__*, Bash(qmd:*)
---

# QMD - Vault Search

Local search engine for Michael's Obsidian vault (2200+ docs) via the `vault-search` MCP server.

## Critical: QMD has NO frontmatter filtering

QMD treats all content as text. Metadata fields like `status: active` or `relationship: past-employer` are not filterable. You MUST use query technique to get relevant results.

## Query Strategy

### Choose approach by question type

| Question type | Strategy | Example |
|---------------|----------|---------|
| Current work / temporal | HYDE + intent | "what am I working on?" |
| Entity lookup | lex (exact name) | "tell me about Cogna" |
| Knowledge / how-to | vec (semantic) | "how does the K3s cluster work?" |
| Decision history | lex + vec | "what did we decide about auth?" |
| Meeting search | lex + intent | "meetings with Lars about Protobloc" |

### For current/active work queries

Always use HYDE with explicit project names. This is the single most important technique.

```json
{
  "searches": [
    {
      "type": "hyde",
      "query": "Active projects: Muse (museum SaaS), Nova (AI assistant), ULLR (ski maps React Native), Protobloc (web3 data sovereignty), Dots (NixOS dotfiles), Golf Simulator, Homelab Networking, Mosaic (Neovim), Zenith (K3s cluster), K8s Operator, Killin GC, BlocAlpha. Active clients via Lucent Advisory: Cogna, Muse, Mendo, Neurovirse."
    },
    { "type": "vec", "query": "current active projects and work" }
  ],
  "intent": "Find current/active work only, not historical projects like Beamery (past employer, ended ~2022)"
}
```

**Why:** HYDE embeds a hypothetical *answer* document. The index finds docs semantically similar to this answer, so active projects score high and old Beamery content drops.

### For entity lookups

```json
{
  "searches": [
    { "type": "lex", "query": "cogna" }
  ],
  "intent": "company profile and relationship details"
}
```

### For knowledge queries

```json
{
  "searches": [
    { "type": "lex", "query": "kubernetes operator CRD" },
    { "type": "vec", "query": "how to build a Kubernetes operator with custom resources" }
  ]
}
```

## Query Types Reference

| Type | Method | When to use |
|------|--------|-------------|
| `lex` | BM25 keywords | Know exact terms, names, identifiers |
| `vec` | Vector semantic | Natural language questions |
| `hyde` | Hypothetical doc | Write 50-100 words of what the answer looks like |

- First search entry gets **2x weight** in fusion — put your best query first
- Use `intent` to disambiguate ambiguous terms
- `lex` supports: prefix match (`perf`), exact phrase (`"rate limiter"`), exclude (`-sports`)

## Post-search validation

After getting results, **always check frontmatter** before presenting as current:
- `relationship: past-employer` / `past-client` = historical, not current work
- `status: completed` / `abandoned` / `paused` = not active
- `status: active` + `relationship: employer` / `client` = current work

## MCP Tools

| Tool | Use |
|------|-----|
| `query` | Search with lex/vec/hyde queries |
| `get` | Retrieve full doc by path or `#docid` |
| `multi_get` | Batch retrieve by glob or comma list |
| `status` | Collection health and stats |

## Collection

The vault collection is named `vault`. Always use `"collections": ["vault"]` or omit (defaults to all).
