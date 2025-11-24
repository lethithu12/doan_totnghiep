import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/category_model.dart';
import 'basic_info_section.dart';
import 'image_and_description_section.dart';
import 'product_options_section.dart';

class MobileProductForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController quantityController;
  final TextEditingController descriptionController;
  final String? selectedParentCategoryId;
  final String? selectedChildCategoryId;
  final String? selectedStatus;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final ValueChanged<String?> onParentCategoryChanged;
  final ValueChanged<String?> onChildCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final PlatformFile? selectedImageFile;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final bool isLoading;
  final bool isUploading;
  final VoidCallback onSubmit;
  final List<String> versions;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> options;
  final TextEditingController versionController;
  final TextEditingController colorNameController;
  final TextEditingController colorHexController;
  final String? selectedVersionForOption;
  final String? selectedColorForOption;
  final TextEditingController optionOriginalPriceController;
  final TextEditingController optionDiscountController;
  final TextEditingController optionQuantityController;
  final int basePrice;
  final ValueChanged<String?> onVersionChanged;
  final ValueChanged<String?> onColorChanged;
  final VoidCallback onAddVersion;
  final Function(int) onRemoveVersion;
  final VoidCallback onAddColor;
  final Function(int) onRemoveColor;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;

  const MobileProductForm({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.originalPriceController,
    required this.quantityController,
    required this.descriptionController,
    required this.selectedParentCategoryId,
    required this.selectedChildCategoryId,
    required this.selectedStatus,
    required this.parentCategories,
    required this.childCategories,
    required this.onParentCategoryChanged,
    required this.onChildCategoryChanged,
    required this.onStatusChanged,
    required this.selectedImageFile,
    required this.imageUrl,
    required this.onPickImage,
    required this.isLoading,
    required this.isUploading,
    required this.onSubmit,
    required this.versions,
    required this.colors,
    required this.options,
    required this.versionController,
    required this.colorNameController,
    required this.colorHexController,
    required this.selectedVersionForOption,
    required this.selectedColorForOption,
    required this.optionOriginalPriceController,
    required this.optionDiscountController,
    required this.optionQuantityController,
    required this.basePrice,
    required this.onVersionChanged,
    required this.onColorChanged,
    required this.onAddVersion,
    required this.onRemoveVersion,
    required this.onAddColor,
    required this.onRemoveColor,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BasicInfoSection(
          nameController: nameController,
          priceController: priceController,
          originalPriceController: originalPriceController,
          quantityController: quantityController,
          selectedParentCategoryId: selectedParentCategoryId,
          selectedChildCategoryId: selectedChildCategoryId,
          selectedStatus: selectedStatus,
          parentCategories: parentCategories,
          childCategories: childCategories,
          onParentCategoryChanged: onParentCategoryChanged,
          onChildCategoryChanged: onChildCategoryChanged,
          onStatusChanged: onStatusChanged,
          isTablet: false,
        ),
        const SizedBox(height: 16),
        ImageAndDescriptionSection(
          selectedImageFile: selectedImageFile,
          imageUrl: imageUrl,
          onPickImage: onPickImage,
          descriptionController: descriptionController,
          isUploading: isUploading,
          isTablet: false,
        ),
        const SizedBox(height: 16),
        ProductOptionsSection(
          versions: versions,
          colors: colors,
          options: options,
          versionController: versionController,
          colorNameController: colorNameController,
          colorHexController: colorHexController,
          selectedVersionForOption: selectedVersionForOption,
          selectedColorForOption: selectedColorForOption,
          optionOriginalPriceController: optionOriginalPriceController,
          optionDiscountController: optionDiscountController,
          optionQuantityController: optionQuantityController,
          basePrice: basePrice,
          onVersionChanged: onVersionChanged,
          onColorChanged: onColorChanged,
          onAddVersion: onAddVersion,
          onRemoveVersion: onRemoveVersion,
          onAddColor: onAddColor,
          onRemoveColor: onRemoveColor,
          onAddOption: onAddOption,
          onRemoveOption: onRemoveOption,
          isTablet: false,
          isMobile: true,
        ),
      ],
    );
  }
}

