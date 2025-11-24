import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Chờ'),
              Tab(text: 'Giao hàng'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Hủy bỏ'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OrdersTab(status: 'Chờ'),
              _OrdersTab(status: 'Giao hàng'),
              _OrdersTab(status: 'Hoàn thành'),
              _OrdersTab(status: 'Hủy bỏ'),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final String status;

  const _OrdersTab({required this.status});

  // Map status to Vietnamese
  String get _statusKey {
    switch (status) {
      case 'Chờ':
        return 'pending';
      case 'Giao hàng':
        return 'delivering';
      case 'Hoàn thành':
        return 'completed';
      case 'Hủy bỏ':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock orders data based on status
    final orders = _getOrdersByStatus(_statusKey);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng $status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }

  List<Map<String, dynamic>> _getOrdersByStatus(String statusKey) {
    // Mock data - trong thực tế sẽ lấy từ API/Firebase
    final allOrders = [
      {
        'id': 'ORD-1001',
        'date': '2025-01-20',
        'status': 'pending',
        'products': [
          {
            'name': 'Laptop Acer Aspire Lite 15 AL15-71P...',
            'quantity': 1,
            'price': 13790000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
          {
            'name': 'Tai nghe Bluetooth True Wireless JBL...',
            'quantity': 1,
            'price': 3990000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
          {
            'name': 'iPhone 14 128GB | Chính hãng VN/A:',
            'quantity': 1,
            'price': 13690000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
        ],
      },
      {
        'id': 'ORD-1002',
        'date': '2025-01-19',
        'status': 'pending',
        'products': [
          {
            'name': 'iPhone 14 128GB | Chính hãng VN/A:',
            'quantity': 1,
            'price': 13690000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
        ],
      },
      {
        'id': 'ORD-1003',
        'date': '2025-01-18',
        'status': 'pending',
        'products': [
          {
            'name': 'Laptop Acer Aspire Lite 15 AL15-71P...',
            'quantity': 1,
            'price': 13790000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
        ],
      },
      {
        'id': 'ORD-2001',
        'date': '2025-01-17',
        'status': 'delivering',
        'products': [
          {
            'name': 'Samsung Galaxy S24 Ultra',
            'quantity': 1,
            'price': 24990000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
        ],
      },
      {
        'id': 'ORD-3001',
        'date': '2025-01-15',
        'status': 'completed',
        'products': [
          {
            'name': 'MacBook Pro M3',
            'quantity': 1,
            'price': 45990000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
        ],
      },
      {
        'id': 'ORD-4001',
        'date': '2025-01-10',
        'status': 'cancelled',
        'products': [
          {
            'name': 'iPad Pro 12.9 inch',
            'quantity': 1,
            'price': 28990000,
            'image': 'https://baotinmobile.vn/uploads/2025/09/iphone-17-2-400x400.jpg',
          },
        ],
      },
    ];

    return allOrders.where((order) => order['status'] == statusKey).toList();
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  int get _totalAmount {
    final products = order['products'] as List;
    return products.fold<int>(
      0,
      (sum, product) => sum + (product['price'] as int) * (product['quantity'] as int),
    );
  }

  int get _totalItems {
    final products = order['products'] as List;
    return products.fold<int>(
      0,
      (sum, product) => sum + (product['quantity'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = order['products'] as List<Map<String, dynamic>>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danh sách sản phẩm
            ...products.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hình ảnh sản phẩm
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey[400],
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Thông tin sản phẩm
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '(x${product['quantity']})',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatPrice(product['price'] as int)} ₫',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            // Tổng kết
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_totalItems sản phẩm',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  'Tổng số tiền: ${_formatPrice(_totalAmount)} ₫',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
