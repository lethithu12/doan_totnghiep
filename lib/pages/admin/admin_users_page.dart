import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/admin/admin_users/users_search_and_filter_bar.dart';
import '../../widgets/admin/admin_users/users_stats.dart';
import '../../widgets/admin/admin_users/users_data_table.dart';
import '../../widgets/admin/admin_users/mobile_users_view.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  String? _selectedStatus;
  final UserService _userService = UserService();
  List<UserModel> _allUsers = [];
  Map<String, int> _ordersCount = {};

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
    _loadOrdersCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrdersCount() async {
    try {
      final counts = await _userService.getAllUsersOrdersCount();
      if (mounted) {
        setState(() {
          _ordersCount = counts;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<UserModel> _getFilteredUsers(List<UserModel> users) {
    return users.where((user) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          (user.displayName ?? '').toLowerCase().contains(searchQuery) ||
          user.email.toLowerCase().contains(searchQuery);

      // Role filter
      final matchesRole = _selectedRole == null || 
          (user.role.toLowerCase() == (_selectedRole ?? '').toLowerCase());

      // Status filter
      final matchesStatus = _selectedStatus == null ||
          (_selectedStatus == 'Hoạt động' && user.isActive) ||
          (_selectedStatus == 'Khóa' && !user.isActive);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  List<UserModel> _getSortedUsers(List<UserModel> users, int columnIndex, bool ascending) {
    final sorted = List<UserModel>.from(users);
    sorted.sort((a, b) {
      switch (columnIndex) {
        case 0: // Name
          final aName = a.displayName ?? a.email;
          final bName = b.displayName ?? b.email;
          return ascending
              ? aName.compareTo(bName)
              : bName.compareTo(aName);
        case 1: // Email
          return ascending
              ? a.email.compareTo(b.email)
              : b.email.compareTo(a.email);
        case 2: // Role
          return ascending
              ? a.role.compareTo(b.role)
              : b.role.compareTo(a.role);
        case 3: // Status
          final aStatus = a.isActive ? 1 : 0;
          final bStatus = b.isActive ? 1 : 0;
          return ascending
              ? aStatus.compareTo(bStatus)
              : bStatus.compareTo(aStatus);
        case 4: // Created At
          return ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        case 5: // Orders
          final aOrders = _ordersCount[a.uid] ?? 0;
          final bOrders = _ordersCount[b.uid] ?? 0;
          return ascending
              ? aOrders.compareTo(bOrders)
              : bOrders.compareTo(aOrders);
        default:
          return 0;
      }
    });
    return sorted;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRole = null;
      _selectedStatus = null;
    });
  }

  void _handleSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  bool _listEquals(List<UserModel> a, List<UserModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].uid != b[i].uid) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Show loading only on initial load
    if (_allUsers.isEmpty) {
      return StreamBuilder<List<UserModel>>(
        stream: _userService.getAllUsers(),
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
                    'Lỗi khi tải người dùng',
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
                  _allUsers = snapshot.data!;
                });
                _loadOrdersCount();
              }
            });
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // Use cached users for filtering/sorting
    final filteredUsers = _getFilteredUsers(_allUsers);
    final sortedUsers = _getSortedUsers(filteredUsers, _sortColumnIndex, _sortAscending);

    return Stack(
      children: [
        // Main UI
        if (isMobile)
          MobileUsersView(
            users: sortedUsers,
            ordersCount: _ordersCount,
            searchController: _searchController,
            selectedRole: _selectedRole,
            selectedStatus: _selectedStatus,
            onRoleChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
            },
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
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
                      'Quản lý người dùng',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 22 : 28,
                          ),
                    ),
                  
                  ],
                ),
                const SizedBox(height: 24),
                // Search and Filter
                UsersSearchAndFilterBar(
                  searchController: _searchController,
                  selectedRole: _selectedRole,
                  selectedStatus: _selectedStatus,
                  onRoleChanged: (value) {
                    setState(() {
                      _selectedRole = value;
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
                UsersStats(
                  users: sortedUsers,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),
                // Data Table
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: UsersDataTable(
                        users: sortedUsers,
                        ordersCount: _ordersCount,
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
        StreamBuilder<List<UserModel>>(
          stream: _userService.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final newUsers = snapshot.data!;
              if (_allUsers.length != newUsers.length ||
                  !_listEquals(_allUsers, newUsers)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _allUsers = newUsers;
                    });
                    _loadOrdersCount();
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
