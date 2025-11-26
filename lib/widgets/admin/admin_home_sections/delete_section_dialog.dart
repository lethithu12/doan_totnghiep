import 'package:flutter/material.dart';
import '../../../models/home_section_model.dart';

class DeleteSectionDialog extends StatelessWidget {
  final HomeSectionModel section;

  const DeleteSectionDialog({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn có chắc chắn muốn xóa section "${section.title}"?'),
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

