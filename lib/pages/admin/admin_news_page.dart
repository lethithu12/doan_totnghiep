import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../config/colors.dart';

class AdminNewsPage extends StatefulWidget {
  const AdminNewsPage({super.key});

  @override
  State<AdminNewsPage> createState() => _AdminNewsPageState();
}

class _AdminNewsPageState extends State<AdminNewsPage> {
  final NewsService _newsService = NewsService();
  List<NewsModel> _allArticles = [];
  List<NewsModel> _filteredArticles = [];
  List<NewsModel> _currentPageArticles = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  List<String> _categories = ['Tất cả'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterArticles);
    _loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final news = await _newsService.getNewsList();
      final categoriesList = await _newsService.getNewsCategories();

      setState(() {
        _allArticles = news;
        _filteredArticles = news;
        _categories = ['Tất cả', ...categoriesList];
        _isLoading = false;
        _totalPages = (news.length / _itemsPerPage).ceil();
        if (_totalPages == 0) _totalPages = 1;
        _updateCurrentPageArticles();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải tin tức: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterArticles() {
    List<NewsModel> filtered = _allArticles;

    // Filter by category
    if (_selectedCategory != 'Tất cả') {
      filtered = filtered
          .where((article) => article.category == _selectedCategory)
          .toList();
    }

    // Filter by search keyword
    final searchKeyword = _searchController.text.toLowerCase();
    if (searchKeyword.isNotEmpty) {
      filtered = filtered.where((article) {
        return article.title.toLowerCase().contains(searchKeyword) ||
            article.summary.toLowerCase().contains(searchKeyword) ||
            article.author.toLowerCase().contains(searchKeyword);
      }).toList();
    }

    setState(() {
      _filteredArticles = filtered;
      _totalPages = (filtered.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
      _currentPage = 1;
      _updateCurrentPageArticles();
    });
  }

  void _updateCurrentPageArticles() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex < _filteredArticles.length) {
      _currentPageArticles = _filteredArticles.sublist(
        startIndex,
        endIndex > _filteredArticles.length
            ? _filteredArticles.length
            : endIndex,
      );
    } else {
      _currentPageArticles = [];
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _updateCurrentPageArticles();
    });
  }

  Future<void> _deleteArticle(NewsModel article) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài viết "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _newsService.deleteNews(article.id);
        await _loadNews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa bài viết thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra khi xóa bài viết: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _togglePublishStatus(NewsModel article) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _newsService.togglePublishStatus(article.id, !article.isPublished);
      await _loadNews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(article.isPublished
                ? 'Đã ẩn bài viết'
                : 'Đã xuất bản bài viết'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.newspaper,
                    color: AppColors.primary, size: isMobile ? 24 : 28),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Quản lý tin tức',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '${_filteredArticles.length} bài viết${_totalPages > 1 ? ' (Trang $_currentPage/$_totalPages)' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                ElevatedButton.icon(
                  onPressed: () => context.go('/admin/news/new'),
                  icon: const Icon(Icons.add),
                  label: Text(isMobile ? 'Thêm' : 'Thêm bài viết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 20,
                        vertical: isMobile ? 8 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Filters
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bài viết...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Danh mục',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                            _filterArticles();
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm bài viết...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Danh mục',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                              _filterArticles();
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Articles List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      )
                    : _currentPageArticles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Không có bài viết nào',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.all(isMobile ? 12 : 20),
                                  itemCount: _currentPageArticles.length,
                                  itemBuilder: (context, index) {
                                    final article =
                                        _currentPageArticles[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border:
                                            Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          // Article Image
                                          Container(
                                            width: isMobile ? 60 : 80,
                                            height: isMobile ? 45 : 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                article.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey[600],
                                                      size: isMobile ? 20 : 24,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: isMobile ? 12 : 16),
                                          // Article Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        article.title,
                                                        style: TextStyle(
                                                          fontSize:
                                                              isMobile ? 14 : 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey[800],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: article
                                                                .isPublished
                                                            ? Colors.green
                                                            : Colors.orange,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        article.isPublished
                                                            ? 'Đã xuất bản'
                                                            : 'Bản nháp',
                                                        style: TextStyle(
                                                          fontSize: isMobile
                                                              ? 10
                                                              : 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height: isMobile ? 2 : 4),
                                                Text(
                                                  article.summary,
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 12 : 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                    height: isMobile ? 4 : 8),
                                                Wrap(
                                                  spacing: isMobile ? 8 : 16,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.person,
                                                            size: isMobile
                                                                ? 12
                                                                : 14,
                                                            color: Colors
                                                                .grey[500]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          article.author,
                                                          style: TextStyle(
                                                            fontSize: isMobile
                                                                ? 10
                                                                : 12,
                                                            color:
                                                                Colors.grey[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.category,
                                                            size: isMobile
                                                                ? 12
                                                                : 14,
                                                            color: Colors
                                                                .grey[500]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          article.category,
                                                          style: TextStyle(
                                                            fontSize: isMobile
                                                                ? 10
                                                                : 12,
                                                            color:
                                                                Colors.grey[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                            Icons.calendar_today,
                                                            size: isMobile
                                                                ? 12
                                                                : 14,
                                                            color: Colors
                                                                .grey[500]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          _formatDate(
                                                              article
                                                                  .publishDate),
                                                          style: TextStyle(
                                                            fontSize: isMobile
                                                                ? 10
                                                                : 12,
                                                            color:
                                                                Colors.grey[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Actions
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () => context.go(
                                                    '/admin/news/${article.id}/edit'),
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                tooltip: 'Chỉnh sửa',
                                                iconSize: isMobile ? 20 : 24,
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _togglePublishStatus(
                                                        article),
                                                icon: Icon(
                                                  article.isPublished
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: article.isPublished
                                                      ? Colors.orange
                                                      : Colors.green,
                                                ),
                                                tooltip: article.isPublished
                                                    ? 'Ẩn bài viết'
                                                    : 'Xuất bản',
                                                iconSize: isMobile ? 20 : 24,
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _deleteArticle(article),
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                tooltip: 'Xóa',
                                                iconSize: isMobile ? 20 : 24,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Pagination
                              if (_totalPages > 1)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _currentPage > 1
                                            ? () => _onPageChanged(
                                                _currentPage - 1)
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                      ),
                                      ...List.generate(
                                        _totalPages,
                                        (index) {
                                          final page = index + 1;
                                          final isCurrentPage =
                                              page == _currentPage;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: InkWell(
                                              onTap: () => _onPageChanged(page),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isCurrentPage
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isCurrentPage
                                                        ? AppColors.primary
                                                        : Colors.grey[300]!,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$page',
                                                    style: TextStyle(
                                                      color: isCurrentPage
                                                          ? Colors.white
                                                          : Colors.grey[700],
                                                      fontWeight:
                                                          isCurrentPage
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: _currentPage < _totalPages
                                            ? () => _onPageChanged(
                                                _currentPage + 1)
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

