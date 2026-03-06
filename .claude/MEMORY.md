# Autogram Project Memory

## RBAC Tizimi — Umumiy Reja (7 bosqich)

### ✅ Tugallangan bosqichlar:

**Bosqich 1 — PermissionService (Markaziy Huquq Tekshiruvi)**
- `lib/core/services/permission_service.dart` yaratildi
- `MemberRole` enum: owner, admin, manager, marketing, viewer (level-based hierarchy)
- `Permission` enum: 8 ta huquq (createListing, manageListings, boostListing, viewAnalytics, manageMembers, manageSettings, manageKpi, chatWithBuyers)
- Permission matritsasi: owner=to'liq, admin=settings bundan mustasno, manager=listing+chat, marketing=boost+analytics, viewer=faqat analytics
- Individual seller = avtomatik owner, dealer/showroom = member.role bo'yicha tekshiriladi
- `customPermissions` override imkoniyati mavjud
- DI: `_initCore()` da `PermissionService` LazySingleton sifatida ro'yxatdan o'tkazildi
- Commit: `0cb20f9`

**Bosqich 2 — SellerMember Tizimi (Clean Architecture)**
- Entity: `lib/features/seller/domain/entities/seller_member.dart`
- Model: `lib/features/seller/data/models/seller_member_model.dart` (fromJson/toJson/fromEntity)
- Repository interface: `lib/features/seller/domain/repositories/seller_member_repository.dart` (6 method)
- DataSource: `lib/features/seller/data/datasources/seller_member_remote_datasource.dart` (Supabase, `seller_members` jadvali)
- Repository impl: `lib/features/seller/data/repositories/seller_member_repository_impl.dart`
- 5 ta UseCase: GetTeamMembers, AddMember, UpdateMemberRole, RemoveMember, GetCurrentMembership
- MockData yangilandi: user4-user6 qo'shildi, 5 ta mockSellerMembers, 3 ta helper method
- DI: `_initSellerMembers()` metodi qo'shildi (injection.dart)
- Commit: `0cb20f9`

**Bosqich 3 — Taklif tizimi (Invitation Flow)**
- Entity: `lib/features/seller/domain/entities/seller_invitation.dart` — InvitationStatus enum (pending/accepted/rejected/expired/cancelled), computed: isPending, isExpired, daysRemaining
- Repository: `seller_invitation_repository.dart` — 6 method (send/accept/reject/cancel, getPending, getMyInvitations)
- 6 ta UseCase: SendInvitation, AcceptInvitation, RejectInvitation, CancelInvitation, GetPendingInvitations, GetMyInvitations
- Model: `seller_invitation_model.dart` — fromJson with joined profile data, toInsertJson
- DataSource: `seller_invitation_remote_datasource.dart` — token-based, 7-day expiry, existing member/invitation check, `_selectWithJoins = '*, inviter:invited_by(...), seller_profile:seller_profile_id(...)'`
- AcceptInvitation: 2-step — update invitation status + create SellerMember record
- MockData: 4 ta mockSellerInvitations + 3 helper method
- DI: `_initSellerInvitations()` — datasource, repo, 6 use case
- `api_endpoints.dart`: sellerInvitations, memberActivityLog qo'shildi
- Commit: `91c5191`

**Bosqich 4 — Team Management UI**
- TeamBloc: `lib/features/seller/presentation/bloc/team/` — 8 event, TeamStatus enum (6 holat)
- TeamState: members, pendingInvitations, myInvitations, currentMembership, sellerProfileId, failure, successMessage
- _onLoadRequested: members + invitations + currentMembership parallel yuklash
- 3 ta ekran:
  - `TeamMembersScreen` — members + pending invitations, permission-gated add button, RefreshIndicator
  - `AddMemberScreen` — email AppTextField + RoleSelectionWidget, email validation regex
  - `MemberDetailScreen` — avatar/name/role header, PopupMenuButton role change, PermissionGrid, remove with AlertDialog
- 5 ta widget:
  - `RoleBadge` — rangli chip per role
  - `RoleSelectionWidget` — visual cards with AnimatedContainer, filtered by currentUserRole level
  - `MemberListTile` — CircleAvatar + name + email + RoleBadge + chevron
  - `InvitationListTile` — email + role + days remaining + cancel button
  - `PermissionGrid` — 2-column Wrap with check/x icons per Permission
- GoRouter: /team, /team/add, /team/member/:id (parentNavigatorKey: _rootNavigatorKey)
- app.dart: TeamBloc qo'shildi MultiBlocProvider ga
- Commit: `91c5191`

**Bosqich 5 — Activity Logging**
- Entity: `activity_log.dart` — ActivityType enum (14 qiymat: listingCreated/Updated/Deleted/Boosted, memberInvited/Removed/RoleChanged/Joined, invitationSent/Accepted/Rejected/Cancelled, settingsUpdated, profileUpdated), har biri: value, label, icon, category (listings/members/settings)
- Repository: `activity_log_repository.dart` — 3 method (logActivity, getActivityLogs with filtering/pagination, getMemberActivityLogs)
- 3 ta UseCase: LogActivity, GetActivityLogs, GetMemberActivityLogs
- Model: `activity_log_model.dart` — fromJson with JSONB metadata parsing + joined actor profile
- DataSource: `activity_log_remote_datasource.dart` — `'*, actor:user_id(full_name, avatar_url)'` join, `inFilter` for category filtering, `.range()` pagination
- `ActivityLogWidget` — timeline-style (vertical line + colored dots), actor name + relative time, load more button
- `ActivityLogScreen` — FilterChip row (Barchasi/E'lonlar/Xodimlar/Sozlamalar), activities as constructor param
- TeamBloc integration: LogActivityUseCase inject qilindi, `_logActivity()` helper method
  - Auto-log: memberRoleChanged, memberRemoved, memberInvited, invitationCancelled
- GoRouter: /team/activity (extra: Map with sellerProfileId + activities)
- MockData: 10 ta mockActivityLogs + 2 helper method (getBySellerProfileId, getByUserId)
- DI: `_initActivityLog()` — datasource, repo, 3 use case; TeamBloc ga logActivityUseCase qo'shildi (11 ta inject)
- L10n: "team" (30+ key) + "activity" (18+ key) sectionlari 3 tilga qo'shildi (uz/ru/en)
- Commit: `91c5191`
- `flutter analyze` — 0 error ✅

### ⏳ Keyingi bosqichlar (bajarilmagan):

**Bosqich 6 — KPI Tizimi**
- `kpi_targets` jadvali yaratish
- KPI entity: maqsad qo'yish (listings_created, listings_sold, views_generated, revenue_generated)
- Period turlari: daily, weekly, monthly
- KPI progress hisoblash logic
- KpiBloc yaratish (events: SetTarget, GetTargets, GetProgress)
- KPI use cases: SetKpiTarget, GetKpiTargets, GetKpiProgress, GetTeamKpiSummary
- KPI ekrani: target setting form, progress bar, achievement badges
- Har bir xodim uchun individual KPI tracking
- Data layer: model, datasource (Supabase), repository impl

**Bosqich 7 — Owner Dashboard**
- Yig'ma hisobot ekrani (summary cards)
- Har bir xodim uchun statistika (member performance cards)
- KPI bajarilish foizi (progress rings/bars)
- Grafik va diagrammalar (fl_chart yoki syncfusion_flutter_charts)
- Faoliyat timeline integratsiyasi (activity log widget re-use)
- Vaqt oralig'i filtrlari (bugun/hafta/oy/yil)
- Export imkoniyati (PDF/CSV) — kelajakda
- DashboardBloc yaratish

## Git Branch Ma'lumotlari
- Working branch: `claude/lucid-haslett`
- Asosiy branch: `version(1.0.0)` — merge qilingan
- Commitlar: `0cb20f9` (Phase 1-2), `91c5191` (Phase 3-5), `f92f2e1` (merge commit on version(1.0.0))
- Hammasi origin ga push qilingan ✅

## DI Registration Xaritasi (injection.dart)
- `_initCore()` — StorageService, SecureStorageService, NetworkInfo, ApiClient, PermissionService
- `_initAuth()` — 2 datasource, repo, 5 use case, AuthBloc
- `_initHome()` — datasource, repo, 1 use case, HomeBloc
- `_initReels()` — datasource, repo, 3 use case, ReelsBloc
- `_initSearch()` — 2 datasource, repo, 2 use case, SearchBloc
- `_initListing()` — datasource, repo, 1 use case, ListingBloc
- `_initSaved()` — datasource, repo, SavedBloc
- `_initChat()` — datasource, repo, ConversationsBloc
- `_initSellerMembers()` — datasource, repo, 5 use case
- `_initSellerInvitations()` — datasource, repo, 6 use case
- `_initActivityLog()` — datasource, repo, 3 use case
- `_initTeam()` — TeamBloc (11 use case inject)
- `_initProfile()` — TODO
- `_initNotifications()` — TODO

## Supabase Jadvallari
- `profiles` — user profile ma'lumotlari
- `seller_profiles` — biznes profil
- `seller_members` — jamoa a'zolari (ApiEndpoints.sellerMembers)
- `seller_invitations` — taklifnomalar (ApiEndpoints.sellerInvitations)
- `member_activity_log` — faoliyat logi (ApiEndpoints.memberActivityLog)
- `listings` — e'lonlar
- Storage buckets: avatars, logos, covers, listings, videos, thumbnails, documents

## GoRouter Yo'llari (routes)
- Auth: /splash, /onboarding, /login, /otp, /register
- Shell tabs: / (home), /reels, /search, /chat, /profile
- Detail: /listing/:id, /chat/:id, /saved, /notifications
- Team: /team, /team/add, /team/member/:id, /team/activity

## Design System
- Figma dan o'rganilgan — batafsil: `memory/design_system.md`
- Shrift: Inter, Ranglar: Highlight #006FFD, Neutral #1F2024-#FFFFFF, Success/Warning/Error
- Komponentlar: Button, Card, TextField, TabBar, NavBar, Dialog, Toast, Banner, Calendar, Stepper, Chat, Map va boshqalar
- AppTextField parametrlari: hint (hintText emas!), label, controller, validator, prefixIcon, suffixIcon, keyboardType

## Muhim eslatmalar
- Test mode: `TestConfig.isTestMode = true`, test emaillar: test@autogram.uz, sardor@example.com, aziza@example.com (OTP: 123456)
- Arxitektura: Clean Architecture + BLoC, dartz Either pattern (Left=Failure, Right=Success), GetIt DI
- Tillar: uz (default/fallback), ru, en — easy_localization, JSON files in assets/l10n/
- ActivityType enum: 14 ta (listingPublished/listingDeactivated YO'Q — listingDeleted ishlatiladi)
- AppTextField: `hint` parametri ishlatiladi, `hintText` emas
- Barrel exports: har bir feature uchun (auth.dart, seller.dart, etc.)
- NetworkInfo + ErrorHandler.handleException pattern barcha repo impl larda
