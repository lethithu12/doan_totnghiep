import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class UsersSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedRole;
  final String? selectedStatus;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const UsersSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 12 : 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: isMobile
                    ? 'Tìm kiếm...'
                    : 'Tìm kiếm theo tên hoặc email...',
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
                  horizontal: isMobile ? 12 : (isTablet ? 12 : 16),
                  vertical: isMobile ? 12 : (isTablet ? 12 : 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filters
            if (isMobile)
              // Mobile: Vertical layout
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Vai trò',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'user', child: Text('User')),
                    ],
                    onChanged: onRoleChanged,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')),
                      DropdownMenuItem(value: 'Khóa', child: Text('Khóa')),
                    ],
                    onChanged: onStatusChanged,
                  ),
                  if (selectedRole != null ||
                      selectedStatus != null ||
                      searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Xóa bộ lọc'),
                        onPressed: onClearFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else
              // Desktop/Tablet: Horizontal layout
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Vai trò',
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
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'user', child: Text('User')),
                      ],
                      onChanged: onRoleChanged,
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
                        DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')),
                        DropdownMenuItem(value: 'Khóa', child: Text('Khóa')),
                      ],
                      onChanged: onStatusChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (selectedRole != null ||
                      selectedStatus != null ||
                      searchController.text.isNotEmpty)
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

