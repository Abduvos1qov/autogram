#!/usr/bin/env python3
"""Sync the three locale JSON files: ensure every nested leaf key path exists in en, ru, uz.

For any leaf path present in one or more locales but missing in others, fill the
missing locales with the marker "TODO: <full.dot.path>". Walks the nested tree and
inserts intermediate sub-objects as needed. Sorts each level alphabetically. Writes
UTF-8 with `ensure_ascii=False` so Cyrillic / Uzbek characters stay legible.

Usage:
  python3 sync_translations.py
      Sync existing key paths across locales (fill missing with TODO markers).

  python3 sync_translations.py --add KEY VAL
      Add a new dot-path key with a translation in the default locale (uz).

  python3 sync_translations.py --add KEY VAL --lang en
      Add with explicit locale.

  python3 sync_translations.py --dry-run
      Don't write files; just print what would change.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any

LOCALES = ("en", "ru", "uz")
DEFAULT_LOCALE = "uz"


def project_root() -> Path:
    env = os.environ.get("CLAUDE_PROJECT_DIR")
    if env:
        return Path(env)
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "pubspec.yaml").exists():
            return parent
    return Path.cwd()


def translations_dir() -> Path:
    return project_root() / "assets" / "l10n"


def load_locale(locale: str) -> dict:
    path = translations_dir() / f"{locale}.json"
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def sort_nested(value: Any) -> Any:
    """Recursively sort dict keys alphabetically at every level."""
    if isinstance(value, dict):
        return {k: sort_nested(value[k]) for k in sorted(value.keys())}
    if isinstance(value, list):
        return [sort_nested(v) for v in value]
    return value


def write_locale(locale: str, data: dict) -> None:
    path = translations_dir() / f"{locale}.json"
    sorted_data = sort_nested(data)
    with path.open("w", encoding="utf-8") as f:
        json.dump(sorted_data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def flatten(d: dict, prefix: str = "") -> dict[str, str]:
    out: dict[str, str] = {}
    for k, v in d.items():
        path = f"{prefix}.{k}" if prefix else k
        if isinstance(v, dict):
            out.update(flatten(v, path))
        else:
            out[path] = v if isinstance(v, str) else json.dumps(v, ensure_ascii=False)
    return out


def set_nested(d: dict, dot_path: str, value: Any) -> None:
    """Set d[a][b][c] = value given dot_path 'a.b.c'. Creates sub-objects as needed.

    Raises ValueError if the path collides with a non-dict value at an intermediate level
    (e.g., d[a] = 'string' but you're trying to set d[a][b]).
    """
    parts = dot_path.split(".")
    cursor = d
    for part in parts[:-1]:
        if part in cursor and not isinstance(cursor[part], dict):
            raise ValueError(
                f"Cannot set '{dot_path}': intermediate '{part}' is "
                f"a {type(cursor[part]).__name__}, not a dict."
            )
        cursor = cursor.setdefault(part, {})
    cursor[parts[-1]] = value


def has_nested(d: dict, dot_path: str) -> bool:
    parts = dot_path.split(".")
    cursor: Any = d
    for part in parts:
        if not isinstance(cursor, dict) or part not in cursor:
            return False
        cursor = cursor[part]
    return True


def todo_marker(path: str) -> str:
    return f"TODO: {path}"


def sync(locales: dict[str, dict]) -> tuple[dict[str, int], int]:
    """Add missing leaf paths to each locale with TODO markers. Returns (additions, total)."""
    flat = {loc: flatten(d) for loc, d in locales.items()}
    all_keys: set[str] = set()
    for f in flat.values():
        all_keys.update(f.keys())

    additions: dict[str, int] = {loc: 0 for loc in LOCALES}
    for loc in LOCALES:
        for path in all_keys:
            if not has_nested(locales[loc], path):
                set_nested(locales[loc], path, todo_marker(path))
                additions[loc] += 1

    return additions, len(all_keys)


def add_key(
    locales: dict[str, dict],
    path: str,
    value: str,
    lang: str,
) -> list[str]:
    """Add a single dot-path key with `value` in `lang`, TODO markers in others.

    Returns list of locales that received a TODO marker.
    """
    if lang not in LOCALES:
        raise SystemExit(f"--lang must be one of {LOCALES}, got: {lang}")
    if not path or " " in path or "." not in path:
        raise SystemExit(
            "Key must be a dot-path with at least one segment, no spaces "
            "(e.g., 'auth.login' or 'favorites.empty.title')."
        )
    for segment in path.split("."):
        if not segment or " " in segment:
            raise SystemExit(f"Invalid path segment: {segment!r}")

    todo_added: list[str] = []
    for loc in LOCALES:
        if loc == lang:
            set_nested(locales[loc], path, value)
        elif not has_nested(locales[loc], path):
            set_nested(locales[loc], path, todo_marker(path))
            todo_added.append(loc)
    return todo_added


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "--add",
        nargs=2,
        metavar=("KEY", "VALUE"),
        help="Add a single dot-path key + value. Other locales get TODO markers.",
    )
    p.add_argument(
        "--lang",
        default=DEFAULT_LOCALE,
        choices=LOCALES,
        help=f"Locale for --add value (default: {DEFAULT_LOCALE}).",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Don't write files; just print what would change.",
    )
    args = p.parse_args()

    locales = {loc: load_locale(loc) for loc in LOCALES}

    if args.add:
        path, value = args.add
        todo_added = add_key(locales, path, value, args.lang)
        print(f"Added '{path}' = {value!r} in {args.lang}.json")
        if todo_added:
            print(f"TODO marker added in: {', '.join(t + '.json' for t in todo_added)}")
        else:
            print(f"All other locales already had '{path}' — no TODO needed.")

    additions, total = sync(locales)
    print(f"\nTotal unique leaf-key paths: {total}")
    for loc in LOCALES:
        if additions[loc]:
            print(f"  {loc}.json: +{additions[loc]} TODO marker(s)")
        else:
            print(f"  {loc}.json: no changes")

    if args.dry_run:
        print("\n--dry-run: skipping writes.")
        return 0

    for loc, data in locales.items():
        write_locale(loc, data)

    print("\nWrote en.json, ru.json, uz.json (sorted within each level, UTF-8).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
