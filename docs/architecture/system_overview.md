# System Architecture - Mine Framework

## Overview
Mine is a workflow framework for human-AI collaboration inside AI-first IDEs such as Antigravity and Cursor. It acts as a layer on top of the IDE: users trigger slash commands, and the AI follows structured workflows, persists project memory, and restores context across work sessions.

## Core Components

### 1. Global Workflows (`workflows/coding/`, `workflows/system/`)
- Markdown workflows define the expected behavior for commands such as `/plan`, `/code`, `/save-brain`, and `/recap`.
- The AI reads these files as operating instructions for each role and task.

### 2. Schemas & Templates (`schemas/`, `templates/`)
- Schemas define the structure for persistent memory files.
- Templates provide starter examples for new projects.
- The memory model now includes `brain.json`, `session.json`, and `history.json`.

### 3. Memory System (`.brain/`)
- `brain.json`: stable project knowledge that has been verified from code, docs, or Git-backed changes.
- `session.json`: the current working snapshot, including branch, HEAD, task in progress, pending work, and local uncommitted state.
- `history.json`: cross-session handoff entries anchored to commit ranges so `/recap` can reconstruct what changed between days.

### 4. Installation & Maintenance Scripts
- `install.ps1` / `install.sh`: install workflows, schemas, templates, and skills into the user's global Mine directory.
- `uninstall.ps1` / `uninstall.sh`: remove the installed Mine resources.

### 5. Skill Catalog (`skills/`)
- Bundled skills are grouped by domain under `skills/frontend/`, `skills/backend/`, `skills/quality/`, `skills/media/`, and `skills/system/`.
- Installation keeps the public skill names stable in the user's global Mine directory.

## Data Flow
1. The user triggers a workflow command such as `/plan` or `/save-brain`.
2. The AI reads the matching workflow file.
3. The AI loads `.brain/brain.json`, `.brain/session.json`, and `.brain/history.json` when available.
4. For memory-sensitive commands, the AI reconciles the loaded memory with the current Git state.
5. The AI performs the requested task.
6. The AI updates:
   - `brain.json` for stable project facts
   - `session.json` for the latest working snapshot
   - `history.json` for session-to-session handoff
