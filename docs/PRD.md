# AUTOGRAM - Product Requirements Document (PRD)

**Version:** 1.0
**Last Updated:** February 2026
**Product Manager:** AUTOGRAM Team
**Status:** Active Development

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Vision](#product-vision)
3. [Target Market](#target-market)
4. [User Personas](#user-personas)
5. [User Stories](#user-stories)
6. [Feature Prioritization](#feature-prioritization)
7. [Success Metrics](#success-metrics)
8. [Competitive Analysis](#competitive-analysis)
9. [Market Considerations for Uzbekistan](#market-considerations-for-uzbekistan)
10. [Analytics Requirements](#analytics-requirements)

---

## Executive Summary

AUTOGRAM is a revolutionary mobile-first car marketplace designed specifically for the Uzbekistan market. Unlike traditional classified ad platforms, AUTOGRAM introduces a **Reels-style video-first experience** that allows car dealers and individual sellers to showcase vehicles through short, engaging video content.

### Key Differentiators

- **Video-First Listings:** TikTok/Instagram Reels-style vertical video browsing
- **Verified Sellers:** Trust system with seller verification badges
- **Local Focus:** Designed for Uzbekistan with local cities, UZS/USD currency, and Uzbek language
- **Social Features:** Like, save, share, follow sellers, and in-app messaging
- **Modern UX:** Swipe-based navigation, optimized for mobile consumption

### Current Implementation Status

| Feature Area | Status |
|-------------|--------|
| Authentication (OTP) | Implemented |
| Reels Video Feed | Implemented |
| Search & Filters | Implemented |
| Listing Details | Implemented |
| Chat/Messaging | Implemented |
| Saved/Wishlist | Implemented |
| Notifications | Implemented |
| Seller Profiles | Implemented |
| User Profiles | Implemented |

---

## Product Vision

### Vision Statement

> "To become the #1 car marketplace in Uzbekistan by transforming how people discover, explore, and purchase vehicles through immersive video content and trusted seller relationships."

### Mission

Empower car buyers to make informed decisions through transparent video presentations while helping sellers reach more qualified buyers faster.

### Long-Term Goals (3 Years)

1. Achieve 1M+ monthly active users in Uzbekistan
2. Process 50,000+ car transactions annually
3. Onboard 80% of registered car dealerships
4. Expand to neighboring Central Asian countries (Kazakhstan, Kyrgyzstan, Tajikistan)

---

## Target Market

### Primary Market

**Uzbekistan Automotive Market**
- Population: 35+ million
- Growing middle class with increasing purchasing power
- High smartphone penetration (80%+)
- Strong preference for video content consumption
- Underdeveloped digital car marketplace

### Target Users

| Segment | Description | % of Users |
|---------|-------------|------------|
| Car Buyers | Individuals looking to purchase new/used cars | 70% |
| Individual Sellers | Private car owners selling their vehicles | 15% |
| Car Dealerships | Professional businesses selling multiple cars | 10% |
| Auto Salons | Showrooms and premium dealers | 5% |

---

## User Personas

### Persona 1: Aziz (The First-Time Buyer)

**Demographics:**
- Age: 28
- Location: Tashkent
- Occupation: IT Specialist
- Income: 15,000,000 UZS/month

**Goals:**
- Find a reliable used car within his budget
- Verify the condition before visiting
- Contact sellers directly
- Compare multiple options

**Pain Points:**
- Doesn't trust static photos (could be outdated)
- Afraid of hidden defects
- Waste of time visiting sellers with misleading ads
- Difficulty verifying seller legitimacy

**How AUTOGRAM Helps:**
- Video walkarounds show real car condition
- Verified seller badges build trust
- Filter by no-accident history
- Direct messaging before visiting

---

### Persona 2: Madina (The Upgrader)

**Demographics:**
- Age: 35
- Location: Samarkand
- Occupation: Business Owner
- Family: Married with 2 children

**Goals:**
- Upgrade from sedan to SUV for family
- Sell current vehicle quickly
- Find a car with specific features

**Pain Points:**
- Limited time for car shopping
- Needs to sell current car first
- Wants family-friendly features
- Prefers negotiable prices

**How AUTOGRAM Helps:**
- Browse during commute with swipeable videos
- Post her own listing with video
- Filter by body type and features
- See "Negotiable" price tags

---

### Persona 3: Rustam (The Dealer)

**Demographics:**
- Age: 45
- Location: Tashkent
- Occupation: Auto Salon Owner
- Business: 50+ cars in inventory

**Goals:**
- Reach more buyers online
- Stand out from competition
- Manage multiple listings
- Build business reputation

**Pain Points:**
- High competition with OLX and Avtoelon
- Difficult to showcase car quality in photos
- Managing inquiries from multiple platforms
- Building trust with new customers

**How AUTOGRAM Helps:**
- Video listings differentiate from competitors
- Verified seller badge
- Analytics on views/engagement
- Centralized chat inbox
- Business subscription with premium features

---

### Persona 4: Bobur (The Car Enthusiast)

**Demographics:**
- Age: 22
- Location: Namangan
- Occupation: University Student

**Goals:**
- Browse dream cars for inspiration
- Save favorites for future
- Follow premium dealers
- Stay updated on new listings

**Pain Points:**
- Can't afford yet but wants to explore
- Wants engaging browsing experience
- Interested in specific brands/models

**How AUTOGRAM Helps:**
- Endless scrolling like TikTok
- Save listings to wishlist
- Follow favorite sellers
- Price drop notifications

---

## User Stories

### Authentication & Onboarding

| ID | Story | Priority |
|----|-------|----------|
| US-001 | As a new user, I want to sign up with my phone number so that I can create an account easily | Must Have |
| US-002 | As a user, I want to receive an OTP via SMS to verify my phone number | Must Have |
| US-003 | As a new user, I want to complete my profile (name, avatar) after verification | Must Have |
| US-004 | As a user, I want to choose between Buyer and Seller roles during registration | Must Have |
| US-005 | As a user, I want to see an onboarding tutorial explaining app features | Should Have |
| US-006 | As a user, I want to select my preferred language (Uzbek, Russian, English) | Must Have |

### Browsing & Discovery

| ID | Story | Priority |
|----|-------|----------|
| US-010 | As a buyer, I want to swipe through car videos vertically (like TikTok) to discover listings | Must Have |
| US-011 | As a buyer, I want to see car details (price, specs) overlaid on the video | Must Have |
| US-012 | As a buyer, I want to like videos to show interest | Must Have |
| US-013 | As a buyer, I want to save listings to my wishlist for later | Must Have |
| US-014 | As a buyer, I want to share listings with friends via social media | Must Have |
| US-015 | As a buyer, I want to see seller information and verification status | Must Have |
| US-016 | As a buyer, I want to follow sellers to see their new listings | Should Have |
| US-017 | As a buyer, I want videos to auto-play and pause when I scroll | Must Have |
| US-018 | As a buyer, I want to view video duration and progress | Should Have |

### Search & Filtering

| ID | Story | Priority |
|----|-------|----------|
| US-020 | As a buyer, I want to search by brand and model name | Must Have |
| US-021 | As a buyer, I want to filter by price range (min/max) | Must Have |
| US-022 | As a buyer, I want to filter by year of manufacture | Must Have |
| US-023 | As a buyer, I want to filter by mileage | Must Have |
| US-024 | As a buyer, I want to filter by transmission type (automatic/manual) | Must Have |
| US-025 | As a buyer, I want to filter by fuel type (petrol, diesel, gas, electric, hybrid) | Must Have |
| US-026 | As a buyer, I want to filter by body type (sedan, SUV, etc.) | Must Have |
| US-027 | As a buyer, I want to filter by city/region | Must Have |
| US-028 | As a buyer, I want to filter by verified sellers only | Should Have |
| US-029 | As a buyer, I want to filter by "no accident" history | Should Have |
| US-030 | As a buyer, I want to filter by first owner | Should Have |
| US-031 | As a buyer, I want to sort results (newest, price, popularity, mileage) | Must Have |
| US-032 | As a buyer, I want to see my recent search history | Should Have |
| US-033 | As a buyer, I want to see popular/trending searches | Should Have |
| US-034 | As a buyer, I want to save filter presets for quick access | Could Have |

### Listing Details

| ID | Story | Priority |
|----|-------|----------|
| US-040 | As a buyer, I want to view full listing details with all specs | Must Have |
| US-041 | As a buyer, I want to view a gallery of photos and videos | Must Have |
| US-042 | As a buyer, I want to see the seller's profile and ratings | Must Have |
| US-043 | As a buyer, I want to see seller's contact information | Must Have |
| US-044 | As a buyer, I want to call the seller directly from the app | Must Have |
| US-045 | As a buyer, I want to message the seller in-app | Must Have |
| US-046 | As a buyer, I want to see similar listings | Should Have |
| US-047 | As a buyer, I want to report suspicious listings | Must Have |
| US-048 | As a buyer, I want to see view count and engagement metrics | Should Have |
| US-049 | As a buyer, I want to see listing publish date | Must Have |

### Messaging/Chat

| ID | Story | Priority |
|----|-------|----------|
| US-050 | As a user, I want to send text messages to sellers/buyers | Must Have |
| US-051 | As a user, I want to see my conversation history | Must Have |
| US-052 | As a user, I want to see which listing the conversation is about | Must Have |
| US-053 | As a user, I want to see read receipts for messages | Should Have |
| US-054 | As a user, I want to receive push notifications for new messages | Must Have |
| US-055 | As a user, I want to share my location in chat | Could Have |
| US-056 | As a user, I want to share photos in chat | Should Have |
| US-057 | As a user, I want to share contact information in chat | Could Have |

### Seller Features

| ID | Story | Priority |
|----|-------|----------|
| US-060 | As a seller, I want to create a business profile | Must Have |
| US-061 | As a seller, I want to upload video listings | Must Have |
| US-062 | As a seller, I want to add photos to my listing | Must Have |
| US-063 | As a seller, I want to specify car details (brand, model, year, etc.) | Must Have |
| US-064 | As a seller, I want to set price and mark as negotiable | Must Have |
| US-065 | As a seller, I want to manage my active listings | Must Have |
| US-066 | As a seller, I want to see views/engagement analytics | Should Have |
| US-067 | As a seller, I want to mark listings as sold | Must Have |
| US-068 | As a seller, I want to archive/delete listings | Must Have |
| US-069 | As a seller, I want to feature/boost my listings | Should Have |
| US-070 | As a seller, I want to get verified status | Should Have |
| US-071 | As a seller, I want to see my reviews and ratings | Should Have |

### Notifications

| ID | Story | Priority |
|----|-------|----------|
| US-080 | As a user, I want to receive notifications for new messages | Must Have |
| US-081 | As a buyer, I want notifications when saved listings drop in price | Should Have |
| US-082 | As a buyer, I want notifications when followed sellers post new listings | Should Have |
| US-083 | As a seller, I want notifications when someone views my listing | Could Have |
| US-084 | As a seller, I want notifications when subscription is expiring | Should Have |
| US-085 | As a user, I want to manage notification preferences | Should Have |

### Profile & Settings

| ID | Story | Priority |
|----|-------|----------|
| US-090 | As a user, I want to view and edit my profile | Must Have |
| US-091 | As a user, I want to change my avatar | Should Have |
| US-092 | As a user, I want to change my phone number | Should Have |
| US-093 | As a user, I want to change my preferred language | Must Have |
| US-094 | As a user, I want to view my saved listings | Must Have |
| US-095 | As a user, I want to view my activity history | Could Have |
| US-096 | As a user, I want to log out of my account | Must Have |
| US-097 | As a user, I want to delete my account | Must Have |

---

## Feature Prioritization (MoSCoW Method)

### Must Have (MVP)

| Feature | Description | Status |
|---------|-------------|--------|
| Phone Authentication | OTP-based login/registration | Done |
| Reels Feed | Vertical video browsing | Done |
| Listing Details | Full car information view | Done |
| Search | Basic search with filters | Done |
| Messaging | In-app chat | Done |
| Saved/Wishlist | Save listings for later | Done |
| User Profile | View/edit profile | Done |
| Seller Profile | View seller information | Done |

### Should Have (Phase 2)

| Feature | Description | Status |
|---------|-------------|--------|
| Listing Creation | Sellers post new listings | Pending |
| Analytics Dashboard | Views, engagement for sellers | Pending |
| Seller Verification | Verified badge system | Partial |
| Push Notifications | Real-time alerts | Pending |
| Price Drop Alerts | Notify on price changes | Pending |
| Reviews & Ratings | Rate sellers after transaction | Pending |
| Advanced Filters | Save presets, more options | Partial |
| Share to Social | Share to Telegram, Instagram | Pending |

### Could Have (Phase 3)

| Feature | Description | Status |
|---------|-------------|--------|
| Featured Listings | Paid promotion/boosting | Pending |
| Subscription Plans | Dealer premium features | Pending |
| Payment Integration | Click, Payme, Uzum | Pending |
| Car History Report | VIN check integration | Pending |
| AR Preview | View car in AR | Pending |
| Video Calling | Video chat with sellers | Pending |
| Price Comparison | Market value analysis | Pending |
| Loan Calculator | Financing options | Pending |

### Won't Have (Out of Scope)

| Feature | Reason |
|---------|--------|
| Car Insurance | Different business model |
| Car Parts | Different marketplace category |
| Car Services | Different marketplace category |
| International Markets | Focus on Uzbekistan first |

---

## Success Metrics (KPIs)

### User Acquisition

| Metric | Target (Month 6) | Target (Year 1) |
|--------|------------------|-----------------|
| Total Downloads | 100,000 | 500,000 |
| Monthly Active Users (MAU) | 50,000 | 250,000 |
| Daily Active Users (DAU) | 15,000 | 75,000 |
| DAU/MAU Ratio | 30% | 30% |
| New User Registrations (monthly) | 15,000 | 50,000 |

### Engagement

| Metric | Target |
|--------|--------|
| Avg. Session Duration | 8+ minutes |
| Sessions per User per Day | 2.5+ |
| Videos Watched per Session | 15+ |
| Like Rate | 5% of views |
| Save Rate | 3% of views |
| Share Rate | 1% of views |
| Message Rate (listing to chat) | 8% |

### Marketplace

| Metric | Target (Year 1) |
|--------|-----------------|
| Total Listings | 50,000 |
| Active Listings | 20,000 |
| Listings with Video | 80% |
| Verified Sellers | 5,000 |
| Avg. Time to Sell | 14 days |
| Transactions Facilitated | 25,000 |

### Revenue (Phase 3+)

| Metric | Target (Year 2) |
|--------|-----------------|
| Featured Listings Revenue | $50,000/month |
| Subscription Revenue | $30,000/month |
| Transaction Fees | $20,000/month |
| Premium Seller MRR | $100,000 |

### Quality

| Metric | Target |
|--------|--------|
| App Store Rating | 4.5+ stars |
| Crash-Free Rate | 99.5% |
| API Latency (p95) | < 500ms |
| Video Load Time | < 3 seconds |
| Customer Support Response | < 4 hours |

---

## Competitive Analysis

### Overview of Uzbekistan Car Marketplace

| Platform | Type | Video Support | Mobile App | Verified Sellers | Est. Market Share |
|----------|------|---------------|------------|------------------|-------------------|
| **OLX.uz** | General Classifieds | No | Yes | No | 35% |
| **Avtoelon.uz** | Auto Classifieds | Limited | No | No | 30% |
| **Olx.uz/avto** | Auto Category | No | Yes | No | 15% |
| **Telegram Channels** | Social | Videos | No | No | 15% |
| **AUTOGRAM** | Video Marketplace | Yes (Core) | Yes | Yes | Target: 25% |

### Detailed Competitor Analysis

#### OLX.uz

**Strengths:**
- Established brand recognition
- Large user base
- Multi-category platform
- Mobile app available

**Weaknesses:**
- No video support
- Generic design (not auto-specific)
- No seller verification
- Outdated UX

**AUTOGRAM Advantage:**
- Video-first experience
- Modern, auto-focused UI
- Verified seller program

---

#### Avtoelon.uz

**Strengths:**
- Auto-specific focus
- Detailed car specifications
- Established market presence

**Weaknesses:**
- Web-only (no native app)
- Limited video support
- Cluttered interface
- No social features

**AUTOGRAM Advantage:**
- Native mobile app
- TikTok-style video browsing
- Social engagement features
- Modern design

---

#### Telegram Channels

**Strengths:**
- Familiar to Uzbekistan users
- Supports video
- Free to use
- Direct messaging

**Weaknesses:**
- No search/filter functionality
- No structured listings
- Hard to verify sellers
- Scattered across many channels

**AUTOGRAM Advantage:**
- Structured marketplace with search
- All listings in one place
- Advanced filtering
- Seller verification

---

### Competitive Positioning Map

```
                    HIGH VIDEO CAPABILITY
                           |
    Telegram Channels      |      AUTOGRAM (Target)
         (-)               |           (+)
                           |
LOW TRUST ----------------+---------------- HIGH TRUST
                           |
      OLX.uz               |       Avtoelon.uz
        (+/-)              |           (+/-)
                           |
                    LOW VIDEO CAPABILITY
```

### Competitive Advantages Summary

1. **Video-First:** Only platform with TikTok-style video browsing
2. **Mobile Native:** Purpose-built mobile experience
3. **Trust:** Verified seller badges and reviews
4. **Modern UX:** Swipe navigation, social features
5. **Local Focus:** Uzbek language, UZS currency, local cities
6. **Engagement:** Like, save, follow, share features

---

## Market Considerations for Uzbekistan

### Localization Requirements

#### Language Support

| Language | Priority | Current Status |
|----------|----------|----------------|
| Uzbek (Latin) | Primary | Implemented |
| Russian | Secondary | Planned |
| English | Tertiary | Planned |

#### Currency Display

- **Primary:** USD (commonly used for car pricing)
- **Secondary:** UZS (Uzbek Som)
- **Feature:** Real-time conversion toggle
- **Format:** 25,000 USD or 315,000,000 UZS

#### Regional Coverage

All major cities implemented:
- Toshkent (Tashkent)
- Samarqand (Samarkand)
- Buxoro (Bukhara)
- Namangan
- Andijon (Andijan)
- Farg'ona (Fergana)
- Qo'qon (Kokand)
- Nukus
- Qarshi
- Jizzax (Jizzakh)
- Urganch (Urgench)
- Navoiy (Navoi)
- Termiz (Termez)
- Guliston
- Chirchiq
- Olmaliq
- Angren
- Margilan

### Payment Methods (Phase 3)

| Provider | Type | Integration Priority |
|----------|------|---------------------|
| **Click** | Mobile Payment | High |
| **Payme** | Mobile Payment | High |
| **Uzum** | Mobile Payment | Medium |
| **Bank Cards** | Humo/UzCard | Medium |
| **Cash** | In-person | N/A |

### Cultural Considerations

1. **Negotiation Culture:** Price negotiation is common; "Kelishiladi" (negotiable) badge is essential
2. **Trust Factor:** Personal recommendations matter; seller verification crucial
3. **WhatsApp/Telegram:** Popular messaging apps; consider integration
4. **Video Preference:** High consumption of video content (TikTok popular)
5. **Family Decision:** Car purchases often involve family input

### Technical Considerations

1. **Network Quality:** Variable 4G coverage; optimize video streaming
2. **Device Range:** Support mid-range Android devices
3. **Offline Mode:** Consider caching for poor connectivity areas
4. **Data Costs:** Offer low-data mode for video quality

---

## Analytics Requirements

### Event Tracking Schema

#### User Events

| Event Name | Properties | Trigger |
|------------|------------|---------|
| `user_registered` | method, role | Account creation complete |
| `user_logged_in` | method | Login success |
| `user_logged_out` | - | Logout action |
| `profile_updated` | fields_changed | Profile save |
| `language_changed` | from, to | Language selection |

#### Browsing Events

| Event Name | Properties | Trigger |
|------------|------------|---------|
| `reel_viewed` | listing_id, seller_id, duration, percentage | Reel displayed |
| `reel_completed` | listing_id, duration | Video played 100% |
| `reel_liked` | listing_id | Like button tap |
| `reel_saved` | listing_id | Save button tap |
| `reel_shared` | listing_id, platform | Share action |
| `seller_followed` | seller_id | Follow button tap |

#### Search Events

| Event Name | Properties | Trigger |
|------------|------------|---------|
| `search_performed` | query, filters, results_count | Search submit |
| `filter_applied` | filter_type, value | Filter selection |
| `filter_cleared` | - | Clear filters |
| `sort_changed` | sort_option | Sort selection |
| `search_result_clicked` | listing_id, position | Result tap |

#### Listing Events

| Event Name | Properties | Trigger |
|------------|------------|---------|
| `listing_viewed` | listing_id, source | Detail screen open |
| `listing_gallery_viewed` | listing_id, image_index | Gallery navigation |
| `listing_call_clicked` | listing_id, seller_id | Call button tap |
| `listing_message_clicked` | listing_id, seller_id | Message button tap |
| `listing_reported` | listing_id, reason | Report submit |

#### Chat Events

| Event Name | Properties | Trigger |
|------------|------------|---------|
| `conversation_started` | listing_id, seller_id | First message sent |
| `message_sent` | conversation_id, type | Message send |
| `message_read` | conversation_id | Messages marked read |

#### Seller Events

| Event Name | Properties | Trigger |
|------------|------------|---------|
| `listing_created` | listing_id, has_video | Listing published |
| `listing_updated` | listing_id, fields_changed | Listing edit |
| `listing_marked_sold` | listing_id | Status change |
| `listing_deleted` | listing_id | Deletion |

### Conversion Funnels

#### Buyer Funnel

```
1. App Open
   ↓ (retention rate)
2. Reel Viewed (10+ reels)
   ↓ (engagement rate)
3. Listing Detail Opened
   ↓ (interest rate)
4. Contact Action (call/message)
   ↓ (intent rate)
5. Transaction (marked sold)
```

#### Seller Funnel

```
1. Registration
   ↓ (activation rate)
2. Profile Completed
   ↓ (setup rate)
3. First Listing Created
   ↓ (activation rate)
4. First Inquiry Received
   ↓ (quality rate)
5. Listing Sold
```

### Dashboard Metrics

#### Executive Dashboard

- DAU / MAU / WAU
- New registrations
- Total active listings
- Messages sent
- Seller conversion rate

#### Engagement Dashboard

- Avg. reels watched per session
- Avg. session duration
- Like/Save/Share rates
- Search-to-view rate
- View-to-contact rate

#### Marketplace Dashboard

- New listings (daily/weekly)
- Listings with video %
- Avg. time to first inquiry
- Avg. time to sale
- Listings by status

#### Quality Dashboard

- Crash-free rate
- API error rate
- Video load time
- App launch time
- Report rate

---

## Appendix

### A. Glossary

| Term | Definition |
|------|------------|
| Reel | Short-form vertical video of a car listing |
| Feed | Scrollable list of reels or listings |
| Verified Seller | Seller who passed identity verification |
| Featured Listing | Paid placement for increased visibility |
| Wishlist | User's saved listings |

### B. Technical Dependencies

- Flutter for mobile app
- Bloc for state management
- Supabase/Firebase for backend
- Video hosting (HLS streaming)
- Push notification service
- SMS gateway for OTP

### C. Design Resources

- Figma designs (link TBD)
- Design system documentation
- Brand guidelines

---

*Document maintained by AUTOGRAM Product Team*
