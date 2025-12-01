import 'package:flutter/material.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';
import 'review_card.dart';

class ReviewsTab extends StatefulWidget {
  final bool isMobile;
  final String productId;

  const ReviewsTab({
    super.key,
    required this.isMobile,
    required this.productId,
  });

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final ReviewService _reviewService = ReviewService();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReviewModel>>(
      stream: _reviewService.getReviews(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi khi tải đánh giá',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đánh giá sản phẩm (${reviews.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isMobile ? 18 : 20,
                    ),
              ),
              const SizedBox(height: 24),
              if (reviews.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.rate_review, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có đánh giá nào',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...reviews.map((review) {
                  return ReviewCard(
                    review: review,
                    isMobile: widget.isMobile,
                    formatDate: _formatDate,
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
