---
allowed-tools: Bash, AskUserQuestion, Read, Write, Edit
argument-hint: "[framework-name] [folder]"
description: Install AI development workflow framework (BMAD, Spec Kit, OpenSpec, Superpowers, or Get Shit Done)
---

# Install Workflow Command

Installs AI development workflow frameworks into your project with intelligent setup.

**Syntax:** `/install-workflow [framework-name] [folder]`
- `framework-name`: Optional - bmad, spec-kit, openspec, superpowers, gsd (prompts if omitted)
- `folder`: Optional - target installation directory (defaults to current directory)

## Installation Strategy

**Superpowers:** Clone and copy directly to `.claude/` folder (file-based skills)

**Others (BMAD, Spec Kit, OpenSpec):**
1. Check for `devenv.nix` in project
2. If exists: Add framework to `devenv.nix` (declarative)
3. If not: Install directly with package managers

## Available Frameworks

### 1. BMAD (Breakthrough Method for Agile AI-Driven Development)

**Best for:** Full-featured PM framework with multi-agent workflows

**What it provides:**
- 18+ specialized agents (requirements, architecture, testing, security, etc.)
- 40+ structured workflows for feature development
- Project management orchestration
- Sequential approval gates

**Installation via devenv.nix:**
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.nodejs_20 ];

  scripts.bmad-setup.exec = ''
    npx bmad-method install --non-interactive --ide=claude-code
  '';

  enterShell = ''
    if [ ! -d .claude/commands/bmad ]; then
      echo "Run: bmad-setup"
    fi
  '';
}
```

**Direct installation:** `npx bmad-method install`

**Location:** `.claude/commands/bmad/`

**Usage:** `/bmad-master`, `/bmad-architect`, `/bmad-tester`, etc.

**Repository:** https://github.com/bmad-code-org/BMAD-METHOD

---

### 2. GitHub Spec Kit

**Best for:** Structured spec-driven development with approval gates

**What it provides:**
- Constitution-based project principles
- Spec → Plan → Tasks → Implement workflow
- Technical architecture planning
- GitHub's official approach to AI-assisted development

**Installation via devenv.nix:**
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.python3 pkgs.uv ];

  scripts.speckit-setup.exec = ''
    TARGET_DIR="''${1:-.}"
    uvx --from git+https://github.com/github/spec-kit.git specify init "$TARGET_DIR"
  '';

  enterShell = ''
    if [ ! -d .speckit ]; then
      echo "📋 Spec Kit available but not initialized"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "Run: speckit-setup [folder]"
      echo ""
      echo "Examples:"
      echo "  speckit-setup          # Install in current directory"
      echo "  speckit-setup .        # Install in current directory"
      echo "  speckit-setup my-app   # Install in ./my-app subdirectory"
    fi
  '';
}
```

**Direct installation:**
- Current directory: `uvx --from git+https://github.com/github/spec-kit.git specify init .`
- Specific folder: `uvx --from git+https://github.com/github/spec-kit.git specify init <folder>`

**Location:** `.speckit/` directory

**Usage:** `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`

**Repository:** https://github.com/github/spec-kit

---

### 3. OpenSpec / Spec-Workflow-MCP

**Best for:** Lightweight spec-driven workflow with optional MCP dashboard

**Two flavors:**

#### OpenSpec (Simple - File-based)

**Installation via devenv.nix:**
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.nodejs ];

  scripts.openspec-setup.exec = ''
    npx openspec-cli init
  '';

  enterShell = ''
    if [ ! -d .openspec ]; then
      echo "Run: openspec-setup"
    fi
  '';
}
```

**Direct installation:** `openspec init`

#### Spec-Workflow-MCP (Enhanced - with dashboard)

**Installation via devenv.nix:**
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.nodejs ];

  scripts.spec-mcp-dashboard.exec = ''
    npx -y @pimzino/spec-workflow-mcp@latest --dashboard
  '';

  scripts.spec-mcp-add.exec = ''
    claude mcp add spec-workflow npx -y @pimzino/spec-workflow-mcp@latest $(pwd)
  '';

  enterShell = ''
    echo "Run: spec-mcp-add (first time only)"
    echo "Run: spec-mcp-dashboard (to start dashboard on :5000)"
  '';
}
```

**Direct installation:** `claude mcp add spec-workflow npx -y @pimzino/spec-workflow-mcp@latest $(pwd)`

**Repositories:**
- https://github.com/Fission-AI/OpenSpec
- https://github.com/Pimzino/spec-workflow-mcp

---

### 4. Superpowers

**Best for:** Core skills library with automatic activation (no PM overhead)

**What it provides:**
- Auto-activating skills (TDD, systematic debugging, security review)
- Planning workflows (brainstorm, write-plan, execute-plan)
- Defense-in-depth security patterns
- Verification and testing protocols

**Installation method:**
Add to `.claude/settings.local.json`:
```json
{
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true
  },
  "extraKnownMarketplaces": {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    }
  }
}
```

**Usage:** `/superpowers:brainstorm`, `/superpowers:write-plan`, skills auto-activate

**Repository:** https://github.com/obra/superpowers-marketplace

---

### 5. Get Shit Done (GSD)

**Best for:** Solo developers wanting structured AI-assisted development without enterprise ceremony

**What it provides:**
- Context engineering with PROJECT.md, ROADMAP.md, and STATE.md
- Atomic 2-3 task phases executed in fresh subagents (prevents context degradation)
- XML-structured task planning with verification steps
- Individual git commits per task for traceability
- Brownfield project support via codebase mapping

**Installation via devenv.nix:**
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.nodejs ];

  scripts.gsd-setup.exec = ''
    npx get-shit-done-cc --local
  '';

  enterShell = ''
    if [ ! -f .claude/commands/gsd:new-project.md ]; then
      echo "Run: gsd-setup"
    fi
  '';
}
```

**Direct installation:** `npx get-shit-done-cc --local`

**Location:** `.claude/` directory (project-local only)

**Usage:** `/gsd:new-project`, `/gsd:create-roadmap`, `/gsd:map-codebase`, `/gsd:plan-phase`, `/gsd:execute-plan`

**Repository:** https://github.com/glittercowboy/get-shit-done

---

## Usage

```bash
# Interactive installation (asks which framework)
/install-workflow

# Direct installation in current directory
/install-workflow bmad
/install-workflow spec-kit
/install-workflow openspec
/install-workflow superpowers

# Install in specific folder
/install-workflow spec-kit my-project
/install-workflow openspec ./subfolder
```

## Installation Process

### Step 1: Parse Arguments

**Parse command line arguments:**
```bash
FRAMEWORK="${1:-}"  # First argument: framework name (optional)
FOLDER="${2:-.}"    # Second argument: target folder (defaults to current directory)
```

### Step 2: Framework Selection

If no framework argument provided, use AskUserQuestion to present options:

**Question:** "Which workflow framework would you like to install?"

**Options:**
1. **BMAD** - Full PM framework with 18+ agents and 40+ workflows (large teams)
2. **GitHub Spec Kit** - Structured spec-driven development (small teams)
3. **OpenSpec** - Lightweight spec workflow, file-based (solo developers)
4. **Spec-Workflow-MCP** - OpenSpec + real-time dashboard (solo developers, visual tracking)
5. **Superpowers** - Core skills library, auto-activating (minimal overhead, any team size)
6. **Get Shit Done** - Context engineering with subagent execution (solo developers, structured without ceremony)

### Step 3: Environment Detection

**Check for devenv.nix:**
```bash
if [ -f devenv.nix ]; then
  echo "Found devenv.nix - will add framework declaratively"
  USE_DEVENV=true
else
  echo "No devenv.nix - will install directly"
  USE_DEVENV=false
fi
```

**Check for .claude directory:**
```bash
if [ ! -d .claude ]; then
  mkdir -p .claude
fi
```

### Step 4: Framework Installation

#### For Superpowers (Marketplace installation):

```bash
# Find or create .claude/settings.local.json
SETTINGS_FILE=".claude/settings.local.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p .claude
  echo '{}' > "$SETTINGS_FILE"
fi

# Add superpowers marketplace and enable plugin
# This uses jq to merge the configuration properly
jq '. + {
  "enabledPlugins": (.enabledPlugins // {} | . + {"superpowers@superpowers-marketplace": true}),
  "extraKnownMarketplaces": (.extraKnownMarketplaces // {} | . + {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    }
  })
}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

echo "✓ Superpowers marketplace added to .claude/settings.local.json"
echo "Skills will auto-activate based on context"
echo "Commands available: /superpowers:brainstorm, /superpowers:write-plan, etc."
```

#### For BMAD:

**If devenv.nix exists:**
```bash
# Add BMAD configuration to devenv.nix
# - Add nodejs_20 to packages
# - Add bmad-setup script
# - Add enterShell notification

echo "✓ Added BMAD to devenv.nix"
echo "Run 'devenv shell' then 'bmad-setup' to complete installation"
```

**If no devenv.nix:**
```bash
# Check Node.js version
node --version  # Must be v20+

# Run interactive installer
npx bmad-method install
# - Select Claude Code as IDE
# - Choose .claude/commands/bmad/ directory
# - Select modules (Core + Method recommended)

echo "✓ BMAD installed"
echo "Available agents: /bmad-master, /bmad-architect, etc."
```

#### For Spec Kit:

**If devenv.nix exists:**
```bash
# Add Spec Kit configuration to devenv.nix
# - Add python3 and uv to packages
# - Add speckit-setup script
# - Add enterShell notification

echo "✓ Added Spec Kit to devenv.nix"
echo "Run 'devenv shell' then 'speckit-setup' to complete installation"
```

**If no devenv.nix:**
```bash
# Ensure uv is available
which uvx || pip install uv

# Initialize in current directory or specified folder
FOLDER="${1:-.}"
uvx --from git+https://github.com/github/spec-kit.git specify init "$FOLDER"

echo "✓ Spec Kit initialized in .speckit/"
echo "Start with: /speckit.constitution"
```

#### For OpenSpec:

**If devenv.nix exists:**
```bash
# Add OpenSpec configuration to devenv.nix
# - Add nodejs to packages
# - Add openspec-setup script
# - Add enterShell notification

echo "✓ Added OpenSpec to devenv.nix"
echo "Run 'devenv shell' then 'openspec-setup' to complete installation"
```

**If no devenv.nix:**
```bash
# Initialize OpenSpec
npx openspec-cli init

echo "✓ OpenSpec initialized in .openspec/"
echo "Follow documentation-driven workflow"
```

#### For Spec-Workflow-MCP:

**If devenv.nix exists:**
```bash
# Add Spec-Workflow-MCP configuration to devenv.nix
# - Add nodejs to packages
# - Add spec-mcp-add and spec-mcp-dashboard scripts
# - Add enterShell notification

echo "✓ Added Spec-Workflow-MCP to devenv.nix"
echo "Run 'devenv shell' then 'spec-mcp-add' to complete installation"
echo "Start dashboard with: spec-mcp-dashboard"
```

**If no devenv.nix:**
```bash
# Add MCP server to Claude Code
claude mcp add spec-workflow npx -y @pimzino/spec-workflow-mcp@latest $(pwd)

echo "✓ Spec-Workflow-MCP server added"
echo "Start dashboard: npx -y @pimzino/spec-workflow-mcp@latest --dashboard"
echo "Dashboard URL: http://localhost:5000"
```

#### For Get Shit Done (GSD):

**If devenv.nix exists:**
```bash
# Add GSD configuration to devenv.nix
# - Add nodejs to packages
# - Add gsd-setup script
# - Add enterShell notification

echo "✓ Added GSD to devenv.nix"
echo "Run 'devenv shell' then 'gsd-setup' to complete installation"
```

**If no devenv.nix:**
```bash
# Run installer with local flag (project-specific install)
npx get-shit-done-cc --local

echo "✓ GSD installed to .claude/"
echo "New projects: /gsd:new-project"
echo "Existing codebases: /gsd:map-codebase"
```

### Step 5: Verification & Next Steps

**Report installation results:**
- Show what was installed
- Display file/directory locations
- Provide first-use commands
- Link to documentation

## Compatibility Notes

**Can be used together:**
- Superpowers + any other framework (complementary)
- OpenSpec + Superpowers (minimal overhead)
- GSD + Superpowers (structured execution + skills)

**Potentially conflicting:**
- BMAD + Spec Kit (both provide full PM workflows)
- OpenSpec + Spec Kit (overlapping approaches)
- GSD + BMAD (both provide structured task execution)
- GSD + Spec Kit (overlapping spec-driven approaches)

**Best combinations:**
- **Solo dev, minimal overhead:** Superpowers only
- **Solo dev, structured:** OpenSpec + Superpowers or GSD + Superpowers
- **Small team:** Spec Kit + Superpowers
- **Large team:** BMAD + Superpowers

## Troubleshooting

**Superpowers clone fails:**
- Check git is installed
- Check network connectivity
- Try: `git clone --depth 1 https://github.com/obra/superpowers.git /tmp/superpowers-install`

**BMAD requires Node v20+:**
- Check: `node --version`
- If using devenv.nix: Ensure `pkgs.nodejs_20` in packages
- If not: Install Node v20: `nvm install 20` or similar

**Spec Kit uvx not found:**
- Install uv: `pip install uv` or `pipx install uv`
- Check PATH includes uv binaries
- If using devenv.nix: Add `pkgs.python3` and `pkgs.uv`

**OpenSpec command not found:**
- Install: `npm install -g openspec-cli`
- Or use npx: `npx openspec-cli init`

**MCP server conflicts:**
- Check existing servers: `claude mcp list`
- Remove if needed: `claude mcp remove spec-workflow`
- Ensure port 5000 available for dashboard

**GSD installation issues:**
- Ensure Node.js is installed: `node --version`
- Check npx available: `npx --version`
- Always use `--local` flag: `npx get-shit-done-cc --local`

**devenv.nix modifications:**
- Back up before editing: `cp devenv.nix devenv.nix.backup`
- Test shell: `devenv shell`
- Validate syntax if errors occur

## Examples

```bash
# Install Superpowers for skills-based development
/install-workflow superpowers

# Install BMAD for large team (will use devenv.nix if present)
/install-workflow bmad

# Install lightweight spec workflow for solo project
/install-workflow openspec

# Install GSD for structured solo development
/install-workflow gsd

# Install Spec Kit in a specific subfolder
/install-workflow spec-kit my-new-project

# Interactive installation with framework selection
/install-workflow
```

## devenv.nix Integration Benefits

**Why use devenv.nix when available:**
- **Reproducible:** Everyone gets same tool versions
- **Declarative:** Framework setup is documented in code
- **Isolated:** No global package pollution
- **Portable:** Works across different machines
- **Version-locked:** Consistent environment

**Project stays clean:**
- Setup commands documented in `devenv.nix`
- Easy onboarding: `devenv shell` then run setup script
- Framework tools available in dev shell only
