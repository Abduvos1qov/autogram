/// Environment configuration for the app
/// Handles different environments (dev, staging, prod)

enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  // Supabase Configuration
  static String get supabaseUrl {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://your-project.supabase.co',
        );
      case Environment.staging:
        return const String.fromEnvironment('SUPABASE_STAGING_URL');
      case Environment.production:
        return const String.fromEnvironment('SUPABASE_PROD_URL');
    }
  }

  static String get supabaseAnonKey {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'your-anon-key',
        );
      case Environment.staging:
        return const String.fromEnvironment('SUPABASE_STAGING_ANON_KEY');
      case Environment.production:
        return const String.fromEnvironment('SUPABASE_PROD_ANON_KEY');
    }
  }

  // Cloudflare Stream Configuration
  static String get cloudflareAccountId {
    return const String.fromEnvironment(
      'CLOUDFLARE_ACCOUNT_ID',
      defaultValue: '',
    );
  }

  static String get cloudflareApiToken {
    return const String.fromEnvironment(
      'CLOUDFLARE_API_TOKEN',
      defaultValue: '',
    );
  }

  static String get cloudflareCustomerCode {
    return const String.fromEnvironment(
      'CLOUDFLARE_CUSTOMER_CODE',
      defaultValue: '',
    );
  }

  // App Configuration
  static String get appName => 'Autogram';

  static String get appVersion => '1.0.0';

  static bool get enableLogging => !isProduction;

  static bool get enableCrashlytics => isProduction;
}
