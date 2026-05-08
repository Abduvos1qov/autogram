/// Billing cycle for subscription payments.
enum BillingCycle {
  monthly,
  yearly;

  String get value => name;

  String get label {
    switch (this) {
      case BillingCycle.monthly:
        return 'Oylik';
      case BillingCycle.yearly:
        return 'Yillik';
    }
  }

  static BillingCycle fromString(String value) {
    return value.toLowerCase() == 'yearly'
        ? BillingCycle.yearly
        : BillingCycle.monthly;
  }
}
