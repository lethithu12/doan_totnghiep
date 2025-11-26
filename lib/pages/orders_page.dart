import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../widgets/pages/orders/orders_tab.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Chờ'),
              Tab(text: 'Giao hàng'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Hủy bỏ'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OrdersTab(status: OrderStatus.pending),
              OrdersTab(status: OrderStatus.delivering),
              OrdersTab(status: OrderStatus.completed),
              OrdersTab(status: OrderStatus.cancelled),
            ],
          ),
        ),
      ],
    );
  }
}

