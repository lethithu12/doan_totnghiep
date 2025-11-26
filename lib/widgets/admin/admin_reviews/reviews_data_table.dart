import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../models/review_model.dart';
import 'review_detail_dialog.dart';

class ReviewsDataTable extends StatelessWidget {
  final List<ReviewModel> reviews;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(DateTime) formatDate;

  const ReviewsDataTable({
    super.key,
    required this.reviews,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1000,
      columnSpacing: isTablet ? 8 : 12,
      horizontalMargin: isTablet ? 8 : 12,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: [
        DataColumn2(
          label: const Text('Người dùng'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(0, ascending),
        ),
        DataColumn2(
          label: const Text('Mã sản phẩm'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(1, ascending),
        ),
        DataColumn2(
          label: const Text('Đánh giá'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) => onSort(2, ascending),
        ),
        DataColumn2(
          label: const Text('Nội dung'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text('Hình ảnh'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('Phản hồi'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) => onSort(3, ascending),
        ),
        DataColumn2(
          label: const Text('Ngày đánh giá'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(4, ascending),
        ),
        const DataColumn2(
          label: Text('Hành động'),
          size: ColumnSize.S,
        ),
      ],
      source: ReviewsDataSource(
        reviews: reviews,
        context: context,
        onView: (review) {
          showDialog(
            context: context,
            builder: (context) => ReviewDetailDialog(review: review),
          );
        },
        formatDate: formatDate,
      ),
      empty: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có đánh giá nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewsDataSource extends DataTableSource {
  final List<ReviewModel> reviews;
  final BuildContext context;
  final Function(ReviewModel) onView;
  final String Function(DateTime) formatDate;

  ReviewsDataSource({
    required this.reviews,
    required this.context,
    required this.onView,
    required this.formatDate,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= reviews.length) return null;

    final review = reviews[index];

    return DataRow2(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  review.userName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            review.productId,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(5, (starIndex) {
                return Icon(
                  starIndex < review.rating
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
              const SizedBox(width: 4),
              Text(
                '${review.rating}/5',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              review.comment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          review.imageUrls.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${review.imageUrls.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : const Text(
                  '-',
                  style: TextStyle(color: Colors.grey),
                ),
        ),
        DataCell(
          review.adminReply != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Đã phản hồi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Chưa phản hồi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
        ),
        DataCell(Text(formatDate(review.createdAt))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                color: Colors.blue,
                onPressed: () => onView(review),
                tooltip: 'Xem chi tiết',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => reviews.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

