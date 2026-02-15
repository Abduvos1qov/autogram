/// API endpoints for Supabase and external services

class ApiEndpoints {
  ApiEndpoints._();

  // Supabase Tables
  static const String profiles = 'profiles';
  static const String sellerProfiles = 'seller_profiles';
  static const String sellerMembers = 'seller_members';
  static const String categories = 'categories';
  static const String listings = 'listings';
  static const String listingAutoDetails = 'listing_auto_details';
  static const String likes = 'likes';
  static const String saves = 'saves';
  static const String views = 'views';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String reviews = 'reviews';
  static const String notifications = 'notifications';
  static const String subscriptionPlans = 'subscription_plans';
  static const String payments = 'payments';
  static const String boosts = 'boosts';

  // Supabase Edge Functions
  static const String sendOtp = 'send-otp';
  static const String verifyOtp = 'verify-otp';
  static const String processVideo = 'process-video';
  static const String sendNotification = 'send-notification';
  static const String paymentWebhook = 'payment-webhook';

  // Supabase Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String logosBucket = 'logos';
  static const String coversBucket = 'covers';
  static const String listingsBucket = 'listings';
  static const String videosBucket = 'videos';
  static const String thumbnailsBucket = 'thumbnails';
  static const String documentsBucket = 'documents';

  // Cloudflare Stream
  static String cloudflareStreamUrl(String accountId) =>
      'https://api.cloudflare.com/client/v4/accounts/$accountId/stream';

  static String cloudflareVideoUrl(String customerCode, String videoId) =>
      'https://customer-$customerCode.cloudflarestream.com/$videoId/manifest/video.m3u8';

  static String cloudflareThumbnailUrl(String customerCode, String videoId) =>
      'https://customer-$customerCode.cloudflarestream.com/$videoId/thumbnails/thumbnail.jpg';

  // Payment Providers
  static const String clickPrepareUrl = 'https://my.click.uz/services/pay';
  static const String paymeTestUrl = 'https://checkout.test.paycom.uz';
  static const String paymeProdUrl = 'https://checkout.paycom.uz';
  static const String uzumApiUrl = 'https://api.uzum.uz/payment';
}
