#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false

if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

link_dir() {
    local src="$1"
    local dst="$2"

    if [[ -e "$dst" || -L "$dst" ]]; then
        if $FORCE; then
            rm -rf "$dst"
        else
            echo "WARNING: skipping pre-existing skill $dst"
            return
        fi
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "Linked $dst -> $src"
}

# Skills
if [[ -d "$SCRIPT_DIR/skills" ]]; then
    for elem in "$SCRIPT_DIR/skills"/*/; do
        [[ -d "$elem" ]] || continue
        name="$(basename "$elem")"
        link_dir "$elem" "$HOME/.agents/skills/$name"
    done
fi

# Agents
if [[ -d "$SCRIPT_DIR/agents" ]]; then
    for elem in "$SCRIPT_DIR/agents"/*; do
        [[ -f "$elem" ]] || continue
        name="$(basename "$elem")"
        link_dir "$elem" "$HOME/.agents/agents/$name"

        if [[ -d "$HOME/.config/opencode" ]]; then
            link_dir "$elem" "$HOME/.config/opencode/agents/$name"
        fi
    done
fi
