import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:data_table_2/data_table_2.dart';

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

  // Mock data
  final List<Map<String, dynamic>> _users = List.generate(
    50,
    (index) => {
      'id': index + 1,
      'name': 'Người dùng ${index + 1}',
      'email': 'user${index + 1}@example.com',
      'role': index % 3 == 0 ? 'Admin' : (index % 3 == 1 ? 'Staff' : 'User'),
      'status': index % 4 == 0 ? 'Khóa' : 'Hoạt động',
      'createdAt': '${2024 - (index % 3)}-${((index % 12) + 1).toString().padLeft(2, '0')}-${((index % 28) + 1).toString().padLeft(2, '0')}',
      'orders': (index * 3) % 100,
    },
  );

  List<Map<String, dynamic>> _sortedUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _sortedUsers = List.from(_users);
    _filteredUsers = List.from(_users);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _users.where((user) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            (user['name'] as String).toLowerCase().contains(searchQuery) ||
            (user['email'] as String).toLowerCase().contains(searchQuery);

        // Role filter
        final matchesRole = _selectedRole == null || user['role'] == _selectedRole;

        // Status filter
        final matchesStatus = _selectedStatus == null || user['status'] == _selectedStatus;

        return matchesSearch && matchesRole && matchesStatus;
      }).toList();

      // Apply sorting
      _sortUsers(_sortColumnIndex, _sortAscending);
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRole = null;
      _selectedStatus = null;
      _applyFilters();
    });
  }

  void _sortUsers(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedUsers = List.from(_filteredUsers);
      _sortedUsers.sort((a, b) {
        switch (columnIndex) {
          case 0: // Name
            return ascending
                ? (a['name'] as String).compareTo(b['name'] as String)
                : (b['name'] as String).compareTo(a['name'] as String);
          case 1: // Email
            return ascending
                ? (a['email'] as String).compareTo(b['email'] as String)
                : (b['email'] as String).compareTo(a['email'] as String);
          case 2: // Role
            return ascending
                ? (a['role'] as String).compareTo(b['role'] as String)
                : (b['role'] as String).compareTo(a['role'] as String);
          case 3: // Status
            return ascending
                ? (a['status'] as String).compareTo(b['status'] as String)
                : (b['status'] as String).compareTo(a['status'] as String);
          case 4: // Created At
            return ascending
                ? (a['createdAt'] as String).compareTo(b['createdAt'] as String)
                : (b['createdAt'] as String).compareTo(a['createdAt'] as String);
          case 5: // Orders
            return ascending
                ? (a['orders'] as int).compareTo(b['orders'] as int)
                : (b['orders'] as int).compareTo(a['orders'] as int);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile) {
      return _MobileUsersView(
        users: _sortedUsers,
        searchController: _searchController,
        selectedRole: _selectedRole,
        selectedStatus: _selectedStatus,
        onRoleChanged: (value) {
          setState(() {
            _selectedRole = value;
            _applyFilters();
          });
        },
        onStatusChanged: (value) {
          setState(() {
            _selectedStatus = value;
            _applyFilters();
          });
        },
        onClearFilters: _clearFilters,
        onSort: _sortUsers,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
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
                'Quản lý người dùng',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 22 : 28,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add new user
                },
                icon: const Icon(Icons.person_add),
                label: Text(isTablet ? 'Thêm' : 'Thêm người dùng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search and Filter
          _SearchAndFilterBar(
            searchController: _searchController,
            selectedRole: _selectedRole,
            selectedStatus: _selectedStatus,
            onRoleChanged: (value) {
              setState(() {
                _selectedRole = value;
                _applyFilters();
              });
            },
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
          _UsersStats(users: _sortedUsers, isTablet: isTablet),
          const SizedBox(height: 24),
          // Data Table
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _UsersDataTable(
                  users: _sortedUsers,
                  onSort: _sortUsers,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  rowsPerPage: _rowsPerPage,
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _rowsPerPage = value ?? 10;
                    });
                  },
                  isTablet: isTablet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersStats extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool isTablet;

  const _UsersStats({
    required this.users,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u['status'] == 'Hoạt động').length;
    final adminUsers = users.where((u) => u['role'] == 'Admin').length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Tổng người dùng',
            value: totalUsers.toString(),
            icon: Icons.people,
            color: Colors.blue,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Đang hoạt động',
            value: activeUsers.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Quản trị viên',
            value: adminUsers.toString(),
            icon: Icons.admin_panel_settings,
            color: Colors.orange,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 12 : 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isTablet ? 20 : 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 20,
                        ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;

  const _UsersDataTable({
    required this.users,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1000,
      columnSpacing: isTablet ? 8 : 12,
      horizontalMargin: isTablet ? 8 : 12,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: [
        DataColumn2(
          label: const Text('Tên'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => onSort(0, ascending),
        ),
        DataColumn2(
          label: const Text('Email'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => onSort(1, ascending),
        ),
        DataColumn2(
          label: const Text('Vai trò'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(2, ascending),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(3, ascending),
        ),
        DataColumn2(
          label: const Text('Ngày đăng ký'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(4, ascending),
        ),
        DataColumn2(
          label: const Text('Đơn hàng'),
          size: ColumnSize.S,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(5, ascending),
        ),
        const DataColumn2(
          label: Text('Hành động'),
          size: ColumnSize.S,
        ),
      ],
      source: _UsersDataSource(
        users: users,
        context: context,
        onEdit: (user) {
          // TODO: Edit user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉnh sửa: ${user['name']}')),
          );
        },
        onDelete: (user) {
          // TODO: Delete user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xóa: ${user['name']}')),
          );
        },
      ),
      empty: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có người dùng nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> users;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;
  final BuildContext context;

  _UsersDataSource({
    required this.users,
    required this.onEdit,
    required this.onDelete,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;

    final user = users[index];
    final isActive = user['status'] == 'Hoạt động';
    final role = user['role'] as String;

    Color getRoleColor() {
      switch (role) {
        case 'Admin':
          return Colors.red;
        case 'Staff':
          return Colors.orange;
        default:
          return Colors.blue;
      }
    }

    return DataRow2(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  (user['name'] as String)[0],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            user['email'] as String,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getRoleColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: getRoleColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user['status'] as String,
              style: TextStyle(
                color: isActive ? Colors.green[700] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(user['createdAt'] as String)),
        DataCell(Text(user['orders'].toString())),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.blue,
                onPressed: () => onEdit(user),
                tooltip: 'Chỉnh sửa',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                onPressed: () => onDelete(user),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class _SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedRole;
  final String? selectedStatus;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const _SearchAndFilterBar({
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 16,
                  vertical: isTablet ? 12 : 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Vai trò',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                      DropdownMenuItem(value: 'User', child: Text('User')),
                    ],
                    onChanged: onRoleChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')),
                      DropdownMenuItem(value: 'Khóa', child: Text('Khóa')),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: 12),
                if (selectedRole != null || selectedStatus != null || searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Xóa bộ lọc',
                    onPressed: onClearFilters,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileUsersView extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final TextEditingController searchController;
  final String? selectedRole;
  final String? selectedStatus;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;

  const _MobileUsersView({
    required this.users,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý người dùng',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 16),
          // Search and Filter
          _SearchAndFilterBar(
            searchController: searchController,
            selectedRole: selectedRole,
            selectedStatus: selectedStatus,
            onRoleChanged: onRoleChanged,
            onStatusChanged: onStatusChanged,
            onClearFilters: onClearFilters,
            isTablet: false,
          ),
          const SizedBox(height: 16),
          // Mobile list view
          ...users.map((user) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      (user['name'] as String)[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email'] as String),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (user['status'] == 'Hoạt động'
                                      ? Colors.green
                                      : Colors.red)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user['status'] as String,
                              style: TextStyle(
                                color: user['status'] == 'Hoạt động'
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user['role'] as String,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: Edit user
                      } else if (value == 'delete') {
                        // TODO: Delete user
                      }
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
