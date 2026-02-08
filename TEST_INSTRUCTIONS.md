# AUTOGRAM - Test Mode Instructions

This document provides instructions for testing the AUTOGRAM app using mock data without requiring a backend connection.

## Overview

The app has been configured with a **Test Mode** that allows you to:
- Login with predefined test phone numbers
- Use mock OTP codes (no real SMS required)
- Browse static listing data
- Test all app features without a live backend

## Enabling/Disabling Test Mode

Test mode is controlled by the `TestConfig.isTestMode` constant in `/lib/core/config/test_config.dart`.

### To Enable Test Mode (Default)
```dart
static const bool isTestMode = true;
```

### To Disable Test Mode (Production)
```dart
static const bool isTestMode = false;
```

## Test Phone Numbers and OTP Codes

When test mode is enabled, you can use any of the following phone numbers to login:

| Phone Number    | OTP Code | User           |
|----------------|----------|----------------|
| +998901234567  | 1234     | Sardor Aliyev  |
| +998909876543  | 1234     | Aziza Karimova |
| +998971234567  | 1234     | Jasur Toshmatov|
| +998881234567  | 1234     | Test User 4    |
| +998891234567  | 1234     | Test User 5    |

**Note:** The OTP code for all test phone numbers is `1234`.

## Login Process

1. Launch the app
2. On the login screen, you'll see a yellow "Test rejimi" (Test Mode) banner showing:
   - Test phone number
   - OTP code (1234)
3. Enter any test phone number from the table above
4. Click "Davom etish" (Continue)
5. Enter the OTP code: `1234`
6. You'll be logged in successfully

## Available Mock Data

### Users (3 users)
- Sardor Aliyev (Buyer)
- Aziza Karimova (Seller - AutoStar Salon)
- Jasur Toshmatov (Seller - AvtoPlus Motors)

### Sellers (3 dealers)
- **AutoStar Salon** - Toshkent, Sergeli (4.8 rating, 156 reviews)
- **AvtoPlus Motors** - Toshkent, Chilonzor (4.6 rating, 98 reviews)
- **Premium Auto** - Toshkent, Yunusobod (4.9 rating, 45 reviews)

### Listings (7 cars)
1. **Chevrolet Gentra 2022** - $15,000 (Featured)
2. **Chevrolet Malibu 2 2023** - $32,000
3. **Chevrolet Tracker 2024** - $28,500 (Featured)
4. **Chevrolet Cobalt 2021** - $12,000
5. **Kia K5 2022** - $35,000 (Featured)
6. **Kia Sportage 2023** - $42,000
7. **Chevrolet Lacetti 2020** - $9,500

All listings include:
- Detailed auto specifications
- Placeholder images (via picsum.photos)
- Mock video URLs (Cloudflare Stream sample)
- View/like/save counts
- Seller information

### Reels
All listings with video URLs are available as reels (same 7 items).

### Conversations (3 chats)
- Chat about Chevrolet Gentra 2022
- Chat about Chevrolet Tracker 2024
- Chat about Kia K5 2022

Each conversation includes 2-4 mock messages.

## Testing Features

### Home Feed
- Opens automatically after login
- Shows all 7 mock listings
- Scroll to load more (pagination simulated)
- Like/save buttons work (state persists in session)

### Reels
- Navigate to Reels tab
- Swipe vertically through video listings
- All 7 listings with videos are available
- Like/save/share interactions work

### Search
- Use the search bar to filter listings
- Filter by:
  - Brand (Chevrolet, Kia)
  - Model (Gentra, Malibu, Tracker, etc.)
  - Year range
  - Price range
  - City (Toshkent)

### Listing Details
- Tap any listing to view details
- See full specifications
- View image gallery
- See seller information
- Contact seller (opens chat)

### Chat
- Navigate to Chat tab
- View 3 mock conversations
- Open any chat to see messages
- Send messages (mock - won't persist)

### Saved
- Navigate to Saved tab
- View your saved listings
- Remove from saved

### Profile
- View current user profile
- Edit profile information (mock)

## Mock Data Behavior

### Network Simulation
All mock data calls include a 500ms delay to simulate network latency, making the app feel more realistic during testing.

### State Persistence
- Like/save states persist during the session
- Data resets when you restart the app
- No data is saved to a database

### Actions That Work
- Login with test phone
- Browse feed and reels
- Search and filter listings
- View listing details
- Like/save listings
- View conversations and messages
- View seller profiles

### Actions That Don't Work (Mock Only)
- Sending messages (displayed but not saved)
- Creating new listings
- Uploading photos/videos
- Receiving push notifications
- Real-time updates

## Placeholder Images

The app uses the following services for placeholder content:

### Car Images
- Source: `https://picsum.photos/400/600?random={id}`
- Each listing has 2-4 random placeholder images

### Avatar Images
- Source: `https://ui-avatars.com/api/?name={name}&size=200`
- Generated based on user/seller names

### Video Thumbnails
- Same as car images
- Actual video playback uses Cloudflare Stream sample URL

## Switching to Production Mode

When you're ready to test with the real backend:

1. Open `/lib/core/config/test_config.dart`
2. Change `isTestMode` to `false`:
   ```dart
   static const bool isTestMode = false;
   ```
3. Restart the app
4. The test mode banner will disappear
5. All API calls will go to the real Supabase backend

## Troubleshooting

### Login Not Working
- Ensure you're using a test phone number from the list above
- OTP must be exactly `1234`
- Check that test mode is enabled in `test_config.dart`

### No Data Showing
- Verify test mode is enabled
- Check console logs for "TEST MODE:" messages
- Restart the app

### Images Not Loading
- Placeholder images require internet connection
- picsum.photos and ui-avatars.com must be accessible
- Check your network connection

## Developer Notes

### Adding More Mock Data

To add more test data:

1. Open `/lib/core/data/mock_data.dart`
2. Add items to the appropriate list:
   - `mockUsers` - Add users
   - `mockSellers` - Add sellers
   - `mockListings` - Add car listings
   - `mockConversations` - Add chats
   - `mockMessages` - Add messages

### Modifying Test Phone Numbers

To add/remove test phone numbers:

1. Open `/lib/core/config/test_config.dart`
2. Modify the `testPhones` map:
   ```dart
   static const Map<String, String> testPhones = {
     '+998901234567': '1234',
     // Add more here...
   };
   ```

### Testing Specific Features

Each feature's remote datasource checks for test mode:
- `/lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `/lib/features/home/data/datasources/home_remote_datasource.dart`
- `/lib/features/reels/data/datasources/reels_remote_datasource.dart`
- `/lib/features/chat/data/datasources/chat_remote_datasource.dart`
- `/lib/features/listing/data/datasources/listing_remote_datasource.dart`
- `/lib/features/search/data/datasources/search_remote_datasource.dart`

## Support

For questions or issues with test mode:
1. Check console logs for "TEST MODE:" debug messages
2. Verify test configuration in `test_config.dart`
3. Review mock data in `mock_data.dart`
4. Ensure all imports are correct after code changes

---

**Happy Testing!** 🚗
