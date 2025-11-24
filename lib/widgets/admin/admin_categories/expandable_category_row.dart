import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/category_model.dart';

class ExpandableCategoryRow {
  final CategoryModel category;
  final List<CategoryModel> children;
  bool isExpanded;

  ExpandableCategoryRow({
    required this.category,
    required this.children,
    this.isExpanded = false,
  });
}

class ExpandableCategoryDataRow extends DataRow2 {
  final ExpandableCategoryRow expandableRow;
  final BuildContext context;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final VoidCallback? onToggleExpand;

  ExpandableCategoryDataRow({
    required this.expandableRow,
    required this.context,
    required this.onEdit,
    required this.onDelete,
    this.onToggleExpand,
  }) : super(
          cells: _buildCells(
            expandableRow,
            context,
            onEdit,
            onDelete,
            onToggleExpand,
          ),
        );

  static List<DataCell> _buildCells(
    ExpandableCategoryRow expandableRow,
    BuildContext context,
    Function(CategoryModel) onEdit,
    Function(CategoryModel) onDelete,
    VoidCallback? onToggleExpand,
  ) {
    final category = expandableRow.category;
    final isVisible = category.status == 'Hiển thị';
    final hasChildren = expandableRow.children.isNotEmpty;

    return [
      // Image
      DataCell(
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: category.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: category.imageUrl!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                )
              : Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
        ),
      ),
      // Name with expand/collapse
      DataCell(
        Row(
          children: [
            if (hasChildren)
              InkWell(
                onTap: onToggleExpand,
                child: Icon(
                  expandableRow.isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 20,
                  color: Colors.grey[600],
                ),
              )
            else
              const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Parent category (always empty for parent rows)
      const DataCell(Text('—')),
      // Product count
      DataCell(
        Text(
          category.productCount.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),
      // Status
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isVisible
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category.status,
            style: TextStyle(
              color: isVisible ? Colors.green[700] : Colors.orange[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // Created date
      DataCell(Text(category.createdAt.toString().split(' ')[0])),
      // Actions
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              color: Colors.orange,
              onPressed: () => onEdit(category),
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.red,
              onPressed: () => onDelete(category),
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    ];
  }
}

// Child row (nested under parent)
class ChildCategoryDataRow extends DataRow2 {
  final CategoryModel category;
  final String parentName;
  final BuildContext context;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;

  ChildCategoryDataRow({
    required this.category,
    required this.parentName,
    required this.context,
    required this.onEdit,
    required this.onDelete,
  }) : super(
          cells: _buildCells(
            category,
            parentName,
            context,
            onEdit,
            onDelete,
          ),
        );

  static List<DataCell> _buildCells(
    CategoryModel category,
    String parentName,
    BuildContext context,
    Function(CategoryModel) onEdit,
    Function(CategoryModel) onDelete,
  ) {
    final isVisible = category.status == 'Hiển thị';

    return [
      // Image
      DataCell(
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: category.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: category.imageUrl!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                )
              : Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
        ),
      ),
      // Name with indentation
      DataCell(
        Row(
          children: [
            const SizedBox(width: 40),
            Icon(
              Icons.subdirectory_arrow_right,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Parent category name
      DataCell(
        Text(
          parentName,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      // Product count
      DataCell(
        Text(
          category.productCount.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),
      // Status
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isVisible
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category.status,
            style: TextStyle(
              color: isVisible ? Colors.green[700] : Colors.orange[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // Created date
      DataCell(Text(category.createdAt.toString().split(' ')[0])),
      // Actions
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              color: Colors.orange,
              onPressed: () => onEdit(category),
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.red,
              onPressed: () => onDelete(category),
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    ];
  }
}

