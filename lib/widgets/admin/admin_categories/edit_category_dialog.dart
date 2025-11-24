import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/image_service.dart';
import '../../../models/category_model.dart';

class EditCategoryDialog extends StatefulWidget {
  final CategoryModel category;
  final List<CategoryModel> allCategories;
  final Function(CategoryModel) onSave;

  const EditCategoryDialog({
    super.key,
    required this.category,
    required this.allCategories,
    required this.onSave,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _imageService = ImageService();
  late String? _selectedStatus;
  late String? _selectedParentId;
  PlatformFile? _selectedImageFile;
  String? _currentImageUrl;
  bool _isUploading = false;
  bool _imageChanged = false;

  // Get parent categories (categories without parentId)
  List<CategoryModel> get _parentCategories {
    return widget.allCategories
        .where((cat) => cat.parentId == null && cat.id != widget.category.id)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(text: widget.category.description ?? '');
    _selectedStatus = widget.category.status;
    _selectedParentId = widget.category.parentId;
    _currentImageUrl = widget.category.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final platformFile = await _imageService.pickImage();
      if (platformFile != null) {
        setState(() {
          _selectedImageFile = platformFile;
          _imageChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? finalImageUrl = _currentImageUrl;

      // Upload new image if changed
      if (_imageChanged && _selectedImageFile != null) {
        // Delete old image if exists
        if (_currentImageUrl != null) {
          await _imageService.deleteCategoryImage(_currentImageUrl!);
        }
        // Upload new image
        finalImageUrl = await _imageService.uploadCategoryImage(
          _selectedImageFile!,
          categoryId: widget.category.id,
        );
      }

      final updatedCategory = widget.category.copyWith(
        name: _nameController.text,
        imageUrl: finalImageUrl,
        parentId: _selectedParentId,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      widget.onSave(updatedCategory);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_selectedImageFile != null) {
      // Show preview of selected image
      if (kIsWeb) {
        // Web: use Image.memory with bytes
        if (_selectedImageFile!.bytes != null) {
          return Stack(
            children: [
              Image.memory(
                _selectedImageFile!.bytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: Icon(Icons.error, size: 48),
          );
        }
      } else {
        // Mobile/Desktop: use Image.file with path
        if (_selectedImageFile!.path != null) {
          return Stack(
            children: [
              Image.file(
                File(_selectedImageFile!.path!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: Icon(Icons.error, size: 48),
          );
        }
      }
    } else if (_currentImageUrl != null) {
      // Show existing image from URL
      return Stack(
        children: [
          CachedNetworkImage(
            imageUrl: _currentImageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error, size: 48),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      );
    } else {
      // Show placeholder
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn hình ảnh',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Chỉnh sửa danh mục',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 20 : 22,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Image selection
                  Text(
                    'Hình ảnh danh mục',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildImagePreview(),
                      ),
                    ),
                  ),
                  if (_selectedImageFile != null || _currentImageUrl != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () {
                              setState(() {
                                _selectedImageFile = null;
                                _currentImageUrl = null;
                                _imageChanged = true;
                              });
                            },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Xóa ảnh'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên danh mục *',
                      hintText: 'Nhập tên danh mục',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên danh mục';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      hintText: 'Nhập mô tả danh mục',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Parent category field
                  DropdownButtonFormField<String?>(
                    value: _selectedParentId,
                    decoration: InputDecoration(
                      labelText: 'Danh mục cha (tùy chọn)',
                      hintText: 'Chọn danh mục cha hoặc để trống',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      helperText: 'Để trống nếu đây là danh mục cha',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Không có (Danh mục cha)'),
                      ),
                      if (_parentCategories.isNotEmpty)
                        ..._parentCategories.map((parent) {
                          return DropdownMenuItem<String?>(
                            value: parent.id,
                            child: Text(parent.name),
                          );
                        }).toList(),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedParentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Status field
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Hiển thị', child: Text('Hiển thị')),
                      DropdownMenuItem(value: 'Ẩn', child: Text('Ẩn')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn trạng thái';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Lưu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
