import 'package:flutter/material.dart';
import '../../../models/review_model.dart';
import 'review_images_section.dart';
import 'admin_reply_section.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isMobile;
  final String Function(DateTime) formatDate;

  const ReviewCard({
    super.key,
    required this.review,
    required this.isMobile,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 20 : 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: isMobile ? 14 : 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isMobile ? 14 : 16,
                  height: 1.5,
                ),
          ),
          // Review images
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            ReviewImagesSection(
              imageUrls: review.imageUrls,
              isMobile: isMobile,
            ),
          ],
          // Admin reply
          if (review.adminReply != null) ...[
            const SizedBox(height: 12),
            AdminReplySection(
              reply: review.adminReply!,
              replyAt: review.adminReplyAt!,
              isMobile: isMobile,
              formatDate: formatDate,
            ),
          ],
        ],
      ),
    );
  }
}

