/// Payable product types in Autogram.
enum PaymentProduct {
  subscription,
  additionalSeat,
  boost;

  String get value {
    switch (this) {
      case PaymentProduct.subscription:
        return 'subscription';
      case PaymentProduct.additionalSeat:
        return 'additional_seat';
      case PaymentProduct.boost:
        return 'boost';
    }
  }

  String get label {
    switch (this) {
      case PaymentProduct.subscription:
        return 'Obuna';
      case PaymentProduct.additionalSeat:
        return 'Qo\'shimcha seat';
      case PaymentProduct.boost:
        return 'Ko\'tarish';
    }
  }

  static PaymentProduct fromString(String value) {
    switch (value.toLowerCase()) {
      case 'additional_seat':
      case 'seat':
        return PaymentProduct.additionalSeat;
      case 'boost':
        return PaymentProduct.boost;
      case 'subscription':
      default:
        return PaymentProduct.subscription;
    }
  }
}
