import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../models/home_section_model.dart';
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
      columns: const [
        DataColumn2(
          label: Text('Tiêu đề'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Số sản phẩm'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Thứ tự'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Trạng thái'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Thời gian hiển thị'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Hành động'),
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

