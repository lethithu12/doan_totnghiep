import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 24 : 28,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng quan hệ thống',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 16,
                ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          // Stats cards
          _StatsGrid(isMobile: isMobile, isTablet: isTablet),
          SizedBox(height: isMobile ? 24 : 32),
          // Charts section
          _ChartsSection(isMobile: isMobile, isTablet: isTablet),
          SizedBox(height: isMobile ? 24 : 32),
          // Recent activities
          _RecentActivities(isMobile: isMobile, isTablet: isTablet),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _StatsGrid({
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'Tổng đơn hàng',
        'value': '1,234',
        'change': '+12.5%',
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
      {
        'title': 'Tổng doanh thu',
        'value': '2.5 tỷ',
        'change': '+8.2%',
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': 'Sản phẩm',
        'value': '456',
        'change': '+5.1%',
        'icon': Icons.inventory_2,
        'color': Colors.orange,
      },
      {
        'title': 'Người dùng',
        'value': '3,789',
        'change': '+15.3%',
        'icon': Icons.people,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 2.5 : 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _StatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          change: stat['change'] as String,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
          isMobile: isMobile,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isMobile;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? 24 : 28,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : 24,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 12 : 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _ChartsSection({
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biểu đồ thống kê',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _ChartCard(
                title: 'Doanh thu theo tháng',
                isMobile: isMobile,
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Đơn hàng theo ngày',
                isMobile: isMobile,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _ChartCard(
                  title: 'Doanh thu theo tháng',
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChartCard(
                  title: 'Đơn hàng theo ngày',
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final bool isMobile;

  const _ChartCard({
    required this.title,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                  ),
            ),
            const SizedBox(height: 24),
            // Placeholder for chart
            Container(
              height: isMobile ? 200 : 250,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: isMobile ? 48 : 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Biểu đồ sẽ được hiển thị ở đây',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 12 : 14,
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

class _RecentActivities extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _RecentActivities({
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'user': 'Nguyễn Văn A', 'action': 'Đã đặt hàng', 'time': '5 phút trước'},
      {'user': 'Trần Thị B', 'action': 'Đã hủy đơn hàng', 'time': '15 phút trước'},
      {'user': 'Lê Văn C', 'action': 'Đã thanh toán', 'time': '30 phút trước'},
      {'user': 'Phạm Thị D', 'action': 'Đã đặt hàng', 'time': '1 giờ trước'},
      {'user': 'Hoàng Văn E', 'action': 'Đã đánh giá sản phẩm', 'time': '2 giờ trước'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động gần đây',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  activity['user'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),
                subtitle: Text(
                  activity['action'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
                trailing: Text(
                  activity['time'] as String,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

