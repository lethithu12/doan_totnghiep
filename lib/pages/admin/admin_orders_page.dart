import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:data_table_2/data_table_2.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedDateRange;

  // Mock data
  final List<Map<String, dynamic>> _orders = List.generate(
    50,
    (index) {
      final statuses = ['Chờ xử lý', 'Đã xác nhận', 'Đang xử lý', 'Đang giao', 'Đã hoàn thành', 'Đã hủy'];
      final status = statuses[index % statuses.length];
      final total = 1000000 + (index * 50000);
      return {
        'id': 'ORD${(index + 1).toString().padLeft(6, '0')}',
        'customerName': 'Khách hàng ${index + 1}',
        'customerEmail': 'customer${index + 1}@example.com',
        'products': '${(index % 5) + 1} sản phẩm',
        'total': total,
        'status': status,
        'createdAt': '${2024 - (index % 2)}-${((index % 12) + 1).toString().padLeft(2, '0')}-${((index % 28) + 1).toString().padLeft(2, '0')}',
        'paymentMethod': index % 2 == 0 ? 'Tiền mặt' : 'Chuyển khoản',
      };
    },
  );

  List<Map<String, dynamic>> _sortedOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _sortedOrders = List.from(_orders);
    _filteredOrders = List.from(_orders);
    _searchController.addListener(_applyFilters);
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

  void _applyFilters() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            (order['id'] as String).toLowerCase().contains(searchQuery) ||
            (order['customerName'] as String).toLowerCase().contains(searchQuery) ||
            (order['customerEmail'] as String).toLowerCase().contains(searchQuery);

        // Status filter
        final matchesStatus = _selectedStatus == null || order['status'] == _selectedStatus;

        // Date range filter (simplified - can be enhanced)
        final matchesDate = _selectedDateRange == null || true; // TODO: Implement date range

        return matchesSearch && matchesStatus && matchesDate;
      }).toList();

      // Apply sorting
      _sortOrders(_sortColumnIndex, _sortAscending);
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedDateRange = null;
      _applyFilters();
    });
  }

  void _sortOrders(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedOrders = List.from(_filteredOrders);
      _sortedOrders.sort((a, b) {
        switch (columnIndex) {
          case 0: // ID
            return ascending
                ? (a['id'] as String).compareTo(b['id'] as String)
                : (b['id'] as String).compareTo(a['id'] as String);
          case 1: // Customer Name
            return ascending
                ? (a['customerName'] as String).compareTo(b['customerName'] as String)
                : (b['customerName'] as String).compareTo(a['customerName'] as String);
          case 2: // Products
            return ascending
                ? (a['products'] as String).compareTo(b['products'] as String)
                : (b['products'] as String).compareTo(a['products'] as String);
          case 3: // Total
            return ascending
                ? (a['total'] as int).compareTo(b['total'] as int)
                : (b['total'] as int).compareTo(a['total'] as int);
          case 4: // Status
            return ascending
                ? (a['status'] as String).compareTo(b['status'] as String)
                : (b['status'] as String).compareTo(a['status'] as String);
          case 5: // Payment Method
            return ascending
                ? (a['paymentMethod'] as String).compareTo(b['paymentMethod'] as String)
                : (b['paymentMethod'] as String).compareTo(a['paymentMethod'] as String);
          case 6: // Created At
            return ascending
                ? (a['createdAt'] as String).compareTo(b['createdAt'] as String)
                : (b['createdAt'] as String).compareTo(a['createdAt'] as String);
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
      return _MobileOrdersView(
        orders: _sortedOrders,
        searchController: _searchController,
        selectedStatus: _selectedStatus,
        selectedDateRange: _selectedDateRange,
        onStatusChanged: (value) {
          setState(() {
            _selectedStatus = value;
            _applyFilters();
          });
        },
        onDateRangeChanged: (value) {
          setState(() {
            _selectedDateRange = value;
            _applyFilters();
          });
        },
        onClearFilters: _clearFilters,
        onSort: _sortOrders,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        formatPrice: _formatPrice,
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
                'Quản lý đơn hàng',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 22 : 28,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Export orders
                },
                icon: const Icon(Icons.download),
                label: Text(isTablet ? 'Xuất' : 'Xuất Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search and Filter
          _OrdersSearchAndFilterBar(
            searchController: _searchController,
            selectedStatus: _selectedStatus,
            selectedDateRange: _selectedDateRange,
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
                _applyFilters();
              });
            },
            onDateRangeChanged: (value) {
              setState(() {
                _selectedDateRange = value;
                _applyFilters();
              });
            },
            onClearFilters: _clearFilters,
            isTablet: isTablet,
          ),
          const SizedBox(height: 24),
          // Stats
          _OrdersStats(orders: _sortedOrders, isTablet: isTablet, formatPrice: _formatPrice),
          const SizedBox(height: 24),
          // Data Table
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _OrdersDataTable(
                  orders: _sortedOrders,
                  onSort: _sortOrders,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersStats extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final bool isTablet;
  final String Function(int) formatPrice;

  const _OrdersStats({
    required this.orders,
    required this.isTablet,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;
    final pendingOrders = orders.where((o) => o['status'] == 'Chờ xử lý' || o['status'] == 'Đang xử lý').length;
    final completedOrders = orders.where((o) => o['status'] == 'Đã hoàn thành').length;
    final totalRevenue = orders
        .where((o) => o['status'] == 'Đã hoàn thành')
        .fold<int>(0, (sum, order) => sum + (order['total'] as int));

    return Row(
      children: [
        Expanded(
          child: _OrderStatCard(
            title: 'Tổng đơn hàng',
            value: totalOrders.toString(),
            icon: Icons.shopping_cart,
            color: Colors.blue,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OrderStatCard(
            title: 'Đang xử lý',
            value: pendingOrders.toString(),
            icon: Icons.pending,
            color: Colors.orange,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OrderStatCard(
            title: 'Đã hoàn thành',
            value: completedOrders.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OrderStatCard(
            title: 'Tổng doanh thu',
            value: '${formatPrice(totalRevenue)} đ',
            icon: Icons.attach_money,
            color: Colors.purple,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class _OrderStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const _OrderStatCard({
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 11 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _OrdersSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedStatus;
  final String? selectedDateRange;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const _OrdersSearchAndFilterBar({
    required this.searchController,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
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
                hintText: 'Tìm kiếm theo mã đơn, tên khách hàng, email...',
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
                      DropdownMenuItem(value: 'Chờ xử lý', child: Text('Chờ xử lý')),
                      DropdownMenuItem(value: 'Đã xác nhận', child: Text('Đã xác nhận')),
                      DropdownMenuItem(value: 'Đang xử lý', child: Text('Đang xử lý')),
                      DropdownMenuItem(value: 'Đang giao', child: Text('Đang giao')),
                      DropdownMenuItem(value: 'Đã hoàn thành', child: Text('Đã hoàn thành')),
                      DropdownMenuItem(value: 'Đã hủy', child: Text('Đã hủy')),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDateRange,
                    decoration: InputDecoration(
                      labelText: 'Khoảng thời gian',
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
                      DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
                      DropdownMenuItem(value: 'week', child: Text('Tuần này')),
                      DropdownMenuItem(value: 'month', child: Text('Tháng này')),
                      DropdownMenuItem(value: 'year', child: Text('Năm nay')),
                    ],
                    onChanged: onDateRangeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                if (selectedStatus != null || selectedDateRange != null || searchController.text.isNotEmpty)
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

class _OrdersDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(int) formatPrice;

  const _OrdersDataTable({
    required this.orders,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatPrice,
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
          label: const Text('Mã đơn'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(0, ascending),
        ),
        DataColumn2(
          label: const Text('Khách hàng'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => onSort(1, ascending),
        ),
        DataColumn2(
          label: const Text('Sản phẩm'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) => onSort(2, ascending),
        ),
        DataColumn2(
          label: const Text('Tổng tiền'),
          size: ColumnSize.M,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(3, ascending),
        ),
        DataColumn2(
          label: const Text('Hình thức thanh toán'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(4, ascending),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(5, ascending),
        ),
        DataColumn2(
          label: const Text('Ngày đặt'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(6, ascending),
        ),
        const DataColumn2(
          label: Text('Hành động'),
          size: ColumnSize.S,
        ),
      ],
      source: _OrdersDataSource(
        orders: orders,
        context: context,
        onView: (order) {
          // TODO: View order details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xem chi tiết: ${order['id']}')),
          );
        },
        onEdit: (order) {
          // TODO: Edit order
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉnh sửa: ${order['id']}')),
          );
        },
        formatPrice: formatPrice,
      ),
      empty: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có đơn hàng nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> orders;
  final BuildContext context;
  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onEdit;
  final String Function(int) formatPrice;

  _OrdersDataSource({
    required this.orders,
    required this.context,
    required this.onView,
    required this.onEdit,
    required this.formatPrice,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Chờ xử lý':
        return Colors.orange;
      case 'Đã xác nhận':
        return Colors.teal;
      case 'Đang xử lý':
        return Colors.blue;
      case 'Đang giao':
        return Colors.purple;
      case 'Đã hoàn thành':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod) {
      case 'Tiền mặt':
        return Colors.orange;
      case 'Chuyển khoản':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= orders.length) return null;

    final order = orders[index];
    final status = order['status'] as String;
    final statusColor = getStatusColor(status);

    return DataRow2(
      cells: [
        DataCell(
          Text(
            order['id'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order['customerName'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order['customerEmail'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        DataCell(Text(order['products'] as String)),
        DataCell(
          Text(
            '${formatPrice(order['total'] as int)} đ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        DataCell(
          Builder(
            builder: (context) {
              final paymentMethod = order['paymentMethod'] as String;
              final paymentColor = getPaymentMethodColor(paymentMethod);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: paymentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  paymentMethod,
                  style: TextStyle(
                    color: paymentMethod == 'Tiền mặt' ? Colors.orange[700] : Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(order['createdAt'] as String)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                color: Colors.blue,
                onPressed: () => onView(order),
                tooltip: 'Xem chi tiết',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.orange,
                onPressed: () => onEdit(order),
                tooltip: 'Chỉnh sửa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => orders.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class _MobileOrdersView extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final TextEditingController searchController;
  final String? selectedStatus;
  final String? selectedDateRange;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final String Function(int) formatPrice;

  const _MobileOrdersView({
    required this.orders,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.formatPrice,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Chờ xử lý':
        return Colors.orange;
      case 'Đã xác nhận':
        return Colors.teal;
      case 'Đang xử lý':
        return Colors.blue;
      case 'Đang giao':
        return Colors.purple;
      case 'Đã hoàn thành':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod) {
      case 'Tiền mặt':
        return Colors.orange;
      case 'Chuyển khoản':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý đơn hàng',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 16),
          // Search and Filter
          _OrdersSearchAndFilterBar(
            searchController: searchController,
            selectedStatus: selectedStatus,
            selectedDateRange: selectedDateRange,
            onStatusChanged: onStatusChanged,
            onDateRangeChanged: onDateRangeChanged,
            onClearFilters: onClearFilters,
            isTablet: false,
          ),
          const SizedBox(height: 16),
          // Mobile list view
          ...orders.map((order) {
            final status = order['status'] as String;
            final statusColor = getStatusColor(status);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['id'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order['customerName'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['customerEmail'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatPrice(order['total'] as int)} đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final paymentMethod = order['paymentMethod'] as String;
                            final paymentColor = getPaymentMethodColor(paymentMethod);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: paymentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                paymentMethod,
                                style: TextStyle(
                                  color: paymentMethod == 'Tiền mặt' ? Colors.orange[700] : Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['createdAt'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Xem'),
                          onPressed: () {
                            // TODO: View order
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Sửa'),
                          onPressed: () {
                            // TODO: Edit order
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
