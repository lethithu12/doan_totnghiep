import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'products_data_source.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';

class ProductsDataTable extends StatelessWidget {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(int) formatPrice;
  final Function(ProductModel) onView;
  final Function(ProductModel) onEdit;
  final Function(ProductModel) onDelete;

  const ProductsDataTable({
    super.key,
    required this.products,
    required this.categories,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatPrice,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1200,
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
          label: const Text('Tên sản phẩm'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => onSort(0, ascending),
        ),
        DataColumn2(
          label: const Text('Danh mục'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(1, ascending),
        ),
        DataColumn2(
          label: const Text('Giá'),
          size: ColumnSize.M,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(2, ascending),
        ),
        DataColumn2(
          label: const Text('Giá gốc'),
          size: ColumnSize.M,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(3, ascending),
        ),
        DataColumn2(
          label: const Text('Số lượng'),
          size: ColumnSize.S,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(4, ascending),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) => onSort(5, ascending),
        ),
        const DataColumn2(
          label: Text('Hành động'),
          size: ColumnSize.S,
        ),
      ],
      source: ProductsDataSource(
        products: products,
        categories: categories,
        context: context,
        onView: onView,
        onEdit: onEdit,
        onDelete: onDelete,
        formatPrice: formatPrice,
      ),
      empty: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có sản phẩm nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

