import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../models/payment_method.dart';
import 'payment_methods_section.dart';
import 'recipient_info_section.dart';

class PaymentStep extends StatefulWidget {
  final VoidCallback onBack;
  final Function(PaymentMethod paymentMethod) onNext;
  final String? fullName;
  final String? phone;
  final String? address;

  const PaymentStep({
    super.key,
    required this.onBack,
    required this.onNext,
    this.fullName,
    this.phone,
    this.address,
  });

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.momo; // Default: MoMo

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
          // Mobile: Stack vertically
          return Column(
            children: [
              // Recipient info on top
              if (widget.fullName != null && widget.phone != null && widget.address != null)
                RecipientInfoSection(
                  fullName: widget.fullName!,
                  phone: widget.phone!,
                  address: widget.address!,
                ),
              if (widget.fullName != null && widget.phone != null && widget.address != null)
                const SizedBox(height: 24),
              // Payment methods
              PaymentMethodsSection(
                selectedMethod: _selectedPaymentMethod,
                onMethodSelected: (method) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Quay lại'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onNext(_selectedPaymentMethod);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Tiếp tục'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop: Grid layout
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: Payment methods
                  Expanded(
                    flex: 2,
                    child: PaymentMethodsSection(
                      selectedMethod: _selectedPaymentMethod,
                      onMethodSelected: (method) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right column: Recipient info (always show if available)
                  Expanded(
                    flex: 1,
                    child: widget.fullName != null && widget.phone != null && widget.address != null
                        ? RecipientInfoSection(
                            fullName: widget.fullName!,
                            phone: widget.phone!,
                            address: widget.address!,
                          )
                        : Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Vui lòng nhập thông tin giao hàng',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Quay lại'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onNext(_selectedPaymentMethod);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Tiếp tục'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
    }
  }
}
