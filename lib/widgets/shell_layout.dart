import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'header.dart';

class ShellLayout extends StatefulWidget {
  final Widget child;

  const ShellLayout({
    super.key,
    required this.child,
  });

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
  int _getCurrentIndex(String path) {
    switch (path) {
      case '/':
        return 0;
      case '/products':
        return 1;
      case '/orders':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final currentPath = GoRouterState.of(context).uri.path;
    final currentIndex = _getCurrentIndex(currentPath);

    return Scaffold(
      body: Column(
        children: [
          // Header - hiển thị trên tất cả các màn hình
          const Header(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 0 : (isTablet ? 0 : 250),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar chỉ hiển thị trên mobile
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(index, context),
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.phone_android_outlined),
                  activeIcon: Icon(Icons.phone_android),
                  label: 'Sản phẩm',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Đơn hàng',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Tài khoản',
                ),
              ],
            )
          : null,
    );
  }
}
