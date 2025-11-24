import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/footer.dart';
import '../widgets/pages/products/parent_categories_list.dart';
import '../widgets/pages/products/child_categories_list.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _categoryService = CategoryService();
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

        // Mock products data
    final allProducts = List.generate(20, (index) {
      final categoryId = index % 4 == 0
          ? '1'
          : index % 4 == 1
              ? '2'
              : index % 4 == 2
                  ? '3'
                  : '4';
      final childCategoryId = categoryId == '1'
          ? (index % 3 == 0 ? '5' : index % 3 == 1 ? '6' : '7')
          : categoryId == '2'
              ? (index % 3 == 0 ? '8' : index % 3 == 1 ? '9' : '10')
              : categoryId == '3'
                  ? (index % 4 == 0
                      ? '11'
                      : index % 4 == 1
                          ? '12'
                          : index % 4 == 2
                              ? '13'
                              : '14')
                  : null;

      return {
        'id': 'product-$index',
        'name': 'Sản phẩm ${index + 1}',
        'originalPrice': (1500000 + index * 500000).toString(),
        'price': (1000000 + index * 500000).toString(),
        'discount': index % 3 == 0 ? 20 : (index % 3 == 1 ? 15 : 10),
        'badge': index % 4 == 0
            ? 'Mới'
            : (index % 4 == 1 ? 'Bán chạy' : (index % 4 == 2 ? 'Hot' : 'Nổi bật')),
        'rating': 4.0 + (index % 5) * 0.2,
        'sold': 100 + index * 50,
        'categoryId': categoryId,
        'childCategoryId': childCategoryId,
        'category': categoryId == '1'
            ? 'Điện thoại'
            : categoryId == '2'
                ? 'Laptop'
                : categoryId == '3'
                    ? 'Phụ kiện'
                    : 'Tablet',
        'image':
            'https://images.unsplash.com/photo-1609692814858-f7cd2f0afa4f?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      };
    });

    // Filter products based on selected categories
    final filteredProducts = allProducts.where((product) {
      if (_selectedChildId != null) {
        return product['childCategoryId'] == _selectedChildId;
      } else if (_selectedParentId != null) {
        return product['categoryId'] == _selectedParentId;
      }
      return true; // Show all if no category selected
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
                      
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {},
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Tính toán chiều cao hình ảnh dựa trên tỉ lệ
                              final imageHeight = constraints.maxHeight * 0.6;
                              final contentHeight = constraints.maxHeight * 0.4;
                              
                              final discount = product['discount'] as int;
                              final originalPrice = int.parse(product['originalPrice'] as String);
                              final price = int.parse(product['price'] as String);
                              final badge = product['badge'] as String;
                              final rating = product['rating'] as double;
                              final sold = product['sold'] as int;
                              
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
                                          child: Image.network(
                                            product['image'] as String,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              log('Error loading image: ${error}');
                                              return Icon(
                                                Icons.image,
                                                size: isMobile ? 48 : 64,
                                                color: Colors.grey[400],
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
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
                                      // Highlight badge
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: badge == 'Mới' 
                                                ? Colors.green
                                                : badge == 'Bán chạy'
                                                    ? Colors.orange
                                                    : badge == 'Hot'
                                                        ? Colors.red
                                                        : Colors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            badge,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
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
                                        if (!isMobile) ...[
                                          Text(
                                            product['category'] as String,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        Flexible(
                                          child: Text(
                                            product['name'] as String,
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
                                                index < rating.floor()
                                                    ? Icons.star
                                                    : (index < rating ? Icons.star_half : Icons.star_border),
                                                size: isMobile ? 12 : 14,
                                                color: Colors.amber,
                                              );
                                            }),
                                            const SizedBox(width: 4),
                                            Text(
                                              '($sold)',
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
                                              '${_formatPrice(price)} đ',
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isMobile ? 16 : 18,
                                                  ),
                                            ),
                                            if (discount > 0) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '${_formatPrice(originalPrice)} đ',
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
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

