import 'package:equatable/equatable.dart';

/// Label for a contact phone — picks an icon + localized chip on the storefront
/// and lets the seller categorize multiple numbers (sales line vs. office vs.
/// WhatsApp, etc.).
///
/// `other` is a free-form fallback that pairs with [ContactPhone.customLabel]
/// when none of the canned options fit.
enum ContactPhoneLabel {
  sales,
  office,
  support,
  whatsapp,
  telegram,
  mobile,
  other;

  /// Translation key for the localized label.
  /// Use as `label.labelKey.tr()` in UI code.
  String get labelKey => 'profile.edit_screen.contact_label_$name';

  /// Defensive parser. Falls back to [other] for unknown / legacy values so a
  /// stale row in the DB never crashes the model.
  static ContactPhoneLabel fromString(String? value) {
    if (value == null) return ContactPhoneLabel.other;
    for (final label in ContactPhoneLabel.values) {
      if (label.name == value.toLowerCase()) return label;
    }
    return ContactPhoneLabel.other;
  }
}

/// One contact-phone row on a seller storefront.
///
/// Schema target: `jsonb` array of `{phone, label, custom_label?}`. The
/// frontend tolerates the legacy `text[]` shape (plain strings) by falling
/// back to [ContactPhoneLabel.other] in [fromMap] / [fromAny].
class ContactPhone extends Equatable {
  final String phone;
  final ContactPhoneLabel label;

  /// Free-form label, only meaningful when [label] is [ContactPhoneLabel.other].
  /// `null` for any of the canned labels.
  final String? customLabel;

  const ContactPhone({
    required this.phone,
    this.label = ContactPhoneLabel.mobile,
    this.customLabel,
  });

  ContactPhone copyWith({
    String? phone,
    ContactPhoneLabel? label,
    String? customLabel,
    bool clearCustomLabel = false,
  }) {
    return ContactPhone(
      phone: phone ?? this.phone,
      label: label ?? this.label,
      customLabel: clearCustomLabel ? null : (customLabel ?? this.customLabel),
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': phone,
        'label': label.name,
        if (label == ContactPhoneLabel.other && customLabel != null)
          'custom_label': customLabel,
      };

  factory ContactPhone.fromMap(Map<String, dynamic> map) {
    final phone = (map['phone'] ?? '').toString();
    final label = ContactPhoneLabel.fromString(map['label'] as String?);
    final custom = map['custom_label'] as String?;
    return ContactPhone(
      phone: phone,
      label: label,
      customLabel: label == ContactPhoneLabel.other ? custom : null,
    );
  }

  /// Polymorphic decoder for backward compatibility — accepts either the new
  /// JSONB-object shape or a legacy plain-string element from the old
  /// `contact_phones text[]` column.
  static ContactPhone? fromAny(Object? raw) {
    if (raw is String) {
      if (raw.isEmpty) return null;
      return ContactPhone(phone: raw, label: ContactPhoneLabel.other);
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final phone = (map['phone'] ?? '').toString();
      if (phone.isEmpty) return null;
      return ContactPhone.fromMap(map);
    }
    return null;
  }

  @override
  List<Object?> get props => [phone, label, customLabel];
}
