import 'package:flutter/material.dart';
import 'product_text_field.dart';

class ProductSpecificationsSection extends StatelessWidget {
  final List<Map<String, String>> specifications;
  final TextEditingController labelController;
  final TextEditingController valueController;
  final VoidCallback onAddSpecification;
  final Function(int) onRemoveSpecification;
  final bool isTablet;
  final bool isMobile;

  const ProductSpecificationsSection({
    super.key,
    required this.specifications,
    required this.labelController,
    required this.valueController,
    required this.onAddSpecification,
    required this.onRemoveSpecification,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông số kỹ thuật',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 24),
            if (isMobile)
              // Mobile: Column layout
              Column(
                children: [
                  ProductTextField(
                    controller: labelController,
                    label: 'Tên thông số',
                    hint: 'Ví dụ: Màn hình',
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 12),
                  ProductTextField(
                    controller: valueController,
                    label: 'Giá trị',
                    hint: 'Ví dụ: 6.7 inch, Super Retina XDR',
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddSpecification,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm thông số'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Desktop/Tablet: Row layout
              Row(
                children: [
                  Expanded(
                    child: ProductTextField(
                      controller: labelController,
                      label: 'Tên thông số',
                      hint: 'Ví dụ: Màn hình',
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ProductTextField(
                      controller: valueController,
                      label: 'Giá trị',
                      hint: 'Ví dụ: 6.7 inch, Super Retina XDR',
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onAddSpecification,
                    icon: const Icon(Icons.add),
                    label: const Text(''),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            if (specifications.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Danh sách thông số (${specifications.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 18,
                    ),
              ),
              const SizedBox(height: 12),
              ...specifications.asMap().entries.map((entry) {
                final index = entry.key;
                final spec = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(isTablet ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: isMobile
                      ? // Mobile: Column layout
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    spec['label'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isTablet ? 14 : 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => onRemoveSpecification(index),
                                  tooltip: 'Xóa thông số',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              spec['value'] ?? '',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        )
                      : // Desktop/Tablet: Row layout
                      Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                spec['label'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 14 : 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                spec['value'] ?? '',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => onRemoveSpecification(index),
                              tooltip: 'Xóa thông số',
                            ),
                          ],
                        ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

