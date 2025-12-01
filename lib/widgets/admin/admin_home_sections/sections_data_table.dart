import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../models/home_section_model.dart';
import '../../../config/colors.dart';
import 'sections_data_source.dart';

class SectionsDataTable extends StatelessWidget {
  final List<HomeSectionModel> sections;
  final Function(HomeSectionModel) onEdit;
  final Function(HomeSectionModel) onDelete;

  const SectionsDataTable({
    super.key,
    required this.sections,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: 1000,
      columnSpacing: 12,
      horizontalMargin: 12,
      rowsPerPage: 10,
      headingRowColor: WidgetStateProperty.all(AppColors.headerBackground),
      headingRowHeight: 56,
      columns: [
        DataColumn2(
          label: Text(
            'Tiêu đề',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text(
            'Số sản phẩm',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text(
            'Thứ tự',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text(
            'Trạng thái',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text(
            'Thời gian hiển thị',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text(
            'Hành động',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.S,
        ),
      ],
      source: SectionsDataSource(
        sections: sections,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

