import 'package:flutter/material.dart';

class DescriptionTab extends StatelessWidget {
  final bool isMobile;
  final String? description;

  const DescriptionTab({
    super.key,
    required this.isMobile,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả sản phẩm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 20,
                ),
          ),
          const SizedBox(height: 16),
          if (description != null && description!.isNotEmpty)
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isMobile ? 14 : 16,
                    height: 1.6,
                  ),
            )
          else
            Text(
              'Chưa có mô tả cho sản phẩm này.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isMobile ? 14 : 16,
                    height: 1.6,
                    color: Colors.grey[600],
                  ),
            ),
        ],
      ),
    );
  }
}

