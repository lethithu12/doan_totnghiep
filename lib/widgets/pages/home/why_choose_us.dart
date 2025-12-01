import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../config/colors.dart';

class WhyChooseUs extends StatelessWidget {
  const WhyChooseUs({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final features = [
      {'icon': Icons.local_shipping, 'title': 'Giao hàng nhanh', 'desc': 'Miễn phí vận chuyển'},
      {'icon': Icons.verified, 'title': 'Chính hãng', 'desc': '100% sản phẩm chính hãng'},
      {'icon': Icons.support_agent, 'title': 'Hỗ trợ 24/7', 'desc': 'Tư vấn nhiệt tình'},
      {'icon': Icons.payment, 'title': 'Thanh toán', 'desc': 'Nhiều phương thức thanh toán'},
    ];
    if (isMobile) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: AppColors.headerBackground,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 24 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 24),
            child: Text(
              'Tại sao chọn chúng tôi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : 24,
                    color: AppColors.headerText,
                  ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          isMobile
              ? Column(
                  children: features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _FeatureItem(
                        icon: feature['icon'] as IconData,
                        title: feature['title'] as String,
                        desc: feature['desc'] as String,
                        isMobile: isMobile,
                      ),
                    );
                  }).toList(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: features.map((feature) {
                      return Expanded(
                        child: _FeatureItem(
                          icon: feature['icon'] as IconData,
                          title: feature['title'] as String,
                          desc: feature['desc'] as String,
                          isMobile: isMobile,
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isMobile;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isMobile ? 40 : 48,
            color: AppColors.headerText,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                  color: AppColors.headerText,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 4 : 4),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isMobile ? 14 : 16,
                  color: AppColors.headerText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

