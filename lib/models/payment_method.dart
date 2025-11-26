enum PaymentMethod {
  momo('momo', 'Thanh toán bằng MoMo', 'Chuyển tiền qua MoMo'),
  cod('cod', 'Thanh toán khi nhận hàng', 'Thanh toán tiền mặt khi nhận hàng'),
  bank('bank', 'Chuyển khoản ngân hàng', 'Chuyển khoản qua ngân hàng');

  final String value;
  final String name;
  final String description;

  const PaymentMethod(this.value, this.name, this.description);

  static PaymentMethod? fromString(String? value) {
    if (value == null) return null;
    try {
      return PaymentMethod.values.firstWhere(
        (method) => method.value == value,
      );
    } catch (e) {
      return null;
    }
  }
}

