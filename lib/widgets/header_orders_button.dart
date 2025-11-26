import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/order_service.dart';
import '../models/order_status.dart';

class HeaderOrdersButton extends StatelessWidget {
  final bool isMobile;

  const HeaderOrdersButton({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final _orderService = OrderService();

    return StreamBuilder(
      stream: _orderService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            color: Colors.grey[600],
            onPressed: () => context.go('/orders'),
          );
        }

        final orders = snapshot.data ?? [];
        // Đếm số đơn hàng đang chờ xác nhận hoặc đang giao
        final pendingCount = orders.where((order) =>
            order.status == OrderStatus.pending ||
            order.status == OrderStatus.delivering).length;

        if (isMobile) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                color: Colors.grey[600],
                onPressed: () => context.go('/orders'),
              ),
              if (pendingCount > 0)
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
                      pendingCount > 9 ? '9+' : '$pendingCount',
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
          // Desktop: Icon với badge
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => context.go('/orders'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: GoRouterState.of(context).uri.path == '/orders'
                        ? Colors.blue[50]
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: GoRouterState.of(context).uri.path == '/orders'
                            ? Colors.blue[700]
                            : Colors.grey[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đơn hàng',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: GoRouterState.of(context).uri.path == '/orders'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: GoRouterState.of(context).uri.path == '/orders'
                                  ? Colors.blue[700]
                                  : Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (pendingCount > 0)
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
                      pendingCount > 9 ? '9+' : '$pendingCount',
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

