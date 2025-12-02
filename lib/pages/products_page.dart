import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../widgets/footer.dart';
import '../widgets/pages/products/parent_categories_list.dart';
import '../widgets/pages/products/child_categories_list.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

enum SortOption {
  none,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _categoryService = CategoryService();
  final _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<RangeValues> _priceRangeNotifier = ValueNotifier<RangeValues>(const RangeValues(0, 10000000));
  final ValueNotifier<SortOption> _sortOptionNotifier = ValueNotifier<SortOption>(SortOption.none);
  String? _selectedParentId;
  String? _selectedChildId;
  bool _isPriceRangeInitialized = false;
  
  // Cache category names để tránh tính toán lại
  final Map<String, String> _categoryNameCache = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceRangeNotifier.dispose();
    _sortOptionNotifier.dispose();
    super.dispose();
  }

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

            // Get products filtered by category (but not by price or search yet)
            final categoryFilteredProducts = allProducts.where((product) {
              if (product.status != 'Còn hàng') return false;

              if (_selectedChildId != null) {
                return product.childCategoryId == _selectedChildId;
              }
              
              if (_selectedParentId != null) {
                return product.categoryId == _selectedParentId;
              }
              
              return true;
            }).toList();

            // Calculate current min/max from category-filtered products for slider range
            final currentMinPrice = categoryFilteredProducts.isEmpty
                ? 0.0
                : categoryFilteredProducts.map((p) => p.price.toDouble()).reduce((a, b) => a < b ? a : b);
            final currentMaxPrice = categoryFilteredProducts.isEmpty
                ? 10000000.0
                : categoryFilteredProducts.map((p) => p.price.toDouble()).reduce((a, b) => a > b ? a : b);
            
            // Initialize price range from available products
            if (!_isPriceRangeInitialized && categoryFilteredProducts.isNotEmpty) {
              _priceRangeNotifier.value = RangeValues(currentMinPrice, currentMaxPrice);
              _isPriceRangeInitialized = true;
            }
            
            // Ensure price range is within bounds
            final currentRange = _priceRangeNotifier.value;
            final adjustedPriceRange = RangeValues(
              currentRange.start.clamp(currentMinPrice, currentMaxPrice),
              currentRange.end.clamp(currentMinPrice, currentMaxPrice),
            );
            if (adjustedPriceRange != currentRange) {
              _priceRangeNotifier.value = adjustedPriceRange;
            }

            // Use ValueListenableBuilder to only rebuild the filtered products list
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, searchValue, child) {
                return ValueListenableBuilder<RangeValues>(
                  valueListenable: _priceRangeNotifier,
                  builder: (context, priceRange, child) {
                    return ValueListenableBuilder<SortOption>(
                      valueListenable: _sortOptionNotifier,
                      builder: (context, sortOption, child) {
                        // Filter products based on selected categories, status, search query, and price range
                        // Optimize: filter by category first (already done), then apply other filters
                        var filteredProducts = categoryFilteredProducts.where((product) {
                          // Search filter
                          final searchQuery = searchValue.text.toLowerCase().trim();
                          if (searchQuery.isNotEmpty) {
                            final productName = product.name.toLowerCase();
                            // Only check category name if needed (lazy evaluation)
                            if (!productName.contains(searchQuery)) {
                              final categoryName = _getCategoryName(product.categoryId, allCategories)?.toLowerCase() ?? '';
                              final description = product.description?.toLowerCase() ?? '';
                              
                              if (!categoryName.contains(searchQuery) &&
                                  !description.contains(searchQuery)) {
                                return false;
                              }
                            }
                          }

                          // Price range filter
                          final productPrice = product.price.toDouble();
                          if (productPrice < priceRange.start || productPrice > priceRange.end) {
                            return false;
                          }
                          
                          return true;
                        }).toList();

                        // Apply sorting
                        if (sortOption != SortOption.none) {
                          filteredProducts = List<ProductModel>.from(filteredProducts);
                          switch (sortOption) {
                            case SortOption.nameAsc:
                              filteredProducts.sort((a, b) => a.name.compareTo(b.name));
                              break;
                            case SortOption.nameDesc:
                              filteredProducts.sort((a, b) => b.name.compareTo(a.name));
                              break;
                            case SortOption.priceAsc:
                              filteredProducts.sort((a, b) => a.price.compareTo(b.price));
                              break;
                            case SortOption.priceDesc:
                              filteredProducts.sort((a, b) => b.price.compareTo(a.price));
                              break;
                            case SortOption.none:
                              break;
                          }
                        }

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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                            'Tất cả sản phẩm',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                              // Search bar
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchController,
                                builder: (context, value, child) {
                                  return TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm sản phẩm...',
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: value.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                _searchController.clear();
                                              },
                                            )
                                          : null,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Sort buttons and Price range filter in one row
                              if (_isPriceRangeInitialized && currentMaxPrice > currentMinPrice)
                                ValueListenableBuilder<RangeValues>(
                                  valueListenable: _priceRangeNotifier,
                                  builder: (context, priceRange, child) {
                                    return ValueListenableBuilder<SortOption>(
                                      valueListenable: _sortOptionNotifier,
                                      builder: (context, sortOption, child) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // First row: Sort buttons and Reset button
                                            Row(
                                              children: [
                                                // Sort buttons
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () {
                                                            if (sortOption == SortOption.nameAsc) {
                                                              _sortOptionNotifier.value = SortOption.nameDesc;
                                                            } else {
                                                              _sortOptionNotifier.value = SortOption.nameAsc;
                                                            }
                                                          },
                                                          icon: Icon(
                                                            sortOption == SortOption.nameAsc 
                                                                ? Icons.arrow_upward 
                                                                : sortOption == SortOption.nameDesc
                                                                    ? Icons.arrow_downward
                                                                    : Icons.sort_by_alpha,
                                                            size: 16,
                                                          ),
                                                          label: Text(sortOption == SortOption.nameAsc || sortOption == SortOption.nameDesc 
                                                              ? 'A-Z ${sortOption == SortOption.nameAsc ? '↑' : '↓'}'
                                                              : 'A-Z'),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor: sortOption == SortOption.nameAsc || sortOption == SortOption.nameDesc
                                                                ? Theme.of(context).colorScheme.primary
                                                                : null,
                                                            side: BorderSide(
                                                              color: sortOption == SortOption.nameAsc || sortOption == SortOption.nameDesc
                                                                  ? Theme.of(context).colorScheme.primary
                                                                  : Colors.grey[300]!,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () {
                                                            if (sortOption == SortOption.priceAsc) {
                                                              _sortOptionNotifier.value = SortOption.priceDesc;
                                                            } else {
                                                              _sortOptionNotifier.value = SortOption.priceAsc;
                                                            }
                                                          },
                                                          icon: Icon(
                                                            sortOption == SortOption.priceAsc 
                                                                ? Icons.arrow_upward 
                                                                : sortOption == SortOption.priceDesc
                                                                    ? Icons.arrow_downward
                                                                    : Icons.attach_money,
                                                            size: 16,
                                                          ),
                                                          label: Text(sortOption == SortOption.priceAsc || sortOption == SortOption.priceDesc
                                                              ? 'Giá ${sortOption == SortOption.priceAsc ? '↑' : '↓'}'
                                                              : 'Giá'),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor: sortOption == SortOption.priceAsc || sortOption == SortOption.priceDesc
                                                                ? Theme.of(context).colorScheme.primary
                                                                : null,
                                                            side: BorderSide(
                                                              color: sortOption == SortOption.priceAsc || sortOption == SortOption.priceDesc
                                                                  ? Theme.of(context).colorScheme.primary
                                                                  : Colors.grey[300]!,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Reset button for all filters
                                                TextButton.icon(
                                                  onPressed: () {
                                                    // Reset search
                                                    _searchController.clear();
                                                    // Reset price range
                                                    _priceRangeNotifier.value = RangeValues(currentMinPrice, currentMaxPrice);
                                                    // Reset sort
                                                    _sortOptionNotifier.value = SortOption.none;
                                                  },
                                                  icon: const Icon(Icons.refresh, size: 16),
                                                  label: const Text('Đặt lại'),
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Price range slider
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Khoảng giá',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                RangeSlider(
                                                  values: priceRange,
                                                  min: currentMinPrice,
                                                  max: currentMaxPrice,
                                                  divisions: 100,
                                                  labels: RangeLabels(
                                                    '${_formatPrice(priceRange.start.round())} đ',
                                                    '${_formatPrice(priceRange.end.round())} đ',
                                                  ),
                                                  onChanged: (RangeValues values) {
                                                    _priceRangeNotifier.value = values;
                                                  },
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${_formatPrice(priceRange.start.round())} đ',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Theme.of(context).colorScheme.primary,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                    Text(
                                                      '${_formatPrice(priceRange.end.round())} đ',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Theme.of(context).colorScheme.primary,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              // If price range not initialized, show only sort buttons
                              if (!_isPriceRangeInitialized || currentMaxPrice <= currentMinPrice)
                                ValueListenableBuilder<SortOption>(
                                  valueListenable: _sortOptionNotifier,
                                  builder: (context, sortOption, child) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    if (sortOption == SortOption.nameAsc) {
                                                      _sortOptionNotifier.value = SortOption.nameDesc;
                                                    } else {
                                                      _sortOptionNotifier.value = SortOption.nameAsc;
                                                    }
                                                  },
                                                  icon: Icon(
                                                    sortOption == SortOption.nameAsc 
                                                        ? Icons.arrow_upward 
                                                        : sortOption == SortOption.nameDesc
                                                            ? Icons.arrow_downward
                                                            : Icons.sort_by_alpha,
                                                    size: 16,
                                                  ),
                                                  label: Text(sortOption == SortOption.nameAsc || sortOption == SortOption.nameDesc 
                                                      ? 'A-Z ${sortOption == SortOption.nameAsc ? '↑' : '↓'}'
                                                      : 'A-Z'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: sortOption == SortOption.nameAsc || sortOption == SortOption.nameDesc
                                                        ? Theme.of(context).colorScheme.primary
                                                        : null,
                                                    side: BorderSide(
                                                      color: sortOption == SortOption.nameAsc || sortOption == SortOption.nameDesc
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Colors.grey[300]!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    if (sortOption == SortOption.priceAsc) {
                                                      _sortOptionNotifier.value = SortOption.priceDesc;
                                                    } else {
                                                      _sortOptionNotifier.value = SortOption.priceAsc;
                                                    }
                                                  },
                                                  icon: Icon(
                                                    sortOption == SortOption.priceAsc 
                                                        ? Icons.arrow_upward 
                                                        : sortOption == SortOption.priceDesc
                                                            ? Icons.arrow_downward
                                                            : Icons.attach_money,
                                                    size: 16,
                                                  ),
                                                  label: Text(sortOption == SortOption.priceAsc || sortOption == SortOption.priceDesc
                                                      ? 'Giá ${sortOption == SortOption.priceAsc ? '↑' : '↓'}'
                                                      : 'Giá'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: sortOption == SortOption.priceAsc || sortOption == SortOption.priceDesc
                                                        ? Theme.of(context).colorScheme.primary
                                                        : null,
                                                    side: BorderSide(
                                                      color: sortOption == SortOption.priceAsc || sortOption == SortOption.priceDesc
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Colors.grey[300]!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            _searchController.clear();
                                            _sortOptionNotifier.value = SortOption.none;
                                          },
                                          icon: const Icon(Icons.refresh, size: 16),
                                          label: const Text('Đặt lại'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              const SizedBox(height: 16),
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
                              padding: const EdgeInsets.all(64),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Không tìm thấy sản phẩm',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          // Use SliverGrid for better performance with large lists
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
                            cacheExtent: 500, // Cache items for better scroll performance
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _ProductCard(
                                product: product,
                                categoryName: _getCategoryName(product.categoryId, allCategories),
                                  onTap: () {
                                    if (product.id.isNotEmpty) {
                                    context.go('/products/${product.id}');
                                  }
                                },
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
              },
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
    // Check cache first
    if (_categoryNameCache.containsKey(categoryId)) {
      return _categoryNameCache[categoryId];
    }
    
    try {
      final name = categories.firstWhere((cat) => cat.id == categoryId).name;
      _categoryNameCache[categoryId] = name;
      return name;
    } catch (e) {
      return null;
    }
  }
}

// Separate widget for product card to optimize rebuilds
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String? categoryName;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    this.categoryName,
    required this.onTap,
  });

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final discount = product.discount;
    final isOutOfStock = product.calculatedStatus == 'Hết hàng';
    
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                                                  ),
                                                ),
                                                child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: product.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              color: isOutOfStock ? Colors.black.withOpacity(0.5) : null,
                              colorBlendMode: isOutOfStock ? BlendMode.darken : null,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
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
                  // Discount badge
                  if (discount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red[600]!,
                              Colors.red[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                  // Out of stock badge
                  if (isOutOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Hết hàng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product info
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Opacity(
                  opacity: isOutOfStock ? 0.6 : 1.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isMobile && categoryName != null) ...[
                        Text(
                          categoryName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Flexible(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Rating trung bình và số feedback
                      FutureBuilder<Map<String, dynamic>>(
                        future: ReviewService().getReviewStats(product.id),
                        builder: (context, reviewSnapshot) {
                          final reviewCount = reviewSnapshot.data?['count'] as int? ?? 0;
                          final averageRating = reviewSnapshot.data?['averageRating'] as double? ?? product.rating;
                          return Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < averageRating.floor()
                                      ? Icons.star
                                      : (index < averageRating ? Icons.star_half : Icons.star_border),
                                  size: isMobile ? 12 : 14,
                                  color: Colors.amber,
                                );
                              }),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '($reviewCount)',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
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
                                fontSize: isMobile ? 11 : 12,
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
              ),
            ),
          ],
        ),
      ),
      // Out of stock overlay (không chặn tap events)
      if (isOutOfStock)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
    ],
  ),
);
  }
}

