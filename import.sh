#!/usr/bin/env bash
# Copies ./config into the IntelliJ config dir. Files that would be overwritten are backed up first.
# Flags: --plugins installs plugins.txt via `idea installPlugins`; --force skips the "IDE is running" check.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

install_plugins=false
force=false
for arg in "$@"; do
  case "$arg" in
    --plugins) install_plugins=true ;;
    --force) force=true ;;
    *) echo "Unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# IntelliJ rewrites its config on exit, which would undo the import.
if ! $force && ide_is_running; then
  echo "IntelliJ is running. Close it first (or use --force)." >&2
  exit 1
fi

config_dir="$(find_config_dir)"
backup_dir="$config_dir.backup-$(date +%Y%m%d-%H%M%S)"
echo "Importing to $config_dir"

while read -r entry; do
  source_path="$STORED_CONFIG_DIR/$entry"
  target_path="$config_dir/$entry"
  [[ -e "$source_path" ]] || continue
  if [[ -e "$target_path" ]]; then
    mkdir -p "$(dirname "$backup_dir/$entry")"
    cp -r "$target_path" "$backup_dir/$entry"
  fi
  if [[ "$entry" == */ ]]; then
    rm -rf "$target_path"
    mkdir -p "$target_path"
    cp -r "$source_path." "$target_path"
  else
    mkdir -p "$(dirname "$target_path")"
    cp "$source_path" "$target_path"
  fi
done < <(manifest_entries)

[[ -d "$backup_dir" ]] && echo "Overwritten files were backed up to $backup_dir"

if $install_plugins; then
  mapfile -t plugin_ids < "$PLUGINS_FILE"
  if ((${#plugin_ids[@]} > 0)); then
    "${IDEA_CMD:-idea}" installPlugins "${plugin_ids[@]}"
  fi
else
  echo "Plugins to install (run with --plugins, or use Settings → Plugins):"
  sed 's/^/  /' "$PLUGINS_FILE"
fi
echo "Done. Start IntelliJ."
