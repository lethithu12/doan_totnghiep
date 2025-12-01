import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/payment_method.dart';
import '../../../../services/cart_service.dart';
import '../../../../services/order_service.dart';
import '../../../../models/cart_model.dart';
import 'recipient_info_section.dart';
import 'order_summary_section.dart';
import 'payment_method_display.dart';
import 'order_success_dialog.dart';

class ConfirmationStep extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onOrderPlaced; // Callback khi đặt hàng thành công
  final String? fullName;
  final String? phone;
  final String? address;
  final String? notes;
  final PaymentMethod? paymentMethod;
  final List<CartItemModel>? specificItems; // Items cụ thể để checkout (nếu null thì lấy tất cả từ cart)

  const ConfirmationStep({
    super.key,
    required this.onBack,
    this.onOrderPlaced,
    this.fullName,
    this.phone,
    this.address,
    this.notes,
    this.paymentMethod,
    this.specificItems,
  });

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  final _cartService = CartService();
  final _orderService = OrderService();
  bool _isPlacingOrder = false;

  Future<void> _handlePlaceOrder() async {
    if (widget.fullName == null ||
        widget.phone == null ||
        widget.address == null ||
        widget.paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Lấy cart items - nếu có specificItems thì dùng nó, không thì lấy tất cả từ cart
      final List<CartItemModel> cartItems;
      if (widget.specificItems != null && widget.specificItems!.isNotEmpty) {
        cartItems = widget.specificItems!;
      } else {
        cartItems = await _cartService.getCartItemsOnce();
      }
      
      if (cartItems.isEmpty) {
        throw 'Giỏ hàng trống';
      }

      // Tính toán tổng tiền
      final subtotal = cartItems.fold<int>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      const shippingFee = 30000; // Phí vận chuyển cố định

      // Convert cart items to map
      final itemsMap = cartItems.map((item) => item.toMap()).toList();

      // Tạo đơn hàng
      final order = await _orderService.createOrder(
        fullName: widget.fullName!,
        phone: widget.phone!,
        address: widget.address!,
        notes: widget.notes,
        paymentMethod: widget.paymentMethod!,
        items: itemsMap,
        subtotal: subtotal,
        shippingFee: shippingFee,
      );

      // Xóa items khỏi giỏ hàng
      if (widget.specificItems != null && widget.specificItems!.isNotEmpty) {
        // Chỉ xóa các items cụ thể (có id)
        for (final item in widget.specificItems!) {
          if (item.id.isNotEmpty) {
            await _cartService.removeFromCart(item.id);
          }
        }
      } else {
        // Xóa toàn bộ giỏ hàng (trường hợp checkout từ cart page)
        await _cartService.clearCart();
      }

      // Gọi callback để đánh dấu đã đặt hàng
      if (widget.onOrderPlaced != null) {
        widget.onOrderPlaced!();
      }

      // Hiển thị popup thành công
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OrderSuccessDialog(order: order),
        ).then((_) {
          // Đóng checkout page và quay về trang chủ
          if (mounted) {
            context.go('/');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    // Nếu có specificItems, dùng nó trực tiếp, không cần stream
    if (widget.specificItems != null && widget.specificItems!.isNotEmpty) {
      final cartItems = widget.specificItems!;
      return _buildContent(isMobile, cartItems);
    }

    // Nếu không có specificItems, lấy từ cart stream
    return StreamBuilder<List<CartItemModel>>(
      stream: _cartService.getCartItems(),
      builder: (context, cartSnapshot) {
        if (cartSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartSnapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${cartSnapshot.error}'),
          );
        }

        final cartItems = cartSnapshot.data ?? [];
        return _buildContent(isMobile, cartItems);
      },
    );
  }

  Widget _buildContent(bool isMobile, List<CartItemModel> cartItems) {

    if (isMobile) {
      // Mobile: Stack vertically
      return Column(
            children: [
              // Delivery info
              if (widget.fullName != null && widget.phone != null && widget.address != null)
                RecipientInfoSection(
                  fullName: widget.fullName!,
                  phone: widget.phone!,
                  address: widget.address!,
                ),
              if (widget.fullName != null && widget.phone != null && widget.address != null)
                const SizedBox(height: 24),
              // Payment method
              if (widget.paymentMethod != null)
                PaymentMethodDisplay(paymentMethod: widget.paymentMethod!),
              if (widget.paymentMethod != null) const SizedBox(height: 24),
              // Order summary
              OrderSummarySection(cartItems: cartItems),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isPlacingOrder ? null : widget.onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Quay lại'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isPlacingOrder
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Đặt hàng'),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
    } else {
      // Desktop: Grid layout
      return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: Order summary
                  Expanded(
                    flex: 2,
                    child: OrderSummarySection(cartItems: cartItems),
                  ),
                  const SizedBox(width: 24),
                  // Right column: Delivery info and Payment method
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        if (widget.fullName != null && widget.phone != null && widget.address != null)
                          RecipientInfoSection(
                            fullName: widget.fullName!,
                            phone: widget.phone!,
                            address: widget.address!,
                          ),
                        if (widget.fullName != null && widget.phone != null && widget.address != null)
                          const SizedBox(height: 24),
                        if (widget.paymentMethod != null)
                          PaymentMethodDisplay(paymentMethod: widget.paymentMethod!),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isPlacingOrder ? null : widget.onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Quay lại'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isPlacingOrder
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Đặt hàng'),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
    }
  }
}
