import 'package:flutter/material.dart';

class ProductDropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<T> items;
  final List<String>? itemLabels;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool isTablet;
  final bool isMobile;

  const ProductDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    this.itemLabels,
    required this.onChanged,
    this.validator,
    required this.isTablet,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true, // Tránh overflow trên mobile
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 12 : 16,
        ),
      ),
      menuMaxHeight: isMobile ? MediaQuery.of(context).size.height * 0.4 : null, // Giới hạn chiều cao menu trên mobile
      itemHeight: isMobile ? 48.0 : null, // Chiều cao item trên mobile
      items: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final label = itemLabels != null && index < itemLabels!.length
            ? itemLabels![index]
            : item.toString();
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: isMobile ? 14 : null,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

