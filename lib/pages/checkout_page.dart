import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/payment_method.dart';
import '../widgets/pages/checkout/checkout_step_indicator.dart';
import '../widgets/pages/checkout/delivery_info_step.dart';
import '../widgets/pages/checkout/payment_step.dart';
import '../widgets/pages/checkout/confirmation_step.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 2; // Step 1: Chọn sản phẩm (completed), Step 2: Thông tin giao hàng (current)
  String? _deliveryFullName;
  String? _deliveryPhone;
  String? _deliveryAddress;
  String? _deliveryNotes;
  PaymentMethod? _paymentMethod;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: ResponsiveConstraints(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator
                CheckoutStepIndicator(currentStep: _currentStep),
                const SizedBox(height: 32),
                // Step Content
                _buildStepContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        // Step 1: Chọn sản phẩm (should not show, but just in case)
        return const Center(child: Text('Bước 1: Chọn sản phẩm'));
      case 2:
        // Step 2: Thông tin giao hàng
        return DeliveryInfoStep(
          onNext: (fullName, phone, address, notes) {
            setState(() {
              _deliveryFullName = fullName;
              _deliveryPhone = phone;
              _deliveryAddress = address;
              _deliveryNotes = notes;
              _currentStep = 3;
            });
          },
        );
      case 3:
        // Step 3: Thanh toán
        return PaymentStep(
          onBack: () {
            setState(() {
              _currentStep = 2;
            });
          },
          onNext: (paymentMethod) {
            setState(() {
              _paymentMethod = paymentMethod;
              _currentStep = 4;
            });
          },
          fullName: _deliveryFullName,
          phone: _deliveryPhone,
          address: _deliveryAddress,
        );
      case 4:
        // Step 4: Xác nhận
        return ConfirmationStep(
          onBack: () {
            setState(() {
              _currentStep = 3;
            });
          },
          fullName: _deliveryFullName,
          phone: _deliveryPhone,
          address: _deliveryAddress,
          notes: _deliveryNotes,
          paymentMethod: _paymentMethod,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

