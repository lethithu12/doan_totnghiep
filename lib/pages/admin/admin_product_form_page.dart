import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/image_service.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../widgets/admin/admin_products/basic_info_section.dart';
import '../../widgets/admin/admin_products/image_and_description_section.dart';
import '../../widgets/admin/admin_products/mobile_product_form.dart';
import '../../widgets/admin/admin_products/product_options_section.dart';
import '../../widgets/admin/admin_products/action_buttons.dart';

class AdminProductFormPage extends StatefulWidget {
  final String? productId; // null = create, not null = edit

  const AdminProductFormPage({
    super.key,
    this.productId,
  });

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _imageService = ImageService();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedParentCategoryId;
  String? _selectedChildCategoryId;
  String? _selectedStatus = 'Còn hàng';
  PlatformFile? _selectedImageFile;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  ProductModel? _existingProduct;

  // Versions and Colors
  final List<String> _versions = [];
  final List<Map<String, dynamic>> _colors = [];
  final List<Map<String, dynamic>> _options = [];

  // Controllers for adding versions/colors/options
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _colorNameController = TextEditingController();
  final TextEditingController _colorHexController = TextEditingController();
  
  // Controllers for adding options
  String? _selectedVersionForOption;
  String? _selectedColorForOption;
  final TextEditingController _optionOriginalPriceController = TextEditingController();
  final TextEditingController _optionDiscountController = TextEditingController();
  final TextEditingController _optionQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final product = await _productService.getProductById(widget.productId!);
      if (product != null && mounted) {
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _priceController.text = product.price.toString();
          _originalPriceController.text = product.originalPrice.toString();
          _quantityController.text = product.quantity.toString();
          _descriptionController.text = product.description ?? '';
          _selectedParentCategoryId = product.categoryId;
          _selectedChildCategoryId = product.childCategoryId;
          _selectedStatus = product.status;
          _imageUrl = product.imageUrl;
          // Load versions, colors, and options
          _versions.clear();
          if (product.versions != null) {
            _versions.addAll(product.versions!);
          }
          _colors.clear();
          if (product.colors != null) {
            _colors.addAll(product.colors!);
          }
          _options.clear();
          if (product.options != null) {
            _options.addAll(product.options!);
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy sản phẩm'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/admin/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final platformFile = await _imageService.pickImage();
      if (platformFile != null) {
        setState(() {
          _selectedImageFile = platformFile;
          _imageUrl = null; // Reset URL when new image is selected
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _colorNameController.dispose();
    _colorHexController.dispose();
    _optionOriginalPriceController.dispose();
    _optionDiscountController.dispose();
    _optionQuantityController.dispose();
    super.dispose();
  }

  void _addVersion() {
    final version = _versionController.text.trim();
    if (version.isEmpty) return;
    if (_versions.contains(version)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phiên bản này đã tồn tại'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _versions.add(version);
      _versionController.clear();
    });
  }

  void _removeVersion(int index) {
    setState(() {
      final version = _versions[index];
      _versions.removeAt(index);
      // Remove options that use this version
      _options.removeWhere((opt) => opt['version'] == version);
    });
  }

  void _addColor() {
    final name = _colorNameController.text.trim();
    final hex = _colorHexController.text.trim();
    if (name.isEmpty || hex.isEmpty) return;
    
    // Validate hex color
    if (!RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$').hasMatch(hex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã màu không hợp lệ. Vui lòng nhập mã hex (ví dụ: #FF0000)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_colors.any((c) => c['name'] == name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Màu sắc này đã tồn tại'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _colors.add({'name': name, 'hex': hex});
      _colorNameController.clear();
      _colorHexController.clear();
    });
  }

  void _removeColor(int index) {
    setState(() {
      final colorName = _colors[index]['name'] as String;
      _colors.removeAt(index);
      // Remove options that use this color
      _options.removeWhere((opt) => opt['colorName'] == colorName);
    });
  }

  void _addOption() {
    if (_selectedVersionForOption == null || _selectedVersionForOption!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn phiên bản'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_selectedColorForOption == null || _selectedColorForOption!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn màu sắc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Check if option already exists
    if (_options.any((opt) => 
        opt['version'] == _selectedVersionForOption && 
        opt['colorName'] == _selectedColorForOption)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Option này đã tồn tại'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final color = _colors.firstWhere((c) => c['name'] == _selectedColorForOption);
    final basePrice = int.tryParse(_priceController.text.trim()) ?? 0;
    final originalPriceText = _optionOriginalPriceController.text.trim();
    final discountText = _optionDiscountController.text.trim();
    
    // Use base price if original price is not provided
    final originalPrice = originalPriceText.isNotEmpty
        ? (int.tryParse(originalPriceText) ?? basePrice)
        : basePrice;
    
    final discount = discountText.isNotEmpty
        ? (int.tryParse(discountText) ?? 0)
        : 0;
    
    if (discount < 0 || discount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giảm giá phải từ 0 đến 100%'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Validate quantity
    final quantityText = _optionQuantityController.text.trim();
    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số lượng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final quantity = int.tryParse(quantityText);
    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số lượng phải là số nguyên dương'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final optionData = <String, dynamic>{
      'version': _selectedVersionForOption,
      'colorName': _selectedColorForOption,
      'colorHex': color['hex'] as String,
      'originalPrice': originalPrice,
      'discount': discount,
      'quantity': quantity,
    };
    
    setState(() {
      _options.add(optionData);
      _selectedVersionForOption = null;
      _selectedColorForOption = null;
      _optionOriginalPriceController.clear();
      _optionDiscountController.clear();
      _optionQuantityController.clear();
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate category
    if (_selectedParentCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
    });

    try {
      String? finalImageUrl = _imageUrl;

      // Upload image if new file is selected
      if (_selectedImageFile != null) {
        finalImageUrl = await _imageService.uploadImage(
          platformFile: _selectedImageFile!,
          folder: 'products',
        );
      }

      final now = DateTime.now();
      final product = ProductModel(
        id: widget.productId ?? '',
        name: _nameController.text.trim(),
        categoryId: _selectedParentCategoryId!,
        childCategoryId: _selectedChildCategoryId,
        price: int.parse(_priceController.text.trim()),
        originalPrice: int.parse(_originalPriceController.text.trim().isEmpty
            ? _priceController.text.trim()
            : _originalPriceController.text.trim()),
        quantity: int.parse(_quantityController.text.trim()),
        status: _selectedStatus ?? 'Còn hàng',
        imageUrl: finalImageUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rating: _existingProduct?.rating ?? 0.0,
        sold: _existingProduct?.sold ?? 0,
        versions: _versions.isEmpty ? null : _versions,
        colors: _colors.isEmpty ? null : _colors,
        options: _options.isEmpty ? null : _options,
        createdAt: _existingProduct?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.productId != null) {
        // Update existing product
        await _productService.updateProduct(widget.productId!, product);
      } else {
        // Create new product
        await _productService.createProduct(product);
      }

      if (mounted) {
        context.go('/admin/products');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productId != null
                  ? 'Cập nhật sản phẩm thành công!'
                  : 'Tạo sản phẩm thành công!',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (_isLoading && widget.productId != null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && widget.productId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/admin/products'),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final allCategories = snapshot.data ?? [];
        final parentCategories = allCategories.where((cat) => cat.parentId == null).toList();
        final childCategories = allCategories
            .where((cat) => cat.parentId == _selectedParentCategoryId)
            .toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/admin/products'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.productId != null ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 24 : 28,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Form content
                if (isMobile)
                  MobileProductForm(
                    nameController: _nameController,
                    priceController: _priceController,
                    originalPriceController: _originalPriceController,
                    quantityController: _quantityController,
                    descriptionController: _descriptionController,
                    selectedParentCategoryId: _selectedParentCategoryId,
                    selectedChildCategoryId: _selectedChildCategoryId,
                    selectedStatus: _selectedStatus,
                    parentCategories: parentCategories,
                    childCategories: childCategories,
                    onParentCategoryChanged: (value) {
                      setState(() {
                        _selectedParentCategoryId = value;
                        _selectedChildCategoryId = null; // Reset child when parent changes
                      });
                    },
                    onChildCategoryChanged: (value) {
                      setState(() {
                        _selectedChildCategoryId = value;
                      });
                    },
                    onStatusChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    selectedImageFile: _selectedImageFile,
                    imageUrl: _imageUrl,
                    onPickImage: _pickImage,
                    isLoading: _isLoading,
                    isUploading: _isUploading,
                    onSubmit: _handleSubmit,
                    versions: _versions,
                    colors: _colors,
                    options: _options,
                    versionController: _versionController,
                    colorNameController: _colorNameController,
                    colorHexController: _colorHexController,
                    selectedVersionForOption: _selectedVersionForOption,
                    selectedColorForOption: _selectedColorForOption,
                    optionOriginalPriceController: _optionOriginalPriceController,
                    optionDiscountController: _optionDiscountController,
                    optionQuantityController: _optionQuantityController,
                    basePrice: int.tryParse(_priceController.text.trim()) ?? 0,
                    onVersionChanged: (value) {
                      setState(() {
                        _selectedVersionForOption = value;
                      });
                    },
                    onColorChanged: (value) {
                      setState(() {
                        _selectedColorForOption = value;
                      });
                    },
                    onAddVersion: _addVersion,
                    onRemoveVersion: _removeVersion,
                    onAddColor: _addColor,
                    onRemoveColor: _removeColor,
                    onAddOption: _addOption,
                    onRemoveOption: _removeOption,
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Basic info
                      Expanded(
                        flex: 2,
                        child: BasicInfoSection(
                          nameController: _nameController,
                          priceController: _priceController,
                          originalPriceController: _originalPriceController,
                          quantityController: _quantityController,
                          selectedParentCategoryId: _selectedParentCategoryId,
                          selectedChildCategoryId: _selectedChildCategoryId,
                          selectedStatus: _selectedStatus,
                          parentCategories: parentCategories,
                          childCategories: childCategories,
                          onParentCategoryChanged: (value) {
                            setState(() {
                              _selectedParentCategoryId = value;
                              _selectedChildCategoryId = null;
                            });
                          },
                          onChildCategoryChanged: (value) {
                            setState(() {
                              _selectedChildCategoryId = value;
                            });
                          },
                          onStatusChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                          isTablet: isTablet,
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right column - Image and Description
                      Expanded(
                        flex: 1,
                        child: ImageAndDescriptionSection(
                          selectedImageFile: _selectedImageFile,
                          imageUrl: _imageUrl,
                          onPickImage: _pickImage,
                          descriptionController: _descriptionController,
                          isUploading: _isUploading,
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                // Product Options Section
                ProductOptionsSection(
                  versions: _versions,
                  colors: _colors,
                  options: _options,
                  versionController: _versionController,
                  colorNameController: _colorNameController,
                  colorHexController: _colorHexController,
                  selectedVersionForOption: _selectedVersionForOption,
                  selectedColorForOption: _selectedColorForOption,
                  optionOriginalPriceController: _optionOriginalPriceController,
                  optionDiscountController: _optionDiscountController,
                  optionQuantityController: _optionQuantityController,
                  basePrice: int.tryParse(_priceController.text.trim()) ?? 0,
                  onVersionChanged: (value) {
                    setState(() {
                      _selectedVersionForOption = value;
                    });
                  },
                  onColorChanged: (value) {
                    setState(() {
                      _selectedColorForOption = value;
                    });
                  },
                  onAddVersion: _addVersion,
                  onRemoveVersion: _removeVersion,
                  onAddColor: _addColor,
                  onRemoveColor: _removeColor,
                  onAddOption: _addOption,
                  onRemoveOption: _removeOption,
                  isTablet: isTablet,
                  isMobile: false,
                ),
                const SizedBox(height: 24),
                // Action buttons
                ActionButtons(
                  isLoading: _isLoading,
                  onSubmit: _handleSubmit,
                  onCancel: () => context.go('/admin/products'),
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
