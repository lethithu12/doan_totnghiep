import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'expandable_categories_data_source.dart';
import 'expandable_category_row.dart';
import '../../../models/category_model.dart';

class CategoriesDataTable extends StatelessWidget {
  final List<ExpandableCategoryRow> expandableRows;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final Function(String) onToggleExpand;
  final bool isTablet;

  const CategoriesDataTable({
    super.key,
    required this.expandableRows,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleExpand,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1000,
      columnSpacing: isTablet ? 8 : 12,
      horizontalMargin: isTablet ? 8 : 12,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: [
        const DataColumn2(
          label: Text('Hình ảnh'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('Tên danh mục'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => onSort(0, ascending),
        ),
        const DataColumn2(
          label: Text('Danh mục cha'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Số sản phẩm'),
          size: ColumnSize.M,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(1, ascending),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(2, ascending),
        ),
        DataColumn2(
          label: const Text('Ngày tạo'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(3, ascending),
        ),
        const DataColumn2(
          label: Text('Hành động'),
          size: ColumnSize.S,
        ),
      ],
      source: ExpandableCategoriesDataSource(
        expandableRows: expandableRows,
        context: context,
        onEdit: onEdit,
        onDelete: onDelete,
        onToggleExpand: onToggleExpand,
      ),
      empty: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có danh mục nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

