import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class UsersStats extends StatelessWidget {
  final List<UserModel> users;
  final bool isTablet;

  const UsersStats({
    super.key,
    required this.users,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u.isActive).length;
    final adminUsers = users.where((u) => u.role == 'admin').length;

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

