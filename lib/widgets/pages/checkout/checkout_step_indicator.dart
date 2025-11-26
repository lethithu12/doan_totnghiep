import 'package:flutter/material.dart';

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep; // 1-4

  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
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
      child: Row(
        children: [
          // Step 1: Chọn sản phẩm (always completed)
          Expanded(
            child: _buildStep(
              stepNumber: 1,
              label: 'Chọn sản phẩm',
              icon: Icons.check,
              isCompleted: true,
              isActive: false,
            ),
          ),
          _buildConnector(isActive: true), // Step 1 is always completed
          // Step 2: Thông tin giao hàng
          Expanded(
            child: _buildStep(
              stepNumber: 2,
              label: 'Thông tin giao hàng',
              icon: Icons.person,
              isCompleted: currentStep > 2,
              isActive: currentStep == 2,
            ),
          ),
          _buildConnector(isActive: currentStep > 2),
          // Step 3: Thanh toán
          Expanded(
            child: _buildStep(
              stepNumber: 3,
              label: 'Thanh toán',
              icon: Icons.credit_card,
              isCompleted: currentStep > 3,
              isActive: currentStep == 3,
            ),
          ),
          _buildConnector(isActive: currentStep > 3),
          // Step 4: Xác nhận
          Expanded(
            child: _buildStep(
              stepNumber: 4,
              label: 'Xác nhận',
              icon: Icons.check_circle,
              isCompleted: currentStep > 4,
              isActive: currentStep == 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String label,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      // Completed step - green
      circleColor = Colors.green;
      iconColor = Colors.white;
      textColor = Colors.grey[800]!;
    } else if (isActive) {
      // Active step - blue
      circleColor = Colors.blue;
      iconColor = Colors.white;
      textColor = Colors.blue;
    } else {
      // Inactive step - gray
      circleColor = Colors.grey[300]!;
      iconColor = Colors.grey[600]!;
      textColor = Colors.grey[600]!;
    }

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? Colors.green : Colors.grey[300],
      ),
    );
  }
}

