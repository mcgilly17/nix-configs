_: {
  SessionStart = [
    {
      matcher = "*";
      hooks = [
        {
          type = "command";
          command = ''
            echo "=== Git Status ==="
            git status --short 2>/dev/null || echo "Not a git repository"
            echo ""
            echo "=== Recent Commits ==="
            git log --oneline -5 2>/dev/null || true
          '';
        }
      ];
    }
  ];
}
