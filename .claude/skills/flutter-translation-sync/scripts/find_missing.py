#!/usr/bin/env python3
"""Find translation keys that are present in some locales but missing in others.

Reads `assets/l10n/{en,ru,uz}.json` and reports drift across the three locales.
Walks the **nested** JSON tree and compares dot-path leaves (e.g., `auth.login`,
`favorites.empty.title`).

Exit code 0 means all locales have identical leaf-key sets; non-zero means drift.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

LOCALES = ("en", "ru", "uz")


def project_root() -> Path:
    env = os.environ.get("CLAUDE_PROJECT_DIR")
    if env:
        return Path(env)
    here = Path(__file__).resolve()
    # walk up until we find pubspec.yaml (project root)
    for parent in here.parents:
        if (parent / "pubspec.yaml").exists():
            return parent
    return Path.cwd()


def translations_dir() -> Path:
    return project_root() / "assets" / "l10n"


def load_locale(locale: str) -> dict:
    path = translations_dir() / f"{locale}.json"
    if not path.exists():
        print(f"ERROR: missing locale file: {path}", file=sys.stderr)
        sys.exit(2)
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def flatten(d: dict, prefix: str = "") -> dict[str, str]:
    """Walk a nested dict and yield {dot.path: leaf_value}.

    Non-dict, non-string scalars (numbers, bools) are kept; lists are JSON-stringified.
    """
    out: dict[str, str] = {}
    for k, v in d.items():
        path = f"{prefix}.{k}" if prefix else k
        if isinstance(v, dict):
            out.update(flatten(v, path))
        else:
            out[path] = v if isinstance(v, str) else json.dumps(v, ensure_ascii=False)
    return out


def main() -> int:
    flat = {loc: flatten(load_locale(loc)) for loc in LOCALES}

    all_keys: set[str] = set()
    for d in flat.values():
        all_keys.update(d.keys())

    print(f"Total unique leaf-key paths across locales: {len(all_keys)}")
    print(f"Per locale: " + ", ".join(f"{loc}={len(d)}" for loc, d in flat.items()))
    print()

    drift = False
    for loc, d in flat.items():
        missing = sorted(all_keys - set(d.keys()))
        if missing:
            drift = True
            print(f"{loc}.json missing {len(missing)} key path(s):")
            for k in missing:
                source = next(
                    (other for other in LOCALES if other != loc and k in flat[other]),
                    "?",
                )
                print(f"  - {k}  (present in: {source})")
            print()

    todo_count_by_locale: dict[str, list[str]] = {}
    for loc, d in flat.items():
        todos = [k for k, v in d.items() if isinstance(v, str) and v.startswith("TODO:")]
        if todos:
            todo_count_by_locale[loc] = todos

    if todo_count_by_locale:
        print("Existing TODO markers (untranslated entries):")
        for loc, todos in todo_count_by_locale.items():
            print(f"  {loc}.json: {len(todos)} TODO(s)")
            for k in todos[:5]:
                print(f"    - {k}")
            if len(todos) > 5:
                print(f"    ... and {len(todos) - 5} more")
        print()

    if not drift and not todo_count_by_locale:
        print("All locales aligned. No missing key paths, no TODO markers.")
        return 0

    if drift:
        print("Drift detected. Run sync_translations.py to add missing key paths with TODO markers.")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
