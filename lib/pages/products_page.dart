import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../widgets/footer.dart';
import '../widgets/pages/products/parent_categories_list.dart';
import '../widgets/pages/products/child_categories_list.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _categoryService = CategoryService();
  final _productService = ProductService();
  String? _selectedParentId;
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategories(),
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

        final allCategories = snapshot.data ?? [];
        
        // Get parent categories (status = 'Hiển thị')
        final parentCategories = allCategories
            .where((cat) => cat.parentId == null && cat.status == 'Hiển thị')
            .toList();

        // Get child categories of selected parent
        final childCategories = _selectedParentId == null
            ? <CategoryModel>[]
            : allCategories
                .where((cat) =>
                    cat.parentId == _selectedParentId && cat.status == 'Hiển thị')
                .toList();

        // Load products from Firebase
        return StreamBuilder<List<ProductModel>>(
          stream: _productService.getProducts(),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi: ${productSnapshot.error}'),
                  ],
                ),
              );
            }

            final allProducts = productSnapshot.data ?? [];

            // Filter products based on selected categories and status
            final filteredProducts = allProducts.where((product) {
              // Only show products with status "Còn hàng"
              if (product.status != 'Còn hàng') return false;

              // Filter by child category if selected
              if (_selectedChildId != null) {
                return product.childCategoryId == _selectedChildId;
              }
              
              // Filter by parent category if selected
              if (_selectedParentId != null) {
                return product.categoryId == _selectedParentId;
              }
              
              // Show all if no category selected
              return true;
            }).toList();

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
                            'Tất cả sản phẩm',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // Parent Categories List
                    ParentCategoriesList(
                      parentCategories: parentCategories,
                      selectedParentId: _selectedParentId,
                      onParentSelected: (parentId) {
                        setState(() {
                          _selectedParentId = parentId;
                          _selectedChildId = null; // Reset child selection when parent changes
                        });
                      },
                    ),
                    // Child Categories List (only show when parent is selected)
                    ChildCategoriesList(
                      childCategories: childCategories,
                      selectedChildId: _selectedChildId,
                      onChildSelected: (childId) {
                        setState(() {
                          _selectedChildId = childId;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Builder(
                        builder: (context) {
                          // Xác định số cột và aspect ratio dựa trên kích thước màn hình
                          int crossAxisCount;
                          double childAspectRatio;
                          if (ResponsiveBreakpoints.of(context).isMobile) {
                            crossAxisCount = 2; // Mobile: 2 cột
                            childAspectRatio = 3/6; // Mobile: tỉ lệ thấp hơn để fit nội dung
                          } else if (ResponsiveBreakpoints.of(context).isTablet) {
                            crossAxisCount = 3; // Tablet: 3 cột
                            childAspectRatio = 0.75;
                          } else {
                            crossAxisCount = 4; // Desktop: 4 cột
                            childAspectRatio = 0.75;
                          }
                          
                          if (filteredProducts.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(48),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Không có sản phẩm nào',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: filteredProducts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              final isMobile = ResponsiveBreakpoints.of(context).isMobile;
                              final discount = product.discount;
                              final categoryName = _getCategoryName(product.categoryId, allCategories);
                              
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    if (product.id.isNotEmpty) {
                                      context.go(
                                        '/products/${product.id}',
                                      );
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
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.primary,
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
                                                if (!isMobile && categoryName != null) ...[
                                                  Text(
                                                    categoryName,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.primary,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                ],
                                                Flexible(
                                                  child: Text(
                                                    product.name,
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                                            : (index < product.rating ? Icons.star_half : Icons.star_border),
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${_formatPrice(product.price)} đ',
                                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                            color: Theme.of(context).colorScheme.primary,
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
                                                          decoration: TextDecoration.lineThrough,
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
                    ),
                    const SizedBox(height: 24),
                    const Footer(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String? _getCategoryName(String categoryId, List<CategoryModel> categories) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return null;
    }
  }
}

