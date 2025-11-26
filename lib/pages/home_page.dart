import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/footer.dart';
import '../widgets/pages/home/banner_with_categories.dart';
import '../widgets/pages/home/dynamic_section.dart';
import '../widgets/pages/home/why_choose_us.dart';
import '../services/home_section_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionService = HomeSectionService();

    return SingleChildScrollView(
      child: ResponsiveConstraints(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner và Categories cùng row
            const BannerWithCategories(),
            
            // Dynamic Sections từ Firebase
            StreamBuilder(
              stream: sectionService.getActiveSections(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // Debug: Hiển thị lỗi để kiểm tra
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red[50],
                    child: Column(
                      children: [
                        Text(
                          'Lỗi khi tải sections: ${snapshot.error}',
                          style: TextStyle(color: Colors.red[800]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vui lòng kiểm tra Firebase console hoặc Firestore rules',
                          style: TextStyle(color: Colors.red[600], fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                final sections = snapshot.data ?? [];
                
                // Debug: Hiển thị số lượng sections
                if (sections.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Chưa có sections nào được tạo hoặc tất cả đều inactive/nằm ngoài thời gian hiển thị',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: sections.map((section) {
                    return DynamicSection(key: ValueKey(section.id), section: section);
                  }).toList(),
                );
              },
            ),
            
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


