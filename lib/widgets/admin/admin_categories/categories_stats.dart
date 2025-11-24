import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class CategoriesStats extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isTablet;

  const CategoriesStats({
    super.key,
    required this.categories,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final totalCategories = categories.length;
    final visibleCategories = categories.where((c) => c.status == 'Hiển thị').length;
    final hiddenCategories = categories.where((c) => c.status == 'Ẩn').length;
    final totalProducts = categories.fold<int>(
      0,
      (sum, category) => sum + category.productCount,
    );

    return Row(
      children: [
        Expanded(
          child: CategoryStatCard(
            title: 'Tổng danh mục',
            value: totalCategories.toString(),
            icon: Icons.category,
            color: Colors.blue,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CategoryStatCard(
            title: 'Đang hiển thị',
            value: visibleCategories.toString(),
            icon: Icons.visibility,
            color: Colors.green,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CategoryStatCard(
            title: 'Đang ẩn',
            value: hiddenCategories.toString(),
            icon: Icons.visibility_off,
            color: Colors.orange,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CategoryStatCard(
            title: 'Tổng sản phẩm',
            value: totalProducts.toString(),
            icon: Icons.shopping_bag,
            color: Colors.purple,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class CategoryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const CategoryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: isTablet ? 20 : 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 14,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
