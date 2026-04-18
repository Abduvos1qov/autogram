# AUTOGRAM — Loyiha Holati va Yo'l Xaritasi

**Oxirgi yangilangan:** 2026-04-11
**Versiya:** 1.0.0

---

## 1. Loyiha haqida qisqacha

Autogram — O'zbekiston uchun TikTok/Reels uslubidagi video-asosli avtomobil marketplace. Flutter + Supabase + Cloudflare Stream. Birinchi fazada faqat AVTO kategoriyasi (ko'chmas mulk keyinroq).

**Maqsad:** O'zbekistondagi #1 avtomobil platformasi. 3 yilda 1M+ MAU, 50,000+ tranzaksiya/yil.

---

## 2. Texnologiyalar

| Qism | Texnologiya |
|------|-------------|
| Mobile | Flutter 3.x (cross-platform) |
| Arxitektura | Clean Architecture + BLoC |
| Backend | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| Video | Cloudflare Stream (HLS, adaptive bitrate) |
| DI | GetIt (manual registration) |
| Navigation | GoRouter (StatefulShellRoute, 5 tab) |
| Localization | easy_localization (uz, ru, en — JSON) |
| Error handling | dartz Either (Left=Failure, Right=Success) |
| To'lov (rejada) | Click + Payme + Uzum |

---

## 3. Feature-by-Feature Holat

### Jami: 14 ta feature rejalashtirilgan, 9 tasi to'liq, 2 tasi qisman, 3 tasi boshlanmagan

| # | Feature | Holat | Domain | Data | UI | DI | Izoh |
|---|---------|-------|--------|------|----|----|------|
| 1 | **Auth** | TAYYOR | 11 use case | Supabase + local | 7 ekran | Faol | OTP, sign up/in, parol tiklash, username |
| 2 | **Home** | TAYYOR | 1 use case | Supabase + mock fallback | 1 ekran, 2 widget | Faol | Feed cards, stories bar (TODO: stories BLoC) |
| 3 | **Reels** | TAYYOR | 3 use case | Supabase + mock fallback | 1 ekran, 3 widget | Faol | PageView, like/save, HLS video |
| 4 | **Search** | TAYYOR | 2 use case | Supabase + local cache | 2 ekran, 1 widget | Faol | Filterlar, sort, debounce, brand qidiruv |
| 5 | **Listing** | TAYYOR | 2 use case | Supabase + mock fallback | 1 ekran, 3 widget | Faol | Gallery, specs, seller card, similar listings |
| 6 | **Saved** | TAYYOR | — | Supabase (real) | 1 ekran | Faol | Wishlist CRUD |
| 7 | **Chat** | TAYYOR | — | Supabase + mock fallback | 2 ekran | Faol | Conversations list + chat screen |
| 8 | **Profile** | TAYYOR | — | Stub repo | 1 ekran | Faol | Ko'rish/tahrirlash, repo to'ldirilmagan |
| 9 | **Seller** | TAYYOR | 1 use case | Supabase (real) | 4 ekran, 3 widget | Faol | Upgrade flow, plan tanlash, biznes profil |
| 10 | **Team (RBAC)** | TAYYOR | 14 use case | Supabase (real) | 4 ekran, 6 widget | Faol | 5 rol, 8 permission, invitation, activity log |
| 11 | **Notifications** | QISMAN | Entity bor | **YO'Q** (DI comment) | Ekran bor (shell) | O'chiq | Repository impl yo'q, BLoC shell |
| 12 | **Create Listing** | BOSHLANMAGAN | — | — | — | — | PRD Phase 2 |
| 13 | **Boost** | BOSHLANMAGAN | — | — | — | — | PRD Phase 3 |
| 14 | **Reviews** | BOSHLANMAGAN | — | — | — | — | PRD Phase 2 |

---

## 4. PRD vs Kod — Solishtiruv

### PRD "Must Have (MVP)" — BARCHASI TAYYOR

| PRD feature | Kod holati |
|-------------|-----------|
| Phone Authentication (OTP) | TAYYOR — Supabase auth, 7 ekran |
| Reels Feed (vertical video) | TAYYOR — PageView, HLS, like/save |
| Listing Details | TAYYOR — gallery, specs, seller card |
| Search with filters | TAYYOR — 12+ filter, sort, brand search |
| Messaging (in-app chat) | TAYYOR — conversations list + chat |
| Saved/Wishlist | TAYYOR — CRUD, Supabase |
| User Profile | TAYYOR — ekran bor, repo stub |
| Seller Profile | TAYYOR — upgrade flow + team management |

### PRD "Should Have (Phase 2)" — KO'PI BOSHLANMAGAN

| PRD feature | Kod holati | Ustuvorlik |
|-------------|-----------|------------|
| **Listing Creation** | BOSHLANMAGAN | YUQORI — sotuvchilar e'lon qo'yolmaydi |
| **Analytics Dashboard** | BOSHLANMAGAN | O'RTA — MEMORY.md Bosqich 7 |
| **Seller Verification** | QISMAN — entity field bor, flow yo'q | O'RTA |
| **Push Notifications** | QISMAN — entity/ekran bor, backend yo'q | YUQORI |
| **Price Drop Alerts** | BOSHLANMAGAN | PAST |
| **Reviews & Ratings** | BOSHLANMAGAN | O'RTA |
| **Advanced Filters** | QISMAN — asosiy filterlar tayyor | PAST |
| **Share to Social** | BOSHLANMAGAN | PAST |

### PRD "Could Have (Phase 3)" — BARCHASI BOSHLANMAGAN

| PRD feature | Kod holati |
|-------------|-----------|
| Featured/Boost listings | Entity field bor, logika yo'q |
| Subscription Plans (to'lov) | Enum bor, purchase flow yo'q |
| Payment Integration | Hech narsa yo'q |
| Car History (VIN) | Hech narsa yo'q |
| AR Preview | Hech narsa yo'q |
| Video Calling | Hech narsa yo'q |
| Price Comparison | Hech narsa yo'q |
| Loan Calculator | Hech narsa yo'q |

---

## 5. USER_FLOWS vs Kod

| Flow | Hujjatda | Kodda |
|------|---------|-------|
| App Launch (splash → auth check → home) | Batafsil | TAYYOR |
| Onboarding (3 slide) | Batafsil | TAYYOR |
| Login/Register (OTP) | Batafsil | TAYYOR (email-based, phone emas) |
| Seller Profile Setup | Batafsil | TAYYOR (upgrade flow) |
| Reels Browsing (swipe, like, save) | Batafsil | TAYYOR |
| Listing Detail (gallery, specs, contact) | Batafsil | TAYYOR |
| Saved/Wishlist | Batafsil | TAYYOR |
| Search & Filter | Batafsil | TAYYOR |
| Chat (conversations + messages) | Batafsil | TAYYOR |
| Notifications | Batafsil | QISMAN (ekran bor, backend yo'q) |
| Profile Management | Batafsil | TAYYOR (repo stub) |
| Settings | Batafsil | REDIRECT (/profile/edit) |
| **Create Listing (6 step)** | Batafsil | **BOSHLANMAGAN** |
| **Listing Management (tabs)** | Batafsil | **BOSHLANMAGAN** |
| **Seller Analytics** | Batafsil | **BOSHLANMAGAN** |
| Deep Linking | Batafsil | Route'lar bor, deep link handler yo'q |
| Error Handling | Batafsil | Pattern bor (ErrorView, EmptyView) |

---

## 6. Monetizatsiya — Hozirgi Holat

### CLAUDE.md rejalari vs Kodda mavjud

**Obuna tizimlari:**

| Reja (CLAUDE.md) | Kodda |
|-------------------|-------|
| 4 ta tarif: Free/Pro/Premium/Enterprise | SubscriptionPlan enum bor (4 tier) |
| Narxlar: 0 / 999K / 1.99M / kelishiladi UZS | Entity'da field bor, UI da PlanCard bor |
| E'lon limiti: 3 / 100 / cheksiz / cheksiz | `maxListings` property bor |
| Seat limiti: 1 / 3 / 10 / cheksiz | `freeSeats` property bor |

**AMMO — quyidagilar UMUMAN YO'Q:**

- To'lov gateway integratsiyasi (Click, Payme, Uzum)
- Obuna sotib olish / yangilash / bekor qilish logikasi
- Obuna muddati, auto-renewal, grace period
- E'lon limiti NAZORATI (Free user cheksiz qo'sha oladi)
- Seat sotib olish va tayinlash logikasi
- Boost sotib olish, davomiylik, scheduling
- Invoice / kvitansiya yaratish
- Revenue tracking / billing history

**Team rollari (to'liq ishlaydi):**

| Rol | Permission'lar | Holat |
|-----|---------------|-------|
| Owner | 8/8 (to'liq) | TAYYOR |
| Admin | 7/8 (manageSettings bundan mustasno) | TAYYOR |
| Manager | createListing, manageListings, chatWithBuyers | TAYYOR |
| Marketing | boostListing, viewAnalytics | TAYYOR |
| Viewer | viewAnalytics | TAYYOR |

---

## 7. RBAC Tizimi — Bosqichlar

| Bosqich | Nomi | Holat | Commit |
|---------|------|-------|--------|
| 1 | PermissionService | TAYYOR | `0cb20f9` |
| 2 | SellerMember CRUD | TAYYOR | `0cb20f9` |
| 3 | Invitation Flow | TAYYOR | `91c5191` |
| 4 | Team Management UI | TAYYOR | `91c5191` |
| 5 | Activity Logging | TAYYOR | `91c5191` |
| 6 | **KPI Tizimi** | **BOSHLANMAGAN** | — |
| 7 | **Owner Dashboard** | **BOSHLANMAGAN** | — |

---

## 8. Infratuzilma Holati

### Supabase

| Qism | Holat |
|------|-------|
| Auth (email OTP) | Ishlaydi (test mode) |
| Database tables | profiles, seller_profiles, seller_members, seller_invitations, member_activity_log, listings |
| Storage buckets | avatars, logos, covers, listings, videos, thumbnails, documents |
| RLS (Row Level Security) | **SOZLANMAGAN** |
| Edge Functions | **YARATILMAGAN** |
| Email Templates (OTP) | **SOZLANMAGAN** (CLAUDE.md da template bor) |

### Test Mode

- `TestConfig.isTestMode = true` (default)
- Mock data: 6 user, 3 seller, feed items, reels, conversations, activity logs
- Test OTP: `123456` (CLAUDE.md) / `1234` (TEST_INSTRUCTIONS.md) — **NOMUVOFIQLIK!**
- Test email: test@autogram.uz, sardor@example.com, aziza@example.com

### Routing (GoRouter)

- Auth: /splash, /onboarding, /login, /otp, /register, /username, /forgot-password
- Bottom tabs: / (home), /reels, /search, /chat, /profile
- Detail: /listing/:id, /chat/:id, /saved, /notifications
- Seller: /upgrade, /upgrade/business-info, /upgrade/plan, /upgrade/success
- Team: /team, /team/add, /team/member/:id, /team/activity
- Settings: /settings → redirects to /profile/edit

---

## 9. Hujjatlar Ro'yxati va Muammolar

### Mavjud hujjatlar

| Fayl | Maqsad | Dolzarbligi |
|------|--------|-------------|
| CLAUDE.md | Claude Code uchun ko'rsatmalar | O'rtacha — RBAC/team haqida yo'q |
| docs/PRD.md | Product Requirements | Yaxshi — lekin "Implemented" statuslari yangilanmagan |
| docs/USER_FLOWS.md | Foydalanuvchi oqimlari | Yaxshi — Create Listing flow batafsil |
| MEMORY.md | RBAC implementation status | Eng yangi — 5 bosqich + DI xaritasi |
| AUTOGRAM_PROJECT_SUMMARY.md | Bajarilgan ishlar ro'yxati | Eskirgan — RBAC/team haqida yo'q |
| CLAUDE_MEMORY.md | Qisqacha xotira | Eskirgan |
| TEST_INSTRUCTIONS.md | Test rejimi yo'riqnomasi | Yaxshi |

### Hujjatlar orasidagi NOMUVOFIQLIKLAR

1. **OTP kodi:** CLAUDE.md = `123456`, TEST_INSTRUCTIONS.md = `1234`
2. **Tarif nomlari:** CLAUDE.md = Free/Pro/Premium/Enterprise, AUTOGRAM_PROJECT_SUMMARY.md = Free/Basic/Pro/Enterprise
3. **Tarif narxlari:** CLAUDE.md = UZS (999K/1.99M), AUTOGRAM_PROJECT_SUMMARY.md = USD ($29/$79/$199)
4. **PRD "Implemented" statuslari:** Notifications "Implemented" deyilgan, aslida shell only
5. **Auth flow:** PRD da "phone number" deyilgan, kodda email OTP ishlatiladi

---

## 10. Kritik Yo'l Xaritasi — Nima Qilish Kerak

### BIRINCHI NAVBAT (MVP uchun zarur)

| # | Vazifa | Sababi | Murakkablik |
|---|--------|--------|-------------|
| 1 | **Create Listing** (6 step flow) | Sotuvchilar e'lon qo'yolmaydi — platformaning asosiy funksiyasi | YUQORI |
| 2 | **E'lon limiti nazorati** | Free user hozir cheksiz e'lon qo'ya oladi | PAST |
| 3 | **Notifications backend** | Repository impl + push notification service | O'RTA |
| 4 | **Supabase RLS** | Xavfsizlik — hozir ma'lumotlar himoyalanmagan | O'RTA |

### IKKINCHI NAVBAT (Monetizatsiya uchun zarur)

| # | Vazifa | Sababi | Murakkablik |
|---|--------|--------|-------------|
| 5 | **To'lov integratsiyasi** (Click/Payme/Uzum) | Obuna sotib olish imkoni yo'q | YUQORI |
| 6 | **Obuna lifecycle** (purchase/renew/cancel/expire) | Tarif tizimi ishlamaydi | YUQORI |
| 7 | **Boost/Reklama tizimi** | Daromad manbasi | O'RTA |
| 8 | **Seat management** | Team tizimi limit nazoratisiz | O'RTA |

### UCHINCHI NAVBAT (Growth uchun)

| # | Vazifa | Sababi | Murakkablik |
|---|--------|--------|-------------|
| 9 | **KPI tizimi** (RBAC Bosqich 6) | Xodimlar samaradorligini o'lchash | O'RTA |
| 10 | **Owner Dashboard** (RBAC Bosqich 7) | Yig'ma hisobot, grafiklar | YUQORI |
| 11 | **Reviews & Ratings** | Ishonch tizimi | O'RTA |
| 12 | **Seller Verification flow** | Verified badge berish jarayoni | O'RTA |
| 13 | **Analytics Dashboard** | Seller engagement ko'rsatkichlari | O'RTA |
| 14 | **Share to Social** (Telegram, Instagram) | Organic growth | PAST |

---

## 11. DI Registration Xaritasi

```
injection.dart
├── _initCore()          — StorageService, SecureStorage, NetworkInfo, ApiClient, PermissionService
├── _initAuth()          — 2 datasource, repo, 5 use case, AuthBloc
├── _initHome()          — datasource, repo, 1 use case, HomeBloc
├── _initReels()         — datasource, repo, 3 use case, ReelsBloc
├── _initSearch()        — 2 datasource, repo, 2 use case, SearchBloc
├── _initListing()       — datasource, repo, 1 use case, ListingBloc
├── _initSaved()         — datasource, repo, SavedBloc
├── _initChat()          — datasource, repo, ConversationsBloc
├── _initSeller()        — datasource, repo, 1 use case, SellerBloc
├── _initSellerMembers() — datasource, repo, 5 use case
├── _initSellerInvitations() — datasource, repo, 6 use case
├── _initActivityLog()   — datasource, repo, 3 use case
├── _initTeam()          — TeamBloc (11 use case inject)
├── _initProfile()       — ProfileBloc (TODO: to'ldirish)
└── _initNotifications() — TODO (comment qilingan)
```

---

## 12. Mock Data Inventar

| Turi | Soni | Faylda |
|------|------|--------|
| Users (buyer + seller) | 6 | mock_data.dart |
| Sellers (business profiles) | 3 | mock_data.dart |
| Seller Members | 5 | mock_data.dart |
| Seller Invitations | 4 | mock_data.dart |
| Activity Logs | 10 | mock_data.dart |
| Feed Items | mavjud | mock_data.dart |
| Reels | mavjud | mock_data.dart |
| Conversations | mavjud | mock_data.dart |
| Search Results | mavjud | mock_data.dart |
| Notifications | mavjud | mock_data.dart |

---

## 13. Git Ma'lumotlari

- **Asosiy branch:** `version(1.0.0)`
- **Oxirgi merge:** `f92f2e1`
- **Muhim commitlar:** `0cb20f9` (RBAC Phase 1-2), `91c5191` (RBAC Phase 3-5)
- **flutter analyze:** 0 error

---

*Bu fayl loyihaning yagona manba hujjati sifatida xizmat qiladi. Har bir muhim o'zgarishdan keyin yangilang.*
