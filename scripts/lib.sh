#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used by the scripts that source this file
# Shared helpers, sourced by export.sh and import.sh.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORED_CONFIG_DIR="$REPO_DIR/config"
MANIFEST="$REPO_DIR/manifest.txt"
PLUGINS_FILE="$REPO_DIR/plugins.txt"

# Newest IntelliJIdea* dir unless INTELLIJ_CONFIG_DIR is set.
find_config_dir() {
  if [[ -n "${INTELLIJ_CONFIG_DIR:-}" ]]; then
    echo "$INTELLIJ_CONFIG_DIR"
    return
  fi
  local found
  found="$(find "$HOME/.config/JetBrains" -maxdepth 1 -type d -name 'IntelliJIdea*' 2>/dev/null | sort -V | tail -n 1)"
  if [[ -z "$found" ]]; then
    echo "No IntelliJIdea* directory found under ~/.config/JetBrains." >&2
    echo "Start IntelliJ once, or set INTELLIJ_CONFIG_DIR." >&2
    return 1
  fi
  echo "$found"
}

# User-installed plugins live in ~/.local/share/JetBrains/<same version dir name>.
find_plugins_dir() {
  echo "${INTELLIJ_PLUGINS_DIR:-$HOME/.local/share/JetBrains/$(basename "$1")}"
}

manifest_entries() {
  grep -vE '^[[:space:]]*(#|$)' "$MANIFEST"
}

ide_is_running() {
  pgrep -f 'com.intellij.idea.Main|/bin/idea( |$)' >/dev/null
}

# IDs of plugins installed under the user plugins dir, one per line.
list_plugin_ids() {
  local plugins_dir="$1" plugin jar id
  [[ -d "$plugins_dir" ]] || return 0
  for plugin in "$plugins_dir"/*/; do
    for jar in "$plugin"lib/*.jar; do
      id="$(unzip -p "$jar" META-INF/plugin.xml 2>/dev/null | grep -m1 -oP '(?<=<id>)[^<]+')" || true
      if [[ -n "$id" ]]; then
        echo "$id"
        break
      fi
    done
  done | sort -u
}
