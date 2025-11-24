import 'package:go_router/go_router.dart';
import '../../pages/home_page.dart';
import '../../pages/products_page.dart';
import '../../pages/categories_page.dart';
import '../../pages/cart_page.dart';
import '../../pages/orders_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/product_detail_page.dart';
import '../../pages/login_page.dart';
import '../../pages/admin/admin_dashboard_page.dart';
import '../../pages/admin/admin_products_page.dart';
import '../../pages/admin/admin_product_form_page.dart';
import '../../pages/admin/admin_categories_page.dart';
import '../../pages/admin/admin_orders_page.dart';
import '../../pages/admin/admin_users_page.dart';
import '../../pages/admin/admin_analytics_page.dart';
import '../../pages/admin/admin_settings_page.dart';
import '../../widgets/shell_layout.dart';
import '../../widgets/admin/admin_shell_layout.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ShellLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'product-detail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return ProductDetailPage(productId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AdminShellLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/admin',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/products',
          name: 'admin-products',
          builder: (context, state) => const AdminProductsPage(),
        ),
        GoRoute(
          path: '/admin/products/new',
          name: 'admin-product-create',
          builder: (context, state) => const AdminProductFormPage(),
        ),
        GoRoute(
          path: '/admin/products/:id/edit',
          name: 'admin-product-edit',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return AdminProductFormPage(productId: id);
          },
        ),
        GoRoute(
          path: '/admin/categories',
          name: 'admin-categories',
          builder: (context, state) => const AdminCategoriesPage(),
        ),
        GoRoute(
          path: '/admin/orders',
          name: 'admin-orders',
          builder: (context, state) => const AdminOrdersPage(),
        ),
        GoRoute(
          path: '/admin/users',
          name: 'admin-users',
          builder: (context, state) => const AdminUsersPage(),
        ),
        GoRoute(
          path: '/admin/analytics',
          name: 'admin-analytics',
          builder: (context, state) => const AdminAnalyticsPage(),
        ),
        GoRoute(
          path: '/admin/settings',
          name: 'admin-settings',
          builder: (context, state) => const AdminSettingsPage(),
        ),
      ],
    ),
  ],
);

