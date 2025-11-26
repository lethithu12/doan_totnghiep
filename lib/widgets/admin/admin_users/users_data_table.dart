import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../models/user_model.dart';

class UsersDataTable extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, int> ordersCount;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(DateTime) formatDate;

  const UsersDataTable({
    super.key,
    required this.users,
    required this.ordersCount,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatDate,
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
      source: UsersDataSource(
        users: users,
        ordersCount: ordersCount,
        context: context,
        formatDate: formatDate,
        onEdit: (user) {
          // TODO: Edit user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉnh sửa: ${user.displayName ?? user.email}')),
          );
        },
        onDelete: (user) {
          // TODO: Delete user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xóa: ${user.displayName ?? user.email}')),
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

class UsersDataSource extends DataTableSource {
  final List<UserModel> users;
  final Map<String, int> ordersCount;
  final BuildContext context;
  final String Function(DateTime) formatDate;
  final Function(UserModel) onEdit;
  final Function(UserModel) onDelete;

  UsersDataSource({
    required this.users,
    required this.ordersCount,
    required this.context,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;

    final user = users[index];
    final userName = user.displayName ?? user.email.split('@').first;
    final isActive = user.isActive;
    final role = user.role;
    final roleColor = _getRoleColor(role);

    return DataRow2(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            user.email,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                color: roleColor,
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
              isActive ? 'Hoạt động' : 'Khóa',
              style: TextStyle(
                color: isActive ? Colors.green[700] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(formatDate(user.createdAt))),
        DataCell(Text((ordersCount[user.uid] ?? 0).toString())),
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

