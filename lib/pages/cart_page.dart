import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../widgets/footer.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../models/cart_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartService = CartService();
  final _authService = AuthService();
  final _productService = ProductService();
  bool _isCheckingStock = false;

  @override
  void initState() {
    super.initState();
    // Check stock when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStockAvailability();
    });
  }

  // Kiểm tra xem có item nào hết hàng không
  Future<bool> _hasOutOfStockItems(List<CartItemModel> items) async {
    for (final item in items) {
      final availableQuantity = await _getAvailableQuantity(item);
      if (availableQuantity == 0) {
        return true;
      }
    }
    return false;
  }

  // Kiểm tra số lượng available của cart item
  Future<int> _getAvailableQuantity(CartItemModel item) async {
    try {
      final product = await _productService.getProductById(item.productId);
      if (product == null) return 0;

      // Nếu có option (version hoặc color)
      if (item.selectedVersion != null || item.selectedColor != null) {
        if (product.options != null && product.options!.isNotEmpty) {
          // Tìm option tương ứng
          final option = product.options!.firstWhere(
            (opt) =>
                opt['version'] == item.selectedVersion &&
                opt['colorName'] == item.selectedColor,
            orElse: () => {},
          );
          if (option.isNotEmpty) {
            return option['quantity'] as int? ?? 0;
          }
        }
        return 0;
      }

      // Nếu không có option, dùng số lượng chính
      return product.actualQuantity;
    } catch (e) {
      return 0;
    }
  }

  // Kiểm tra và cập nhật số lượng cart items (chỉ cập nhật số lượng vượt quá, không tự động xóa)
  Future<void> _checkStockAvailability() async {
    if (_isCheckingStock) return;

    setState(() {
      _isCheckingStock = true;
    });

    try {
      final cartItems = await _cartService.getCartItemsOnce();
      List<Map<String, dynamic>> itemsToUpdate = [];

      for (final item in cartItems) {
        final availableQuantity = await _getAvailableQuantity(item);

        // Chỉ cập nhật số lượng nếu vượt quá, không tự động xóa item hết hàng
        if (availableQuantity > 0 && item.quantity > availableQuantity) {
          // Số lượng trong giỏ hàng vượt quá số lượng có sẵn, cập nhật về số lượng có sẵn
          itemsToUpdate.add({
            'id': item.id,
            'quantity': availableQuantity,
          });
        }
      }

      // Cập nhật số lượng
      for (final update in itemsToUpdate) {
        await _cartService.updateQuantity(update['id'], update['quantity']);
      }

      // Hiển thị thông báo nếu có thay đổi
      if (mounted && itemsToUpdate.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật số lượng ${itemsToUpdate.length} sản phẩm.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi kiểm tra số lượng: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStock = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (!_authService.isLoggedIn) {
      return SingleChildScrollView(
        child: ResponsiveConstraints(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vui lòng đăng nhập để xem giỏ hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Đăng nhập'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return StreamBuilder<List<CartItemModel>>(
      stream: _cartService.getCartItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
              ],
            ),
          );
        }

        final cartItems = snapshot.data ?? [];
        final total = cartItems.fold<int>(
          0,
          (sum, item) => sum + item.totalPrice,
        );
        
        // Kiểm tra xem có item nào hết hàng không (async check sẽ được thực hiện trong FutureBuilder của từng item)

        return SingleChildScrollView(
          child: ResponsiveConstraints(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giỏ hàng',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      if (cartItems.isEmpty)
                    SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Giỏ hàng của bạn đang trống',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (ResponsiveBreakpoints.of(context).isMobile) {
                          // Mobile layout
                          return Column(
                            children: [
                              ListView.builder(
                                itemCount: cartItems.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return FutureBuilder<int>(
                                    future: _getAvailableQuantity(item),
                                    builder: (context, stockSnapshot) {
                                      final availableQuantity = stockSnapshot.data ?? 0;
                                      final isOutOfStock = availableQuantity == 0;
                                      final isQuantityExceeded = item.quantity > availableQuantity;
                                      
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        color: isOutOfStock ? Colors.red[50] : (isQuantityExceeded ? Colors.orange[50] : null),
                                        elevation: isOutOfStock ? 4 : 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: isOutOfStock
                                              ? BorderSide(color: Colors.red[300]!, width: 2)
                                              : (isQuantityExceeded
                                                  ? BorderSide(color: Colors.orange[300]!, width: 1)
                                                  : BorderSide.none),
                                        ),
                                        child: ListTile(
                                      leading: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: item.imageUrl != null
                                              ? CachedNetworkImage(
                                                  imageUrl: item.imageUrl!,
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
                                                    color: Colors.grey[400],
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.image,
                                                  color: Colors.grey[400],
                                                ),
                                        ),
                                      ),
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.productName),
                                          if (item.selectedVersion != null || item.selectedColor != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              [
                                                if (item.selectedVersion != null) item.selectedVersion,
                                                if (item.selectedColor != null) item.selectedColor,
                                              ].join(' - '),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_formatPrice(item.price)} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          if (item.originalPrice > item.price) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_formatPrice(item.originalPrice)} đ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          // Cảnh báo số lượng
                                          if (isOutOfStock) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.warning, size: 14, color: Colors.red[700]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Hết hàng',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red[700],
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else if (isQuantityExceeded) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[100],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.info_outline, size: 14, color: Colors.orange[700]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Chỉ còn $availableQuantity sản phẩm',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.orange[700],
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: isOutOfStock ? null : () {
                                              _updateQuantity(item.id, item.quantity - 1);
                                            },
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              color: isOutOfStock ? Colors.red[700] : null,
                                              fontWeight: isQuantityExceeded ? FontWeight.bold : null,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: (isOutOfStock || item.quantity >= availableQuantity) ? null : () {
                                              _updateQuantity(item.id, item.quantity + 1);
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: isOutOfStock ? Colors.red[700] : null,
                                            ),
                                            onPressed: () {
                                              _removeItem(item.id);
                                            },
                                            tooltip: 'Xóa sản phẩm',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tổng thanh toán',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Tạm tính:'),
                                          Text('${_formatPrice(total)} đ'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Phí vận chuyển:'),
                                          Text('Miễn phí'),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tổng cộng:',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            '${_formatPrice(total)} đ',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      FutureBuilder<bool>(
                                        future: _hasOutOfStockItems(cartItems),
                                        builder: (context, stockCheckSnapshot) {
                                          final hasOutOfStock = stockCheckSnapshot.data ?? false;
                                          final canCheckout = !cartItems.isEmpty && !hasOutOfStock;
                                          
                                          return SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: canCheckout
                                                  ? () {
                                                      context.push('/checkout');
                                                    }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: hasOutOfStock ? Colors.grey : null,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Text(
                                                  hasOutOfStock
                                                      ? 'Có sản phẩm hết hàng'
                                                      : 'Tiến hành thanh toán',
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Desktop layout
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListView.builder(
                                  itemCount: cartItems.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    return FutureBuilder<int>(
                                      future: _getAvailableQuantity(item),
                                      builder: (context, stockSnapshot) {
                                        final availableQuantity = stockSnapshot.data ?? 0;
                                        final isOutOfStock = availableQuantity == 0;
                                        final isQuantityExceeded = item.quantity > availableQuantity;
                                        
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          color: isOutOfStock ? Colors.red[50] : (isQuantityExceeded ? Colors.orange[50] : null),
                                          elevation: isOutOfStock ? 4 : 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: isOutOfStock
                                                ? BorderSide(color: Colors.red[300]!, width: 2)
                                                : (isQuantityExceeded
                                                    ? BorderSide(color: Colors.orange[300]!, width: 1)
                                                    : BorderSide.none),
                                          ),
                                          child: ListTile(
                                        leading: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: item.imageUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: item.imageUrl!,
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
                                                      color: Colors.grey[400],
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.image,
                                                    color: Colors.grey[400],
                                                  ),
                                          ),
                                        ),
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.productName),
                                            if (item.selectedVersion != null || item.selectedColor != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                [
                                                  if (item.selectedVersion != null) item.selectedVersion,
                                                  if (item.selectedColor != null) item.selectedColor,
                                                ].join(' - '),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_formatPrice(item.price)} đ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            if (item.originalPrice > item.price) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_formatPrice(item.originalPrice)} đ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                            // Cảnh báo số lượng
                                            if (isOutOfStock) ...[
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.warning, size: 14, color: Colors.red[700]),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Hết hàng',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.red[700],
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ] else if (isQuantityExceeded) ...[
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.info_outline, size: 14, color: Colors.orange[700]),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Chỉ còn $availableQuantity sản phẩm',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.orange[700],
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline),
                                              onPressed: isOutOfStock ? null : () {
                                                _updateQuantity(item.id, item.quantity - 1);
                                              },
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                color: isOutOfStock ? Colors.red[700] : null,
                                                fontWeight: isQuantityExceeded ? FontWeight.bold : null,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline),
                                              onPressed: (isOutOfStock || item.quantity >= availableQuantity) ? null : () {
                                                _updateQuantity(item.id, item.quantity + 1);
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline),
                                              onPressed: () {
                                                _removeItem(item.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 300,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tổng thanh toán',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Tạm tính:'),
                                            Text('${_formatPrice(total)} đ'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Phí vận chuyển:'),
                                            Text('Miễn phí'),
                                          ],
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Tổng cộng:',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              '${_formatPrice(total)} đ',
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        FutureBuilder<bool>(
                                          future: _hasOutOfStockItems(cartItems),
                                          builder: (context, stockCheckSnapshot) {
                                            final hasOutOfStock = stockCheckSnapshot.data ?? false;
                                            final canCheckout = !cartItems.isEmpty && !hasOutOfStock;
                                            
                                            return SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: canCheckout
                                                    ? () {
                                                        context.push('/checkout');
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: hasOutOfStock ? Colors.grey : null,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Text(
                                                    hasOutOfStock
                                                        ? 'Có sản phẩm hết hàng'
                                                        : 'Tiến hành thanh toán',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
                const Footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    try {
      // Lấy cart item để kiểm tra số lượng available
      final cartItems = await _cartService.getCartItemsOnce();
      final item = cartItems.firstWhere((item) => item.id == itemId);
      final availableQuantity = await _getAvailableQuantity(item);
      
      // Kiểm tra số lượng available
      if (availableQuantity == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sản phẩm đã hết hàng'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        // Xóa item khỏi giỏ hàng
        await _cartService.removeFromCart(itemId);
        return;
      }
      
      // Giới hạn số lượng không vượt quá số lượng có sẵn
      final finalQuantity = newQuantity.clamp(1, availableQuantity);
      
      if (finalQuantity != newQuantity) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chỉ còn $availableQuantity sản phẩm. Đã cập nhật số lượng.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      
      await _cartService.updateQuantity(itemId, finalQuantity);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _cartService.removeFromCart(itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
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
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

