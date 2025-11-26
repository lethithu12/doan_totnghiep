import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../widgets/admin/admin_reviews/reviews_search_and_filter_bar.dart';
import '../../widgets/admin/admin_reviews/reviews_stats.dart';
import '../../widgets/admin/admin_reviews/reviews_data_table.dart';
import '../../widgets/admin/admin_reviews/mobile_reviews_view.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedRating;
  bool? _hasReply;
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _allReviews = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          // Trigger rebuild when search text changes
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<ReviewModel> _getFilteredReviews(List<ReviewModel> reviews) {
    return reviews.where((review) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          review.userName.toLowerCase().contains(searchQuery) ||
          review.comment.toLowerCase().contains(searchQuery) ||
          review.productId.toLowerCase().contains(searchQuery);

      // Rating filter
      final matchesRating = _selectedRating == null || review.rating == _selectedRating;

      // Reply filter
      final matchesReply = _hasReply == null ||
          (_hasReply == true && review.adminReply != null) ||
          (_hasReply == false && review.adminReply == null);

      return matchesSearch && matchesRating && matchesReply;
    }).toList();
  }

  List<ReviewModel> _getSortedReviews(List<ReviewModel> reviews, int columnIndex, bool ascending) {
    final sorted = List<ReviewModel>.from(reviews);
    sorted.sort((a, b) {
      switch (columnIndex) {
        case 0: // User Name
          return ascending
              ? a.userName.compareTo(b.userName)
              : b.userName.compareTo(a.userName);
        case 1: // Product ID
          return ascending
              ? a.productId.compareTo(b.productId)
              : b.productId.compareTo(a.productId);
        case 2: // Rating
          return ascending
              ? a.rating.compareTo(b.rating)
              : b.rating.compareTo(a.rating);
        case 3: // Has Reply
          final aHasReply = a.adminReply != null ? 1 : 0;
          final bHasReply = b.adminReply != null ? 1 : 0;
          return ascending
              ? aHasReply.compareTo(bHasReply)
              : bHasReply.compareTo(aHasReply);
        case 4: // Created At
          return ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        default:
          return 0;
      }
    });
    return sorted;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRating = null;
      _hasReply = null;
    });
  }

  void _handleSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  bool _listEquals(List<ReviewModel> a, List<ReviewModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Show loading only on initial load
    if (_allReviews.isEmpty) {
      return StreamBuilder<List<ReviewModel>>(
        stream: _reviewService.getAllReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi khi tải đánh giá',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _allReviews = snapshot.data!;
                });
              }
            });
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // Use cached reviews for filtering/sorting
    final filteredReviews = _getFilteredReviews(_allReviews);
    final sortedReviews = _getSortedReviews(filteredReviews, _sortColumnIndex, _sortAscending);

    return Stack(
      children: [
        // Main UI
        if (isMobile)
          MobileReviewsView(
            reviews: sortedReviews,
            searchController: _searchController,
            selectedRating: _selectedRating,
            hasReply: _hasReply,
            onRatingChanged: (value) {
              setState(() {
                _selectedRating = value;
              });
            },
            onReplyChanged: (value) {
              setState(() {
                _hasReply = value;
              });
            },
            onClearFilters: _clearFilters,
            onSort: _handleSort,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            formatDate: _formatDate,
          )
        else
          Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quản lý đánh giá',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 22 : 28,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Search and Filter
                ReviewsSearchAndFilterBar(
                  searchController: _searchController,
                  selectedRating: _selectedRating,
                  hasReply: _hasReply,
                  onRatingChanged: (value) {
                    setState(() {
                      _selectedRating = value;
                    });
                  },
                  onReplyChanged: (value) {
                    setState(() {
                      _hasReply = value;
                    });
                  },
                  onClearFilters: _clearFilters,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),
                // Stats
                ReviewsStats(
                  reviews: sortedReviews,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),
                // Data Table
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ReviewsDataTable(
                        reviews: sortedReviews,
                        onSort: _handleSort,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        rowsPerPage: _rowsPerPage,
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value ?? 10;
                          });
                        },
                        isTablet: isTablet,
                        formatDate: _formatDate,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Background stream listener (invisible, only updates state)
        StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.getAllReviews(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final newReviews = snapshot.data!;
              if (_allReviews.length != newReviews.length ||
                  !_listEquals(_allReviews, newReviews)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _allReviews = newReviews;
                    });
                  }
                });
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

