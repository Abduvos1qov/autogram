# AUTOGRAM - User Flow Documentation

**Version:** 1.0
**Last Updated:** February 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication Flow](#authentication-flow)
3. [Buyer Journey](#buyer-journey)
4. [Seller Journey](#seller-journey)
5. [Search and Filter Flow](#search-and-filter-flow)
6. [Chat Flow](#chat-flow)
7. [Notification Flow](#notification-flow)
8. [Profile Management Flow](#profile-management-flow)

---

## Overview

This document describes the complete user flows within the AUTOGRAM application. Each flow is documented with screens, actions, and decision points.

### Flow Notation

- **[Screen]** - A distinct screen/page in the app
- **{Action}** - User interaction or tap
- **<Decision>** - Conditional branching
- **->** - Navigation flow
- **(State)** - App/data state

---

## Authentication Flow

### 1. App Launch Flow

```
[Splash Screen]
    |
    v
<Check Auth Token>
    |
    +--> (Valid Token) --> [Home Screen]
    |
    +--> (No Token) --> <First Launch?>
                            |
                            +--> (Yes) --> [Onboarding Screen]
                            |
                            +--> (No) --> [Login Screen]
```

### 2. Onboarding Flow

```
[Onboarding Screen]
    |
    v
[Slide 1: Welcome]
    "AUTOGRAM - O'zbekistonning birinchi
     video-asosidagi avto bozori"
    |
    {Swipe Right}
    v
[Slide 2: Discover]
    "TikTok uslubida mashina
     videolarini ko'ring"
    |
    {Swipe Right}
    v
[Slide 3: Connect]
    "Sotuvchilar bilan bevosita
     bog'laning"
    |
    {Tap "Boshlash"}
    v
[Login Screen]
```

### 3. Login/Registration Flow

```
[Login Screen]
    |
    {Enter Phone Number}
    "+998 XX XXX XX XX"
    |
    {Tap "Davom etish"}
    |
    v
(Send OTP via SMS)
    |
    v
[OTP Screen]
    |
    {Enter 6-digit code}
    |
    v
<OTP Valid?>
    |
    +--> (Invalid) --> [Show Error] --> [OTP Screen]
    |
    +--> (Valid) --> <Existing User?>
                        |
                        +--> (Yes) --> (Load Profile) --> [Home Screen]
                        |
                        +--> (No) --> [Register Screen]
```

### 4. Registration Flow

```
[Register Screen]
    |
    {Enter Full Name}
    |
    {Select Avatar (optional)}
    |
    {Select Role}
    +-- [Buyer] - "Sotib oluvchi"
    +-- [Seller] - "Sotuvchi"
    |
    {Select Language}
    +-- Uzbek
    +-- Russian
    +-- English
    |
    {Tap "Ro'yxatdan o'tish"}
    |
    v
<Role = Seller?>
    |
    +--> (Yes) --> [Seller Profile Setup]
    |
    +--> (No) --> [Home Screen]
```

### 5. Seller Profile Setup Flow

```
[Seller Profile Setup]
    |
    {Enter Business Name}
    |
    {Select Business Type}
    +-- Individual (Jismoniy shaxs)
    +-- Dealer (Diler)
    +-- Salon (Avtosalon)
    |
    {Enter Address}
    |
    {Enter City}
    |
    {Add Contact Phones}
    |
    {Add Social Links (optional)}
    +-- Telegram
    +-- Instagram
    +-- Website
    |
    {Upload Logo (optional)}
    |
    {Tap "Yakunlash"}
    |
    v
[Home Screen]
```

---

## Buyer Journey

### Complete Buyer Flow: Browse -> View -> Contact -> Purchase

```
                        [App Launch]
                             |
                             v
                      [Splash Screen]
                             |
                             v
    +------------------[Home Screen]------------------+
    |                        |                        |
    v                        v                        v
[Reels Tab]           [Search Tab]           [Saved Tab]
    |                        |                        |
    |                        v                        |
    |              [Search Results]                   |
    |                        |                        |
    +------------+-----------+----------+-------------+
                 |
                 v
        [Listing Detail Screen]
                 |
        +--------+--------+
        |                 |
        v                 v
   {Call Seller}    {Message Seller}
        |                 |
        v                 v
   [Phone App]     [Chat Screen]
        |                 |
        +--------+--------+
                 |
                 v
          (Arrange Meeting)
                 |
                 v
           (View Car IRL)
                 |
                 v
          (Negotiate Price)
                 |
                 v
           (Make Payment)
                 |
                 v
          (Complete Sale)
```

### Reels Browsing Flow

```
[Reels Screen]
    |
    (Auto-play first reel)
    |
    v
+---[Reel Player]---+
|                   |
|  [Video Content]  |
|                   |
|  +-- Price        |
|  +-- Title        |
|  +-- Seller Info  |
|  +-- Location     |
|                   |
|  [Action Buttons] |
|  +-- Like         |
|  +-- Comment      |
|  +-- Save         |
|  +-- Share        |
|                   |
+-------------------+
    |
    <User Action>
    |
    +--> {Swipe Up} --> [Next Reel]
    |
    +--> {Swipe Down} --> [Previous Reel]
    |
    +--> {Tap Video} --> [Pause/Play]
    |
    +--> {Tap Like} --> (Toggle Like State)
    |
    +--> {Tap Save} --> (Add to Wishlist)
    |
    +--> {Tap Share} --> [Share Sheet]
    |
    +--> {Tap Seller} --> [Seller Profile]
    |
    +--> {Tap Price/Details} --> [Listing Detail]
```

### Listing Detail Flow

```
[Listing Detail Screen]
    |
    +--[Gallery Section]--+
    |  - Video Player     |
    |  - Photo Carousel   |
    |  - Swipe indicators |
    +---------------------+
    |
    +--[Info Section]-----+
    |  - Title            |
    |  - Price            |
    |  - Negotiable badge |
    |  - Stats (views,    |
    |    likes, city)     |
    +---------------------+
    |
    +--[Specs Section]----+
    |  - Brand/Model      |
    |  - Year             |
    |  - Mileage          |
    |  - Fuel Type        |
    |  - Transmission     |
    |  - Body Type        |
    |  - Color            |
    |  - Engine Volume    |
    |  - Condition        |
    |  - Accident History |
    |  - Owners Count     |
    +---------------------+
    |
    +--[Description]------+
    |  (Full text)        |
    +---------------------+
    |
    +--[Seller Card]------+
    |  - Logo/Avatar      |
    |  - Business Name    |
    |  - Verified Badge   |
    |  - Rating           |
    |  - Follow Button    |
    +---------------------+
    |
    +--[Similar Listings]-+
    |  (Grid of cards)    |
    +---------------------+
    |
    +--[Bottom Bar]-------+
    |  [Like] [Call] [Message]
    +---------------------+

    <User Actions>
    |
    +--> {Tap Call} --> [Phone Dialer]
    |
    +--> {Tap Message} --> [Chat Screen]
    |
    +--> {Tap Save} --> (Add to Wishlist)
    |
    +--> {Tap Share} --> [Share Sheet]
    |
    +--> {Tap Report} --> [Report Dialog]
    |
    +--> {Tap Seller Card} --> [Seller Profile]
    |
    +--> {Tap Similar} --> [Listing Detail]
```

### Saved/Wishlist Flow

```
[Saved Screen]
    |
    <Has Saved Items?>
    |
    +--> (No) --> [Empty State]
    |              "Saqlanganlar yo'q"
    |
    +--> (Yes) --> [Saved List]
                      |
                      v
                +--[Saved Card]--+
                |  - Thumbnail   |
                |  - Title       |
                |  - Price       |
                |  - Specs       |
                |  - Seller      |
                +----------------+
                      |
                <User Actions>
                      |
    +-----------------+------------------+
    |                 |                  |
    v                 v                  v
{Tap Card}      {Swipe Left}      {Tap Delete All}
    |                 |                  |
    v                 v                  v
[Listing Detail] (Remove Item)    [Confirm Dialog]
                                        |
                                        v
                                  (Clear All)
```

---

## Seller Journey

### Complete Seller Flow: Register -> Post -> Manage -> Sell

```
[Registration]
    |
    {Select Seller Role}
    |
    v
[Seller Profile Setup]
    |
    v
[Home Screen]
    |
    {Tap "+" or Create Listing}
    |
    v
[Create Listing Flow]
    |
    v
[Listing Management]
    |
    v
[Receive Inquiries]
    |
    v
[Negotiate via Chat]
    |
    v
[Mark as Sold]
```

### Create Listing Flow (Planned - Phase 2)

```
[Create Listing Screen]
    |
    +--[Step 1: Media]----+
    |  {Record/Upload     |
    |   Video}            |
    |  {Add Photos        |
    |   (up to 10)}       |
    +---------------------+
    |
    {Tap "Davom etish"}
    |
    v
    +--[Step 2: Details]--+
    |  {Select Brand}     |
    |  {Select Model}     |
    |  {Enter Year}       |
    |  {Enter Mileage}    |
    +---------------------+
    |
    {Tap "Davom etish"}
    |
    v
    +--[Step 3: Specs]----+
    |  {Select Fuel Type} |
    |  {Select Trans}     |
    |  {Select Body Type} |
    |  {Select Color}     |
    |  {Enter Engine Vol} |
    |  {Select Condition} |
    |  {Accident History} |
    |  {Owners Count}     |
    +---------------------+
    |
    {Tap "Davom etish"}
    |
    v
    +--[Step 4: Price]----+
    |  {Enter Price}      |
    |  {Select Currency}  |
    |  {Toggle Negotiable}|
    +---------------------+
    |
    {Tap "Davom etish"}
    |
    v
    +--[Step 5: Location]-+
    |  {Select City}      |
    |  {Select District}  |
    +---------------------+
    |
    {Tap "Davom etish"}
    |
    v
    +--[Step 6: Description]
    |  {Enter Title}      |
    |  {Enter Description}|
    +---------------------+
    |
    {Tap "E'lon berish"}
    |
    v
<Validation Check>
    |
    +--> (Invalid) --> [Show Errors]
    |
    +--> (Valid) --> (Submit to Review)
                          |
                          v
                    [Success Screen]
                          |
                    "E'loningiz moderatsiyadan
                     o'tkazilmoqda"
                          |
                          v
                    [My Listings Screen]
```

### Listing Management Flow (Planned - Phase 2)

```
[My Listings Screen]
    |
    +--[Tab: Active]------+
    |  (Published listings)
    +---------------------+
    +--[Tab: Pending]-----+
    |  (Under review)     |
    +---------------------+
    +--[Tab: Drafts]------+
    |  (Unpublished)      |
    +---------------------+
    +--[Tab: Sold]--------+
    |  (Completed sales)  |
    +---------------------+
    +--[Tab: Archived]----+
    |  (Deactivated)      |
    +---------------------+
    |
    {Tap Listing}
    |
    v
[Listing Actions Menu]
    |
    +--> {Edit} --> [Edit Listing Flow]
    |
    +--> {Mark Sold} --> [Confirm Dialog]
    |                         |
    |                         v
    |                   (Update Status)
    |
    +--> {Boost/Feature} --> [Payment Flow]
    |
    +--> {Archive} --> [Confirm Dialog]
    |
    +--> {Delete} --> [Confirm Dialog]
    |
    +--> {View Stats} --> [Analytics Screen]
```

### Seller Analytics Flow (Planned - Phase 2)

```
[Seller Dashboard]
    |
    +--[Overview Stats]---+
    |  - Total Views      |
    |  - Total Likes      |
    |  - Total Messages   |
    |  - Total Listings   |
    +---------------------+
    |
    +--[Charts]-----------+
    |  - Views over time  |
    |  - Engagement rate  |
    +---------------------+
    |
    +--[Top Listings]-----+
    |  (Ranked by views)  |
    +---------------------+
    |
    {Tap Listing}
    |
    v
[Listing Analytics]
    |
    +--[Performance]------+
    |  - Views           |
    |  - Unique Views    |
    |  - Video Watch %   |
    |  - Likes           |
    |  - Saves           |
    |  - Shares          |
    |  - Messages        |
    +---------------------+
    |
    +--[Audience]---------+
    |  - City breakdown   |
    |  - Time of day      |
    +---------------------+
```

---

## Search and Filter Flow

### Search Flow

```
[Search Screen]
    |
    +--[Search Bar]-------+
    |  "Marka yoki model  |
    |   qidiring..."      |
    +---------------------+
    |
    <Initial State>
    |
    v
+--[Initial View]---------+
|                         |
|  [Suggestions]          |
|  - Chevrolet Cobalt     |
|  - Kia K5               |
|  - etc.                 |
|                         |
|  [Recent Searches]      |
|  - (History items)      |
|  - [Clear All]          |
|                         |
|  [Popular Searches]     |
|  - Trending terms       |
|                         |
+-------------------------+
    |
    {Type Query}
    |
    v
(Debounce 300ms)
    |
    v
(Fetch Suggestions)
    |
    v
[Autocomplete List]
    |
    {Tap Suggestion or Submit}
    |
    v
(Execute Search)
    |
    v
+--[Results View]---------+
|                         |
|  [Results Count + Sort] |
|  "245 ta natija"        |
|                         |
|  [Results Grid]         |
|  +---+  +---+           |
|  |   |  |   |           |
|  +---+  +---+           |
|  +---+  +---+           |
|  |   |  |   |           |
|  +---+  +---+           |
|                         |
+-------------------------+
    |
    <Scroll to Bottom>
    |
    v
(Load More Results)
```

### Filter Flow

```
[Search Screen]
    |
    {Tap Filter Icon}
    |
    v
[Filter Screen]
    |
    +--[Price Range]------+
    |  Min: [_______]     |
    |  Max: [_______]     |
    |  Currency: USD/UZS  |
    +---------------------+
    |
    +--[Brand & Model]----+
    |  Brand: [Dropdown]  |
    |  Model: [Dropdown]  |
    +---------------------+
    |
    +--[Year]-------------+
    |  Min: [____]        |
    |  Max: [____]        |
    +---------------------+
    |
    +--[Mileage]----------+
    |  Max: [________]    |
    +---------------------+
    |
    +--[Fuel Type]--------+
    |  [ ] Benzin         |
    |  [ ] Dizel          |
    |  [ ] Gaz            |
    |  [ ] Elektr         |
    |  [ ] Gibrid         |
    +---------------------+
    |
    +--[Transmission]-----+
    |  ( ) Mexanik        |
    |  ( ) Avtomat        |
    +---------------------+
    |
    +--[Body Type]--------+
    |  [ ] Sedan          |
    |  [ ] SUV            |
    |  [ ] Xetchbek       |
    |  [ ] Krossover      |
    |  [ ] etc.           |
    +---------------------+
    |
    +--[Color]------------+
    |  (Color picker)     |
    +---------------------+
    |
    +--[Location]---------+
    |  City: [Dropdown]   |
    |  District: [Drop]   |
    +---------------------+
    |
    +--[Other Filters]----+
    |  [x] Verified Only  |
    |  [x] No Accident    |
    |  [x] First Owner    |
    +---------------------+
    |
    +--[Bottom Actions]---+
    |  [Reset] [Apply]    |
    +---------------------+
    |
    {Tap "Apply"}
    |
    v
(Apply Filters)
    |
    v
[Search Screen with Filtered Results]
    |
    (Badge shows active filter count)
```

### Sort Flow

```
[Search Results]
    |
    {Tap Sort Button}
    |
    v
[Sort Bottom Sheet]
    |
    ( ) Eng yangi (Newest)
    ( ) Eng eski (Oldest)
    ( ) Arzon (Price Low)
    ( ) Qimmat (Price High)
    ( ) Mashhur (Popular)
    ( ) Kam yurgan (Low Mileage)
    |
    {Select Option}
    |
    v
(Apply Sort)
    |
    v
[Reordered Results]
```

---

## Chat Flow

### Conversation List Flow

```
[Conversations Screen]
    |
    <Has Conversations?>
    |
    +--> (No) --> [Empty State]
    |              "Xabarlar yo'q"
    |
    +--> (Yes) --> [Conversation List]
                        |
                        v
                +--[Conversation Item]--+
                |  - User Avatar        |
                |  - User Name          |
                |  - Verified Badge     |
                |  - Last Message       |
                |  - Time               |
                |  - Unread Badge       |
                |  - Listing Thumbnail  |
                +----------------------+
                        |
                    {Tap Item}
                        |
                        v
                   [Chat Screen]
```

### Chat Screen Flow

```
[Chat Screen]
    |
    +--[App Bar]----------+
    |  - Back Button      |
    |  - User Avatar      |
    |  - User Name        |
    |  - Listing Title    |
    +---------------------+
    |
    +--[Messages List]----+
    |                     |
    |  +--[Message Bubble]--+
    |  |  (Their message)   |
    |  |  - Content         |
    |  |  - Time            |
    |  +--------------------+
    |                     |
    |    +--[Message Bubble]--+
    |    |  (My message)      |
    |    |  - Content         |
    |    |  - Time            |
    |    |  - Read Status     |
    |    +--------------------+
    |                     |
    +---------------------+
    |
    +--[Input Area]-------+
    |  [Text Field]       |
    |  [Send Button]      |
    +---------------------+

    <Message Actions>
    |
    +--> {Type Text} --> (Update Input)
    |
    +--> {Tap Send} --> (Send Message)
    |                        |
    |                        v
    |                   (Add to List)
    |                        |
    |                        v
    |                   (Scroll to Bottom)
    |
    +--> {Receive Message} --> (Real-time Update)
    |                              |
    |                              v
    |                         (Add to List)
    |                              |
    |                              v
    |                         (Mark as Read)
```

### Start New Conversation Flow

```
[Listing Detail Screen]
    |
    {Tap "Xabar" (Message)}
    |
    v
<Existing Conversation?>
    |
    +--> (Yes) --> [Existing Chat Screen]
    |
    +--> (No) --> (Create Conversation)
                       |
                       v
                 [New Chat Screen]
                       |
                 (Pre-filled context)
                 "Salom! {Listing Title}
                  haqida so'ramoqchi edim."
```

---

## Notification Flow

### Notification Screen Flow

```
[Notifications Screen]
    |
    <Has Notifications?>
    |
    +--> (No) --> [Empty State]
    |              "Bildirishnomalar yo'q"
    |
    +--> (Yes) --> [Notification List]
                        |
                        v
                +--[Notification Item]--+
                |  - Icon (by type)     |
                |  - Title              |
                |  - Body               |
                |  - Time               |
                |  - Read Status        |
                +----------------------+
```

### Notification Types

```
[Notification Types]

1. NEW_MESSAGE
   Icon: chat_bubble
   Title: "Yangi xabar"
   Body: "{Sender}: {Message preview}"
   Action: Open Chat Screen

2. PRICE_DROP
   Icon: trending_down
   Title: "Narx tushdi!"
   Body: "{Listing Title} - {Old} -> {New}"
   Action: Open Listing Detail

3. NEW_LISTING
   Icon: fiber_new
   Title: "Yangi e'lon"
   Body: "{Seller} yangi e'lon joylashtirdi"
   Action: Open Listing Detail

4. LISTING_VIEWED
   Icon: visibility
   Title: "E'loningiz ko'rildi"
   Body: "{Count} kishi ko'rdi"
   Action: Open Analytics

5. SUBSCRIPTION_EXPIRING
   Icon: warning
   Title: "Obuna tugayapti"
   Body: "{Days} kun qoldi"
   Action: Open Subscription Screen

6. REVIEW_RECEIVED
   Icon: star
   Title: "Yangi baho"
   Body: "{User} sizga {Rating} baho berdi"
   Action: Open Reviews

7. PROMOTION
   Icon: local_offer
   Title: "{Promo Title}"
   Body: "{Promo Description}"
   Action: Open Promo Screen
```

### Push Notification Flow

```
[App in Background/Closed]
    |
    (Receive Push Notification)
    |
    v
[System Notification]
    |
    {User Taps Notification}
    |
    v
[App Launches]
    |
    v
(Parse Deep Link)
    |
    v
<Notification Type>
    |
    +--> message --> [Chat Screen]
    |
    +--> listing --> [Listing Detail]
    |
    +--> profile --> [Seller Profile]
    |
    +--> other --> [Notifications Screen]
```

---

## Profile Management Flow

### Profile Screen Flow

```
[Profile Screen]
    |
    +--[Header Section]---+
    |  - Avatar           |
    |  - Full Name        |
    |  - Phone            |
    |  - Role Badge       |
    |  - Edit Button      |
    +---------------------+
    |
    +--[Stats Section]----+   (Sellers only)
    |  - Total Listings   |
    |  - Active Listings  |
    |  - Total Views      |
    |  - Total Sold       |
    +---------------------+
    |
    +--[Menu Items]-------+
    |  - My Listings      |  (Sellers)
    |  - Saved            |
    |  - Notifications    |
    |  - Settings         |
    |  - Help & Support   |
    |  - About            |
    |  - Log Out          |
    +---------------------+
```

### Edit Profile Flow

```
[Profile Screen]
    |
    {Tap Edit}
    |
    v
[Edit Profile Screen]
    |
    +--[Avatar Section]---+
    |  (Tap to change)    |
    +---------------------+
    |
    +--[Form Fields]------+
    |  - Full Name        |
    |  - Email (optional) |
    +---------------------+
    |
    +--[Actions]----------+
    |  [Cancel] [Save]    |
    +---------------------+
    |
    {Tap Save}
    |
    v
<Validation>
    |
    +--> (Invalid) --> [Show Errors]
    |
    +--> (Valid) --> (Update Profile)
                          |
                          v
                    [Profile Screen]
                    (Updated data)
```

### Settings Flow

```
[Settings Screen]
    |
    +--[Language]---------+
    |  - Uzbek (O'zbek)   |
    |  - Russian (Русский)|
    |  - English          |
    +---------------------+
    |
    +--[Notifications]----+
    |  - Messages: [ON]   |
    |  - Price Drops: [ON]|
    |  - New Listings:[ON]|
    |  - Promotions: [OFF]|
    +---------------------+
    |
    +--[Appearance]-------+
    |  - Theme: Auto/Light|
    |           /Dark     |
    +---------------------+
    |
    +--[Privacy]----------+
    |  - Show Phone: [ON] |
    +---------------------+
    |
    +--[Account]----------+
    |  - Change Phone     |
    |  - Delete Account   |
    +---------------------+
```

### Logout Flow

```
[Profile Screen]
    |
    {Tap "Chiqish" (Log Out)}
    |
    v
[Confirmation Dialog]
    "Hisobingizdan chiqmoqchimisiz?"
    |
    +--[Bekor qilish]---> (Dismiss)
    |
    +--[Chiqish]--------> (Clear Token)
                               |
                               v
                         (Clear Local Data)
                               |
                               v
                         [Login Screen]
```

### Delete Account Flow

```
[Settings Screen]
    |
    {Tap "Hisobni o'chirish"}
    |
    v
[Warning Dialog]
    "Hisobingiz va barcha ma'lumotlaringiz
     o'chiriladi. Bu amalni qaytarib
     bo'lmaydi."
    |
    {Enter Phone Number to Confirm}
    |
    +--[Bekor qilish]---> (Dismiss)
    |
    +--[O'chirish]------> <Phone Matches?>
                               |
                               +--> (No) --> [Error]
                               |
                               +--> (Yes) --> (Delete Account)
                                                   |
                                                   v
                                             [Login Screen]
                                             (Account Deleted)
```

---

## Error Handling Flows

### Network Error Flow

```
[Any Screen with Network Request]
    |
    (Network Request)
    |
    v
<Response Status>
    |
    +--> (Success) --> (Process Data)
    |
    +--> (Network Error) --> [Error View]
    |                        "Internet aloqasi yo'q"
    |                        [Qayta urinish]
    |                              |
    |                              v
    |                        (Retry Request)
    |
    +--> (Server Error) --> [Error View]
    |                       "Xatolik yuz berdi"
    |                       [Qayta urinish]
    |
    +--> (Auth Error) --> (Clear Token)
                               |
                               v
                         [Login Screen]
```

### Empty State Flow

```
[List Screen]
    |
    (Load Data)
    |
    v
<Has Items?>
    |
    +--> (No) --> [Empty View]
    |              - Icon
    |              - Title
    |              - Message
    |              - Action Button (optional)
    |
    +--> (Yes) --> [List View]
```

---

## Deep Linking Flows

### Supported Deep Links

```
autogram://                     --> [Home Screen]
autogram://listing/{id}         --> [Listing Detail]
autogram://seller/{id}          --> [Seller Profile]
autogram://chat/{conversationId}--> [Chat Screen]
autogram://search?q={query}     --> [Search Results]
autogram://reels                --> [Reels Screen]
autogram://saved                --> [Saved Screen]
autogram://profile              --> [Profile Screen]
```

### Deep Link Handling

```
[App Launch via Deep Link]
    |
    (Parse URI)
    |
    v
<User Authenticated?>
    |
    +--> (No) --> [Login Screen]
    |                  |
    |             (After Login)
    |                  |
    |                  v
    |            (Navigate to Link)
    |
    +--> (Yes) --> (Navigate to Link)
                        |
                        v
                  [Target Screen]
```

---

*Document maintained by AUTOGRAM Product Team*
