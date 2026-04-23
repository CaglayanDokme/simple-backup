# Shell Coding Guidelines

This document outlines coding standards and best practices for this project. All shell scripts should follow these conventions to maintain consistency, safety, and readability.

## File Structure & Headers

- Use `#!/bin/bash` shebang for all scripts
- Add a header comment explaining the script's purpose
- Start all scripts with `set -euo pipefail` for safety

```bash
#!/bin/bash

# ============================================================================
# Brief description of script purpose
# ============================================================================

set -euo pipefail
```

## Variable Conventions

### Naming

- Use **snake_case** for all variable names (e.g., `backup_file`, `source_dir`, `is_valid`)
- Use **UPPER_CASE** for constants and readonly variables
- Use descriptive names that clearly indicate purpose

### Declarations

- Declare all global variables at the top of the script after `set -euo pipefail`
- Use `readonly` for immutable values to prevent accidental reassignment:
  ```bash
  readonly SCRIPT_NAME="$(basename "$0")"
  readonly DEFAULT_EXTENSION=".bkp"
  ```
- Use `local` for all function variables to prevent polluting the global scope:
  ```bash
  backup_file() {
      local source="$1"
      local destination="$2"
      # ...
  }
  ```

### Quoting

- **Always double-quote variable references** to handle spaces and special characters safely:
  ```bash
  cp "$source" "$destination"  # Correct
  cp $source $destination      # Incorrect - breaks with spaces
  ```
- Use `${var}` for clarity when needed:
  ```bash
  echo "${filename}.bkp"
  ```
- Avoid unquoted expansions unless explicitly working with word splitting

## Error Handling & Safety

### Trap & Cleanup

- Use `trap` to ensure cleanup runs on exit:
  ```bash
  cleanup() {
      if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
          rm -rf "$TEMP_DIR"
      fi
  }
  trap cleanup EXIT
  ```

### Error Messages

- Redirect error messages to stderr using `>&2`
- Provide clear, actionable messages with context:
  ```bash
  echo "Error: source file does not exist: $source" >&2
  exit 1
  ```

### Parameter Validation

- Validate all required parameters before execution
- Check file/directory existence before use:
  ```bash
  if [[ ! -f "$source" ]]; then
      echo "Error: file not found: $source" >&2
      exit 1
  fi
  ```

### Exit Codes

- Exit with `0` on success
- Exit with non-zero (typically `1`) on failure
- Use consistent exit codes across the project

## Conditional & Loop Syntax

- Use `[[ ]]` instead of `[ ]` for conditional tests (modern Bash):
  ```bash
  if [[ -f "$file" ]]; then      # Correct
      ...
  fi

  if [ -f "$file" ]; then        # Avoid
      ...
  fi
  ```

- Use `[[ ]]` for string comparisons:
  ```bash
  if [[ "$mode" == "recursive" ]]; then
      ...
  fi
  ```

## Function Structure

- Define functions before they are called
- Use a clear naming convention: `action_target` (e.g., `validate_source`, `backup_file`)
- Keep functions focused and reusable:
  ```bash
  validate_source() {
      local source="$1"
      if [[ ! -e "$source" ]]; then
          echo "Error: source does not exist: $source" >&2
          return 1
      fi
  }
  ```

## ShellCheck Compliance

- Run ShellCheck on all scripts to catch common errors:
  ```bash
  shellcheck src/backup.sh
  ```

- Address all warnings and errors
- Use directive comments for justified exceptions:
  ```bash
  # shellcheck disable=SC2086  # Explanation for disabling this check
  ```

- Common issues to watch for:
  - Unquoted variables
  - Missing local declarations
  - Incorrect conditionals
  - Unsafe command substitution

## Command Substitution

- Use `$()` instead of backticks:
  ```bash
  current_time="$(date +%s)"  # Correct
  current_time=`date +%s`     # Avoid
  ```

## Argument Parsing

- Validate argument count before processing
- Support both short and long flags:
  ```bash
  while [[ $# -gt 0 ]]; do
      case $1 in
          -r|--recursive)
              recursive=true
              shift
              ;;
          -f|--force)
              force=true
              shift
              ;;
          --)
              shift
              break
              ;;
          *)
              echo "Error: unknown option: $1" >&2
              exit 1
              ;;
      esac
  done
  ```

- Support combined short flags where appropriate (e.g., `-rf`)

## Testing

- Write scenario-based tests in `test/` directory
- Each test script validates one specific behavior
- Use helper functions from `test/testlib.bash`
- All tests should be executable: `bash test/scenario-name.sh`

## Code Style

- Use 4 spaces for indentation (no tabs)
- Keep lines readable; break long commands into multiple lines:
  ```bash
  cp \
      --verbose \
      --archive \
      --no-preserve=mode \
      "$source" "$destination"
  ```

- Avoid unnecessary echo statements; use concise output
- Keep functions and scripts focused and maintainable

## Dependency Awareness

- Minimize external dependencies; use only standard Bash and common coreutils
- Document any version or portability requirements
- Fail fast with a clear message if required tools are unavailable:
  ```bash
  if ! command -v jq &> /dev/null; then
      echo "Error: jq is required but not installed" >&2
      exit 1
  fi
  ```

## Example: Well-Formatted Function

```bash
# Create a backup of a file with optional force overwrite
backup_file() {
    local source="$1"
    local destination="$2"
    local force="${3:-false}"

    if [[ ! -f "$source" ]]; then
        echo "Error: source file not found: $source" >&2
        return 1
    fi

    if [[ -f "$destination" && "$force" != "true" ]]; then
        echo "Error: destination already exists: $destination" >&2
        return 1
    fi

    cp "$source" "$destination" || {
        echo "Error: failed to copy file" >&2
        return 1
    }
}
```
