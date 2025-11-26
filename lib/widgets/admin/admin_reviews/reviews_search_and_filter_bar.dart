import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ReviewsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final int? selectedRating;
  final bool? hasReply;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<bool?> onReplyChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const ReviewsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedRating,
    required this.hasReply,
    required this.onRatingChanged,
    required this.onReplyChanged,
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
                    : 'Tìm kiếm theo tên, nội dung, mã sản phẩm...',
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
                  DropdownButtonFormField<int>(
                    value: selectedRating,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Đánh giá',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...List.generate(5, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Row(
                            children: [
                              ...List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < index + 1
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text('${index + 1} sao'),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: onRatingChanged,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
                    value: hasReply,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Phản hồi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem<bool>(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Đã phản hồi'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Chưa phản hồi'),
                      ),
                    ],
                    onChanged: onReplyChanged,
                  ),
                  if (selectedRating != null ||
                      hasReply != null ||
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
                    child: DropdownButtonFormField<int>(
                      value: selectedRating,
                      decoration: InputDecoration(
                        labelText: 'Đánh giá',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        ...List.generate(5, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Row(
                              children: [
                                ...List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < index + 1
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text('${index + 1} sao'),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: onRatingChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      value: hasReply,
                      decoration: InputDecoration(
                        labelText: 'Phản hồi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<bool>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Text('Đã phản hồi'),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Text('Chưa phản hồi'),
                        ),
                      ],
                      onChanged: onReplyChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (selectedRating != null ||
                      hasReply != null ||
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

