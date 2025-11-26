import 'package:flutter/material.dart';

class AdminReplySection extends StatelessWidget {
  final String reply;
  final DateTime replyAt;
  final bool isMobile;
  final String Function(DateTime) formatDate;

  const AdminReplySection({
    super.key,
    required this.reply,
    required this.replyAt,
    required this.isMobile,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                'Phản hồi từ quản trị viên',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              Text(
                formatDate(replyAt),
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.blue[900],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

