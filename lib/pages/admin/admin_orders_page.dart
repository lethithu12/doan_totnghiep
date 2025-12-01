import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../models/order_model.dart';
import '../../models/order_status.dart';
import '../../models/payment_method.dart';
import '../../services/order_service.dart';
import '../../config/colors.dart';
import '../../widgets/pages/orders/order_detail_dialog.dart';

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
  OrderStatus? _selectedStatus;
  String? _selectedDateRange;
  final OrderService _orderService = OrderService();
  List<OrderModel> _allOrders = [];

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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    return orders.where((order) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          order.orderCode.toLowerCase().contains(searchQuery) ||
          order.fullName.toLowerCase().contains(searchQuery) ||
          order.phone.toLowerCase().contains(searchQuery);

      // Status filter
      final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;

      // Date range filter (simplified - can be enhanced)
      final matchesDate = _selectedDateRange == null || true; // TODO: Implement date range

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  List<OrderModel> _getSortedOrders(List<OrderModel> orders, int columnIndex, bool ascending) {
    final sorted = List<OrderModel>.from(orders);
    sorted.sort((a, b) {
      switch (columnIndex) {
        case 0: // Order Code
          return ascending
              ? a.orderCode.compareTo(b.orderCode)
              : b.orderCode.compareTo(a.orderCode);
        case 1: // Customer Name
          return ascending
              ? a.fullName.compareTo(b.fullName)
              : b.fullName.compareTo(a.fullName);
        case 2: // Products
          final aCount = a.items.length;
          final bCount = b.items.length;
          return ascending
              ? aCount.compareTo(bCount)
              : bCount.compareTo(aCount);
        case 3: // Total
          return ascending
              ? a.total.compareTo(b.total)
              : b.total.compareTo(a.total);
        case 4: // Payment Method
          return ascending
              ? a.paymentMethod.name.compareTo(b.paymentMethod.name)
              : b.paymentMethod.name.compareTo(a.paymentMethod.name);
        case 5: // Status
          return ascending
              ? a.status.adminDisplayName.compareTo(b.status.adminDisplayName)
              : b.status.adminDisplayName.compareTo(a.status.adminDisplayName);
        case 6: // Created At
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
      _selectedStatus = null;
      _selectedDateRange = null;
    });
  }

  void _handleSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _handleStatusUpdate(String orderId, OrderStatus newStatus) {
    setState(() {
      final index = _allOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _allOrders[index] = _allOrders[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  bool _listEquals(List<OrderModel> a, List<OrderModel> b) {
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
    if (_allOrders.isEmpty) {
      return StreamBuilder<List<OrderModel>>(
        stream: _orderService.getAllOrders(),
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
                    'Lỗi khi tải đơn hàng',
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
                  _allOrders = snapshot.data!;
                });
              }
            });
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // Use cached orders for filtering/sorting
    final filteredOrders = _getFilteredOrders(_allOrders);
    final sortedOrders = _getSortedOrders(filteredOrders, _sortColumnIndex, _sortAscending);

    return Stack(
      children: [
        // Main UI
        if (isMobile)
          _MobileOrdersView(
            orders: sortedOrders,
            searchController: _searchController,
            selectedStatus: _selectedStatus,
            selectedDateRange: _selectedDateRange,
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            onDateRangeChanged: (value) {
              setState(() {
                _selectedDateRange = value;
              });
            },
            onClearFilters: _clearFilters,
            onSort: _handleSort,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            formatPrice: _formatPrice,
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
                      'Quản lý đơn hàng',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 22 : 28,
                          ),
                    ),
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     // TODO: Export orders
                    //   },
                    //   icon: const Icon(Icons.download),
                    //   label: Text(isTablet ? 'Xuất' : 'Xuất Excel'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Theme.of(context).colorScheme.primary,
                    //     foregroundColor: Colors.white,
                    //   ),
                    // ),
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
                    });
                  },
                  onDateRangeChanged: (value) {
                    setState(() {
                      _selectedDateRange = value;
                    });
                  },
                  onClearFilters: _clearFilters,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),
                // Stats
                _OrdersStats(
                  orders: sortedOrders,
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
                    child: _OrdersDataTable(
                      orders: sortedOrders,
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
                      formatPrice: _formatPrice,
                      formatDate: _formatDate,
                      onStatusUpdated: _handleStatusUpdate,
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Background stream listener (invisible, only updates state)
        StreamBuilder<List<OrderModel>>(
          stream: _orderService.getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final newOrders = snapshot.data!;
              if (_allOrders.length != newOrders.length ||
                  !_listEquals(_allOrders, newOrders)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _allOrders = newOrders;
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

class _OrdersStats extends StatelessWidget {
  final List<OrderModel> orders;
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
    final pendingOrders = orders.where((o) =>
        o.status == OrderStatus.pending ||
        o.status == OrderStatus.processing).length;
    final completedOrders = orders.where((o) => o.status == OrderStatus.completed).length;
    final totalRevenue = orders
        .where((o) => o.status == OrderStatus.completed)
        .fold<int>(0, (sum, order) => sum + order.total);

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
  final OrderStatus? selectedStatus;
  final String? selectedDateRange;
  final ValueChanged<OrderStatus?> onStatusChanged;
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
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 12 : 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: isMobile
                    ? 'Tìm kiếm...'
                    : 'Tìm kiếm theo mã đơn, tên khách hàng, email...',
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
                  horizontal: isMobile ? 12 : (isTablet ? 12 : 16),
                  vertical: isMobile ? 12 : (isTablet ? 12 : 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filters
            if (isMobile)
              // Mobile: Vertical layout
              Column(
                children: [
                  DropdownButtonFormField<OrderStatus>(
                    value: selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<OrderStatus>(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...OrderStatus.values.map((status) {
                        return DropdownMenuItem<OrderStatus>(
                          value: status,
                          child: Text(
                            status.adminDisplayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: onStatusChanged,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDateRange,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Khoảng thời gian',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                  if (selectedStatus != null ||
                      selectedDateRange != null ||
                      searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Xóa bộ lọc'),
                        onPressed: onClearFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else
              // Desktop/Tablet: Horizontal layout
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<OrderStatus>(
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
                      items: [
                        const DropdownMenuItem<OrderStatus>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        ...OrderStatus.values.map((status) {
                          return DropdownMenuItem<OrderStatus>(
                            value: status,
                            child: Text(status.adminDisplayName),
                          );
                        }),
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
                  if (selectedStatus != null ||
                      selectedDateRange != null ||
                      searchController.text.isNotEmpty)
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
  final List<OrderModel> orders;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;
  final Function(String orderId, OrderStatus newStatus)? onStatusUpdated;

  const _OrdersDataTable({
    required this.orders,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatPrice,
    required this.formatDate,
    this.onStatusUpdated,
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
      headingRowColor: WidgetStateProperty.all(AppColors.headerBackground),
      headingRowHeight: 56,
      columns: [
        DataColumn2(
          label: Text(
            'Mã đơn',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(0, ascending),
        ),
        DataColumn2(
          label: Text(
            'Khách hàng',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => onSort(1, ascending),
        ),
        DataColumn2(
          label: Text(
            'Sản phẩm',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) => onSort(2, ascending),
        ),
        DataColumn2(
          label: Text(
            'Tổng tiền',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.M,
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(3, ascending),
        ),
        DataColumn2(
          label: Text(
            'Hình thức thanh toán',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(4, ascending),
        ),
        DataColumn2(
          label: Text(
            'Trạng thái',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(5, ascending),
        ),
        DataColumn2(
          label: Text(
            'Ngày đặt',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => onSort(6, ascending),
        ),
        DataColumn2(
          label: Text(
            'Hành động',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          size: ColumnSize.S,
        ),
      ],
      source: _OrdersDataSource(
        orders: orders,
        context: context,
        onView: (order) {
          showDialog(
            context: context,
            builder: (context) => OrderDetailDialog(order: order),
          );
        },
        onEdit: (order) {
          // TODO: Edit order
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉnh sửa: ${order.orderCode}')),
          );
        },
        onStatusUpdated: onStatusUpdated,
        formatPrice: formatPrice,
        formatDate: formatDate,
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
  final List<OrderModel> orders;
  final BuildContext context;
  final Function(OrderModel) onView;
  final Function(OrderModel) onEdit;
  final Function(String orderId, OrderStatus newStatus)? onStatusUpdated;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;
  final OrderService _orderService = OrderService();
  final Map<String, bool> _updatingStatus = {};

  _OrdersDataSource({
    required this.orders,
    required this.context,
    required this.onView,
    required this.onEdit,
    this.onStatusUpdated,
    required this.formatPrice,
    required this.formatDate,
  });

  Future<void> _updateOrderStatus(OrderModel order, OrderStatus newStatus) async {
    if (_updatingStatus[order.id] == true) return; // Already updating

    // Update local state immediately for instant UI feedback
    onStatusUpdated?.call(order.id, newStatus);

    setState(() {
      _updatingStatus[order.id] = true;
    });
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(order.id, newStatus);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái đơn hàng ${order.orderCode}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Revert local state on error
      onStatusUpdated?.call(order.id, order.status);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _updatingStatus[order.id] = false;
      });
      notifyListeners();
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= orders.length) return null;

    final order = orders[index];

    return DataRow2(
      cells: [
        DataCell(
          Text(
            order.orderCode,
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
                order.fullName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order.phone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        DataCell(Text('${order.items.length} sản phẩm')),
        DataCell(
          Text(
            '${formatPrice(order.total)} đ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        DataCell(
          Builder(
            builder: (context) {
              final paymentColor = order.paymentMethod == PaymentMethod.cod
                  ? Colors.orange
                  : Colors.blue;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: paymentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.paymentMethod.name,
                  style: TextStyle(
                    color: order.paymentMethod == PaymentMethod.cod
                        ? Colors.orange[700]
                        : Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        DataCell(
          _updatingStatus[order.id] == true
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(order.status.color),
                  ),
                )
              : order.status == OrderStatus.cancelled
                  ? Tooltip(
                      message: 'Đơn hàng đã hủy không thể cập nhật trạng thái',
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.status.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: order.status.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: order.status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                order.status.adminDisplayName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: order.status.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lock,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      constraints: const BoxConstraints(minWidth: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: order.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: order.status.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<OrderStatus>(
                          value: order.status,
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: order.status.color,
                          ),
                          style: TextStyle(
                            color: order.status.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          items: OrderStatus.values.map((status) {
                            return DropdownMenuItem<OrderStatus>(
                              value: status,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: status.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      status.adminDisplayName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: status.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (OrderStatus? newStatus) {
                            if (newStatus != null && newStatus != order.status) {
                              _updateOrderStatus(order, newStatus);
                            }
                          },
                        ),
                      ),
                    ),
        ),
        DataCell(Text(formatDate(order.createdAt))),
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
  final List<OrderModel> orders;
  final TextEditingController searchController;
  final OrderStatus? selectedStatus;
  final String? selectedDateRange;
  final ValueChanged<OrderStatus?> onStatusChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;

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
    required this.formatDate,
  });

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
                          order.orderCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: order.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status.adminDisplayName,
                            style: TextStyle(
                              color: order.status.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.phone,
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
                          '${formatPrice(order.total)} đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (order.paymentMethod == PaymentMethod.cod
                                    ? Colors.orange
                                    : Colors.blue)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.paymentMethod.name,
                            style: TextStyle(
                              color: order.paymentMethod == PaymentMethod.cod
                                  ? Colors.orange[700]
                                  : Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(order.createdAt),
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
                            showDialog(
                              context: context,
                              builder: (context) => OrderDetailDialog(order: order),
                            );
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Sửa'),
                          onPressed: () {
                            // TODO: Edit order
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Chỉnh sửa: ${order.orderCode}')),
                            );
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
