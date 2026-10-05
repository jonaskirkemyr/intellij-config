# intellij-config

My IntelliJ setup: keymap, theme, fonts, vmoptions, plugin list and a shell helper.
`manifest.txt` decides which files are tracked. Machine-specific and private files are left out on purpose.

## Update the repo

Run after changing something in IntelliJ:

```sh
./export.sh            # copy live config into ./config and stage it
./export.sh --commit   # same, and commit
```

IntelliJ can stay open while exporting. Changes made in Settings are written to disk straight away.
`options/other.xml` contains some UI state, so it may show small diffs that aren't real changes.

## Set up a new machine

1. Install IntelliJ and start it once, so `~/.config/JetBrains/IntelliJIdea<version>` exists. Then close it.
2. Clone this repo and run:

   ```sh
   ./import.sh            # copy config into place
   ./import.sh --plugins  # ...and install the plugins in plugins.txt
   ```

   Files that get overwritten are backed up to `<config dir>.backup-<timestamp>`.
   The script refuses to run while IntelliJ is open, because IntelliJ rewrites its config on exit.
3. Add the `idea` function to `~/.zshrc`:

   ```sh
   source ~/git/jonask/intellij-config/shell/idea.zsh
   ```

   It starts IntelliJ in the background, so closing the terminal doesn't kill it.
4. Start IntelliJ.

`--plugins` runs `idea installPlugins`. If that fails, install the plugins from `plugins.txt` in Settings → Plugins.

## Options

- `INTELLIJ_CONFIG_DIR`: use this config dir instead of the newest `IntelliJIdea*` under `~/.config/JetBrains`.
- `INTELLIJ_PLUGINS_DIR`: user plugin dir, defaults to `~/.local/share/JetBrains/<same version dir>`.
- `IDEA_CMD`: launcher used by `--plugins`, defaults to `idea`.

## Not tracked

JDK paths (`jdk.table.xml`), recent and trusted projects, database connections, SSL certificates,
window state and usage statistics. Set up JDKs again on the new machine.
