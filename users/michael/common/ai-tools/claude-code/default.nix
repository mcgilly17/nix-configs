{
  lib,
  pkgs,
  ...
}:

let
  # Auto-discover command files
  commandFiles = builtins.readDir ./commands;
  commandEntries = lib.filterAttrs (
    name: type: type == "regular" && lib.hasSuffix ".md" name
  ) commandFiles;
  commandFileAttrs = lib.mapAttrs' (
    name: _: lib.nameValuePair ".claude/commands/${name}" { source = ./commands/${name}; }
  ) commandEntries;

  # Auto-discover hook files
  hooksDir = ./hooks;
  hookFiles = builtins.readDir hooksDir;
  importHook = name: import (hooksDir + "/${name}") { inherit pkgs; };
  hooks = lib.foldl' (acc: name: acc // (importHook name)) { } (
    lib.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames hookFiles)
  );

in
{
  home.file = lib.mkMerge [
    commandFileAttrs
    {
      ".claude/CLAUDE.md".source = ./CLAUDE.md;
      ".claude/skill-rules.json".source = ./skill-rules.json;
      ".claude/agents".source = ./agents;
      ".claude/skills".source = ./skills;
    }
  ];

  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
      inherit hooks;
      permissions = {
        allow = [
          # Safe read-only git commands
          "Bash(git add:*)"
          "Bash(git status)"
          "Bash(git log:*)"
          "Bash(git diff:*)"
          "Bash(git show:*)"
          "Bash(git branch:*)"
          "Bash(git remote:*)"

          # Safe Nix commands (mostly read-only)
          "Bash(nix:*)"

          # Safe file system operations
          "Bash(ls:*)"
          "Bash(find:*)"
          "Bash(grep:*)"
          "Bash(rg:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(mkdir:*)"
          "Bash(chmod:*)"

          # Safe system info commands
          "Bash(systemctl list-units:*)"
          "Bash(systemctl list-timers:*)"
          "Bash(systemctl status:*)"
          "Bash(journalctl:*)"
          "Bash(dmesg:*)"
          "Bash(env)"
          "Bash(claude --version)"
          "Bash(nh search:*)"

          # Core Claude Code tools
          "Glob(*)"
          "Grep(*)"
          "LS(*)"
          "Read(*)"
          "Search(*)"
          "Task(*)"
          "TodoWrite(*)"

          # Safe web fetch from trusted domains
          "WebFetch(domain:github.com)"
          "WebFetch(domain:raw.githubusercontent.com)"
        ];
        ask = [
          # Potentially destructive git commands
          "Bash(git reset:*)"
          "Bash(git commit:*)"
          "Bash(git push:*)"
          "Bash(git pull:*)"
          "Bash(git merge:*)"
          "Bash(git rebase:*)"
          "Bash(git checkout:*)"
          "Bash(git switch:*)"
          "Bash(git stash:*)"

          # File deletion and modification
          "Bash(rm:*)"
          "Bash(mv:*)"
          "Bash(cp:*)"

          # System control operations
          "Bash(systemctl start:*)"
          "Bash(systemctl stop:*)"
          "Bash(systemctl restart:*)"
          "Bash(systemctl reload:*)"
          "Bash(systemctl enable:*)"
          "Bash(systemctl disable:*)"
          "Bash(systemctl mask:*)"
          "Bash(systemctl unmask:*)"

          # Network operations
          "Bash(curl:*)"
          "Bash(wget:*)"
          "Bash(ping:*)"
          "Bash(ssh:*)"
          "Bash(scp:*)"
          "Bash(rsync:*)"

          # Package management
          "Bash(sudo:*)"
          "Bash(nixos-rebuild:*)"

          # Process management
          "Bash(kill:*)"
          "Bash(killall:*)"
          "Bash(pkill:*)"
        ];
        deny = [
          # Sensitive files - secrets, credentials, keys
          "Read(.env)"
          "Read(.env.*)"
          "Read(**/secrets/*)"
          "Read(**/*credential*)"
          "Read(**/*.pem)"
          "Read(**/*.key)"
        ];
        defaultMode = "default";
      };
      verbose = true;
      includeCoAuthoredBy = false;

      statusLine = {
        type = "command";
        command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
        padding = 0;
      };
    };
  };
}
