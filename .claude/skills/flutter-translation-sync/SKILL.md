---
name: flutter-translation-sync
description: Synchronize and validate the three i18n JSON files (en.json, ru.json, uz.json) for the Autogram Flutter project. Use when the user asks to "add a translation", "tarjima qo'sh", "translation key qo'sh", "i18n sync", "find missing translations", or after editing any of `assets/l10n/*.json`. Detects missing keys across locales (walking the nested key tree), fills gaps with TODO markers, validates structure, and prevents key drift between languages.
---

# flutter-translation-sync

Keeps the three locale files in `assets/l10n/` aligned: every nested key path must exist in `en.json`, `ru.json`, and `uz.json`. Missing keys cause runtime `'auth.login'.tr()` to fall back to the literal key string — a silent UX bug.

## When to use

Trigger this skill when:
- User says "tarjima qo'sh", "add translation", "i18n sync", "translation key qo'sh"
- User wants to add a new `easy_localization` key (e.g., `'favorites.empty.title'.tr()`) and it isn't in any of the JSONs yet
- After any edit to `assets/l10n/*.json` — to verify no keys were dropped
- During PR review when translations were touched
- User reports "this string isn't translating" — likely a missing key in one locale

Do **not** use this skill for:
- Replacing translation strings with better wording (just edit the JSON directly)
- Changing locale loading code (that's in `lib/main.dart` / `lib/app.dart`)

## File layout

```
assets/l10n/
├── en.json    # English
├── ru.json    # Russian
└── uz.json    # Uzbek (default + fallback locale)
```

All three are **nested JSON** with section namespaces. Keys are referenced by **dot path** in code: `'auth.login'.tr()`, `'home.feed'.tr()`, `'errors.network'.tr()`.

Top-level namespaces include: `app_name`, `common`, `auth`, `home`, `feed`, `reels`, `saved`, `search`, `listing`, `profile`, `chat`, `seller`, `team`, `activity`, `errors`, `body_types`, `fuel_types`, `transmission_types`, `conditions`, `sort_options`, `notifications`, `settings`. Add a new namespace only when no existing one fits.

## Operations

### 1. Find missing keys

Use the script: `scripts/find_missing.py`

```bash
python3 .claude/skills/flutter-translation-sync/scripts/find_missing.py
```

Output: which **nested key paths** exist in some locales but are missing in others, grouped by locale. Walks the full tree depth-first and compares leaf-key paths.

### 2. Sync (add missing keys with TODO markers)

Use the script: `scripts/sync_translations.py`

```bash
python3 .claude/skills/flutter-translation-sync/scripts/sync_translations.py
```

Behavior: for every leaf key path that exists in any locale, fill the missing locales with a `"TODO: <full.dot.path>"` marker. Preserves the nested structure (creates sub-objects as needed). Writes UTF-8 with `ensure_ascii=False` (Cyrillic and Uzbek characters stay readable).

### 3. Add a new key across all locales

For a specific dot-path key the user provides, add it to **all three** files atomically:

```bash
python3 scripts/sync_translations.py --add favorites.empty.title "Sevimlilar bo'sh" --lang uz
```

This:
1. Adds `favorites.empty.title = "Sevimlilar bo'sh"` to `uz.json` (the user's specified locale, default `uz`).
2. Adds `favorites.empty.title = "TODO: favorites.empty.title"` to the other two files.
3. Creates the nested `favorites` and `favorites.empty` sub-objects automatically if they don't exist yet.
4. Writes all three files back, sorted within each level, UTF-8 with `ensure_ascii=False`.

The user-provided translation goes into the language they specified. After, the skill prompts them for the missing English / Russian translations (or accepts the TODO markers if they want to defer).

## Project conventions

1. **Nested JSON** — `'auth.login'.tr()` lookups walk the JSON tree (`json['auth']['login']`). `easy_localization` handles the dot-path resolution.
2. **Dot-path naming** — `<namespace>.<feature>.<sub_section?>.<key>` — e.g., `favorites.empty.title`, `auth.otp.invalid`. Use `snake_case` segments.
3. **TODO marker format** — `"TODO: <full.dot.path>"` so a regex sweep can find untranslated entries.
4. **Default locale + fallback is `uz`** — when in doubt, prioritize the Uzbek translation as authoritative. The app loads `uz` first.
5. **Sort within each level** — `sync_translations.py` sorts keys at every nesting level; preserve this on manual edits.
6. **UTF-8 without escapes** — Russian and Uzbek special characters (ʻ, ʼ, ё) must NOT be `\u00xx` escaped (`ensure_ascii=False`).
7. **2-space indentation** — matches the existing files.
8. **Don't mix flat keys at top-level with namespaced keys** — `app_name` is the only top-level scalar; everything else is a sub-object. If you're adding a new top-level scalar, ask first.

## Steps for "add a translation" flow

1. Confirm the dot-path key (segments are `snake_case`, no spaces, no quotes).
2. Confirm at least one translation (preferably Uzbek as the source of truth).
3. Run `python3 scripts/sync_translations.py --add <dot.path> "<value>" --lang <uz|ru|en>`.
4. Show the user the diff: what was added to each file.
5. Prompt for the missing translations (or accept TODO markers if the user wants to defer).
6. After applying, run `python3 scripts/find_missing.py` once more to verify zero drift.

## Anti-patterns

- Editing only one locale and assuming "I'll do the others later" — drift accumulates.
- Adding a flat top-level key (e.g., `cart_empty: "..."`) when a namespaced location fits (`cart.empty`). Stick to the nested structure.
- Inserting an English string into `uz.json` as a placeholder — use the explicit `"TODO: <path>"` marker so it's findable.
- Removing keys without checking usage with `grep -r "'<dot.path>'.tr()"` first.
- Renaming a top-level namespace (`auth` → `authentication`) without a code-wide find/replace — every `.tr()` call site uses the dot path.
- Hand-editing the JSON in a way that breaks the sort order — use the `sync` script after to normalize.
