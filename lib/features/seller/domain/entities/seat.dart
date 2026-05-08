import 'package:equatable/equatable.dart';

/// Team seat occupied within a seller subscription.
///
/// A seat is a slot that can be occupied by a team member. Free plans get
/// one (owner-only) seat; paid plans bundle additional seats with the
/// subscription, and more can be purchased on top via [SellerProfile.additionalSeats].
class Seat extends Equatable {
  final String id;
  final String sellerProfileId;

  /// User assigned to this seat. `null` means the seat is unassigned/vacant.
  final String? userId;
  final bool isActive;
  final DateTime createdAt;

  /// Set when the seat was bought as a paid add-on tied to the billing cycle.
  /// `null` for seats included with the base plan.
  final DateTime? expiresAt;

  const Seat({
    required this.id,
    required this.sellerProfileId,
    this.userId,
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
  });

  Seat copyWith({
    String? id,
    String? sellerProfileId,
    String? userId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Seat(
      id: id ?? this.id,
      sellerProfileId: sellerProfileId ?? this.sellerProfileId,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerProfileId,
        userId,
        isActive,
        createdAt,
        expiresAt,
      ];
}
