import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../widgets/pages/orders/orders_tab.dart';
import '../widgets/pages/orders/my_reviews_tab.dart';
import '../config/colors.dart';

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.headerBackground.withOpacity(0.03),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // TabBar with modern design
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.headerBackground,
                    AppColors.primaryLight,
                  ],
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Chờ xử lý'),
                Tab(text: 'Đang giao'),
                Tab(text: 'Hoàn thành'),
                Tab(text: 'Hủy bỏ'),
                Tab(text: 'Đánh giá của tôi'),
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
                const MyReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

