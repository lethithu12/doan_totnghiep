import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool isMobile;

  const ActionButtons({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onCancel,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isLoading ? null : onCancel,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          child: Text(
            'Hủy',
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: isMobile ? 20 : 24,
                  width: isMobile ? 20 : 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}

