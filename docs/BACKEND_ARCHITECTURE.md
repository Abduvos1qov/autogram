# AUTOGRAM — Backend Arxitektura Rejasi

**Yaratilgan:** 2026-04-11
**Maqsad:** Supabase o'rniga to'liq custom backend

---

## 1. Texnologiya Stack — Yakuniy Qaror

| Qatlam | Texnologiya | Sababi |
|--------|-------------|--------|
| **Til** | **Go 1.22** | Goroutine (100K+ parallel), single binary deploy, Claude AI bilan juda yaxshi ishlaydi |
| **Database** | **PostgreSQL 15** | JSONB, Full-Text Search, PostGIS, ACID, o'zbek tili support |
| **Cache** | **Redis 7.0** | Pub/Sub (real-time chat), session, rate limiting, feed cache |
| **Message Queue** | **Bull (Redis-backed)** | Job scheduling, retry logic, alohida servis kerak emas |
| **Real-time** | **WebSocket + Redis Pub/Sub** | Chat, notifications, listing updates — sub-100ms |
| **Search (v1)** | **PostgreSQL FTS** | <100K listing uchun yetarli, qo'shimcha servis kerak emas |
| **Search (v2)** | **Elasticsearch** | 100K+ listing bo'lganda — fuzzy, phonetic, ranking |
| **Object Storage** | **Cloudflare R2** | Egress $0, Toshkentda edge PoP, Stream bilan bir vendor |
| **Video** | **Cloudflare Stream** | HLS, adaptive bitrate, DRM, analytics |
| **API** | **REST + OpenAPI 3.1** | Sodda, cacheable, Flutter uchun ideal, SDK generation |
| **Auth** | **OTP + JWT + Refresh Token** | Parolsiz, xavfsiz, O'zbekistonda OTP standart |
| **To'lov** | **Adapter pattern** | Click/Payme/Uzum — har biri alohida adapter |
| **Container** | **Docker + Alpine** | Minimal size, tez startup |
| **Orchestration** | **Kubernetes (DOKS)** | Auto-scaling, health check, rolling deploy |
| **Cloud** | **DigitalOcean + Cloudflare** | Arzon, shaffof narx, CDN bepul |
| **Monitoring** | **Prometheus + Grafana** | Open-source, self-hosted |
| **CI/CD** | **GitHub Actions** | Avtomatik test → build → deploy |

---

## 2. Nima Uchun Go?

| Mezon | Go | Node.js | Python |
|-------|-----|---------|--------|
| Claude AI bilan ishlash | A+ (idiomatik, aniq) | A | A |
| Real-time performance | A+ (goroutine) | B+ (event loop) | C (sekin) |
| Memory | 30-50MB | 80-150MB | 100-200MB |
| Deploy | 1 ta binary, 0 dependency | node_modules kerak | venv kerak |
| Concurrency | 100K+ goroutine | Event loop limiti | GIL muammosi |
| Compile-time type safety | Ha | TypeScript bilan | Yo'q |

**Xulosa:** Solo dev + Claude AI + real-time chat + enterprise scale = **Go eng yaxshi tanlov**.

---

## 3. Arxitektura — Modular Monolith

### Nima uchun microservice EMAS?

| | Monolith | Modular Monolith | Microservices |
|--|----------|------------------|---------------|
| Deploy | 1 binary | 1 binary (modullar bilan) | 10+ servis |
| ACID tranzaksiya | Oson | Oson | Saga pattern (murakkab) |
| Solo dev uchun | Ha | **HA** | Yo'q |
| Keyinchalik ajratish | Qiyin | **Oson** | Kerak emas |

**Qaror:** Modular Monolith — modullar aniq chegaralangan, kerak bo'lganda microservice ga ajratish oson.

### Loyiha Strukturasi

```
autogram-backend/
├── cmd/
│   └── api/
│       └── main.go                  # Entry point
├── internal/
│   ├── auth/                        # Autentifikatsiya
│   │   ├── service.go               # Business logic
│   │   ├── handler.go               # HTTP handlers
│   │   ├── repository.go            # DB queries
│   │   └── models.go
│   ├── listings/                    # E'lonlar CRUD
│   │   ├── service.go
│   │   ├── handler.go
│   │   ├── repository.go
│   │   └── models.go
│   ├── chat/                        # Real-time chat
│   │   ├── service.go
│   │   ├── handler.go               # WebSocket
│   │   ├── repository.go
│   │   └── models.go
│   ├── search/                      # Qidiruv + filterlar
│   │   ├── service.go
│   │   └── repository.go
│   ├── payments/                    # To'lov tizimi
│   │   ├── service.go
│   │   ├── handler.go
│   │   ├── adapters/
│   │   │   ├── click.go
│   │   │   ├── payme.go
│   │   │   └── uzum.go
│   │   └── models.go
│   ├── notifications/               # Bildirishnomalar
│   │   ├── service.go
│   │   ├── worker.go                # Job processor
│   │   └── models.go
│   ├── sellers/                     # Seller profil + RBAC
│   │   ├── service.go
│   │   ├── handler.go
│   │   ├── repository.go
│   │   └── models.go
│   ├── reviews/                     # Baholar
│   │   ├── service.go
│   │   ├── handler.go
│   │   └── repository.go
│   ├── analytics/                   # Dashboard
│   │   ├── service.go
│   │   └── worker.go
│   ├── common/                      # Umumiy
│   │   ├── middleware.go            # Auth, CORS, logging
│   │   ├── errors.go
│   │   └── config.go
│   └── infra/                       # Infratuzilma
│       ├── postgres/
│       ├── redis/
│       ├── cloudflare/
│       └── logger.go
├── migrations/                      # SQL migratsiyalar
│   ├── 001_init.sql
│   ├── 002_listings.sql
│   └── ...
├── api/
│   └── openapi.yaml                 # API spetsifikatsiya
├── docker-compose.yml               # Local dev
├── Dockerfile
├── go.mod
├── go.sum
└── Makefile
```

---

## 4. API Endpointlar

```
Auth:
  POST   /api/v1/auth/signup              → OTP yuborish
  POST   /api/v1/auth/verify-otp          → Tasdiqlash + JWT
  POST   /api/v1/auth/refresh             → Token yangilash
  DELETE /api/v1/auth/logout              → Chiqish

Listings:
  POST   /api/v1/listings                 → E'lon yaratish
  GET    /api/v1/listings/{id}            → E'lon ko'rish
  PUT    /api/v1/listings/{id}            → Tahrirlash
  DELETE /api/v1/listings/{id}            → O'chirish
  PATCH  /api/v1/listings/{id}/status     → Status o'zgartirish (sold/archived)

Feed:
  GET    /api/v1/feed/for-you             → Reels feed (cursor pagination)
  GET    /api/v1/feed/home                → Home feed

Search:
  GET    /api/v1/search                   → Qidiruv (12+ filter)
  GET    /api/v1/brands                   → Brendlar ro'yxati

Chat:
  GET    /api/v1/conversations            → Suhbatlar ro'yxati
  GET    /api/v1/conversations/{id}       → Xabarlar tarixi
  POST   /api/v1/messages                 → Xabar yuborish
  WS     /api/v1/ws/chat/{room_id}        → Real-time WebSocket

Sellers:
  POST   /api/v1/sellers                  → Sotuvchi bo'lish
  GET    /api/v1/sellers/{id}             → Profil ko'rish
  PUT    /api/v1/sellers/{id}             → Profil tahrirlash
  GET    /api/v1/sellers/{id}/analytics   → Dashboard

Team (RBAC):
  GET    /api/v1/team/members             → A'zolar ro'yxati
  POST   /api/v1/team/members             → A'zo qo'shish
  PUT    /api/v1/team/members/{id}/role   → Rol o'zgartirish
  DELETE /api/v1/team/members/{id}        → A'zoni chiqarish
  POST   /api/v1/team/invitations         → Taklif yuborish
  PUT    /api/v1/team/invitations/{id}    → Qabul/rad qilish

Payments:
  POST   /api/v1/payments/orders          → Buyurtma yaratish
  POST   /api/v1/payments/initiate        → To'lovni boshlash
  POST   /api/v1/webhooks/click           → Click webhook
  POST   /api/v1/webhooks/payme           → Payme webhook
  POST   /api/v1/webhooks/uzum            → Uzum webhook

Subscriptions:
  GET    /api/v1/subscriptions/plans      → Tariflar
  POST   /api/v1/subscriptions            → Obuna bo'lish
  PUT    /api/v1/subscriptions/{id}       → Upgrade/downgrade
  DELETE /api/v1/subscriptions/{id}       → Bekor qilish

Boosts:
  POST   /api/v1/boosts                   → Boost sotib olish
  GET    /api/v1/boosts                   → Faol boostlar

Notifications:
  GET    /api/v1/notifications            → Ro'yxat
  PUT    /api/v1/notifications/{id}/read  → O'qildi
  PUT    /api/v1/notifications/read-all   → Barchasini o'qish

Reviews:
  POST   /api/v1/reviews                  → Baho berish
  GET    /api/v1/sellers/{id}/reviews     → Baholar ro'yxati

Saved:
  GET    /api/v1/saved                    → Saqlanganlar
  POST   /api/v1/saved/{listing_id}       → Saqlash
  DELETE /api/v1/saved/{listing_id}       → O'chirish
```

---

## 5. Database Schema (Asosiy Jadvallar)

```sql
-- Users
users (id, email, phone, full_name, avatar_url, role, language, created_at)

-- Seller Profiles
seller_profiles (id, user_id, business_name, business_type, subscription_plan,
                 subscription_expires_at, max_listings, is_verified, created_at)

-- Team Members
seller_members (id, seller_profile_id, user_id, role, custom_permissions, joined_at)

-- Invitations
seller_invitations (id, seller_profile_id, email, role, token, status,
                    invited_by, expires_at, created_at)

-- Listings
listings (id, seller_id, user_id, title, description, price, currency,
          is_negotiable, status, video_id, location, boost_until, created_at)

-- Listing Details
listing_details (listing_id, brand, model, year, mileage, fuel_type,
                 transmission, body_type, color, engine_volume, condition,
                 accident_history, owners_count)

-- Listing Photos
listing_photos (id, listing_id, photo_url, position)

-- Conversations
conversations (id, buyer_id, seller_id, listing_id, last_message_at, created_at)

-- Messages
messages (id, conversation_id, sender_id, content, read_at, created_at)

-- Notifications
notifications (id, user_id, type, title, body, metadata JSONB,
               read_at, created_at)

-- Orders (to'lovlar)
orders (id, user_id, type, amount, currency, status, payment_method,
        provider_order_id, created_at, paid_at)

-- Subscriptions
subscriptions (id, user_id, seller_profile_id, plan, status,
               started_at, expires_at, auto_renew)

-- Boosts
boosts (id, listing_id, user_id, type, started_at, expires_at, order_id)

-- Reviews
reviews (id, reviewer_id, seller_id, listing_id, rating, comment, created_at)

-- Activity Log
activity_logs (id, seller_profile_id, user_id, action, metadata JSONB, created_at)

-- Saved Listings
saved_listings (id, user_id, listing_id, created_at)

-- Analytics (kunlik aggregat)
analytics_daily (date, seller_id, listing_id, views, contacts, saves, revenue)
```

---

## 6. Real-time Arxitektura

```
Flutter/Web Client
    ↓ WebSocket upgrade
Go Server (goroutine per connection)
    ↓ subscribe
Redis Pub/Sub
    ↓ broadcast
Barcha ulangan clientlar

Channellar:
  chat:{room_id}           → Suhbat xabarlari
  notifications:{user_id}  → Bildirishnomalar
  feed:updates              → Yangi listing/boost
```

---

## 7. To'lov Arxitekturasi

```
Client → "Click bilan to'lash" → API → ClickAdapter → Click API
                                                    ↓
                                              Foydalanuvchi to'laydi
                                                    ↓
                                          Click webhook → API
                                                    ↓
                                          Order status = "paid"
                                                    ↓
                                          Subscription faollashtiriladi
```

Har bir provider (Click, Payme, Uzum) uchun alohida adapter — `PaymentGateway` interface ni implement qiladi.

---

## 8. Deploy Bosqichlari

| Bosqich | MAU | Infra | Narx/oy |
|---------|-----|-------|---------|
| **MVP** (0-2 oy) | <1K | DigitalOcean 1 VPS + managed DB + Redis | ~$60 |
| **Growth** (3-6 oy) | 1K-10K | DOKS 3-node + managed DB + Redis | ~$150 |
| **Scale** (7-12 oy) | 10K-100K | DOKS 5-10 node + DB replicas + Redis Cluster | ~$500 |
| **Enterprise** (2-3 yil) | 100K-1M | Multi-node DOKS + sharding + Elasticsearch | ~$2-5K |

---

## 9. Implementation Ketma-ketligi

### Faza 1 — Asos (2-3 hafta)
1. Go project setup (cmd/api, internal/, go.mod)
2. PostgreSQL migratsiyalar (barcha jadvallar)
3. Auth moduli (OTP + JWT + refresh)
4. Middleware (auth, CORS, logging, error handling)
5. Docker + docker-compose (local dev)

### Faza 2 — Core Features (3-4 hafta)
6. Listings CRUD + photo upload (R2)
7. Video integration (Cloudflare Stream)
8. Search + filterlar (PostgreSQL FTS)
9. Feed endpoint (cursor pagination, boost ranking)

### Faza 3 — Communication (2-3 hafta)
10. Chat (REST + WebSocket + Redis Pub/Sub)
11. Notifications (in-app + push via FCM)
12. Saved listings

### Faza 4 — Monetizatsiya (2-3 hafta)
13. Seller profil + RBAC (team, invitation, activity log)
14. Payment adapters (Click, Payme, Uzum)
15. Subscription lifecycle (purchase, renew, expire)
16. Boost tizimi

### Faza 5 — Polish (1-2 hafta)
17. Reviews & ratings
18. Analytics dashboard
19. OpenAPI spec + Swagger UI
20. CI/CD pipeline (GitHub Actions → DOKS)

**Jami: ~10-14 hafta (Claude AI bilan)**

---

## 10. Flutter Integratsiya Rejasi

Backend tayyor bo'lgach, Flutter appdagi o'zgarishlar:

1. `ApiClient` — Supabase SDK o'rniga Dio + custom REST endpoints
2. `AuthRepository` — Supabase auth → custom OTP + JWT
3. `WebSocketService` — yangi servis (chat + notifications)
4. Remote data sourcelar — barcha Supabase querylar → REST API calls
5. `TestConfig` — mock fallback saqlanadi, backend URL environment variable

**Arxitektura o'zgarmaydi** — Clean Architecture + BLoC pattern bir xil qoladi, faqat data layer o'zgaradi.

---

*Bu hujjat backend arxitekturasining asosiy yo'l xaritasi. Har bir modul uchun batafsil spetsifikatsiya alohida yaratiladi.*
