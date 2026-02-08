{ pkgs, ... }:
{
  PostToolUse = [
    {
      matcher = "Write|Edit";
      hooks = [
        {
          type = "command";
          timeout = 60;
          command = ''
            input=$(cat)
            file_path=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.tool_input.file_path // .tool_input.path // empty')

            # Check if it's a dependency file
            case "$file_path" in
              */package.json)
                echo "Checking npm dependencies for vulnerabilities..."
                dir=$(dirname "$file_path")
                cd "$dir" 2>/dev/null && npm audit --audit-level=high 2>&1 | head -20 || true
                ;;
              */requirements.txt|*/pyproject.toml)
                if command -v pip-audit >/dev/null 2>&1; then
                  echo "Checking Python dependencies..."
                  dir=$(dirname "$file_path")
                  cd "$dir" 2>/dev/null && pip-audit 2>&1 | head -20 || true
                fi
                ;;
              */Cargo.toml)
                if command -v cargo-audit >/dev/null 2>&1; then
                  echo "Checking Rust dependencies..."
                  dir=$(dirname "$file_path")
                  cd "$dir" 2>/dev/null && cargo audit 2>&1 | head -20 || true
                fi
                ;;
              *)
                # Not a dependency file, skip
                ;;
            esac
            exit 0
          '';
        }
      ];
    }
  ];
}
