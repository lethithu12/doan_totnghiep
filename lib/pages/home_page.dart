import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/footer.dart';
import '../widgets/pages/home/banner_with_categories.dart';
import '../widgets/pages/home/featured_products.dart';
import '../widgets/pages/home/why_choose_us.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ResponsiveConstraints(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner và Categories cùng row
            const BannerWithCategories(),
            
            // Featured Products
            const FeaturedProducts(),
            
            // Why Choose Us
            const WhyChooseUs(),
            
            // Footer
            const Footer(),
          ],
        ),
      ),
    );
  }
}


