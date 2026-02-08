# AUTOGRAM - Loyiha Rejasi va Bajarilgan Ishlar

## Loyiha Haqida

**Autogram** - Avtomobillar uchun Reels-formatli maxsus platforma (O'zbekiston uchun).

> **Eslatma:** Birinchi fazada faqat AVTO kategoriyasi. Ko'chmas mulk keyinroq qo'shiladi.

---

## Tanlangan Texnologiyalar

| Qism | Texnologiya | Sababi |
|------|-------------|--------|
| Mobile App | Flutter 3.x | Cross-platform, yaxshi performance |
| State Management | **flutter_bloc** | Predictable, testable, SOLID-friendly |
| Architecture | **Clean Architecture** | Separation of concerns, modular |
| Localization | **easy_localization** | Oson tarjima, JSON support |
| Local DB | **sqflite** | Offline support, caching |
| DI | **GetIt** | Dependency injection |
| Navigation | **GoRouter** | Declarative routing |
| Backend | **Supabase** | PostgreSQL, Auth, Storage, Realtime |
| Video Hosting | **Cloudflare Stream** | HLS, adaptive bitrate, global CDN |
| Push Notifications | Firebase Cloud Messaging | Bepul, ishonchli |
| Payments | **Click + Payme + Uzum** | O'zbekiston uchun to'liq qamrov |

---

## Bajarilgan Tasklar

### Task #1: Update pubspec.yaml ✅
- Barcha kerakli dependencies qo'shildi
- flutter_bloc, get_it, go_router, dio, supabase_flutter
- video_player, cached_network_image, easy_localization
- sqflite, shared_preferences, flutter_secure_storage

### Task #2: Create core module structure ✅
```
lib/core/
├── core.dart                    # Barrel export
├── config/
│   ├── env_config.dart          # Environment (dev/staging/prod)
│   └── app_config.dart          # App constants
├── constants/
│   ├── api_endpoints.dart       # Supabase tables
│   ├── storage_keys.dart        # Local storage keys
│   ├── asset_paths.dart         # Asset paths
│   └── app_constants.dart       # Business constants
├── errors/
│   ├── exceptions.dart          # Custom exceptions
│   ├── failures.dart            # Failure classes (Either pattern)
│   └── error_handler.dart       # Global error handling
├── network/
│   ├── api_client.dart          # Dio wrapper
│   ├── network_info.dart        # Connectivity check
│   ├── api_response.dart        # Response models
│   └── interceptors/
│       ├── auth_interceptor.dart
│       ├── error_interceptor.dart
│       └── logging_interceptor.dart
├── database/
│   └── database_helper.dart     # SQLite setup
├── services/
│   ├── storage_service.dart     # SharedPreferences wrapper
│   └── secure_storage_service.dart
├── utils/
│   ├── logger.dart
│   ├── formatters.dart          # Date, price formatters
│   ├── validators.dart          # Form validators
│   └── helpers.dart
├── extensions/
│   ├── context_extensions.dart
│   ├── string_extensions.dart
│   ├── datetime_extensions.dart
│   └── num_extensions.dart
├── theme/
│   ├── app_theme.dart
│   ├── app_colors.dart
│   ├── app_typography.dart
│   └── app_spacing.dart
├── widgets/
│   ├── widgets.dart             # Barrel export
│   ├── buttons/
│   │   ├── primary_button.dart
│   │   ├── secondary_button.dart
│   │   └── app_icon_button.dart
│   ├── inputs/
│   │   ├── app_text_field.dart
│   │   ├── phone_input.dart
│   │   └── search_field.dart
│   ├── feedback/
│   │   ├── loading_indicator.dart
│   │   ├── error_view.dart
│   │   ├── empty_view.dart
│   │   └── shimmer_loading.dart
│   ├── media/
│   │   ├── cached_image.dart
│   │   └── avatar.dart
│   └── layout/
│       └── safe_scaffold.dart
└── usecases/
    └── usecase.dart             # Base UseCase class
```

### Task #3: Create auth feature module ✅
```
lib/features/auth/
├── auth.dart                    # Barrel export
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── send_otp_usecase.dart
│       ├── verify_otp_usecase.dart
│       ├── register_usecase.dart
│       ├── logout_usecase.dart
│       └── get_current_user_usecase.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── login_screen.dart
    │   ├── otp_screen.dart
    │   └── register_screen.dart
    └── widgets/
        └── otp_input.dart
```

### Task #4: Create home feature module ✅
```
lib/features/home/
├── home.dart
├── domain/
│   ├── entities/feed_item.dart
│   ├── repositories/home_repository.dart
│   └── usecases/get_feed_usecase.dart
├── data/
│   ├── models/feed_item_model.dart
│   ├── datasources/home_remote_datasource.dart
│   └── repositories/home_repository_impl.dart
└── presentation/
    ├── bloc/home_bloc.dart, home_event.dart, home_state.dart
    ├── screens/home_screen.dart
    └── widgets/feed_card.dart, stories_bar.dart
```

### Task #5: Create reels feature module ✅
```
lib/features/reels/
├── reels.dart
├── domain/
│   ├── entities/reel.dart
│   ├── repositories/reels_repository.dart
│   └── usecases/
│       ├── get_reels_usecase.dart
│       ├── like_reel_usecase.dart
│       └── save_reel_usecase.dart
├── data/
│   ├── models/reel_model.dart
│   ├── datasources/reels_remote_datasource.dart
│   └── repositories/reels_repository_impl.dart
└── presentation/
    ├── bloc/reels_bloc.dart, reels_event.dart, reels_state.dart
    ├── screens/reels_screen.dart
    └── widgets/
        ├── reel_player.dart
        ├── reel_overlay.dart
        └── reel_actions.dart
```

### Task #6: Create remaining feature modules ✅

**Search Module:**
```
lib/features/search/
├── search.dart
├── domain/
│   ├── entities/search_result.dart, filter.dart
│   ├── repositories/search_repository.dart
│   └── usecases/search_listings_usecase.dart, get_brands_usecase.dart
├── data/
│   ├── models/search_result_model.dart, filter_model.dart
│   ├── datasources/search_remote_datasource.dart, search_local_datasource.dart
│   └── repositories/search_repository_impl.dart
└── presentation/
    ├── bloc/search_bloc.dart, search_event.dart, search_state.dart
    ├── screens/search_screen.dart, filter_screen.dart
    └── widgets/search_result_card.dart
```

**Listing Module:**
```
lib/features/listing/
├── listing.dart
├── domain/
│   ├── entities/listing.dart (Listing, AutoDetails, Seller)
│   ├── repositories/listing_repository.dart
│   └── usecases/get_listing_usecase.dart, get_seller_usecase.dart
├── data/
│   ├── models/listing_model.dart
│   ├── datasources/listing_remote_datasource.dart
│   └── repositories/listing_repository_impl.dart
└── presentation/
    ├── bloc/listing_bloc.dart, listing_event.dart, listing_state.dart
    ├── screens/listing_detail_screen.dart
    └── widgets/listing_gallery.dart, listing_specs.dart, seller_card.dart
```

**Saved Module:**
```
lib/features/saved/
├── saved.dart
├── domain/
│   ├── entities/saved_item.dart
│   └── repositories/saved_repository.dart
├── data/
│   ├── models/saved_item_model.dart
│   ├── datasources/saved_remote_datasource.dart
│   └── repositories/saved_repository_impl.dart
└── presentation/
    ├── bloc/saved_bloc.dart
    └── screens/saved_screen.dart
```

**Chat Module:**
```
lib/features/chat/
├── chat.dart
├── domain/
│   ├── entities/conversation.dart, message.dart
│   └── repositories/chat_repository.dart
├── data/
│   ├── models/conversation_model.dart, message_model.dart
│   ├── datasources/chat_remote_datasource.dart
│   └── repositories/chat_repository_impl.dart
└── presentation/
    ├── bloc/conversations_bloc.dart
    └── screens/conversations_screen.dart, chat_screen.dart
```

**Profile Module:**
```
lib/features/profile/
├── profile.dart
├── domain/
│   ├── entities/user_profile.dart
│   └── repositories/profile_repository.dart
├── data/
│   └── models/user_profile_model.dart
└── presentation/
    ├── bloc/profile_bloc.dart
    └── screens/profile_screen.dart
```

**Notifications Module:**
```
lib/features/notifications/
├── notifications.dart
├── domain/
│   ├── entities/notification.dart
│   └── repositories/notification_repository.dart
└── presentation/
    ├── bloc/notifications_bloc.dart
    └── screens/notifications_screen.dart
```

### Task #7: Create navigation and DI setup ✅
```
lib/navigation/
├── route_names.dart             # Route constants
├── navigation_shell.dart        # Bottom navigation wrapper
└── app_router.dart              # GoRouter configuration

lib/di/
└── injection.dart               # GetIt dependency injection
```

### Task #8: Create localization files ✅
```
assets/l10n/
├── uz.json                      # O'zbekcha
├── ru.json                      # Русский
└── en.json                      # English
```

### Task #9: Create main app entry files ✅
```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp widget
└── bootstrap.dart               # Initialization
```

---

## Keyingi Qadamlar (Backendni sozlash)

### Supabase Setup

1. **Supabase Project yaratish**
   - supabase.com/dashboard
   - New project → "autogram"

2. **Database schema yaratish**
   - Plandan SQL scriptlarini ishlatish
   - Tables: users, seller_profiles, listings, etc.

3. **Storage buckets yaratish**
   - avatars, logos, covers, listings, videos, thumbnails

4. **Edge Functions yaratish**
   - send-otp, verify-otp, process-video, payment-webhook

5. **Row Level Security (RLS) sozlash**

### Cloudflare Stream Setup

1. **Account yaratish** - cloudflare.com
2. **Stream enable qilish**
3. **API keys olish**
4. **Direct upload URL olish**

### Payment Integration

1. **Click** - my.click.uz/merchants
2. **Payme** - merchant.paycom.uz
3. **Uzum** - business.uzum.uz

---

## Subscription Plans

| Plan | Narx | Limitlar |
|------|------|----------|
| FREE | $0/oy | 3 e'lon, basic stats |
| BASIC | $29/oy | 15 e'lon, full stats, 2 boost |
| PRO | $79/oy | Cheksiz, CRM, 10 boost, verified |
| ENTERPRISE | $199/oy | Full API, team, 30 boost |

---

## UI Screens Overview

```
Bottom Navigation:
🏠 Home    - Instagram-style feed with cards
🎬 Reels   - TikTok/Reels full-screen video
🔍 Search  - Search & filters
💬 Chat    - Messages
👤 Profile - User profile
```

---

## Arxitektura

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  (BLoC, Screens, Widgets)                                   │
├─────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                           │
│  (Entities, Repositories (abstract), UseCases)              │
├─────────────────────────────────────────────────────────────┤
│                        DATA LAYER                            │
│  (Models, DataSources, Repositories (impl))                 │
├─────────────────────────────────────────────────────────────┤
│                         CORE                                 │
│  (Config, Services, Utils, Theme, Widgets)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Env Variables (env_config.dart)

```dart
// Development
supabaseUrl: 'https://xxx.supabase.co'
supabaseAnonKey: 'eyJxxx...'

// Production
supabaseUrl: 'https://xxx.supabase.co'
supabaseAnonKey: 'eyJxxx...'

// Cloudflare Stream
cloudflareAccountId: 'xxx'
cloudflareApiToken: 'xxx'
```

---

## Eslatmalar

1. **Clean Architecture** - Har bir feature moduli domain, data, presentation layerlardan iborat
2. **BLoC Pattern** - State management uchun flutter_bloc ishlatiladi
3. **Either Pattern** - Error handling uchun dartz Either ishlatiladi
4. **Optimistic Updates** - Like/Save operatsiyalari optimistic yangilanadi
5. **Supabase Realtime** - Chat va notifications uchun real-time subscription

---

*Ushbu hujjat loyiha rejasi va bajarilgan ishlar haqida to'liq ma'lumot beradi.*
