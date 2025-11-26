import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../models/home_section_model.dart';

class SectionsDataSource extends DataTableSource {
  final List<HomeSectionModel> sections;
  final Function(HomeSectionModel) onEdit;
  final Function(HomeSectionModel) onDelete;

  SectionsDataSource({
    required this.sections,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= sections.length) return null;
    final section = sections[index];

    String timeRangeText = 'Luôn hiển thị';
    if (section.startDate != null || section.endDate != null) {
      final start = section.startDate != null
          ? '${section.startDate!.day}/${section.startDate!.month}/${section.startDate!.year}'
          : '';
      final end = section.endDate != null
          ? '${section.endDate!.day}/${section.endDate!.month}/${section.endDate!.year}'
          : '';
      if (start.isNotEmpty && end.isNotEmpty) {
        timeRangeText = '$start - $end';
      } else if (start.isNotEmpty) {
        timeRangeText = 'Từ $start';
      } else if (end.isNotEmpty) {
        timeRangeText = 'Đến $end';
      }
    }

    return DataRow2(
      cells: [
        DataCell(Text(section.title)),
        DataCell(Text(section.productIds.length.toString())),
        DataCell(Text(section.order.toString())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: section.isActive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              section.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: section.isActive ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(Text(timeRangeText)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => onEdit(section),
                tooltip: 'Sửa',
                color: Colors.blue,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => onDelete(section),
                tooltip: 'Xóa',
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => sections.length;

  @override
  int get selectedRowCount => 0;
}

