import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/colors.dart';
import '../../../services/category_service.dart';
import '../../../models/category_model.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final categoryService = CategoryService();
    
    return StreamBuilder<List<CategoryModel>>(
      stream: categoryService.getParentCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Lỗi: ${snapshot.error}'),
                ],
              ),
            ),
          );
        }

        final categories = snapshot.data ?? [];
        
        // Chỉ hiển thị categories có status "Hiển thị"
        final visibleCategories = categories.where((cat) => cat.status == 'Hiển thị').toList();

        if (isMobile) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Danh mục sản phẩm',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180, // 2 dòng x 90px mỗi item
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 dòng
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: visibleCategories.length,
                    itemBuilder: (context, index) {
                      final category = visibleCategories[index];
                      return InkWell(
                        onTap: () => context.go('/products?category=${category.id}'),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              child: category.imageUrl != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: category.imageUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.category,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.category,
                                      color: AppColors.primary,
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              category.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
    
        // Desktop: hiển thị dạng list row với màu trắng và nổi khối
        return Container(
          decoration: BoxDecoration(
            color: AppColors.categoryContainerBackground,
            borderRadius: BorderRadius.circular(AppColors.categoryBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: AppColors.categoryElevation * 2,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Danh mục',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              Expanded(
                child: visibleCategories.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có danh mục nào',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: visibleCategories.length,
                        itemBuilder: (context, index) {
                          final category = visibleCategories[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.categoryItemBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => context.go('/products?category=${category.id}'),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      category.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: CachedNetworkImage(
                                                imageUrl: category.imageUrl!,
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => Icon(
                                                  Icons.category,
                                                  color: AppColors.primary,
                                                  size: 24,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.category,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

