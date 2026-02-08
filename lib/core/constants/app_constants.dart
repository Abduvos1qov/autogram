/// App-wide constants

class AppConstants {
  AppConstants._();

  // Supported languages
  static const String uzbek = 'uz';
  static const String russian = 'ru';
  static const String english = 'en';

  static const List<String> supportedLanguages = [uzbek, russian, english];

  // User roles
  static const String buyerRole = 'buyer';
  static const String sellerRole = 'seller';

  // Business types
  static const String individualType = 'individual';
  static const String dealerType = 'dealer';
  static const String salonType = 'salon';

  // Subscription types
  static const String freePlan = 'free';
  static const String basicPlan = 'basic';
  static const String proPlan = 'pro';
  static const String enterprisePlan = 'enterprise';

  // Listing statuses
  static const String draftStatus = 'draft';
  static const String pendingStatus = 'pending';
  static const String activeStatus = 'active';
  static const String soldStatus = 'sold';
  static const String archivedStatus = 'archived';

  // Payment providers
  static const String clickProvider = 'click';
  static const String paymeProvider = 'payme';
  static const String uzumProvider = 'uzum';

  // Fuel types
  static const List<String> fuelTypes = [
    'petrol',
    'diesel',
    'gas',
    'electric',
    'hybrid',
  ];

  // Transmission types
  static const List<String> transmissionTypes = ['manual', 'automatic'];

  // Drive types
  static const List<String> driveTypes = ['front', 'rear', 'all'];

  // Body types
  static const List<String> bodyTypes = [
    'sedan',
    'suv',
    'hatchback',
    'crossover',
    'minivan',
    'coupe',
    'wagon',
    'pickup',
    'convertible',
  ];

  // Condition types
  static const List<String> conditionTypes = [
    'new',
    'excellent',
    'good',
    'fair',
  ];

  // Cities in Uzbekistan
  static const List<String> cities = [
    'Toshkent',
    'Samarqand',
    'Buxoro',
    'Namangan',
    'Andijon',
    'Farg\'ona',
    'Qo\'qon',
    'Nukus',
    'Qarshi',
    'Jizzax',
    'Urganch',
    'Navoiy',
    'Termiz',
    'Guliston',
    'Chirchiq',
    'Olmaliq',
    'Angren',
    'Margilan',
  ];

  // Currency
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = ['USD', 'UZS'];

  // Mileage ranges (in km)
  static const List<String> mileageRanges = [
    '0-10000',
    '10000-50000',
    '50000-100000',
    '100000-200000',
    '200000+',
  ];

  // Phone regex for Uzbekistan
  static const String uzbekPhoneRegex = r'^\+998[0-9]{9}$';
  static const String uzbekPhonePrefix = '+998';
}
