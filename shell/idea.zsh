# Start IntelliJ detached from the terminal so closing the terminal doesn't kill it (like `code .`)
idea() {
  command idea "$@" >/dev/null 2>&1 &!
}
