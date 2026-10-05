#!/usr/bin/env bash
# Copies the files listed in manifest.txt from the live IntelliJ config into ./config,
# and refreshes plugins.txt. Pass --commit to commit the result.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

commit=false
[[ "${1:-}" == "--commit" ]] && commit=true

config_dir="$(find_config_dir)"
echo "Exporting from $config_dir"

while read -r entry; do
  source_path="$config_dir/$entry"
  target_path="$STORED_CONFIG_DIR/$entry"
  if [[ ! -e "$source_path" ]]; then
    echo "  skipped (not found): $entry"
    continue
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

list_plugin_ids "$(find_plugins_dir "$config_dir")" > "$PLUGINS_FILE"

git -C "$REPO_DIR" add --all
if git -C "$REPO_DIR" diff --cached --quiet; then
  echo "No changes."
  exit 0
fi
git -C "$REPO_DIR" diff --cached --stat

if $commit; then
  git -C "$REPO_DIR" commit --quiet -m "Update IntelliJ config ($(date +%F))"
  echo "Committed."
else
  echo "Changes are staged. Commit them yourself, or run with --commit."
fi
