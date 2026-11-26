/// Reps paid toward a debt on one calendar day.
class DebtPayment {
  const DebtPayment({required this.date, required this.amount});

  final DateTime date;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is DebtPayment && other.date == date && other.amount == amount;

  @override
  int get hashCode => Object.hash(date, amount);
}

/// The shortfall left by one missed day.
class Debt {
  Debt({
    required this.originDate,
    required this.amount,
    required this.dueBy,
    required this.isCarried,
    required List<DebtPayment> payments,
  }) : payments = List.unmodifiable(payments);

  final DateTime originDate;
  final int amount;
  final DateTime dueBy;

  /// Whether the debt missed its deadline. This stays true after late payment.
  final bool isCarried;

  final List<DebtPayment> payments;

  int get paidAmount =>
      payments.fold(0, (total, payment) => total + payment.amount);

  int get remaining => amount - paidAmount;

  bool get isPaid => remaining == 0;

  @override
  bool operator ==(Object other) {
    if (other is! Debt ||
        other.originDate != originDate ||
        other.amount != amount ||
        other.dueBy != dueBy ||
        other.isCarried != isCarried ||
        other.payments.length != payments.length) {
      return false;
    }
    for (var i = 0; i < payments.length; i++) {
      if (other.payments[i] != payments[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    originDate,
    amount,
    dueBy,
    isCarried,
    Object.hashAll(payments),
  );
}
