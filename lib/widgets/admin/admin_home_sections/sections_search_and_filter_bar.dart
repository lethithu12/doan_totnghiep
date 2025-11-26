import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SectionsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;

  const SectionsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile
            ? Column(
                children: [
                  _buildSearchField(context),
                  const SizedBox(height: 12),
                  _buildFilters(context),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildSearchField(context)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFilters(context)),
                  if (selectedStatus != null || searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: IconButton(
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Xóa bộ lọc',
                        onPressed: onClearFilters,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm theo tiêu đề...',
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
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return DropdownButtonFormField<String>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Tất cả')),
        DropdownMenuItem(value: 'Active', child: Text('Active')),
        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
      ],
      onChanged: onStatusChanged,
      isExpanded: isMobile,
    );
  }
}

