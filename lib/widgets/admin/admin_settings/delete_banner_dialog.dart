import 'package:flutter/material.dart';
import '../../../models/banner_model.dart';

class DeleteBannerDialog extends StatelessWidget {
  final BannerModel banner;

  const DeleteBannerDialog({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn có chắc chắn muốn xóa banner này?'),
          const SizedBox(height: 8),
          Text(
            'Hành động này không thể hoàn tác.',
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}

