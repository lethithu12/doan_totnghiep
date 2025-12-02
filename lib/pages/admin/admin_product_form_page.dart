import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/image_service.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../widgets/admin/admin_products/product_options_section.dart';
import '../../widgets/admin/admin_products/product_specifications_section.dart';
import '../../widgets/admin/admin_products/product_info_tab.dart';
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

class _AdminProductFormPageState extends State<AdminProductFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _imageService = ImageService();
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedParentCategoryId;
  String? _selectedChildCategoryId;
  String? _selectedStatus = 'Còn hàng';
  final List<PlatformFile> _selectedImageFiles = [];
  final List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;
  ProductModel? _existingProduct;

  // Versions and Colors
  final List<String> _versions = [];
  final List<Map<String, dynamic>> _colors = [];
  final List<Map<String, dynamic>> _options = [];
  
  // Specifications
  final List<Map<String, String>> _specifications = [];
  final TextEditingController _specLabelController = TextEditingController();
  final TextEditingController _specValueController = TextEditingController();

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
    _tabController = TabController(length: 3, vsync: this);
    // Add listener to quantity controller to trigger validation when quantity changes
    _quantityController.addListener(_validateQuantity);
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  void _validateQuantity() {
    // Trigger validation for quantity field when it changes
    // This ensures validation runs when quantity or options change
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
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
          // Load images
          _imageUrls.clear();
          if (product.imageUrl != null) {
            _imageUrls.add(product.imageUrl!);
          }
          if (product.imageUrls != null) {
            _imageUrls.addAll(product.imageUrls!);
          }
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
          // Load specifications
          _specifications.clear();
          if (product.specifications != null) {
            _specifications.addAll(product.specifications!);
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

  Future<void> _pickImages() async {
    try {
      final platformFiles = await _imageService.pickMultipleImages();
      if (platformFiles.isNotEmpty) {
        setState(() {
          _selectedImageFiles.addAll(platformFiles);
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

  void _removeImage(int index) {
    setState(() {
      if (index < _selectedImageFiles.length) {
        _selectedImageFiles.removeAt(index);
      } else {
        final urlIndex = index - _selectedImageFiles.length;
        _imageUrls.removeAt(urlIndex);
      }
    });
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
    _specLabelController.dispose();
    _specValueController.dispose();
    _tabController.dispose();
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
    // Trigger validation after adding option
    _validateQuantity();
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
    // Trigger validation after removing option
    _validateQuantity();
  }

  void _addSpecification() {
    final label = _specLabelController.text.trim();
    final value = _specValueController.text.trim();
    if (label.isEmpty || value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tên và giá trị thông số'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _specifications.add({'label': label, 'value': value});
      _specLabelController.clear();
      _specValueController.clear();
    });
  }

  void _removeSpecification(int index) {
    setState(() {
      _specifications.removeAt(index);
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

    // Validate quantity vs total options quantity
    final quantityText = _quantityController.text.trim();
    if (quantityText.isNotEmpty) {
      final quantity = int.tryParse(quantityText);
      if (quantity != null && _options.isNotEmpty) {
        final totalOptionsQuantity = _options.fold<int>(
          0,
          (sum, option) => sum + (option['quantity'] as int? ?? 0),
        );
        if (totalOptionsQuantity > quantity) {
          // Switch to tab 0 (Thông tin) to show the error
          _tabController.animateTo(0);
          // Wait a bit for tab animation, then trigger validation
          await Future.delayed(const Duration(milliseconds: 300));
          // Trigger validation again to show the error
          if (mounted && _formKey.currentState != null) {
            _formKey.currentState!.validate();
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tổng số lượng options ($totalOptionsQuantity) không được lớn hơn số lượng ($quantity). Vui lòng kiểm tra lại.',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
    });

    try {
      // Upload all selected images
      final List<String> uploadedImageUrls = [];
      
      // Upload new files
      for (final file in _selectedImageFiles) {
        final url = await _imageService.uploadImage(
          platformFile: file,
          folder: 'products',
        );
        uploadedImageUrls.add(url);
      }
      
      // Combine with existing URLs
      uploadedImageUrls.addAll(_imageUrls);
      
      // First image is main image, rest are additional images
      final String? finalImageUrl = uploadedImageUrls.isNotEmpty ? uploadedImageUrls.first : null;
      final List<String>? finalImageUrls = uploadedImageUrls.length > 1 
          ? uploadedImageUrls.sublist(1) 
          : null;

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
        imageUrls: finalImageUrls,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rating: _existingProduct?.rating ?? 0.0,
        sold: _existingProduct?.sold ?? 0,
        versions: _versions.isEmpty ? null : _versions,
        colors: _colors.isEmpty ? null : _colors,
        options: _options.isEmpty ? null : _options,
        specifications: _specifications.isEmpty ? null : _specifications,
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

        return Scaffold(
          body: Column(
            children: [
              // Header - Fixed at top
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
                child: Row(
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
              ),
              // Tab Bar - Fixed below header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : (isTablet ? 24 : 32)),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Thông tin'),
                    Tab(text: 'Option'),
                    Tab(text: 'Thông số'),
                  ],
                ),
              ),
              // Tab Bar View - Scrollable content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Thông tin
                      SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
                        child: Column(
                          children: [
                            ProductInfoTab(
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
                              selectedImageFiles: _selectedImageFiles,
                              imageUrls: _imageUrls,
                              onPickImages: _pickImages,
                              onRemoveImage: _removeImage,
                              options: _options,
                              isUploading: _isUploading,
                              isTablet: isTablet,
                              isMobile: isMobile,
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            ActionButtons(
                              isLoading: _isLoading,
                              onSubmit: _handleSubmit,
                              onCancel: () => context.go('/admin/products'),
                              isMobile: isMobile,
                            ),
                            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                          ],
                        ),
                      ),
                      // Tab 2: Option
                      SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
                        child: Column(
                          children: [
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
                              isMobile: isMobile,
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            ActionButtons(
                              isLoading: _isLoading,
                              onSubmit: _handleSubmit,
                              onCancel: () => context.go('/admin/products'),
                              isMobile: isMobile,
                            ),
                            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                          ],
                        ),
                      ),
                      // Tab 3: Thông số
                      SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
                        child: Column(
                          children: [
                            ProductSpecificationsSection(
                              specifications: _specifications,
                              labelController: _specLabelController,
                              valueController: _specValueController,
                              onAddSpecification: _addSpecification,
                              onRemoveSpecification: _removeSpecification,
                              isTablet: isTablet,
                              isMobile: isMobile,
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            ActionButtons(
                              isLoading: _isLoading,
                              onSubmit: _handleSubmit,
                              onCancel: () => context.go('/admin/products'),
                              isMobile: isMobile,
                            ),
                            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
