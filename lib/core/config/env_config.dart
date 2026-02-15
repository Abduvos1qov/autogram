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
          'https://kgopjdapitfggskllcal.supabase.co',
          defaultValue: 'https://kgopjdapitfggskllcal.supabase.co',
        );
      case Environment.staging:
        return const String.fromEnvironment('https://kgopjdapitfggskllcal.supabase.co');
      case Environment.production:
        return const String.fromEnvironment('https://kgopjdapitfggskllcal.supabase.co');
    }
  }

  static String get supabaseAnonKey {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtnb3BqZGFwaXRmZ2dza2xsY2FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMjQyMjQsImV4cCI6MjA4NjYwMDIyNH0.vso8IxialhJc4p3LOh5U9f_r12wbAzpsu51B_jxfd2M',
          defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtnb3BqZGFwaXRmZ2dza2xsY2FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMjQyMjQsImV4cCI6MjA4NjYwMDIyNH0.vso8IxialhJc4p3LOh5U9f_r12wbAzpsu51B_jxfd2M',
        );
      case Environment.staging:
        return const String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtnb3BqZGFwaXRmZ2dza2xsY2FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMjQyMjQsImV4cCI6MjA4NjYwMDIyNH0.vso8IxialhJc4p3LOh5U9f_r12wbAzpsu51B_jxfd2M');
      case Environment.production:
        return const String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtnb3BqZGFwaXRmZ2dza2xsY2FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMjQyMjQsImV4cCI6MjA4NjYwMDIyNH0.vso8IxialhJc4p3LOh5U9f_r12wbAzpsu51B_jxfd2M');
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
