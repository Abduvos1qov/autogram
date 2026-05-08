/// Payment lifecycle status.
///
/// Persisted as snake_case strings via [value]; parsed defensively via
/// [fromString] so unknown server values fall back to [PaymentStatus.pending].
enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled,
  refunded;

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.success:
        return 'success';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.cancelled:
        return 'cancelled';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Kutilmoqda';
      case PaymentStatus.processing:
        return 'Jarayonda';
      case PaymentStatus.success:
        return 'Muvaffaqiyatli';
      case PaymentStatus.failed:
        return 'Xatolik';
      case PaymentStatus.cancelled:
        return 'Bekor qilingan';
      case PaymentStatus.refunded:
        return 'Qaytarilgan';
    }
  }

  bool get isTerminal {
    switch (this) {
      case PaymentStatus.success:
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
      case PaymentStatus.refunded:
        return true;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return false;
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return PaymentStatus.processing;
      case 'success':
      case 'succeeded':
      case 'completed':
        return PaymentStatus.success;
      case 'failed':
      case 'failure':
      case 'error':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}
