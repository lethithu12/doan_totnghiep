import 'package:flutter/material.dart';
import '../../../models/order_status.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import 'order_card.dart';

class OrdersTab extends StatelessWidget {
  final OrderStatus status;

  const OrdersTab({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final _orderService = OrderService();

    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi khi tải đơn hàng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allOrders = snapshot.data ?? [];
        // Filter orders by status
        final filteredOrders = allOrders.where((order) => order.status == status).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có đơn hàng ${status.customerDisplayName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return OrderCard(order: order);
          },
        );
      },
    );
  }
}

