/// Supported payment gateways for Uzbekistan market.
enum PaymentGateway {
  click,
  payme,
  octobank;

  String get value {
    switch (this) {
      case PaymentGateway.click:
        return 'click';
      case PaymentGateway.payme:
        return 'payme';
      case PaymentGateway.octobank:
        return 'octobank';
    }
  }

  String get label {
    switch (this) {
      case PaymentGateway.click:
        return 'Click';
      case PaymentGateway.payme:
        return 'Payme';
      case PaymentGateway.octobank:
        return 'Octobank';
    }
  }

  static PaymentGateway fromString(String value) {
    switch (value.toLowerCase()) {
      case 'payme':
        return PaymentGateway.payme;
      case 'octobank':
      case 'octo':
        return PaymentGateway.octobank;
      case 'click':
      default:
        return PaymentGateway.click;
    }
  }
}
