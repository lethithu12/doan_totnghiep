import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../widgets/admin/admin_settings/banners_management_section.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 24 : 28,
                ),
          ),
          const SizedBox(height: 24),
          // Quản lý Banners
          const BannersManagementSection(),
        ],
      ),
    );
  }
}

