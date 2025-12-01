import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';

class AdminShellLayout extends StatelessWidget {
  final Widget child;

  const AdminShellLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile) {
      return _AdminMobileLayout(child: child);
    } else {
      return _AdminDesktopLayout(
        child: child,
        isTablet: isTablet,
      );
    }
  }
}

class _AdminDesktopLayout extends StatefulWidget {
  final Widget child;
  final bool isTablet;

  const _AdminDesktopLayout({
    required this.child,
    required this.isTablet,
  });

  @override
  State<_AdminDesktopLayout> createState() => _AdminDesktopLayoutState();
}

class _AdminDesktopLayoutState extends State<_AdminDesktopLayout> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _AdminSidebar(
            isTablet: widget.isTablet,
            isCollapsed: _isCollapsed,
            onToggle: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _AdminMobileLayout extends StatefulWidget {
  final Widget child;

  const _AdminMobileLayout({required this.child});

  @override
  State<_AdminMobileLayout> createState() => _AdminMobileLayoutState();
}

class _AdminMobileLayoutState extends State<_AdminMobileLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _AdminDrawer(
        onItemSelected: () {
          _scaffoldKey.currentState?.closeDrawer();
        },
      ),
      body: widget.child,
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final bool isTablet;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _AdminSidebar({
    required this.isTablet,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final width = isCollapsed ? 70.0 : (isTablet ? 200.0 : 250.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      color: Colors.grey[900],
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isCollapsed ? 12 : (isTablet ? 16 : 20)),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: isTablet ? 24 : 28,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Thu gọn',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggle,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Mở rộng',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggle,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AdminSidebarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                  isActive: currentPath == '/admin',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.inventory_2,
                  label: 'Sản phẩm',
                  route: '/admin/products',
                  isActive: currentPath.startsWith('/admin/products'),
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.category,
                  label: 'Danh mục',
                  route: '/admin/categories',
                  isActive: currentPath == '/admin/categories',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.shopping_cart,
                  label: 'Đơn hàng',
                  route: '/admin/orders',
                  isActive: currentPath == '/admin/orders',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.rate_review,
                  label: 'Đánh giá',
                  route: '/admin/reviews',
                  isActive: currentPath == '/admin/reviews',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.people,
                  label: 'Người dùng',
                  route: '/admin/users',
                  isActive: currentPath == '/admin/users',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.home,
                  label: 'Sections Trang Chủ',
                  route: '/admin/home-sections',
                  isActive: currentPath == '/admin/home-sections',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                // _AdminSidebarItem(
                //   icon: Icons.analytics,
                //   label: 'Thống kê',
                //   route: '/admin/analytics',
                //   isActive: currentPath == '/admin/analytics',
                //   isTablet: isTablet,
                //   isCollapsed: isCollapsed,
                // ),
                const Divider(color: Colors.grey, height: 32),
                _AdminSidebarItem(
                  icon: Icons.settings,
                  label: 'Cài đặt',
                  route: '/admin/settings',
                  isActive: currentPath == '/admin/settings',
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                ),
                _AdminSidebarItem(
                  icon: Icons.logout,
                  label: 'Đăng xuất',
                  route: '/',
                  isActive: false,
                  isTablet: isTablet,
                  isCollapsed: isCollapsed,
                  onTap: () async {
                    final authService = AuthService();
                    try {
                      await authService.signOut();
                      if (context.mounted) {
                        context.go('/');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã đăng xuất thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi đăng xuất: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final VoidCallback onItemSelected;

  const _AdminDrawer({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AdminDrawerItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                  isActive: currentPath == '/admin',
                  onTap: () {
                    context.go('/admin');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.inventory_2,
                  label: 'Sản phẩm',
                  route: '/admin/products',
                  isActive: currentPath == '/admin/products',
                  onTap: () {
                    context.go('/admin/products');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.category,
                  label: 'Danh mục',
                  route: '/admin/categories',
                  isActive: currentPath == '/admin/categories',
                  onTap: () {
                    context.go('/admin/categories');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.shopping_cart,
                  label: 'Đơn hàng',
                  route: '/admin/orders',
                  isActive: currentPath == '/admin/orders',
                  onTap: () {
                    context.go('/admin/orders');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.rate_review,
                  label: 'Đánh giá',
                  route: '/admin/reviews',
                  isActive: currentPath == '/admin/reviews',
                  onTap: () {
                    context.go('/admin/reviews');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.people,
                  label: 'Người dùng',
                  route: '/admin/users',
                  isActive: currentPath == '/admin/users',
                  onTap: () {
                    context.go('/admin/users');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.home,
                  label: 'Sections Trang Chủ',
                  route: '/admin/home-sections',
                  isActive: currentPath == '/admin/home-sections',
                  onTap: () {
                    context.go('/admin/home-sections');
                    onItemSelected();
                  },
                ),
                // _AdminDrawerItem(
                //   icon: Icons.analytics,
                //   label: 'Thống kê',
                //   route: '/admin/analytics',
                //   isActive: currentPath == '/admin/analytics',
                //   onTap: () {
                //     context.go('/admin/analytics');
                //     onItemSelected();
                //   },
                // ),
                const Divider(color: Colors.grey, height: 32),
                _AdminDrawerItem(
                  icon: Icons.settings,
                  label: 'Cài đặt',
                  route: '/admin/settings',
                  isActive: currentPath == '/admin/settings',
                  onTap: () {
                    context.go('/admin/settings');
                    onItemSelected();
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.logout,
                  label: 'Đăng xuất',
                  route: '/',
                  isActive: false,
                  onTap: () async {
                    final authService = AuthService();
                    try {
                      await authService.signOut();
                      onItemSelected();
                      if (context.mounted) {
                        context.go('/');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã đăng xuất thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      onItemSelected();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi đăng xuất: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final bool isTablet;
  final bool isCollapsed;
  final VoidCallback? onTap;

  const _AdminSidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.isTablet,
    required this.isCollapsed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = InkWell(
      onTap: onTap ?? () => context.go(route),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 0 : (isTablet ? 12 : 16),
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          border: isActive
              ? Border(
                  left: BorderSide(
                    color: AppColors.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey[400],
              size: isTablet ? 20 : 22,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[400],
                    fontSize: isTablet ? 14 : 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: label,
        child: item,
      );
    }

    return item;
  }
}

class _AdminDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _AdminDrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : Colors.grey[400],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[400],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary.withOpacity(0.2),
      onTap: onTap,
    );
  }
}

