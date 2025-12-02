import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../widgets/footer.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../config/colors.dart';
import '../widgets/pages/product_detail/product_description.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _productService = ProductService();
  final _cartService = CartService();
  final _authService = AuthService();
  ProductModel? _product;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String? _error;
  int selectedImageIndex = 0;
  String? selectedVersion;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final product = await _productService.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
          if (product == null) {
            _error = 'Không tìm thấy sản phẩm';
          } else {
            // Auto-select first version if available
            if (product.versions != null && product.versions!.isNotEmpty) {
              selectedVersion = product.versions!.first;
            }
            // Auto-select first color if available
            if (product.colors != null && product.colors!.isNotEmpty) {
              selectedColor = product.colors!.first['name'] as String;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
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

  int _getCurrentPrice(ProductModel product) {
    // If no version or color selected, return base price
    if (selectedVersion == null || selectedColor == null) {
      return product.price;
    }

    // Find matching option
    if (product.options != null) {
      for (final option in product.options!) {
        if (option['version'] == selectedVersion && 
            option['colorName'] == selectedColor) {
          final originalPrice = option['originalPrice'] as int;
          final discount = option['discount'] as int;
          return originalPrice - (originalPrice * discount ~/ 100);
        }
      }
    }

    // If no matching option found, return base price
    return product.price;
  }

  int _getCurrentOriginalPrice(ProductModel product) {
    // If no version or color selected, return base original price
    if (selectedVersion == null || selectedColor == null) {
      return product.originalPrice;
    }

    // Find matching option
    if (product.options != null) {
      for (final option in product.options!) {
        if (option['version'] == selectedVersion && 
            option['colorName'] == selectedColor) {
          return option['originalPrice'] as int;
        }
      }
    }

    // If no matching option found, return base original price
    return product.originalPrice;
  }

  List<String> _getProductImages(ProductModel product) {
    final images = <String>[];
    if (product.imageUrl != null) {
      images.add(product.imageUrl!);
    }
    if (product.imageUrls != null) {
      images.addAll(product.imageUrls!);
    }
    return images;
  }

  Future<void> _handleAddToCart() async {
    // Check if user is logged in
    if (!_authService.isLoggedIn) {
      if (mounted) {
        context.push('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (_product == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final product = _product!;
      final productImages = _getProductImages(product);
      final currentPrice = _getCurrentPrice(product);
      final currentOriginalPrice = _getCurrentOriginalPrice(product);

      final cartItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        imageUrl: productImages.isNotEmpty ? productImages.first : null,
        price: currentPrice,
        originalPrice: currentOriginalPrice,
        quantity: 1,
        selectedVersion: selectedVersion,
        selectedColor: selectedColor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _cartService.addToCart(cartItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm vào giỏ hàng'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _handleBuyNow() async {
    // Check if user is logged in
    if (!_authService.isLoggedIn) {
      if (mounted) {
        context.push('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để mua hàng'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (_product == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final product = _product!;
      final productImages = _getProductImages(product);
      final currentPrice = _getCurrentPrice(product);
      final currentOriginalPrice = _getCurrentOriginalPrice(product);

      // Tạo cart item (không thêm vào cart, chỉ dùng để checkout)
      final cartItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        imageUrl: productImages.isNotEmpty ? productImages.first : null,
        price: currentPrice,
        originalPrice: currentOriginalPrice,
        quantity: 1,
        selectedVersion: selectedVersion,
        selectedColor: selectedColor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Thêm vào cart để có id (cần id để xóa sau khi đặt hàng)
      await _cartService.addToCart(cartItem);
      
      // Lấy lại item vừa thêm để có id
      final cartItems = await _cartService.getCartItemsOnce();
      final addedItem = cartItems.firstWhere(
        (item) => item.productId == product.id &&
            item.selectedVersion == selectedVersion &&
            item.selectedColor == selectedColor,
        orElse: () => cartItem,
      );

      // Điều hướng đến trang checkout với item cụ thể
      if (mounted) {
        context.go('/checkout', extra: [addedItem]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Responsive values
    final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final imageHeight = isMobile ? 300.0 : (isTablet ? 400.0 : 500.0);
    final imageIconSize = isMobile ? 80.0 : (isTablet ? 100.0 : 120.0);
    final thumbnailSize = isMobile ? 80.0 : (isTablet ? 90.0 : 100.0);
    final thumbnailHeight = isMobile ? 80.0 : (isTablet ? 90.0 : 100.0);
    final thumbnailIconSize = isMobile ? 30.0 : (isTablet ? 35.0 : 40.0);

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.headerBackground.withOpacity(0.03),
                Colors.white,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.headerBackground.withOpacity(0.03),
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lỗi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? "Không tìm thấy sản phẩm",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.headerBackground,
                          AppColors.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.headerBackground.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Quay lại',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final product = _product!;
    final productImages = _getProductImages(product);
    final versions = product.versions ?? [];
    final colors = product.colors ?? [];
    final currentPrice = _getCurrentPrice(product);
    final currentOriginalPrice = _getCurrentOriginalPrice(product);
    final discount = currentOriginalPrice > currentPrice
        ? ((currentOriginalPrice - currentPrice) / currentOriginalPrice * 100).round()
        : 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          ResponsiveConstraints(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ảnh chính và list ảnh
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ảnh chính
                            Container(
                              width: double.infinity,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: productImages.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: productImages[selectedImageIndex],
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.image,
                                          size: imageIconSize,
                                          color: Colors.grey[400],
                                        ),
                                      )
                                    : Icon(
                                        Icons.image,
                                        size: imageIconSize,
                                        color: Colors.grey[400],
                                      ),
                              ),
                            ),
                            SizedBox(height: 12),
                            // List ảnh nhỏ
                            SizedBox(
                              height: thumbnailHeight,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productImages.length,
                                itemBuilder: (context, index) {
                                  final isSelected = index == selectedImageIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImageIndex = index;
                                      });
                                    },
                                    child: Container(
                                      width: thumbnailSize,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: productImages[index],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.image,
                                            size: thumbnailIconSize,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Thông tin sản phẩm
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên sản phẩm
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            // Giá
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatPrice(currentPrice)} đ',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                ),
                                if (discount > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${_formatPrice(currentOriginalPrice)} đ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.red[600]!,
                                              Colors.red[700]!,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '-$discount%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          
                            const SizedBox(height: 24),
                            // Phiên bản
                            if (versions.isNotEmpty) ...[
                              Text(
                                'Phiên bản',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: versions.map((version) {
                                  final isSelected = selectedVersion == version;
                                  // Check if this version has any available option with selected color
                                  bool isAvailable = true;
                                  if (selectedColor != null && product.options != null) {
                                    isAvailable = product.options!.any((opt) {
                                      return opt['version'] == version &&
                                          opt['colorName'] == selectedColor &&
                                          (opt['quantity'] as int? ?? 0) > 0;
                                    });
                                  } else if (product.options != null) {
                                    // If no color selected, check if version has any available option
                                    isAvailable = product.options!.any((opt) {
                                      return opt['version'] == version &&
                                          (opt['quantity'] as int? ?? 0) > 0;
                                    });
                                  }
                                  
                                  return ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          version,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isAvailable ? null : Colors.grey[400],
                                          ),
                                        ),
                                        if (!isAvailable) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '(Hết hàng)',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    selected: isSelected && isAvailable,
                                    onSelected: isAvailable
                                        ? (selected) {
                                            setState(() {
                                              selectedVersion = selected ? version : null;
                                            });
                                          }
                                        : null,
                                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                    disabledColor: Colors.grey[200],
                                    backgroundColor: isAvailable ? Colors.grey[50] : Colors.grey[100],
                                    labelStyle: TextStyle(
                                      color: isSelected && isAvailable
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : (isAvailable ? null : Colors.grey[400]),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isSelected && isAvailable
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey[300]!,
                                        width: isSelected && isAvailable ? 2 : 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Màu sắc
                            if (colors.isNotEmpty) ...[
                              Text(
                                'Màu sắc',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: colors.map((colorData) {
                                  final colorName = colorData['name'] as String;
                                  final colorHex = colorData['hex'] as String;
                                  final isSelected = selectedColor == colorName;
                                  // Check if this color has any available option with selected version
                                  bool isAvailable = true;
                                  if (selectedVersion != null && product.options != null) {
                                    isAvailable = product.options!.any((opt) {
                                      return opt['colorName'] == colorName &&
                                          opt['version'] == selectedVersion &&
                                          (opt['quantity'] as int? ?? 0) > 0;
                                    });
                                  } else if (product.options != null) {
                                    // If no version selected, check if color has any available option
                                    isAvailable = product.options!.any((opt) {
                                      return opt['colorName'] == colorName &&
                                          (opt['quantity'] as int? ?? 0) > 0;
                                    });
                                  }
                                  
                                  return ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: _hexToColor(colorHex),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected && isAvailable
                                                  ? Theme.of(context).colorScheme.primary
                                                  : (isAvailable ? Colors.grey : Colors.grey[300]!),
                                              width: isSelected && isAvailable ? 2 : 1,
                                            ),
                                            boxShadow: isSelected && isAvailable
                                                ? [
                                                    BoxShadow(
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          colorName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isAvailable ? null : Colors.grey[400],
                                          ),
                                        ),
                                        if (!isAvailable) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '(Hết hàng)',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    selected: isSelected && isAvailable,
                                    onSelected: isAvailable
                                        ? (selected) {
                                            setState(() {
                                              selectedColor = selected ? colorName : null;
                                            });
                                          }
                                        : null,
                                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                    disabledColor: Colors.grey[200],
                                    backgroundColor: isAvailable ? Colors.grey[50] : Colors.grey[100],
                                    labelStyle: TextStyle(
                                      color: isSelected && isAvailable
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : (isAvailable ? null : Colors.grey[400]),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isSelected && isAvailable
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey[300]!,
                                        width: isSelected && isAvailable ? 2 : 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                            const SizedBox(height: 24),
                            // Kiểm tra hết hàng
                            if (_product?.calculatedStatus == 'Hết hàng')
                              // Nút HẾT HÀNG
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: null, // Disabled
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    backgroundColor: Colors.red,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.block, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'HẾT HÀNG',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              // Nút Mua ngay
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.headerBackground,
                                      AppColors.primaryLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.headerBackground.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isAddingToCart ? null : _handleBuyNow,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isAddingToCart
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Mua ngay',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Nút Thêm vào giỏ hàng
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isAddingToCart ? null : _handleAddToCart,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isAddingToCart
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_shopping_cart,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Thêm vào giỏ hàng',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    )
                  : ResponsiveRowColumn(
                      layout: ResponsiveRowColumnType.ROW,
                      children: [
                        // Bên trái: Ảnh chính và list ảnh
                        ResponsiveRowColumnItem(
                          child: Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: isTablet ? 16 : 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ảnh chính
                                  Container(
                                    width: double.infinity,
                                    height: imageHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: productImages.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: productImages[selectedImageIndex],
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Icon(
                                                Icons.image,
                                                size: imageIconSize,
                                                color: Colors.grey[400],
                                              ),
                                            )
                                          : Icon(
                                              Icons.image,
                                              size: imageIconSize,
                                              color: Colors.grey[400],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // List ảnh nhỏ
                                  SizedBox(
                                    height: thumbnailHeight,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: productImages.length,
                                      itemBuilder: (context, index) {
                                        final isSelected = index == selectedImageIndex;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedImageIndex = index;
                                            });
                                          },
                                          child: Container(
                                            width: thumbnailSize,
                                            margin: const EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Colors.transparent,
                                                width: 3,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: productImages[index],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => Icon(
                                                  Icons.image,
                                                  size: thumbnailIconSize,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Bên phải: Thông tin sản phẩm
                        ResponsiveRowColumnItem(
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên sản phẩm
                                Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 22 : 24,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                // Giá
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_formatPrice(currentPrice)} đ',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isTablet ? 26 : 28,
                                          ),
                                    ),
                                    if (discount > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${_formatPrice(currentOriginalPrice)} đ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.red[600]!,
                                                  Colors.red[700]!,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              '-$discount%',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Phiên bản
                                if (versions.isNotEmpty) ...[
                                  Text(
                                    'Phiên bản',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: versions.map((version) {
                                      final isSelected = selectedVersion == version;
                                      // Check if this version has any available option with selected color
                                      bool isAvailable = true;
                                      if (selectedColor != null && product.options != null) {
                                        isAvailable = product.options!.any((opt) {
                                          return opt['version'] == version &&
                                              opt['colorName'] == selectedColor &&
                                              (opt['quantity'] as int? ?? 0) > 0;
                                        });
                                      } else if (product.options != null) {
                                        // If no color selected, check if version has any available option
                                        isAvailable = product.options!.any((opt) {
                                          return opt['version'] == version &&
                                              (opt['quantity'] as int? ?? 0) > 0;
                                        });
                                      }
                                      
                                      return ChoiceChip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              version,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                color: isAvailable ? null : Colors.grey[400],
                                              ),
                                            ),
                                            if (!isAvailable) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '(Hết hàng)',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        selected: isSelected && isAvailable,
                                        onSelected: isAvailable
                                            ? (selected) {
                                                setState(() {
                                                  selectedVersion = selected ? version : null;
                                                });
                                              }
                                            : null,
                                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                        disabledColor: Colors.grey[200],
                                        backgroundColor: isAvailable ? Colors.grey[50] : Colors.grey[100],
                                        labelStyle: TextStyle(
                                          color: isSelected && isAvailable
                                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                              : (isAvailable ? null : Colors.grey[400]),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: isSelected && isAvailable
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.grey[300]!,
                                            width: isSelected && isAvailable ? 2 : 1,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                // Màu sắc
                                if (colors.isNotEmpty) ...[
                                  Text(
                                    'Màu sắc',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: colors.map((colorData) {
                                      final colorName = colorData['name'] as String;
                                      final colorHex = colorData['hex'] as String;
                                      final isSelected = selectedColor == colorName;
                                      // Check if this color has any available option with selected version
                                      bool isAvailable = true;
                                      if (selectedVersion != null && product.options != null) {
                                        isAvailable = product.options!.any((opt) {
                                          return opt['colorName'] == colorName &&
                                              opt['version'] == selectedVersion &&
                                              (opt['quantity'] as int? ?? 0) > 0;
                                        });
                                      } else if (product.options != null) {
                                        // If no version selected, check if color has any available option
                                        isAvailable = product.options!.any((opt) {
                                          return opt['colorName'] == colorName &&
                                              (opt['quantity'] as int? ?? 0) > 0;
                                        });
                                      }
                                      
                                      return ChoiceChip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: _hexToColor(colorHex),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected && isAvailable
                                                      ? Theme.of(context).colorScheme.primary
                                                      : (isAvailable ? Colors.grey : Colors.grey[300]!),
                                                  width: isSelected && isAvailable ? 2 : 1,
                                                ),
                                                boxShadow: isSelected && isAvailable
                                                    ? [
                                                        BoxShadow(
                                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              colorName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                color: isAvailable ? null : Colors.grey[400],
                                              ),
                                            ),
                                            if (!isAvailable) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '(Hết hàng)',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        selected: isSelected && isAvailable,
                                        onSelected: isAvailable
                                            ? (selected) {
                                                setState(() {
                                                  selectedColor = selected ? colorName : null;
                                                });
                                              }
                                            : null,
                                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                        disabledColor: Colors.grey[200],
                                        backgroundColor: isAvailable ? Colors.grey[50] : Colors.grey[100],
                                        labelStyle: TextStyle(
                                          color: isSelected && isAvailable
                                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                              : (isAvailable ? null : Colors.grey[400]),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: isSelected && isAvailable
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.grey[300]!,
                                            width: isSelected && isAvailable ? 2 : 1,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                                const SizedBox(height: 32),
                                // Kiểm tra hết hàng
                                if (_product?.calculatedStatus == 'Hết hàng')
                                  // Nút HẾT HÀNG
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: null, // Disabled
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(16),
                                        backgroundColor: Colors.red,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.block, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'HẾT HÀNG',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else ...[
                                  // Nút Mua ngay
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.headerBackground,
                                          AppColors.primaryLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.headerBackground.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isAddingToCart ? null : _handleBuyNow,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(16),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isAddingToCart
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Mua ngay',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Nút Thêm vào giỏ hàng
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: _isAddingToCart ? null : _handleAddToCart,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.all(16),
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isAddingToCart
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_shopping_cart,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Thêm vào giỏ hàng',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Phần mô tả chi tiết sản phẩm
          ProductDescription(
            productId: widget.productId,
            product: product,
          ),
          const Footer(),
        ],
      ),
    );
  }
}

