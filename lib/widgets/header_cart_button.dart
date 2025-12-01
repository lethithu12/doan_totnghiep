import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_service.dart';
import '../models/cart_model.dart';
import '../config/colors.dart';

class HeaderCartButton extends StatelessWidget {
  final bool isMobile;

  const HeaderCartButton({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final _cartService = CartService();

    return StreamBuilder<List<CartItemModel>>(
      stream: _cartService.getCartItems(),
      builder: (context, snapshot) {
        // Tính tổng số lượng sản phẩm (tổng quantity của tất cả items)
        int totalCount = 0;
        if (snapshot.hasData && snapshot.data != null) {
          final items = snapshot.data!;
          for (var item in items) {
            totalCount += item.quantity;
          }
        }

        if (isMobile) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                color: AppColors.headerIcon,
                onPressed: () => context.go('/cart'),
              ),
              if (totalCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      totalCount > 99 ? '99+' : '$totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        } else {
          // Desktop: Icon với badge trong _NavItem
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => context.go('/cart'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GoRouterState.of(context).uri.path == '/cart'
                        ? AppColors.headerNavActiveBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 18,
                        color: GoRouterState.of(context).uri.path == '/cart'
                            ? AppColors.headerNavActive
                            : AppColors.headerText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Giỏ hàng',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: GoRouterState.of(context).uri.path == '/cart'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: GoRouterState.of(context).uri.path == '/cart'
                                  ? AppColors.headerNavActive
                                  : AppColors.headerText,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (totalCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      totalCount > 99 ? '99+' : '$totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}

