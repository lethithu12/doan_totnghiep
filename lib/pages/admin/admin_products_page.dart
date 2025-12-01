import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../widgets/admin/admin_products/products_stats.dart';
import '../../widgets/admin/admin_products/products_search_and_filter_bar.dart';
import '../../widgets/admin/admin_products/products_data_table.dart';
import '../../widgets/admin/admin_products/mobile_products_view.dart';
import '../../widgets/admin/admin_products/view_product_dialog.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _productService = ProductService();
  final _categoryService = CategoryService();
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild when search changes
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  List<ProductModel> _applyFiltersAndSort(
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    // Apply filters
    final filtered = products.where((product) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final categoryName = _getCategoryName(product.categoryId, categories);
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery) ||
          (categoryName?.toLowerCase().contains(searchQuery) ?? false) ||
          (product.description?.toLowerCase().contains(searchQuery) ?? false);

      // Category filter
      final matchesCategory = _selectedCategoryId == null || product.categoryId == _selectedCategoryId;

      // Status filter
      final matchesStatus = _selectedStatus == null || product.status == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    // Apply sorting
    return _sortProductsInternal(filtered, categories, _sortColumnIndex, _sortAscending);
  }

  String? _getCategoryName(String categoryId, List<CategoryModel> categories) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return null;
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedStatus = null;
    });
  }

  void _sortProducts(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<ProductModel> _sortProductsInternal(
    List<ProductModel> products,
    List<CategoryModel> categories,
    int columnIndex,
    bool ascending,
  ) {
    final sorted = List<ProductModel>.from(products);
    sorted.sort((a, b) {
      switch (columnIndex) {
        case 0: // Name
          return ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
        case 1: // Category
          final aCategory = _getCategoryName(a.categoryId, categories) ?? '';
          final bCategory = _getCategoryName(b.categoryId, categories) ?? '';
          return ascending ? aCategory.compareTo(bCategory) : bCategory.compareTo(aCategory);
        case 2: // Price
          return ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price);
        case 3: // Original Price
          return ascending
              ? a.originalPrice.compareTo(b.originalPrice)
              : b.originalPrice.compareTo(a.originalPrice);
        case 4: // Quantity
          return ascending ? a.quantity.compareTo(b.quantity) : b.quantity.compareTo(a.quantity);
        case 5: // Status
          return ascending ? a.status.compareTo(b.status) : b.status.compareTo(a.status);
        default:
          return 0;
      }
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategories(),
      builder: (context, categorySnapshot) {
        final categories = categorySnapshot.data ?? [];
        final parentCategories = categories.where((cat) => cat.parentId == null).toList();

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

            final products = productSnapshot.data ?? [];
            final processedProducts = _applyFiltersAndSort(products, categories);

            if (isMobile) {
              return MobileProductsView(
                products: processedProducts,
                categories: categories,
                searchController: _searchController,
                selectedCategoryId: _selectedCategoryId,
                selectedStatus: _selectedStatus,
                onCategoryChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                onStatusChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                onClearFilters: _clearFilters,
                onSort: _sortProducts,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                formatPrice: _formatPrice,
                onDelete: (product) async {
                  try {
                    await _productService.deleteProduct(product.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa sản phẩm: ${product.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            }

            return Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with primary background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isTablet ? 20 : 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.inventory_2,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Quản lý sản phẩm',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 22 : 28,
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.go('/admin/products/new');
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: Text(
                              isTablet ? 'Thêm' : 'Thêm sản phẩm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16 : 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search and Filter
                  ProductsSearchAndFilterBar(
                    searchController: _searchController,
                    categories: parentCategories,
                    selectedCategoryId: _selectedCategoryId,
                    selectedStatus: _selectedStatus,
                    onCategoryChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    onStatusChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    onClearFilters: _clearFilters,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  ProductsStats(
                    products: processedProducts,
                    isTablet: isTablet,
                    formatPrice: _formatPrice,
                  ),
                  const SizedBox(height: 24),
                  // Data Table
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProductsDataTable(
                          products: processedProducts,
                          categories: categories,
                          onSort: _sortProducts,
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          rowsPerPage: _rowsPerPage,
                          onRowsPerPageChanged: (value) {
                            setState(() {
                              _rowsPerPage = value ?? 10;
                            });
                          },
                          isTablet: isTablet,
                          formatPrice: _formatPrice,
                          onView: (product) {
                            showDialog(
                              context: context,
                              builder: (context) => ViewProductDialog(
                                product: product,
                                categories: categories,
                                formatPrice: _formatPrice,
                                isMobile: false,
                              ),
                            );
                          },
                          onEdit: (product) {
                            context.go('/admin/products/${product.id}/edit');
                          },
                          onDelete: (product) async {
                            try {
                              await _productService.deleteProduct(product.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã xóa sản phẩm: ${product.name}'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
