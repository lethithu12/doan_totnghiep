import 'package:flutter/material.dart';
import '../../../../models/payment_method.dart';

class PaymentMethodDisplay extends StatelessWidget {
  final PaymentMethod paymentMethod;

  const PaymentMethodDisplay({
    super.key,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phương thức thanh toán',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(),
                color: _getPaymentMethodIconColor(),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentMethod.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon() {
    switch (paymentMethod) {
      case PaymentMethod.momo:
        return Icons.credit_card;
      case PaymentMethod.cod:
        return Icons.local_shipping;
      case PaymentMethod.bank:
        return Icons.account_balance;
    }
  }

  Color _getPaymentMethodIconColor() {
    switch (paymentMethod) {
      case PaymentMethod.momo:
        return Colors.red;
      case PaymentMethod.cod:
      case PaymentMethod.bank:
        return Colors.grey[700]!;
    }
  }
}

