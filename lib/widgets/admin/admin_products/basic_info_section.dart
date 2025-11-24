import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import 'product_text_field.dart';
import 'product_dropdown_field.dart';

class BasicInfoSection extends StatelessWidget {
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
  final bool isTablet;

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
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 24),
            ProductTextField(
              controller: nameController,
              label: 'Tên sản phẩm *',
              hint: 'Nhập tên sản phẩm',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên sản phẩm';
                }
                return null;
              },
              isTablet: isTablet,
            ),
            const SizedBox(height: 16),
            ProductDropdownField<String>(
              value: selectedParentCategoryId,
              label: 'Danh mục cha *',
              items: parentCategories.map((cat) => cat.id).toList(),
              itemLabels: parentCategories.map((cat) => cat.name).toList(),
              onChanged: onParentCategoryChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn danh mục cha';
                }
                return null;
              },
              isTablet: isTablet,
            ),
            const SizedBox(height: 16),
            if (selectedParentCategoryId != null && childCategories.isNotEmpty)
              ProductDropdownField<String?>(
                value: selectedChildCategoryId,
                label: 'Danh mục con',
                items: [null, ...childCategories.map((cat) => cat.id).toList()],
                itemLabels: ['Không có', ...childCategories.map((cat) => cat.name).toList()],
                onChanged: onChildCategoryChanged,
                isTablet: isTablet,
              ),
            if (selectedParentCategoryId != null && childCategories.isNotEmpty)
              const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: priceController,
                    label: 'Giá bán *',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập giá bán';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Giá bán phải là số';
                      }
                      return null;
                    },
                    isTablet: isTablet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProductTextField(
                    controller: originalPriceController,
                    label: 'Giá gốc',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Giá gốc phải là số';
                        }
                      }
                      return null;
                    },
                    isTablet: isTablet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: quantityController,
                    label: 'Số lượng *',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số lượng';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Số lượng phải là số';
                      }
                      return null;
                    },
                    isTablet: isTablet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProductDropdownField<String>(
                    value: selectedStatus,
                    label: 'Trạng thái *',
                    items: const ['Còn hàng', 'Hết hàng'],
                    onChanged: onStatusChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn trạng thái';
                      }
                      return null;
                    },
                    isTablet: isTablet,
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

