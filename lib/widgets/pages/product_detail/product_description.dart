import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/product_model.dart';
import 'description_tab.dart';
import 'specifications_tab.dart';
import 'reviews_tab.dart';

class ProductDescription extends StatefulWidget {
  final String productId;
  final ProductModel product;

  const ProductDescription({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
        vertical: isMobile ? 24 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Mô tả'),
              Tab(text: 'Thông số'),
              Tab(text: 'Đánh giá'),
            ],
          ),
          SizedBox(
            height: isMobile ? 400 : 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Mô tả
                DescriptionTab(
                  isMobile: isMobile,
                  description: widget.product.description,
                ),
                // Tab Thông số
                SpecificationsTab(
                  isMobile: isMobile,
                  specifications: widget.product.specifications,
                ),
                // Tab Đánh giá
                ReviewsTab(
                  isMobile: isMobile,
                  productId: widget.productId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

