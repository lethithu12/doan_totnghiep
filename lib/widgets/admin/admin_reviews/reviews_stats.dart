import 'package:flutter/material.dart';
import '../../../models/review_model.dart';

class ReviewsStats extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool isTablet;

  const ReviewsStats({
    super.key,
    required this.reviews,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final totalReviews = reviews.length;
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final withReply = reviews.where((r) => r.adminReply != null).length;
    final withoutReply = totalReviews - withReply;

    return Row(
      children: [
        Expanded(
          child: _ReviewStatCard(
            title: 'Tổng đánh giá',
            value: totalReviews.toString(),
            icon: Icons.rate_review,
            color: Colors.blue,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ReviewStatCard(
            title: 'Đánh giá trung bình',
            value: avgRating.toStringAsFixed(1),
            icon: Icons.star,
            color: Colors.amber,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ReviewStatCard(
            title: 'Đã phản hồi',
            value: withReply.toString(),
            icon: Icons.reply,
            color: Colors.green,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ReviewStatCard(
            title: 'Chưa phản hồi',
            value: withoutReply.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class _ReviewStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const _ReviewStatCard({
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
        padding: EdgeInsets.all(isTablet ? 12 : 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isTablet ? 20 : 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 20,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 11 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

