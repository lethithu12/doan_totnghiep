import 'package:flutter/material.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';
import '../../../services/auth_service.dart';
import 'write_review_dialog.dart';
import 'write_review_bottom_sheet.dart';
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
  final AuthService _authService = AuthService();

  Future<void> _showWriteReviewDialog() async {
    // Check if user is logged in
    if (!_authService.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để viết đánh giá'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Get user data for name
    final userData = await _authService.getCurrentUserData();
    final userName = userData?.displayName ?? 
                    _authService.currentUser?.displayName ?? 
                    _authService.currentUser?.email?.split('@').first ?? 
                    'Người dùng';

    if (widget.isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => WriteReviewBottomSheet(
          productId: widget.productId,
          defaultUserName: userName,
          onReviewSubmitted: () {
            // Reviews will auto-update via StreamBuilder
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cảm ơn bạn đã đánh giá!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => WriteReviewDialog(
          productId: widget.productId,
          defaultUserName: userName,
          onReviewSubmitted: () {
            // Reviews will auto-update via StreamBuilder
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cảm ơn bạn đã đánh giá!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
    }
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đánh giá sản phẩm (${reviews.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.isMobile ? 18 : 20,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _showWriteReviewDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Viết đánh giá'),
                  ),
                ],
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
                        const SizedBox(height: 8),
                        Text(
                          'Hãy là người đầu tiên đánh giá sản phẩm này',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
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
