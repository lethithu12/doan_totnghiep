import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../config/colors.dart';
import '../services/auth_service.dart';
import 'header_orders_button.dart';
import 'header_cart_button.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.headerBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Logo
              GestureDetector(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: AppColors.headerIcon,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ChangStore',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.headerText,
                          ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Navigation Menu
              if (!isMobile) ...[
                _NavItem(
                  label: 'Trang chủ',
                  route: '/',
                ),
                const SizedBox(width: 24),
                _NavItem(
                  label: 'Sản phẩm',
                  route: '/products',
                ),
                const SizedBox(width: 24),
                HeaderCartButton(isMobile: false),
                const SizedBox(width: 24),
                HeaderOrdersButton(isMobile: false),
                const SizedBox(width: 24),
                _AccountButton(isMobile: false),
              ] else ...[
                // Mobile: Orders, Cart icon và Menu button
                HeaderOrdersButton(isMobile: true),
                HeaderCartButton(isMobile: true),
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.headerIcon,
                  ),
                  onPressed: () {
                    _showMobileMenu(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    // Get current route before showing bottom sheet
    final currentRoute = GoRouterState.of(context).uri.path;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MobileNavItem(
                    label: 'Trang chủ',
                    icon: Icons.home,
                    route: '/',
                    currentRoute: currentRoute,
                  ),
                  const SizedBox(height: 8),
                  _MobileNavItem(
                    label: 'Sản phẩm',
                    icon: Icons.phone_android,
                    route: '/products',
                    currentRoute: currentRoute,
                  ),
                  const SizedBox(height: 8),
                  _MobileNavItem(
                    label: 'Đơn hàng',
                    icon: Icons.receipt_long,
                    route: '/orders',
                    currentRoute: currentRoute,
                  ),
                  const SizedBox(height: 8),
                  _MobileNavItem(
                    label: 'Giỏ hàng',
                    icon: Icons.shopping_cart,
                    route: '/cart',
                    currentRoute: currentRoute,
                  ),
                  const SizedBox(height: 8),
                  _MobileAccountButton(currentRoute: currentRoute),
                  SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String route;
  final IconData? icon;

  const _NavItem({
    required this.label,
    required this.route,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.path == route;
    
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.headerNavActiveBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? AppColors.headerNavActive
                    : AppColors.headerText, // Màu trắng khi không active
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? AppColors.headerNavActive
                        : AppColors.headerText, // Màu trắng khi không active
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final String currentRoute;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        icon,
        color: isActive 
            ? Theme.of(context).colorScheme.primary 
            : Colors.grey[700],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : Colors.black87,
        ),
      ),
      trailing: isActive 
          ? Icon(
              Icons.check_circle,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}

class _AccountButton extends StatelessWidget {
  final bool isMobile;
  final AuthService _authService = AuthService();

  _AccountButton({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        
        if (isLoggedIn) {
          // Show account menu with logout option when logged in
          return _AccountMenuButton(isMobile: isMobile);
        } else {
          // Show login button when not logged in
          return _LoginButton(isMobile: isMobile);
        }
      },
    );
  }
}

class _AccountMenuButton extends StatefulWidget {
  final bool isMobile;
  final AuthService _authService = AuthService();

  _AccountMenuButton({required this.isMobile});

  @override
  State<_AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<_AccountMenuButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAccountMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              size: 18,
              color: AppColors.headerNavInactive,
            ),
            const SizedBox(width: 6),
            Text(
              'Tài khoản',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppColors.headerNavInactive,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: AppColors.headerNavInactive,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    if (widget.isMobile) {
      // Mobile: Show bottom sheet
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await widget._authService.signOut();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Desktop: Show popup menu
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + renderBox.size.height,
          offset.dx + renderBox.size.width,
          offset.dy + renderBox.size.height + 100,
        ),
        items: [
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.logout, size: 18),
                const SizedBox(width: 8),
                const Text('Đăng xuất'),
              ],
            ),
            onTap: () async {
              // Delay to allow menu to close first
              await Future.delayed(const Duration(milliseconds: 100));
              try {
                await widget._authService.signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
          ),
        ],
      );
    }
  }
}

class _LoginButton extends StatelessWidget {
  final bool isMobile;

  const _LoginButton({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.path == '/login';

    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.headerNavActiveBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? null
              : Border.all(
                  color: AppColors.headerNavInactive,
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login,
              size: isMobile ? 16 : 18,
              color: isActive
                  ? AppColors.headerNavActive
                  : AppColors.headerNavInactive,
            ),
            const SizedBox(width: 6),
            Text(
              'Đăng nhập',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: isMobile ? 13 : 14,
                    color: isActive
                        ? AppColors.headerNavActive
                        : AppColors.headerNavInactive,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileAccountButton extends StatelessWidget {
  final AuthService _authService = AuthService();
  final String currentRoute;

  _MobileAccountButton({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        
        if (isLoggedIn) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Tài khoản'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close bottom sheet first
              _showAccountMenu(context);
            },
          );
        } else {
          return ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Đăng nhập'),
            onTap: () {
              Navigator.pop(context);
              context.go('/login');
            },
          );
        }
      },
    );
  }

  void _showAccountMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      try {
                        await _authService.signOut();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

