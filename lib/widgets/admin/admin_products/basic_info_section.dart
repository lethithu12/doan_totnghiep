import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import 'product_text_field.dart';
import 'product_dropdown_field.dart';

class BasicInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController quantityController;
  final String? selectedParentCategoryId;
  final String? selectedChildCategoryId;
  final String? selectedStatus;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final ValueChanged<String?> onParentCategoryChanged;
  final ValueChanged<String?> onChildCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final List<Map<String, dynamic>> options;
  final bool isTablet;
  final bool isMobile;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.originalPriceController,
    required this.quantityController,
    required this.selectedParentCategoryId,
    required this.selectedChildCategoryId,
    required this.selectedStatus,
    required this.parentCategories,
    required this.childCategories,
    required this.onParentCategoryChanged,
    required this.onChildCategoryChanged,
    required this.onStatusChanged,
    this.options = const [],
    required this.isTablet,
    this.isMobile = false,
  });

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection> {
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();
    widget.priceController.addListener(_updatePriceDisplay);
    widget.originalPriceController.addListener(_updatePriceDisplay);
  }

  @override
  void dispose() {
    widget.priceController.removeListener(_updatePriceDisplay);
    widget.originalPriceController.removeListener(_updatePriceDisplay);
    super.dispose();
  }

  void _updatePriceDisplay() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final price = int.tryParse(widget.priceController.text.trim()) ?? 0;
    final originalPriceText = widget.originalPriceController.text.trim();
    final originalPrice = originalPriceText.isNotEmpty
        ? (int.tryParse(originalPriceText) ?? 0)
        : price;
    final hasDiscount = originalPrice > price && price > 0;
    final discountPercent = hasDiscount
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isTablet ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isTablet ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 24),
            ProductTextField(
              controller: widget.nameController,
              label: 'Tên sản phẩm *',
              hint: 'Nhập tên sản phẩm',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên sản phẩm';
                }
                return null;
              },
              isTablet: widget.isTablet,
            ),
            const SizedBox(height: 16),
            ProductDropdownField<String>(
              value: widget.selectedParentCategoryId,
              label: 'Danh mục cha *',
              items: widget.parentCategories.map((cat) => cat.id).toList(),
              itemLabels: widget.parentCategories.map((cat) => cat.name).toList(),
              onChanged: widget.onParentCategoryChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn danh mục cha';
                }
                return null;
              },
              isTablet: widget.isTablet,
              isMobile: widget.isMobile,
            ),
            const SizedBox(height: 16),
            if (widget.selectedParentCategoryId != null && widget.childCategories.isNotEmpty)
              ProductDropdownField<String?>(
                value: widget.selectedChildCategoryId,
                label: 'Danh mục con',
                items: [null, ...widget.childCategories.map((cat) => cat.id).toList()],
                itemLabels: ['Không có', ...widget.childCategories.map((cat) => cat.name).toList()],
                onChanged: widget.onChildCategoryChanged,
                isTablet: widget.isTablet,
                isMobile: widget.isMobile,
              ),
            if (widget.selectedParentCategoryId != null && widget.childCategories.isNotEmpty)
              const SizedBox(height: 16),
            ProductTextField(
              controller: widget.priceController,
              label: 'Giá bán *',
              hint: 'Nhập giá bán (VNĐ)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập giá bán';
                }
                final priceValue = int.tryParse(value);
                if (priceValue == null) {
                  return 'Giá bán phải là số';
                }
                if (priceValue < 0) {
                  return 'Giá bán phải lớn hơn 0';
                }
                // Validate: if original price is set, it should be >= price
                final originalPriceText = widget.originalPriceController.text.trim();
                if (originalPriceText.isNotEmpty) {
                  final originalPriceValue = int.tryParse(originalPriceText);
                  if (originalPriceValue != null && originalPriceValue < priceValue) {
                    return 'Giá gốc phải >= giá bán';
                  }
                }
                return null;
              },
              isTablet: widget.isTablet,
            ),
            const SizedBox(height: 16),
            ProductTextField(
              controller: widget.originalPriceController,
              label: 'Giá gốc (tùy chọn)',
              hint: 'Để trống = dùng giá bán',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final originalPriceValue = int.tryParse(value);
                  if (originalPriceValue == null) {
                    return 'Giá gốc phải là số';
                  }
                  if (originalPriceValue < 0) {
                    return 'Giá gốc phải lớn hơn 0';
                  }
                  // Validate: original price should be >= price
                  final priceText = widget.priceController.text.trim();
                  if (priceText.isNotEmpty) {
                    final priceValue = int.tryParse(priceText);
                    if (priceValue != null && originalPriceValue < priceValue) {
                      return 'Giá gốc phải >= giá bán';
                    }
                  }
                }
                return null;
              },
              isTablet: widget.isTablet,
            ),
            // Display discount info if applicable
            if (hasDiscount) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giảm giá: $discountPercent%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[900],
                              fontSize: widget.isTablet ? 13 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${_formatPrice(originalPrice)} đ',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 11 : 12,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '→ ${_formatPrice(price)} đ',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 11 : 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: widget.quantityController,
                    label: 'Số lượng *',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số lượng';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null) {
                        return 'Số lượng phải là số';
                      }
                      if (quantity < 0) {
                        return 'Số lượng phải >= 0';
                      }
                      
                      // Validate: nếu có options thì tổng số lượng options phải bằng số lượng thông tin
                      if (widget.options.isNotEmpty) {
                        final totalOptionsQuantity = widget.options.fold<int>(
                          0,
                          (sum, option) => sum + (option['quantity'] as int? ?? 0),
                        );
                        if (totalOptionsQuantity != quantity) {
                          return 'Tổng số lượng options ($totalOptionsQuantity) phải bằng số lượng ($quantity)';
                        }
                      }
                      
                      return null;
                    },
                    isTablet: widget.isTablet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProductDropdownField<String>(
                    value: widget.selectedStatus,
                    label: 'Trạng thái *',
                    items: const ['Còn hàng', 'Hết hàng'],
                    onChanged: widget.onStatusChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn trạng thái';
                      }
                      return null;
                    },
                    isTablet: widget.isTablet,
                    isMobile: widget.isMobile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

