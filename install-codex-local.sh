#!/bin/sh
# Mine Codex Local Installer

set -eu

PROJECT_PATH="${1:-$(pwd)}"
FORCE="${MINE_FORCE:-0}"
SOURCE_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_ROOT=$(CDPATH= cd -- "$PROJECT_PATH" && pwd)
MINE_ROOT="$TARGET_ROOT/.codex/mine"
BRAIN_ROOT="$TARGET_ROOT/.brain"
AGENTS_FILE="$TARGET_ROOT/AGENTS.md"

copy_directory_clean() {
    source_dir="$1"
    target_dir="$2"

    if [ -e "$target_dir" ]; then
        if [ "$FORCE" != "1" ]; then
            printf '%s\n' "Keeping existing $target_dir. Set MINE_FORCE=1 to replace it."
            return
        fi
        rm -rf "$target_dir"
    fi

    mkdir -p "$(dirname "$target_dir")"
    cp -R "$source_dir" "$target_dir"
}

copy_file_if_missing() {
    source_file="$1"
    target_file="$2"

    if [ ! -e "$target_file" ]; then
        mkdir -p "$(dirname "$target_file")"
        cp "$source_file" "$target_file"
    fi
}

printf '\n%s\n' "Mine Codex local setup"
printf '%s\n\n' "Project: $TARGET_ROOT"

mkdir -p "$MINE_ROOT"

for dir in workflows skills schemas templates; do
    copy_directory_clean "$SOURCE_ROOT/$dir" "$MINE_ROOT/$dir"
done

cp "$SOURCE_ROOT/README.md" "$MINE_ROOT/README.md"
cp "$SOURCE_ROOT/VERSION" "$MINE_ROOT/VERSION"

mkdir -p "$BRAIN_ROOT"
copy_file_if_missing "$SOURCE_ROOT/templates/brain.example.json" "$BRAIN_ROOT/brain.json"
copy_file_if_missing "$SOURCE_ROOT/templates/session.example.json" "$BRAIN_ROOT/session.json"
copy_file_if_missing "$SOURCE_ROOT/templates/history.example.json" "$BRAIN_ROOT/history.json"
copy_file_if_missing "$SOURCE_ROOT/templates/preferences.example.json" "$BRAIN_ROOT/preferences.json"

AGENTS_BLOCK='
<!-- mine-local:start -->
# Mine Local Framework

Use the local Mine framework in `.codex/mine`.

## Workflow Commands

When the user asks for one of these workflows, read and follow the matching file:

- `/brainstorm` -> `.codex/mine/workflows/coding/brainstorm.md`
- `/requirements` -> `.codex/mine/workflows/coding/requirements.md`
- `/plan` -> `.codex/mine/workflows/coding/plan.md`
- `/visualize` -> `.codex/mine/workflows/coding/visualize.md`
- `/code` -> `.codex/mine/workflows/coding/code.md`
- `/test` -> `.codex/mine/workflows/coding/test.md`
- `/debug` -> `.codex/mine/workflows/coding/debug.md`
- `/audit` -> `.codex/mine/workflows/coding/audit.md`
- `/refactor` -> `.codex/mine/workflows/coding/refactor.md`
- `/mock-api` -> `.codex/mine/workflows/coding/mock-api.md`
- `/recap` -> `.codex/mine/workflows/system/recap.md`
- `/save-brain` -> `.codex/mine/workflows/system/save_brain.md`
- `/next` -> `.codex/mine/workflows/system/next.md`
- `/customize` -> `.codex/mine/workflows/system/customize.md`
- `/mine-update` -> `.codex/mine/workflows/system/mine-update.md`

## Memory

Project memory lives in `.brain/`.

- Stable project knowledge: `.brain/brain.json`
- Current session state: `.brain/session.json`
- Cross-session handoff: `.brain/history.json`
- User/project preferences: `.brain/preferences.json`

Validate memory shape against `.codex/mine/schemas/` when editing manually.
<!-- mine-local:end -->
'

if [ -f "$AGENTS_FILE" ]; then
    if grep -q '<!-- mine-local:start -->' "$AGENTS_FILE"; then
        printf '%s\n' "AGENTS.md already has Mine local instructions"
    else
        printf '%s\n' "$AGENTS_BLOCK" >> "$AGENTS_FILE"
        printf '%s\n' "Updated AGENTS.md"
    fi
else
    printf '%s\n' "$AGENTS_BLOCK" | sed '1{/^$/d;}' > "$AGENTS_FILE"
    printf '%s\n' "Created AGENTS.md"
fi

printf '\n%s\n' "Done. Local Mine files are ready in:"
printf '  %s\n' "$MINE_ROOT"
printf '  %s\n' "$BRAIN_ROOT"
