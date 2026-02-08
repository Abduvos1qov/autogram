import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// General helper utilities

class Helpers {
  Helpers._();

  static const _uuid = Uuid();

  // Generate unique ID
  static String generateId() {
    return _uuid.v4();
  }

  // Launch URL
  static Future<bool> launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(url);
    }
    return false;
  }

  // Launch phone call
  static Future<bool> launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(phone);
    }
    return false;
  }

  // Launch SMS
  static Future<bool> launchSms(String phone, {String? body}) async {
    final uri = Uri.parse('sms:$phone${body != null ? '?body=$body' : ''}');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(phone);
    }
    return false;
  }

  // Launch email
  static Future<bool> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(email);
    }
    return false;
  }

  // Launch Telegram
  static Future<bool> launchTelegram(String username) async {
    final cleanUsername =
        username.startsWith('@') ? username.substring(1) : username;
    final url = 'https://t.me/$cleanUsername';
    return launchUrl(url);
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(
    String text, {
    VoidCallback? onCopied,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    onCopied?.call();
  }

  // Get file extension
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  // Check if file is video
  static bool isVideoFile(String path) {
    final ext = getFileExtension(path);
    return ['mp4', 'mov', 'webm', 'avi', 'mkv'].contains(ext);
  }

  // Check if file is image
  static bool isImageFile(String path) {
    final ext = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext);
  }

  // Get file size
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Debounce helper
  static Function(VoidCallback) debounce({
    Duration duration = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return (VoidCallback callback) {
      timer?.cancel();
      timer = Timer(duration, callback);
    };
  }

  // Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Get platform
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  // Delay helper
  static Future<void> delay([Duration duration = const Duration(seconds: 1)]) {
    return Future.delayed(duration);
  }

  // Retry helper
  static Future<T> retry<T>({
    required Future<T> Function() action,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await action();
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
  }

  // Parse boolean from various types
  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  // Safe parse int
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Safe parse double
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

// Timer extension for debounce
class Timer {
  final Duration duration;
  final VoidCallback callback;
  bool _isCancelled = false;

  Timer(this.duration, this.callback) {
    Future.delayed(duration).then((_) {
      if (!_isCancelled) {
        callback();
      }
    });
  }

  void cancel() {
    _isCancelled = true;
  }
}
