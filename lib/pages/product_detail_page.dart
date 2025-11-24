import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/footer.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedImageIndex = 0;
  String? selectedVersion;
  String? selectedColor;

  // Mock data
  final List<String> productImages = List.generate(
    5,
    (index) => 'https://images.unsplash.com/photo-1609692814858-f7cd2f0afa4f?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  );
  final List<String> versions = ['128GB', '256GB', '512GB'];
  final List<Map<String, dynamic>> colors = [
    {'name': 'Đỏ', 'color': Colors.red},
    {'name': 'Xanh', 'color': Colors.blue},
    {'name': 'Đen', 'color': Colors.black},
    {'name': 'Trắng', 'color': Colors.white},
  ];

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final price = 15000000;

    // Responsive values
    final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final imageHeight = isMobile ? 300.0 : (isTablet ? 400.0 : 500.0);
    final imageIconSize = isMobile ? 80.0 : (isTablet ? 100.0 : 120.0);
    final thumbnailSize = isMobile ? 80.0 : (isTablet ? 90.0 : 100.0);
    final thumbnailHeight = isMobile ? 80.0 : (isTablet ? 90.0 : 100.0);
    final thumbnailIconSize = isMobile ? 30.0 : (isTablet ? 35.0 : 40.0);

    return SingleChildScrollView(
      child: Column(
        children: [
          ResponsiveConstraints(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ảnh chính và list ảnh
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ảnh chính
                            Container(
                              width: double.infinity,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  productImages[selectedImageIndex],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image,
                                      size: imageIconSize,
                                      color: Colors.grey[400],
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            // List ảnh nhỏ
                            SizedBox(
                              height: thumbnailHeight,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productImages.length,
                                itemBuilder: (context, index) {
                                  final isSelected = index == selectedImageIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImageIndex = index;
                                      });
                                    },
                                    child: Container(
                                      width: thumbnailSize,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          productImages[index],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image,
                                              size: thumbnailIconSize,
                                              color: Colors.grey[400],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Thông tin sản phẩm
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên sản phẩm
                            Text(
                              'Sản phẩm ${widget.productId}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            // Giá
                            Text(
                              '${_formatPrice(price)} đ',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            // Phiên bản
                            Text(
                              'Phiên bản',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: versions.map((version) {
                                final isSelected = selectedVersion == version;
                                return ChoiceChip(
                                  label: Text(
                                    version,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedVersion = selected ? version : null;
                                    });
                                  },
                                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            // Màu sắc
                            Text(
                              'Màu sắc',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: colors.map((colorData) {
                                final isSelected = selectedColor == colorData['name'];
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: colorData['color'] as Color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        colorData['name'] as String,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedColor = selected ? colorData['name'] as String : null;
                                    });
                                  },
                                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            // Nút Mua ngay
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(14),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: const Text(
                                  'Mua ngay',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Nút Thêm vào giỏ hàng
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(14),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'Thêm vào giỏ hàng',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : ResponsiveRowColumn(
                      layout: ResponsiveRowColumnType.ROW,
                      children: [
                        // Bên trái: Ảnh chính và list ảnh
                        ResponsiveRowColumnItem(
                          child: Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: isTablet ? 16 : 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ảnh chính
                                  Container(
                                    width: double.infinity,
                                    height: imageHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        productImages[selectedImageIndex],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image,
                                            size: imageIconSize,
                                            color: Colors.grey[400],
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // List ảnh nhỏ
                                  SizedBox(
                                    height: thumbnailHeight,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: productImages.length,
                                      itemBuilder: (context, index) {
                                        final isSelected = index == selectedImageIndex;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedImageIndex = index;
                                            });
                                          },
                                          child: Container(
                                            width: thumbnailSize,
                                            margin: const EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                productImages[index],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.image,
                                                    size: thumbnailIconSize,
                                                    color: Colors.grey[400],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Bên phải: Thông tin sản phẩm
                        ResponsiveRowColumnItem(
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên sản phẩm
                                Text(
                                  'Sản phẩm ${widget.productId}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 22 : 24,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                // Giá
                                Text(
                                  '${_formatPrice(price)} đ',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 26 : 28,
                                      ),
                                ),
                                const SizedBox(height: 32),
                                // Phiên bản
                                Text(
                                  'Phiên bản',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: versions.map((version) {
                                    final isSelected = selectedVersion == version;
                                    return ChoiceChip(
                                      label: Text(
                                        version,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          selectedVersion = selected ? version : null;
                                        });
                                      },
                                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                                // Màu sắc
                                Text(
                                  'Màu sắc',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: colors.map((colorData) {
                                    final isSelected = selectedColor == colorData['name'];
                                    return ChoiceChip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: colorData['color'] as Color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            colorData['name'] as String,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          selectedColor = selected ? colorData['name'] as String : null;
                                        });
                                      },
                                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 32),
                                // Nút Mua ngay
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                    child: const Text(
                                      'Mua ngay',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Nút Thêm vào giỏ hàng
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      'Thêm vào giỏ hàng',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Phần mô tả chi tiết sản phẩm
          _ProductDescription(productId: widget.productId),
          const Footer(),
        ],
      ),
    );
  }
}

class _ProductDescription extends StatefulWidget {
  final String productId;

  const _ProductDescription({required this.productId});

  @override
  State<_ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<_ProductDescription>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
        vertical: isMobile ? 24 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Mô tả'),
              Tab(text: 'Thông số'),
              Tab(text: 'Đánh giá'),
            ],
          ),
          SizedBox(
            height: isMobile ? 400 : 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Mô tả
                _DescriptionTab(isMobile: isMobile),
                // Tab Thông số
                _SpecificationsTab(isMobile: isMobile),
                // Tab Đánh giá
                _ReviewsTab(isMobile: isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  final bool isMobile;

  const _DescriptionTab({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả sản phẩm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 20,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sản phẩm điện tử cao cấp với thiết kế hiện đại và tính năng vượt trội. Được chế tạo từ những vật liệu chất lượng cao, sản phẩm mang đến trải nghiệm sử dụng tuyệt vời cho người dùng.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: isMobile ? 14 : 16,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tính năng nổi bật',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
          ),
          const SizedBox(height: 12),
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 20 : 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tính năng ${index + 1}: Mô tả chi tiết về tính năng nổi bật của sản phẩm, giúp người dùng hiểu rõ hơn về sản phẩm.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isMobile ? 14 : 16,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SpecificationsTab extends StatelessWidget {
  final bool isMobile;

  const _SpecificationsTab({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final specifications = [
      {'label': 'Màn hình', 'value': '6.7 inch, Super Retina XDR'},
      {'label': 'Bộ xử lý', 'value': 'Chip A17 Pro'},
      {'label': 'RAM', 'value': '8GB'},
      {'label': 'Bộ nhớ trong', 'value': '128GB / 256GB / 512GB'},
      {'label': 'Camera sau', 'value': '48MP + 12MP + 12MP'},
      {'label': 'Camera trước', 'value': '12MP TrueDepth'},
      {'label': 'Pin', 'value': '4422 mAh'},
      {'label': 'Sạc nhanh', 'value': 'Có, 20W'},
      {'label': 'Kết nối', 'value': '5G, Wi-Fi 6E, Bluetooth 5.3'},
      {'label': 'Hệ điều hành', 'value': 'iOS 17'},
      {'label': 'Kích thước', 'value': '159.9 x 76.7 x 8.25 mm'},
      {'label': 'Trọng lượng', 'value': '221g'},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông số kỹ thuật',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 20,
                ),
          ),
          const SizedBox(height: 24),
          ...specifications.map((spec) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      spec['label'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : 16,
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      spec['value'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey[700],
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatefulWidget {
  final bool isMobile;

  const _ReviewsTab({required this.isMobile});

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  late List<Map<String, dynamic>> reviews;

  @override
  void initState() {
    super.initState();
    reviews = List.generate(5, (index) => {
      'user': 'Người dùng ${index + 1}',
      'rating': 4.0 + (index % 5) * 0.2,
      'date': '${index + 1} ngày trước',
      'comment': 'Sản phẩm rất tốt, đúng như mô tả. Giao hàng nhanh, đóng gói cẩn thận. Tôi rất hài lòng với sản phẩm này.',
    });
  }

  void _showWriteReviewDialog() {
    if (widget.isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _WriteReviewBottomSheet(
          onReviewSubmitted: (review) {
            setState(() {
              reviews.insert(0, review);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cảm ơn bạn đã đánh giá!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => _WriteReviewDialog(
          onReviewSubmitted: (review) {
            setState(() {
              reviews.insert(0, review);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cảm ơn bạn đã đánh giá!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá sản phẩm',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isMobile ? 18 : 20,
                    ),
              ),
              TextButton(
                onPressed: _showWriteReviewDialog,
                child: const Text('Viết đánh giá'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...reviews.map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: widget.isMobile ? 20 : 24,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (review['user'] as String)[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['user'] as String,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.isMobile ? 14 : 16,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  final rating = review['rating'] as double;
                                  return Icon(
                                    index < rating.floor()
                                        ? Icons.star
                                        : (index < rating ? Icons.star_half : Icons.star_border),
                                    size: widget.isMobile ? 14 : 16,
                                    color: Colors.amber,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  review['date'] as String,
                                  style: TextStyle(
                                    fontSize: widget.isMobile ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review['comment'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: widget.isMobile ? 14 : 16,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _WriteReviewDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onReviewSubmitted;

  const _WriteReviewDialog({required this.onReviewSubmitted});

  @override
  State<_WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<_WriteReviewDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final review = {
      'user': _nameController.text.trim().isEmpty ? 'Người dùng' : _nameController.text.trim(),
      'rating': _rating.toDouble(),
      'date': 'Vừa xong',
      'comment': _commentController.text.trim(),
    };

    widget.onReviewSubmitted(review);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Viết đánh giá',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tên người dùng
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên của bạn (tùy chọn)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Đánh giá sao
            Text(
              'Đánh giá của bạn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _rating ? Colors.amber : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Nội dung đánh giá
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Nội dung đánh giá *',
                hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nút gửi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text(
                  'Gửi đánh giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteReviewBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onReviewSubmitted;

  const _WriteReviewBottomSheet({required this.onReviewSubmitted});

  @override
  State<_WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<_WriteReviewBottomSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final review = {
      'user': _nameController.text.trim().isEmpty ? 'Người dùng' : _nameController.text.trim(),
      'rating': _rating.toDouble(),
      'date': 'Vừa xong',
      'comment': _commentController.text.trim(),
    };

    widget.onReviewSubmitted(review);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Viết đánh giá',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tên người dùng
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên của bạn (tùy chọn)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Đánh giá sao
          Text(
            'Đánh giá của bạn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 36,
                  color: index < _rating ? Colors.amber : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Nội dung đánh giá
          TextField(
            controller: _commentController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Nội dung đánh giá *',
              hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Nút gửi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text(
                'Gửi đánh giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

