# Autogram Project Memory

## RBAC Tizimi — Umumiy Reja (7 bosqich)

### ✅ Tugallangan bosqichlar:

**Bosqich 1 — PermissionService (Markaziy Huquq Tekshiruvi)**
- `lib/core/services/permission_service.dart` yaratildi
- `MemberRole` enum: owner, admin, manager, marketing, viewer
- `Permission` enum: 8 ta huquq (createListing, manageListings, boostListing, viewAnalytics, manageMembers, manageSettings, manageKpi, chatWithBuyers)
- Permission matritsasi: owner=to'liq, admin=settings bundan mustasno, manager=listing+chat, marketing=boost+analytics, viewer=faqat analytics
- Individual seller = avtomatik owner, dealer/showroom = member.role bo'yicha tekshiriladi
- `customPermissions` override imkoniyati mavjud
- DI: `_initCore()` da `PermissionService` LazySingleton sifatida ro'yxatdan o'tkazildi

**Bosqich 2 — SellerMember Tizimi (Clean Architecture)**
- Entity: `lib/features/seller/domain/entities/seller_member.dart`
- Model: `lib/features/seller/data/models/seller_member_model.dart` (fromJson/toJson/fromEntity)
- Repository interface: `lib/features/seller/domain/repositories/seller_member_repository.dart` (6 method)
- DataSource: `lib/features/seller/data/datasources/seller_member_remote_datasource.dart` (Supabase, `seller_members` jadvali)
- Repository impl: `lib/features/seller/data/repositories/seller_member_repository_impl.dart`
- 5 ta UseCase: GetTeamMembers, AddMember, UpdateMemberRole, RemoveMember, GetCurrentMembership
- MockData yangilandi: user4-user6 qo'shildi, 5 ta mockSellerMembers, 3 ta helper method
- DI: `_initSellerMembers()` metodi qo'shildi (injection.dart)
- Barrel export yangilandi (seller.dart)
- Commit: `0cb20f9` branch: `claude/lucid-haslett`
- `flutter analyze` — xatosiz o'tdi ✅

### ⏳ Keyingi bosqichlar (bajarilmagan):

**Bosqich 3 — Taklif tizimi (Invitation Flow)**
- `seller_invitations` jadvali
- Taklif yuborish (email orqali)
- Qabul qilish / rad etish oqimi
- Token-based invitation link

**Bosqich 4 — Team Management UI**
- Xodimlar ro'yxati ekrani
- Xodim qo'shish ekrani
- Xodim tafsilotlari ekrani
- Role o'zgartirish UI
- TeamBloc yaratish

**Bosqich 5 — Activity Logging**
- `member_activity_log` jadvali
- Faoliyat qayd qilish (listing_created, listing_updated, etc.)
- Faoliyat logi ekrani

**Bosqich 6 — KPI Tizimi**
- `kpi_targets` jadvali
- Maqsad qo'yish (listings_created, listings_sold, views_generated)
- Period: daily, weekly, monthly
- KPI progress hisoblash
- KpiBloc yaratish

**Bosqich 7 — Owner Dashboard**
- Yig'ma hisobot ekrani
- Har bir xodim uchun statistika
- KPI bajarilish foizi
- Grafik va diagrammalar

## Design System
- Figma dan o'rganilgan — batafsil: `memory/design_system.md`
- Shrift: Inter, Ranglar: Highlight #006FFD, Neutral #1F2024-#FFFFFF, Success/Warning/Error
- Komponentlar: Button, Card, TextField, TabBar, NavBar, Dialog, Toast, Banner, Calendar, Stepper, Chat, Map va boshqalar

## Muhim ma'lumotlar

- Supabase jadvallari: `seller_members` (allaqachon ApiEndpoints.sellerMembers da aniqlangan), `profiles`, `seller_profiles`, `listings`
- Supabase storage: `avatars`, `logos`, `covers`, `listings`, `videos`, `thumbnails`, `documents`
- Test mode: `TestConfig.isTestMode = true`, test emaillar: test@autogram.uz, sardor@example.com, aziza@example.com (OTP: 123456)
- Arxitektura: Clean Architecture + BLoC, dartz Either pattern, GetIt DI
- Tillar: uz (default), ru, en — easy_localization
