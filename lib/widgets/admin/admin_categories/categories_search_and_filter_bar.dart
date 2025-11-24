import 'package:flutter/material.dart';

class CategoriesSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const CategoriesSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedStatus,
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
                hintText: 'Tìm kiếm theo tên danh mục...',
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
                      DropdownMenuItem(value: 'Hiển thị', child: Text('Hiển thị')),
                      DropdownMenuItem(value: 'Ẩn', child: Text('Ẩn')),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: 12),
                if (selectedStatus != null || searchController.text.isNotEmpty)
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

