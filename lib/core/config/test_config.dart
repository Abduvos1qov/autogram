/// Test configuration for the app
/// Toggle test mode via the `TEST_MODE` dart-define.
///
/// Default is `true` (mock backend). For production builds with real Supabase:
///   flutter build apk --dart-define=TEST_MODE=false
library;

class TestConfig {
  /// Enable test mode to bypass real auth and use mock data.
  ///
  /// Defaults to `true` while the Supabase backend is still being wired up.
  /// Production builds opt out explicitly via `--dart-define=TEST_MODE=false`.
  static const bool isTestMode = bool.fromEnvironment(
    'TEST_MODE',
    defaultValue: true,
  );

  /// Canonical test accounts. Sign-in routes the email through
  /// `MockData.activateTestAccount`, which seeds the right `UserProfile` +
  /// (for sellers) `SellerProfile` so the rest of the app sees a coherent
  /// user state.
  ///
  /// Buyer accounts: `buyer@autogram.uz`, `test@autogram.uz`,
  /// `sardor@example.com`.
  ///
  /// Seller accounts (Instagram-style storefront, AutoStar Salon Pro tier):
  /// `seller@autogram.uz`, `aziza@example.com`, `jasur@example.com`.
  ///
  /// Password for every test account is the same — `Test1234!`.
  static const Map<String, String> testCredentials = {
    // Primary accounts — designed to make the buyer/seller split obvious.
    'buyer@autogram.uz': 'Test1234!',
    'seller@autogram.uz': 'Test1234!',
    // Legacy aliases (kept so existing screenshots / docs still log in).
    'test@autogram.uz': 'Test1234!',
    'sardor@example.com': 'Test1234!',
    'aziza@example.com': 'Test1234!',
    'jasur@example.com': 'Test1234!',
  };

  /// Emails treated as sellers in test mode. Keep in sync with
  /// `MockData.activateTestAccount`.
  static const Set<String> sellerTestEmails = {
    'seller@autogram.uz',
    'aziza@example.com',
    'jasur@example.com',
  };

  /// Test emails that bypass OTP verification (legacy — every test email
  /// uses code `123456`).
  static const Map<String, String> testEmails = {
    'buyer@autogram.uz': '123456',
    'seller@autogram.uz': '123456',
    'test@autogram.uz': '123456',
    'sardor@example.com': '123456',
    'aziza@example.com': '123456',
    'jasur@example.com': '123456',
  };

  /// `true` when the email maps to a seller-type test account.
  static bool isSellerTestEmail(String email) =>
      sellerTestEmails.contains(email.toLowerCase());

  /// Test phone numbers (legacy, kept for reference)
  static const Map<String, String> testPhones = {
    '+998901234567': '1234',
    '+998909876543': '1234',
    '+998971234567': '1234',
    '+998881234567': '1234',
    '+998891234567': '1234',
  };

  /// Check if an email is a test email
  static bool isTestEmail(String email) {
    return testCredentials.containsKey(email);
  }

  /// Get the password for a test email
  static String? getTestPassword(String email) {
    return testCredentials[email];
  }

  /// Get the OTP code for a test email (legacy)
  static String? getTestOTP(String email) {
    return testEmails[email];
  }

  /// Check if a phone number is a test phone
  static bool isTestPhone(String phone) {
    return testPhones.containsKey(phone);
  }

  /// Get all test emails as a list
  static List<String> get testEmailList => testCredentials.keys.toList();

  /// Get all test phone numbers as a list
  static List<String> get testPhoneList => testPhones.keys.toList();
}
