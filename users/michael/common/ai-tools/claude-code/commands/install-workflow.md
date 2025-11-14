---
allowed-tools: Bash, AskUserQuestion, Read, Write, Edit
argument-hint: "[framework-name]"
description: Install AI development workflow framework (BMAD, Spec Kit, OpenSpec, or Superpowers)
---

# Install Workflow Command

Installs AI development workflow frameworks into your project with intelligent setup.

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
    PROJECT_NAME=$(basename $(pwd))
    uvx --from git+https://github.com/github/spec-kit.git specify init $PROJECT_NAME
  '';

  enterShell = ''
    if [ ! -d .speckit ]; then
      echo "Run: speckit-setup"
    fi
  '';
}
```

**Direct installation:** `uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>`

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
1. Clone repository: `git clone https://github.com/obra/superpowers.git /tmp/superpowers`
2. Copy to project: `cp -r /tmp/superpowers/.claude/* .claude/`
3. Clean up: `rm -rf /tmp/superpowers`

**Location:** `.claude/skills/superpowers/` and `.claude/commands/superpowers/`

**Usage:** `/superpowers:brainstorm`, `/superpowers:write-plan`, skills auto-activate

**Repository:** https://github.com/obra/superpowers

---

## Usage

```bash
# Interactive installation (asks which framework)
/install-workflow

# Direct installation
/install-workflow bmad
/install-workflow spec-kit
/install-workflow openspec
/install-workflow superpowers
```

## Installation Process

### Step 1: Framework Selection

If no argument provided, use AskUserQuestion to present options:

**Question:** "Which workflow framework would you like to install?"

**Options:**
1. **BMAD** - Full PM framework with 18+ agents and 40+ workflows (large teams)
2. **GitHub Spec Kit** - Structured spec-driven development (small teams)
3. **OpenSpec** - Lightweight spec workflow, file-based (solo developers)
4. **Spec-Workflow-MCP** - OpenSpec + real-time dashboard (solo developers, visual tracking)
5. **Superpowers** - Core skills library, auto-activating (minimal overhead, any team size)

### Step 2: Environment Detection

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

### Step 3: Framework Installation

#### For Superpowers (Always file-based):

```bash
# Clone superpowers repo to temp location
git clone https://github.com/obra/superpowers.git /tmp/superpowers-install

# Copy contents to project .claude folder
cp -r /tmp/superpowers-install/.claude/* .claude/

# Clean up
rm -rf /tmp/superpowers-install

# Verify installation
ls -la .claude/skills/superpowers/
ls -la .claude/commands/superpowers/

echo "✓ Superpowers installed to .claude/"
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

# Initialize with project name
PROJECT_NAME=$(basename $(pwd))
uvx --from git+https://github.com/github/spec-kit.git specify init $PROJECT_NAME

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

### Step 4: Verification & Next Steps

**Report installation results:**
- Show what was installed
- Display file/directory locations
- Provide first-use commands
- Link to documentation

## Compatibility Notes

**Can be used together:**
- Superpowers + any other framework (complementary)
- OpenSpec + Superpowers (minimal overhead)

**Potentially conflicting:**
- BMAD + Spec Kit (both provide full PM workflows)
- OpenSpec + Spec Kit (overlapping approaches)

**Best combinations:**
- **Solo dev, minimal overhead:** Superpowers only
- **Solo dev, structured:** OpenSpec + Superpowers
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
