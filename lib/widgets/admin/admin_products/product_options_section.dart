import 'package:flutter/material.dart';

class ProductOptionsSection extends StatelessWidget {
  final List<String> versions;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> options;
  final TextEditingController versionController;
  final TextEditingController colorNameController;
  final TextEditingController colorHexController;
  final String? selectedVersionForOption;
  final String? selectedColorForOption;
  final TextEditingController optionOriginalPriceController;
  final TextEditingController optionDiscountController;
  final TextEditingController optionQuantityController;
  final int basePrice;
  final ValueChanged<String?> onVersionChanged;
  final ValueChanged<String?> onColorChanged;
  final VoidCallback onAddVersion;
  final Function(int) onRemoveVersion;
  final VoidCallback onAddColor;
  final Function(int) onRemoveColor;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;
  final bool isTablet;
  final bool isMobile;

  const ProductOptionsSection({
    super.key,
    required this.versions,
    required this.colors,
    required this.options,
    required this.versionController,
    required this.colorNameController,
    required this.colorHexController,
    required this.selectedVersionForOption,
    required this.selectedColorForOption,
    required this.optionOriginalPriceController,
    required this.optionDiscountController,
    required this.optionQuantityController,
    required this.basePrice,
    required this.onVersionChanged,
    required this.onColorChanged,
    required this.onAddVersion,
    required this.onRemoveVersion,
    required this.onAddColor,
    required this.onRemoveColor,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.isTablet,
    required this.isMobile,
  });

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    } else if (hexCode.length == 3) {
      final r = hexCode[0] + hexCode[0];
      final g = hexCode[1] + hexCode[1];
      final b = hexCode[2] + hexCode[2];
      return Color(int.parse('FF$r$g$b', radix: 16));
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tùy chọn sản phẩm (Phiên bản & Màu sắc)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 24),
            // Versions Section
            Text(
              'Phiên bản',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 18,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: versionController,
                    style: TextStyle(fontSize: isTablet ? 14 : 16),
                    decoration: InputDecoration(
                      labelText: 'Tên phiên bản',
                      hintText: 'Ví dụ: 128GB',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                    onSubmitted: (_) => onAddVersion(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onAddVersion,
                  icon: const Icon(Icons.add),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            if (versions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: versions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final version = entry.value;
                  return Chip(
                    label: Text(version),
                    onDeleted: () => onRemoveVersion(index),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Colors Section
            Text(
              'Màu sắc',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 18,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: colorNameController,
                    style: TextStyle(fontSize: isTablet ? 14 : 16),
                    decoration: InputDecoration(
                      labelText: 'Tên màu',
                      hintText: 'Ví dụ: Đỏ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: colorHexController,
                    style: TextStyle(fontSize: isTablet ? 14 : 16),
                    decoration: InputDecoration(
                      labelText: 'Mã màu (Hex)',
                      hintText: '#FF0000',
                      prefixText: '#',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isTablet ? 12 : 16,
                      ),
                    ),
                    onSubmitted: (_) => onAddColor(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onAddColor,
                  icon: const Icon(Icons.add),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            if (colors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final colorData = entry.value;
                  final colorName = colorData['name'] as String;
                  final colorHex = colorData['hex'] as String;
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: _hexToColor(colorHex),
                      radius: 12,
                    ),
                    label: Text(colorName),
                    onDeleted: () => onRemoveColor(index),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Options Section
            Text(
              'Tùy chọn sản phẩm',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Giá cơ bản: ${_formatPrice(basePrice)} đ (nếu không điền giá sẽ dùng giá này)',
              style: TextStyle(
                fontSize: isTablet ? 12 : 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            if (versions.isEmpty || colors.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vui lòng thêm ít nhất một phiên bản và một màu sắc trước khi tạo option',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 14,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedVersionForOption,
                      decoration: InputDecoration(
                        labelText: 'Phiên bản *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                      items: versions.map((version) {
                        return DropdownMenuItem<String>(
                          value: version,
                          child: Text(version),
                        );
                      }).toList(),
                      onChanged: onVersionChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedColorForOption,
                      decoration: InputDecoration(
                        labelText: 'Màu sắc *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                      items: colors.map((color) {
                        final name = color['name'] as String;
                        final hex = color['hex'] as String;
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _hexToColor(hex),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: onColorChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: optionOriginalPriceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: isTablet ? 14 : 16),
                      decoration: InputDecoration(
                        labelText: 'Giá gốc (tùy chọn)',
                        hintText: 'Để trống = dùng giá cơ bản',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: optionDiscountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: isTablet ? 14 : 16),
                      decoration: InputDecoration(
                        labelText: 'Giảm giá (%)',
                        hintText: '0-100',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: optionQuantityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: isTablet ? 14 : 16),
                      decoration: InputDecoration(
                        labelText: 'Số lượng *',
                        hintText: 'Nhập số lượng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 12 : 16,
                        ),
                      ),
                      onSubmitted: (_) => onAddOption(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onAddOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (options.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Danh sách options (${options.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 18,
                    ),
              ),
              const SizedBox(height: 12),
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final version = option['version'] as String;
                final colorName = option['colorName'] as String;
                final colorHex = option['colorHex'] as String;
                final originalPrice = option['originalPrice'] as int;
                final discount = option['discount'] as int;
                final quantity = option['quantity'] as int? ?? 0;
                final finalPrice = originalPrice - (originalPrice * discount ~/ 100);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(isTablet ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _hexToColor(colorHex),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$version - $colorName',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14 : 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Giá gốc: ${_formatPrice(originalPrice)} đ',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                if (discount > 0) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    'Giảm: $discount%',
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 14,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Giá cuối: ${_formatPrice(finalPrice)} đ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 14,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Số lượng: $quantity',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 14,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Remove button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onRemoveOption(index),
                        tooltip: 'Xóa option',
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

