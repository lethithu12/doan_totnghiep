import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';

class ProductsDataSource extends DataTableSource {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final BuildContext context;
  final Function(ProductModel) onView;
  final Function(ProductModel) onEdit;
  final Function(ProductModel) onDelete;
  final String Function(int) formatPrice;

  ProductsDataSource({
    required this.products,
    required this.categories,
    required this.context,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.formatPrice,
  });

  String? _getCategoryName(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return null;
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;

    final product = products[index];
    final calculatedStatus = product.calculatedStatus;
    final isInStock = calculatedStatus == 'Còn hàng';
    final discount = product.discount;
    final categoryName = _getCategoryName(product.categoryId);

    return DataRow2(
      cells: [
        DataCell(
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 24,
                        color: Colors.grey[400],
                      ),
                    )
                  : Icon(
                      Icons.image,
                      size: 24,
                      color: Colors.grey[400],
                    ),
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              if (discount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-$discount%',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              categoryName ?? 'N/A',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            '${formatPrice(product.price)} đ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        DataCell(
          product.originalPrice > product.price
              ? Text(
                  '${formatPrice(product.originalPrice)} đ',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                )
              : const Text('-'),
        ),
        DataCell(
          Text(
            product.quantity.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: product.quantity < 10 ? Colors.red[700] : Colors.grey[700],
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isInStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              calculatedStatus,
              style: TextStyle(
                color: isInStock ? Colors.green[700] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                color: Colors.blue,
                onPressed: () => onView(product),
                tooltip: 'Xem chi tiết',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.orange,
                onPressed: () => onEdit(product),
                tooltip: 'Chỉnh sửa',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                onPressed: () => onDelete(product),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => products.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

