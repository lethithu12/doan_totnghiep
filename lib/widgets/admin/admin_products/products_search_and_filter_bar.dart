import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class ProductsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String? selectedStatus;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const ProductsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên sản phẩm, danh mục...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 16,
                  vertical: isTablet ? 12 : 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả')),
                      ...categories.map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          )),
                    ],
                    onChanged: onCategoryChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'Còn hàng', child: Text('Còn hàng')),
                      DropdownMenuItem(value: 'Hết hàng', child: Text('Hết hàng')),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: 12),
                if (selectedCategoryId != null || selectedStatus != null || searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Xóa bộ lọc',
                    onPressed: onClearFilters,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

