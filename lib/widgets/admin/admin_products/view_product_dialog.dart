import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';

class ViewProductDialog extends StatelessWidget {
  final ProductModel product;
  final List<CategoryModel> categories;
  final String Function(int) formatPrice;
  final bool isMobile;

  const ViewProductDialog({
    super.key,
    required this.product,
    required this.categories,
    required this.formatPrice,
    this.isMobile = false,
  });

  String? _getCategoryName(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return null;
    }
  }

  String? _getChildCategoryName(String? childCategoryId) {
    if (childCategoryId == null) return null;
    try {
      return categories.firstWhere((cat) => cat.id == childCategoryId).name;
    } catch (e) {
      return null;
    }
  }

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    } else if (hexCode.length == 3) {
      final r = hexCode[0] + hexCode[0];
      final g = hexCode[1] + hexCode[1];
      final b = hexCode[2] + hexCode[2];
      return Color(int.parse('FF$r$g$b', radix: 16));
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(product.categoryId);
    final childCategoryName = _getChildCategoryName(product.childCategoryId);
    final discount = product.discount;
    final isInStock = product.status == 'Còn hàng';
    final mainImage = product.imageUrl;
    final subImages = product.imageUrls ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 900,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chi tiết sản phẩm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 20,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    if (mainImage != null || subImages.isNotEmpty) ...[
                      Text(
                        'Hình ảnh',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Main image (large, on top)
                      if (mainImage != null)
                        Container(
                          width: double.infinity,
                          height: isMobile ? 250 : 400,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: mainImage,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.image, size: 64, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      // Sub images (horizontal scrollable list, below)
                      if (subImages.isNotEmpty)
                        SizedBox(
                          height: isMobile ? 100 : 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: subImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: isMobile ? 100 : 120,
                                margin: EdgeInsets.only(
                                  right: index == subImages.length - 1 ? 0 : 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: subImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    errorWidget: (context, url, error) => const Center(
                                      child: Icon(Icons.image, size: 32, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    // Basic Info
                    Text(
                      'Thông tin cơ bản',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Tên sản phẩm',
                      value: product.name,
                      isMobile: isMobile,
                    ),
                    _InfoRow(
                      label: 'Danh mục cha',
                      value: categoryName ?? 'N/A',
                      isMobile: isMobile,
                    ),
                    if (childCategoryName != null)
                      _InfoRow(
                        label: 'Danh mục con',
                        value: childCategoryName,
                        isMobile: isMobile,
                      ),
                    _InfoRow(
                      label: 'Giá bán',
                      value: '${formatPrice(product.price)} đ',
                      isMobile: isMobile,
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (product.originalPrice > product.price)
                      _InfoRow(
                        label: 'Giá gốc',
                        value: '${formatPrice(product.originalPrice)} đ',
                        isMobile: isMobile,
                        valueStyle: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (discount > 0)
                      _InfoRow(
                        label: 'Giảm giá',
                        value: '$discount%',
                        isMobile: isMobile,
                        valueStyle: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    _InfoRow(
                      label: 'Số lượng',
                      value: product.quantity.toString(),
                      isMobile: isMobile,
                    ),
                    _InfoRow(
                      label: 'Trạng thái',
                      value: product.status,
                      isMobile: isMobile,
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isInStock
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.status,
                          style: TextStyle(
                            color: isInStock ? Colors.green[700] : Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _InfoRow(
                      label: 'Đánh giá',
                      value: '${product.rating.toStringAsFixed(1)}/5.0',
                      isMobile: isMobile,
                    ),
                    _InfoRow(
                      label: 'Đã bán',
                      value: product.sold.toString(),
                      isMobile: isMobile,
                    ),
                    _InfoRow(
                      label: 'Ngày tạo',
                      value: '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}',
                      isMobile: isMobile,
                    ),
                    _InfoRow(
                      label: 'Ngày cập nhật',
                      value: '${product.updatedAt.day}/${product.updatedAt.month}/${product.updatedAt.year}',
                      isMobile: isMobile,
                    ),
                    // Description
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Mô tả',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    // Versions
                    if (product.versions != null && product.versions!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Phiên bản',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.versions!.map((version) {
                          return Chip(
                            label: Text(version),
                          );
                        }).toList(),
                      ),
                    ],
                    // Colors
                    if (product.colors != null && product.colors!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Màu sắc',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.colors!.map((colorData) {
                          final colorName = colorData['name'] as String;
                          final colorHex = colorData['hex'] as String;
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: _hexToColor(colorHex),
                              radius: 12,
                            ),
                            label: Text(colorName),
                          );
                        }).toList(),
                      ),
                    ],
                    // Options
                    if (product.options != null && product.options!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Tùy chọn sản phẩm',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...product.options!.map((option) {
                        final version = option['version'] as String;
                        final colorName = option['colorName'] as String;
                        final colorHex = option['colorHex'] as String;
                        final originalPrice = option['originalPrice'] as int;
                        final discount = option['discount'] as int;
                        final quantity = option['quantity'] as int? ?? 0;
                        final finalPrice = originalPrice - (originalPrice * discount ~/ 100);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _hexToColor(colorHex),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$version - $colorName',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Giá: ${formatPrice(finalPrice)} đ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'SL: $quantity',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    // Specifications
                    if (product.specifications != null && product.specifications!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Thông số kỹ thuật',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...product.specifications!.map((spec) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  spec['label'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  spec['value'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final TextStyle? valueStyle;
  final bool isMobile;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueStyle,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? 'N/A',
                  style: valueStyle ??
                      TextStyle(
                        fontSize: isMobile ? 14 : 16,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

