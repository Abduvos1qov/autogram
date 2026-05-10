# Backend Migration TODO

This file tracks Supabase schema changes the frontend now expects but the
backend hasn't received yet. The Dart entities/models tolerate missing rows
(nullable fields + `fromAny` polymorphic decoders), so the app runs against
the current production schema — but until the migrations land, the new
features won't fully round-trip.

Run these against Supabase in order. Each block is idempotent.

## 1. `seller_profiles` — username, contact person

```sql
ALTER TABLE seller_profiles ADD COLUMN IF NOT EXISTS username TEXT;
ALTER TABLE seller_profiles ADD CONSTRAINT seller_username_unique UNIQUE (username);
ALTER TABLE seller_profiles ADD CONSTRAINT seller_username_format
  CHECK (username IS NULL OR username ~ '^[a-z0-9_]{3,30}$');

ALTER TABLE seller_profiles ADD COLUMN IF NOT EXISTS contact_person_name TEXT;
ALTER TABLE seller_profiles ADD COLUMN IF NOT EXISTS contact_person_role TEXT;
```

## 2. `user_profiles` — username

```sql
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS username TEXT;
ALTER TABLE user_profiles ADD CONSTRAINT user_username_unique UNIQUE (username);
ALTER TABLE user_profiles ADD CONSTRAINT user_username_format
  CHECK (username IS NULL OR username ~ '^[a-z0-9_]{3,30}$');
```

## 3. `seller_profiles.contact_phones` — text[] → jsonb

The frontend now sends labelled phones as JSONB objects:
`[{"phone": "+998...", "label": "sales"}, ...]`. The decoder still accepts
the legacy `text[]` shape (each string becomes a `{phone, label: "other"}`
row), so this can be deferred — but until you migrate, sellers won't see
their saved labels.

```sql
ALTER TABLE seller_profiles
  ALTER COLUMN contact_phones TYPE JSONB USING (
    to_jsonb(array(
      SELECT jsonb_build_object('phone', x, 'label', 'other')
      FROM unnest(contact_phones) x
    ))
  );
```

## 4. Auth — email/phone change

No schema work needed. `auth.updateUser(...)` and
`auth.verifyOTP(type: emailChange | phoneChange)` are stock Supabase. Make
sure the Supabase dashboard has:

- **Authentication > Providers > Email** — "Secure email change" enabled.
- **Authentication > Email Templates > Change email address** — uses
  `{{ .Token }}` (6-digit OTP), same template style as the other auth flows
  (see CLAUDE.md "Supabase Dashboard Setup" for the existing recipe).

## Verification after migration

1. `select column_name, data_type from information_schema.columns where table_name = 'seller_profiles' order by 1;` — confirms the 3 new columns + `contact_phones` is `jsonb`.
2. Insert a labelled phone via the Edit Profile screen, refresh → label persists across sessions.
3. Change email from Account Settings → confirmation OTP sent.
4. Change password from Account Settings → next sign-in works with the new password.
