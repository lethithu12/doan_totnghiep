import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../widgets/admin/admin_categories/categories_stats.dart';
import '../../widgets/admin/admin_categories/categories_search_and_filter_bar.dart';
import '../../widgets/admin/admin_categories/categories_data_table.dart';
import '../../widgets/admin/admin_categories/mobile_categories_view.dart';
import '../../widgets/admin/admin_categories/edit_category_dialog.dart';
import '../../widgets/admin/admin_categories/delete_category_dialog.dart';
import '../../widgets/admin/admin_categories/create_category_dialog.dart';
import '../../services/category_service.dart';
import '../../services/image_service.dart';
import '../../models/category_model.dart';
import '../../widgets/admin/admin_categories/expandable_category_row.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final _categoryService = CategoryService();
  final _imageService = ImageService();
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  final Set<String> _expandedCategoryIds = {}; // Track expanded categories

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild when search changes
    });
  }

  // Organize categories into expandable structure
  List<ExpandableCategoryRow> _organizeCategories(List<CategoryModel> categories) {
    // Get parent categories (no parentId)
    final parents = categories.where((cat) => cat.parentId == null).toList();
    
    // Sort parents
    parents.sort((a, b) {
      switch (_sortColumnIndex) {
        case 0: // Name
          return _sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        case 1: // Status
          return _sortAscending
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status);
        case 2: // Created At
          return _sortAscending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });

    // Create expandable rows
    return parents.map((parent) {
      // Get children of this parent
      final children = categories
          .where((cat) => cat.parentId == parent.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)); // Sort children by name

      return ExpandableCategoryRow(
        category: parent,
        children: children,
        isExpanded: _expandedCategoryIds.contains(parent.id),
      );
    }).toList();
  }

  void _toggleExpand(String categoryId) {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });
  }

  List<CategoryModel> _applyFiltersAndSort(List<CategoryModel> categories) {
    // Apply filters
    final filtered = categories.where((category) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          category.name.toLowerCase().contains(searchQuery) ||
          (category.description?.toLowerCase().contains(searchQuery) ?? false);

      // Status filter
      final matchesStatus = _selectedStatus == null || category.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    // Apply sorting
    return _sortCategoriesInternal(filtered, _sortColumnIndex, _sortAscending);
  }

  void _showEditDialog(CategoryModel category, List<CategoryModel> allCategories) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(
        category: category,
        allCategories: allCategories,
        onSave: (updatedCategory) async {
          try {
            await _categoryService.updateCategory(category.id, updatedCategory);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật danh mục thành công!'),
                  duration: Duration(seconds: 2),
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
    );
  }

  void _showCreateDialog(List<CategoryModel> allCategories) {
    showDialog(
      context: context,
      builder: (context) => CreateCategoryDialog(
        allCategories: allCategories,
        onCreate: (newCategory) async {
          try {
            await _categoryService.createCategory(newCategory);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tạo danh mục thành công!'),
                  duration: Duration(seconds: 2),
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
    );
  }

  void _showDeleteDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => DeleteCategoryDialog(
        category: category,
        onConfirm: () async {
          try {
            // Check if category has children
            final hasChildren = await _categoryService.hasChildren(category.id);
            if (hasChildren) {
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không thể xóa danh mục có danh mục con!'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              return;
            }

            // Delete image if exists
            if (category.imageUrl != null) {
              await _imageService.deleteCategoryImage(category.imageUrl!);
            }

            // Delete category
            await _categoryService.deleteCategory(category.id);
            
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa danh mục: ${category.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context).pop();
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {}); // Trigger rebuild to re-apply filters
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
    });
  }

  void _sortCategories(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<CategoryModel> _sortCategoriesInternal(
    List<CategoryModel> categories,
    int columnIndex,
    bool ascending,
  ) {
    final sorted = List<CategoryModel>.from(categories);
    
    // Sort by hierarchy first (parents before children), then by selected column
    sorted.sort((a, b) {
      final aIsParent = a.parentId == null;
      final bIsParent = b.parentId == null;
      
      // Parents come before children
      if (aIsParent && !bIsParent) return -1;
      if (!aIsParent && bIsParent) return 1;
      
      // If both are children of the same parent, sort by name
      if (!aIsParent && !bIsParent && a.parentId == b.parentId) {
        return a.name.compareTo(b.name);
      }
      
      // Sort by selected column
      switch (columnIndex) {
        case 0: // Name
          return ascending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        case 1: // Product Count
          return ascending
              ? a.productCount.compareTo(b.productCount)
              : b.productCount.compareTo(a.productCount);
        case 2: // Status
          return ascending
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status);
        case 3: // Created At
          return ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
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

        final categories = snapshot.data ?? [];
        
        // Apply filters and sorting to categories directly in builder
        final filteredCategories = _applyFiltersAndSort(categories);
        
        // Organize into expandable structure
        final expandableRows = _organizeCategories(filteredCategories);

        if (isMobile) {
          return MobileCategoriesView(
            expandableRows: expandableRows,
            searchController: _searchController,
            selectedStatus: _selectedStatus,
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
                _applyFilters();
              });
            },
            onClearFilters: _clearFilters,
            onEdit: (category) => _showEditDialog(category, categories),
            onDelete: _showDeleteDialog,
            onSort: _sortCategories,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onCreate: () => _showCreateDialog(categories),
            onToggleExpand: _toggleExpand,
          );
        }

        return Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quản lý danh mục',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 22 : 28,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(categories),
                    icon: const Icon(Icons.add),
                    label: Text(isTablet ? 'Thêm' : 'Thêm danh mục'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search and Filter
              CategoriesSearchAndFilterBar(
                searchController: _searchController,
                selectedStatus: _selectedStatus,
                onStatusChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                    _applyFilters();
                  });
                },
                onClearFilters: _clearFilters,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              // Stats
              CategoriesStats(
                categories: filteredCategories,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              // Data Table
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CategoriesDataTable(
                      expandableRows: expandableRows,
                      onSort: _sortCategories,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (value) {
                        setState(() {
                          _rowsPerPage = value ?? 10;
                        });
                      },
                      onEdit: (category) => _showEditDialog(category, categories),
                      onDelete: _showDeleteDialog,
                      onToggleExpand: _toggleExpand,
                      isTablet: isTablet,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
