import '../constants/app_constants.dart';

/// Form validation utilities

class Validators {
  Validators._();

  // Phone validation (optional)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final phone = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (!RegExp(AppConstants.uzbekPhoneRegex).hasMatch(phone)) {
      return 'Noto\'g\'ri telefon raqami formati';
    }

    return null;
  }

  // OTP validation
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Tasdiqlash kodini kiriting';
    }

    if (value.length != length) {
      return 'Kod $length ta raqamdan iborat bo\'lishi kerak';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Faqat raqamlar kiritilishi kerak';
    }

    return null;
  }

  // Email validation (optional)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Noto\'g\'ri email formati';
    }

    return null;
  }

  // Email validation (required - for login)
  static String? validateEmailRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email manzilingizni kiriting';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Noto\'g\'ri email formati';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName kiritilishi shart'
          : 'Bu maydon to\'ldirilishi shart';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ismingizni kiriting';
    }

    if (value.trim().length < 2) {
      return 'Ism kamida 2 ta harfdan iborat bo\'lishi kerak';
    }

    if (value.trim().length > 100) {
      return 'Ism 100 ta harfdan oshmasligi kerak';
    }

    return null;
  }

  // Business name validation
  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Biznes nomini kiriting';
    }

    if (value.trim().length < 3) {
      return 'Nom kamida 3 ta harfdan iborat bo\'lishi kerak';
    }

    if (value.trim().length > 200) {
      return 'Nom 200 ta harfdan oshmasligi kerak';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Narxni kiriting';
    }

    final price = double.tryParse(value.replaceAll(',', ''));
    if (price == null) {
      return 'Noto\'g\'ri narx formati';
    }

    if (price <= 0) {
      return 'Narx 0 dan katta bo\'lishi kerak';
    }

    if (price > 10000000) {
      return 'Narx juda katta';
    }

    return null;
  }

  // Year validation
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yilni kiriting';
    }

    final year = int.tryParse(value);
    if (year == null) {
      return 'Noto\'g\'ri yil formati';
    }

    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Yil 1900 va ${currentYear + 1} orasida bo\'lishi kerak';
    }

    return null;
  }

  // Mileage validation
  static String? validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yurgan masofani kiriting';
    }

    final mileage = int.tryParse(value.replaceAll(',', ''));
    if (mileage == null) {
      return 'Noto\'g\'ri format';
    }

    if (mileage < 0) {
      return 'Masofa manfiy bo\'lishi mumkin emas';
    }

    if (mileage > 1000000) {
      return 'Masofa juda katta';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Description is optional
    }

    if (value.trim().length < 10) {
      return 'Tavsif kamida 10 ta belgidan iborat bo\'lishi kerak';
    }

    if (value.trim().length > 2000) {
      return 'Tavsif 2000 ta belgidan oshmasligi kerak';
    }

    return null;
  }

  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sarlavhani kiriting';
    }

    if (value.trim().length < 5) {
      return 'Sarlavha kamida 5 ta belgidan iborat bo\'lishi kerak';
    }

    if (value.trim().length > 200) {
      return 'Sarlavha 200 ta belgidan oshmasligi kerak';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Noto\'g\'ri URL formati';
    }

    return null;
  }

  // Password validation (strong)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parolni kiriting';
    }

    if (value.length < 8) {
      return 'Parol kamida 8 ta belgidan iborat bo\'lishi kerak';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Parolda kamida 1 ta katta harf bo\'lishi kerak';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Parolda kamida 1 ta kichik harf bo\'lishi kerak';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Parolda kamida 1 ta raqam bo\'lishi kerak';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Parolda kamida 1 ta maxsus belgi bo\'lishi kerak';
    }

    return null;
  }

  // Confirm password validation
  static String? Function(String?) validateConfirmPassword(
      String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Parolni tasdiqlang';
      }

      if (value != originalPassword) {
        return 'Parollar mos kelmaydi';
      }

      return null;
    };
  }

  // Username validation (required)
  static String? validateUsernameRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username kiriting';
    }

    final username = value.startsWith('@') ? value.substring(1) : value;

    if (username.length < 3) {
      return 'Username kamida 3 ta belgidan iborat bo\'lishi kerak';
    }

    if (username.length > 32) {
      return 'Username 32 ta belgidan oshmasligi kerak';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Faqat harflar, raqamlar va pastki chiziq';
    }

    return null;
  }

  // Username (Telegram/Instagram) validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    final username = value.startsWith('@') ? value.substring(1) : value;

    if (username.length < 3) {
      return 'Username kamida 3 ta belgidan iborat bo\'lishi kerak';
    }

    if (username.length > 32) {
      return 'Username 32 ta belgidan oshmasligi kerak';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Faqat harflar, raqamlar va pastki chiziq';
    }

    return null;
  }
}
