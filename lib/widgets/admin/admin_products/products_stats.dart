import 'package:flutter/material.dart';
import 'product_stat_card.dart';
import '../../../models/product_model.dart';

class ProductsStats extends StatelessWidget {
  final List<ProductModel> products;
  final bool isTablet;
  final String Function(int) formatPrice;

  const ProductsStats({
    super.key,
    required this.products,
    required this.isTablet,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final totalProducts = products.length;
    final inStockProducts = products.where((p) => p.calculatedStatus == 'Còn hàng').length;
    final outOfStockProducts = products.where((p) => p.calculatedStatus == 'Hết hàng').length;
    final totalValue = products.fold<int>(
      0,
      (sum, product) => sum + (product.price * product.quantity),
    );

    return Row(
      children: [
        Expanded(
          child: ProductStatCard(
            title: 'Tổng sản phẩm',
            value: totalProducts.toString(),
            icon: Icons.inventory_2,
            color: Colors.blue,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProductStatCard(
            title: 'Còn hàng',
            value: inStockProducts.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProductStatCard(
            title: 'Hết hàng',
            value: outOfStockProducts.toString(),
            icon: Icons.cancel,
            color: Colors.red,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProductStatCard(
            title: 'Tổng giá trị',
            value: '${formatPrice(totalValue)} đ',
            icon: Icons.attach_money,
            color: Colors.purple,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

