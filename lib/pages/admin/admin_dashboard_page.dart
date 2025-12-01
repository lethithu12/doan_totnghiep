import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';

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
    final _orderService = OrderService();
    final _productService = ProductService();
    final _authService = AuthService();

    return StreamBuilder(
      stream: _orderService.getAllOrders(),
      builder: (context, orderSnapshot) {
        return StreamBuilder(
          stream: _productService.getProducts(),
          builder: (context, productSnapshot) {
            return StreamBuilder(
              stream: _authService.authStateChanges,
              builder: (context, userSnapshot) {
                // Calculate stats
                final orders = orderSnapshot.data ?? [];
                final products = productSnapshot.data ?? [];
                final totalRevenue = orders
                    .where((order) => order.status.value == 'completed')
                    .fold<int>(0, (sum, order) => sum + order.total);
                
                // Calculate changes (simplified - compare with previous period)
                final completedOrders = orders.where((o) => o.status.value == 'completed').length;
                final pendingOrders = orders.where((o) => o.status.value == 'pending').length;
                
                final stats = [
                  {
                    'title': 'Tổng đơn hàng',
                    'value': _formatNumber(orders.length),
                    'change': '+${pendingOrders} đang chờ',
                    'icon': Icons.shopping_cart,
                    'color': Colors.blue,
                  },
                  {
                    'title': 'Tổng doanh thu',
                    'value': _formatPrice(totalRevenue),
                    'change': '${completedOrders} đơn hoàn thành',
                    'icon': Icons.attach_money,
                    'color': Colors.green,
                  },
                  {
                    'title': 'Sản phẩm',
                    'value': _formatNumber(products.length),
                    'change': '${products.where((p) => p.status == 'Còn hàng').length} còn hàng',
                    'icon': Icons.inventory_2,
                    'color': Colors.orange,
                  },
                  {
                    'title': 'Đơn hoàn thành',
                    'value': _formatNumber(completedOrders),
                    'change': '${((completedOrders / (orders.isEmpty ? 1 : orders.length)) * 100).toStringAsFixed(1)}%',
                    'icon': Icons.check_circle,
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
              },
            );
          },
        );
      },
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000000000) {
      return '${(price / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} triệu';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    }
    return price.toString();
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
                chartType: 'revenue',
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Đơn hàng theo ngày',
                isMobile: isMobile,
                chartType: 'orders',
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
                  chartType: 'revenue',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChartCard(
                  title: 'Đơn hàng theo ngày',
                  isMobile: isMobile,
                  chartType: 'orders',
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
  final String chartType; // 'revenue' or 'orders'

  const _ChartCard({
    required this.title,
    required this.isMobile,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    final _orderService = OrderService();

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
            StreamBuilder(
              stream: _orderService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: isMobile ? 200 : 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final orders = snapshot.data ?? [];
                final chartData = chartType == 'revenue'
                    ? _getRevenueData(orders)
                    : _getOrdersData(orders);

                return Container(
                  height: isMobile ? 200 : 250,
                  padding: const EdgeInsets.all(8),
                  child: chartType == 'revenue'
                      ? _buildRevenueChart(chartData, isMobile)
                      : _buildOrdersChart(chartData, isMobile),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRevenueData(List orders) {
    final now = DateTime.now();
    final data = List.generate(6, (index) {
      final date = DateTime(now.year, now.month - 5 + index, 1);
      final monthOrders = orders.where((order) {
        final orderDate = order.createdAt;
        return orderDate.year == date.year &&
            orderDate.month == date.month &&
            order.status.value == 'completed';
      }).toList();
      final revenue = monthOrders.fold<double>(0.0, (sum, order) => sum + order.total.toDouble());
      return {
        'month': '${date.month}/${date.year}',
        'value': revenue.toDouble(),
      };
    });
    return data;
  }

  List<Map<String, dynamic>> _getOrdersData(List orders) {
    final now = DateTime.now();
    final data = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayOrders = orders.where((order) {
        final orderDate = order.createdAt;
        return orderDate.year == date.year &&
            orderDate.month == date.month &&
            orderDate.day == date.day;
      }).toList();
      return {
        'day': '${date.day}/${date.month}',
        'value': dayOrders.length.toDouble(),
      };
    });
    return data;
  }

  Widget _buildRevenueChart(List<Map<String, dynamic>> data, bool isMobile) {
    final maxValue = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['value'] as double);
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.grey[800]!,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()]['month'] as String,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatPrice(value),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: isMobile ? 10 : 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: spots.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.y,
                color: Colors.green[400],
                width: isMobile ? 16 : 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersChart(List<Map<String, dynamic>> data, bool isMobile) {
    final maxValue = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['value'] as double);
    }).toList();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.grey[800]!,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()]['day'] as String,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: isMobile ? 10 : 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            left: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxValue * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue[400],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue[600]!,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue[50],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000000) {
      return '${(price / 1000000000).toStringAsFixed(1)}T';
    } else if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toInt().toString();
  }
}


