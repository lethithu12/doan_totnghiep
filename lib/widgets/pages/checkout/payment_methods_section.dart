import 'package:flutter/material.dart';
import '../../../../models/payment_method.dart';

class PaymentMethodsSection extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodsSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
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
          const SizedBox(height: 24),
          // MoMo
          _PaymentMethodOption(
            method: PaymentMethod.momo,
            selectedMethod: selectedMethod,
            onSelected: onMethodSelected,
            iconColor: Colors.red,
          ),
          const SizedBox(height: 16),
          // COD
          _PaymentMethodOption(
            method: PaymentMethod.cod,
            selectedMethod: selectedMethod,
            onSelected: onMethodSelected,
            iconColor: Colors.grey[700]!,
          ),
          const SizedBox(height: 16),
          // Bank Transfer
          _PaymentMethodOption(
            method: PaymentMethod.bank,
            selectedMethod: selectedMethod,
            onSelected: onMethodSelected,
            iconColor: Colors.grey[700]!,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final PaymentMethod method;
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod) onSelected;
  final Color iconColor;

  const _PaymentMethodOption({
    required this.method,
    required this.selectedMethod,
    required this.onSelected,
    required this.iconColor,
  });

  IconData _getIcon() {
    switch (method) {
      case PaymentMethod.momo:
        return Icons.credit_card;
      case PaymentMethod.cod:
        return Icons.local_shipping;
      case PaymentMethod.bank:
        return Icons.account_balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: () => onSelected(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<PaymentMethod>(
              value: method,
              groupValue: selectedMethod,
              onChanged: (val) => onSelected(val!),
              activeColor: Colors.red,
            ),
            const SizedBox(width: 12),
            Icon(
              _getIcon(),
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

