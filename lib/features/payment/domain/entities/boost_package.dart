import 'package:equatable/equatable.dart';

/// Boost package — a paid promotion product (boost / TOP / VIP / mega).
class BoostPackage extends Equatable {
  final String id;
  final String name;
  final String description;
  final int priceUzs;
  final int durationDays;

  /// One of: `'boost' | 'top' | 'vip' | 'mega'`.
  final String tier;

  const BoostPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.priceUzs,
    required this.durationDays,
    required this.tier,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        priceUzs,
        durationDays,
        tier,
      ];
}
