import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/category_model.dart';

class ChildCategoriesList extends StatelessWidget {
  final List<CategoryModel> childCategories;
  final String? selectedChildId;
  final Function(String?) onChildSelected;

  const ChildCategoriesList({
    super.key,
    required this.childCategories,
    required this.selectedChildId,
    required this.onChildSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (childCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục con',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isMobile ? 60 : 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategories.length,
              itemBuilder: (context, index) {
                final category = childCategories[index];
                final isSelected = selectedChildId == category.id;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < childCategories.length - 1 ? 8 : 0,
                  ),
                  child: InkWell(
                    onTap: () => onChildSelected(isSelected ? null : category.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20,
                        vertical: isMobile ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: isMobile ? 13 : 14,
                          ),
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
  }
}

