import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../config/colors.dart';
import '../services/auth_service.dart';
import 'header_orders_button.dart';

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
                _NavItem(
                  label: 'Danh mục',
                  route: '/categories',
                ),
                const SizedBox(width: 24),
                _NavItem(
                  label: 'Giỏ hàng',
                  route: '/cart',
                  icon: Icons.shopping_cart,
                ),
                const SizedBox(width: 24),
                HeaderOrdersButton(isMobile: false),
                const SizedBox(width: 24),
                _AccountButton(isMobile: false),
              ] else ...[
                // Mobile: Orders, Cart icon và Menu button
                HeaderOrdersButton(isMobile: true),
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.headerIcon,
                  ),
                  onPressed: () {
                    context.go('/cart');
                  },
                ),
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MobileNavItem(
              label: 'Trang chủ',
              icon: Icons.home,
              route: '/',
            ),
            const SizedBox(height: 16),
            _MobileNavItem(
              label: 'Sản phẩm',
              icon: Icons.phone_android,
              route: '/products',
            ),
            const SizedBox(height: 16),
            _MobileNavItem(
              label: 'Danh mục',
              icon: Icons.category,
              route: '/categories',
            ),
            const SizedBox(height: 16),
            _MobileNavItem(
              label: 'Đơn hàng',
              icon: Icons.receipt_long,
              route: '/orders',
            ),
            const SizedBox(height: 16),
            _MobileNavItem(
              label: 'Giỏ hàng',
              icon: Icons.shopping_cart,
              route: '/cart',
            ),
            const SizedBox(height: 16),
            _MobileAccountButton(),
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
                    : AppColors.headerNavInactive,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        context.go(route);
        Navigator.pop(context);
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
          // Show account menu when logged in
          return _NavItem(
            label: 'Tài khoản',
            route: '/profile',
            icon: Icons.person,
          );
        } else {
          // Show login button when not logged in
          return _LoginButton(isMobile: isMobile);
        }
      },
    );
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

  _MobileAccountButton();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        
        if (isLoggedIn) {
          return _MobileNavItem(
            label: 'Tài khoản',
            icon: Icons.person,
            route: '/profile',
          );
        } else {
          return ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Đăng nhập'),
            onTap: () {
              context.go('/login');
              Navigator.pop(context);
            },
          );
        }
      },
    );
  }
}

