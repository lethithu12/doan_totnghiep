import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/home_section_model.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class DynamicSection extends StatelessWidget {
  final HomeSectionModel section;

  const DynamicSection({
    super.key,
    required this.section,
  });

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (section.productIds.isEmpty) {
      return const SizedBox.shrink();
    }

    // Xác định số cột và aspect ratio dựa trên kích thước màn hình
    int crossAxisCount;
    double childAspectRatio;
    if (ResponsiveBreakpoints.of(context).isMobile) {
      crossAxisCount = 2; // Mobile: 2 cột
      childAspectRatio = 3 / 6; // Mobile: tỉ lệ thấp hơn để fit nội dung
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      crossAxisCount = 3; // Tablet: 3 cột
      childAspectRatio = 0.75;
    } else {
      crossAxisCount = 4; // Desktop: 4 cột
      childAspectRatio = 0.75;
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<ProductModel>>(
            stream: _getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Lỗi khi tải sản phẩm: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                );
              }

              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isMobile =
                      ResponsiveBreakpoints.of(context).isMobile;
                  final discount = product.discount;

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        if (product.id.isNotEmpty) {
                          context.go('/products/${product.id}');
                        }
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Tính toán chiều cao hình ảnh dựa trên tỉ lệ
                          final imageHeight = constraints.maxHeight * 0.6;
                          final contentHeight = constraints.maxHeight * 0.4;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: imageHeight,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: product.imageUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: product.imageUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(
                                                Icons.image,
                                                size: isMobile ? 48 : 64,
                                                color: Colors.grey[400],
                                              ),
                                            )
                                          : Icon(
                                              Icons.image,
                                              size: isMobile ? 48 : 64,
                                              color: Colors.grey[400],
                                            ),
                                    ),
                                  ),
                                  // Badge giảm giá
                                  if (discount > 0)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '-$discount%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Container(
                                height: contentHeight,
                                padding: EdgeInsets.all(isMobile ? 12 : 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        product.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontSize: isMobile ? 14 : null,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Rating và số lượng đã bán
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          return Icon(
                                            index < product.rating.floor()
                                                ? Icons.star
                                                : (index < product.rating
                                                    ? Icons.star_half
                                                    : Icons.star_border),
                                            size: isMobile ? 12 : 14,
                                            color: Colors.amber,
                                          );
                                        }),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${product.sold})',
                                          style: TextStyle(
                                            fontSize: isMobile ? 11 : 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Giá
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_formatPrice(product.price)} đ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMobile ? 16 : 18,
                                              ),
                                        ),
                                        if (discount > 0) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_formatPrice(product.originalPrice)} đ',
                                            style: TextStyle(
                                              fontSize: isMobile ? 12 : 14,
                                              color: Colors.grey[600],
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Stream<List<ProductModel>> _getProductsStream() {
    final productService = ProductService();
    return productService.getProducts().map((allProducts) {
      // Lọc các sản phẩm theo productIds trong section
      final Map<String, ProductModel> productMap = {
        for (var product in allProducts) product.id: product
      };
      
      // Giữ nguyên thứ tự productIds
      return section.productIds
          .map((id) => productMap[id])
          .where((product) => product != null)
          .cast<ProductModel>()
          .toList();
    });
  }
}

