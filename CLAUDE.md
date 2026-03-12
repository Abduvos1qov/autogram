# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Autogram is a mobile car marketplace for Uzbekistan with a TikTok/Reels-style video browsing experience. Built with Flutter, Supabase backend, and Cloudflare Stream for video hosting. Currently in first phase — automobiles only (real estate planned later).

## Build & Run Commands

```bash
# Run the app (debug)
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Run tests
flutter test

# Run a single test file
flutter test test/core/utils/validators_test.dart

# Analyze code
flutter analyze

# Generate code (injectable, freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

**Clean Architecture + BLoC** with three layers per feature module:

```
lib/
├── main.dart / app.dart / bootstrap.dart   # App entry & initialization
├── core/                                    # Shared infrastructure
│   ├── config/        # EnvConfig (Supabase creds), AppConfig, TestConfig
│   ├── errors/        # Failure types (ServerFailure, NetworkFailure, etc.)
│   ├── network/       # Dio ApiClient with Auth/Error/Logging interceptors
│   ├── database/      # SQLite via DatabaseHelper
│   ├── services/      # StorageService, SecureStorageService
│   ├── theme/         # AppTheme, AppColors, AppTypography, AppSpacing
│   ├── widgets/       # Reusable UI components (buttons, inputs, feedback)
│   └── usecases/      # Base UseCase<Type, Params> class
├── features/           # 14 feature modules (see below)
├── di/injection.dart   # GetIt manual registration
└── navigation/         # GoRouter with auth-aware redirects
```

**Each feature follows this structure:**
- `domain/` — entities, abstract repository interfaces, use cases
- `data/` — models (extend entities), data sources, repository implementations
- `presentation/` — BLoC (events/states), screens, widgets

**Key features:** auth, home, reels, search, listing, saved, chat, profile, notifications, seller, create_listing, boost, reviews, settings

## Key Patterns

- **Error handling:** `dartz` Either pattern — `Left(Failure)` / `Right(SuccessData)` throughout repositories and use cases
- **DI:** Manual GetIt registration in `di/injection.dart` — LazySingleton for repos/services, Factory for BLoCs
- **Navigation:** GoRouter with `StatefulShellRoute` for 5 bottom tabs (Home, Reels, Search, Chat, Profile)
- **State management:** BLoC with separate event/state files per feature, all provided in `app.dart`
- **Localization:** `easy_localization` with JSON files in `assets/l10n/` (uz, ru, en). Uzbek is default/fallback.

## Test Mode

Test mode is enabled by default (`TestConfig.isTestMode = true` in `lib/core/config/test_config.dart`). Uses mock data sources with 500ms simulated delay. Test credentials: any email with OTP `123456`, or sign in with `test@autogram.uz` / `Test1234!`. Mock data lives in `lib/core/data/mock_data.dart`.

## Auth Flows

- **Sign-up:** Register → Email OTP verification (6-digit code) → Username selection → Home
- **Forgot password:** Email input → OTP verification → New password → Login
- Test mode OTP code: `123456` for all emails

## Supabase Dashboard Setup (TODO)

Production uchun Supabase dashboardda quyidagilarni sozlash kerak:

1. **Authentication > Providers > Email:**
   - "Confirm email" — enabled
   - "Secure email change" — enabled
   - "OTP Expiry" — 600 sekund (10 daqiqa)

2. **Authentication > Email Templates — Confirm signup:**
   - `{{ .ConfirmationURL }}` o'rniga `{{ .Token }}` ishlatish
   - Shablon:
   ```html
   <h2>Tasdiqlash kodi</h2>
   <p>Autogram ilovasida ro'yxatdan o'tish uchun tasdiqlash kodingiz:</p>
   <h1 style="font-size: 32px; letter-spacing: 8px; text-align: center;">{{ .Token }}</h1>
   <p>Kod 10 daqiqa ichida amal qiladi.</p>
   ```

3. **Authentication > Email Templates — Reset password:**
   - `{{ .ConfirmationURL }}` o'rniga `{{ .Token }}` ishlatish
   - Shablon:
   ```html
   <h2>Parolni tiklash</h2>
   <p>Parolni tiklash uchun tasdiqlash kodingiz:</p>
   <h1 style="font-size: 32px; letter-spacing: 8px; text-align: center;">{{ .Token }}</h1>
   <p>Kod 10 daqiqa ichida amal qiladi.</p>
   ```

## Monetizatsiya — 4 Bosqichli Tarif Tizimi

Komissiya modeli yo'q. Daromad faqat obuna + seat + boost/reklamadan keladi.

### Tarif Rejalari

| | **Free** | **Pro** | **Premium** | **Enterprise** |
|--|---------|---------|------------|---------------|
| **Oylik narx** | 0 | 999,000 UZS (~$76) | 1,999,000 UZS (~$152) | Kelishiladi (4,999,000 - 14,999,000 UZS) |
| **Yillik narx** | 0 | 9,990,000 UZS (~$760) | 19,990,000 UZS (~$1,520) | Shartnoma asosida |
| **E'lonlar limiti** | 3 | 100 | Cheksiz | Cheksiz |
| **Bepul seatlar** | 1 (faqat owner) | 3 | 10 | Cheksiz |
| **Qo'shimcha seat narxi** | — | 149,000 UZS/seat/oy | 249,000 UZS/seat/oy | Kelishiladi |
| **Verified badge** | — | ✓ | ✓ | ✓ |
| **Analitika** | Asosiy | Kengaytirilgan | Premium | Premium+ |
| **Shaxsiy menejer** | — | — | ✓ | ✓ |
| **API kirish** | — | — | — | ✓ |
| **Multi-filial** | — | — | — | ✓ |

### Maqsadli auditoriya

- **Free** — Shaxsiy sotuvchi (1 ta mashinasini sotmoqchi)
- **Pro** — Kichik-o'rta diler (3-5 xodim)
- **Premium** — Yirik avtosalon (10-20 xodim)
- **Enterprise** — Tarmoq avtosalonlar (30+ xodim, bir nechta filial)

### Team Rollari (5 ta)

| Role | Ruxsatlar |
|------|----------|
| **Owner** | To'liq nazorat |
| **Admin** | Xodimlar va e'lonlarni boshqarish |
| **Manager** | E'lon yaratish, xaridorlar bilan chat |
| **Marketing** | E'lonlarni boost qilish, analitika |
| **Viewer** | Faqat statistikani ko'rish |

### Boost/Reklama narxlari

| Xizmat | Narx |
|--------|------|
| Ko'tarish (1 marta) | 15,000-25,000 UZS |
| TOP (1 kun) | 30,000-50,000 UZS |
| VIP (7 kun) | 99,000-149,000 UZS |
| Mega paket (30 kun) | 249,000-399,000 UZS |

### Daromad prognozi (3 yillik)

| | Yil 1 (1,000 sotuvchi) | Yil 2 (5,000 sotuvchi) | Yil 3 (15,000 sotuvchi) |
|--|----------------------|----------------------|------------------------|
| **Yillik daromad** | ~$480,600 | ~$2,500,000 | ~$9,567,000 |

## Conventions

- Barrel exports per feature (e.g., `features/auth/auth.dart`)
- Models use `fromJson`/`toJson` with `json_serializable`
- Currencies: USD and UZS
- Phone format: +998XXXXXXXXX (Uzbekistan)
- Android namespace: `com.example.autogram` (needs updating for production)
