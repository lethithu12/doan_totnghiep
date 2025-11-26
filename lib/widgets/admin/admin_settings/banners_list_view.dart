import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/banner_model.dart';

class BannersListView extends StatelessWidget {
  final List<BannerModel> banners;
  final Function(BannerModel) onEdit;
  final Function(BannerModel) onDelete;

  const BannersListView({
    super.key,
    required this.banners,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return _BannerCard(
            banner: banner,
            onEdit: () => onEdit(banner),
            onDelete: () => onDelete(banner),
            isMobile: true,
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
      ),
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return _BannerCard(
          banner: banner,
          onEdit: () => onEdit(banner),
          onDelete: () => onDelete(banner),
          isMobile: false,
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isMobile;

  const _BannerCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
    required this.isMobile,
  });

  String _getTimeRangeText() {
    if (banner.startDate == null && banner.endDate == null) {
      return 'Luôn hiển thị';
    }
    final start = banner.startDate != null
        ? '${banner.startDate!.day}/${banner.startDate!.month}/${banner.startDate!.year}'
        : '';
    final end = banner.endDate != null
        ? '${banner.endDate!.day}/${banner.endDate!.month}/${banner.endDate!.year}'
        : '';
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
    } else if (start.isNotEmpty) {
      return 'Từ $start';
    } else if (end.isNotEmpty) {
      return 'Đến $end';
    }
    return 'Luôn hiển thị';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          ),
          // Banner Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: banner.isActive ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        banner.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: banner.isActive ? Colors.green[800] : Colors.red[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thứ tự: ${banner.order}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeRangeText(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (banner.link != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Link: ${banner.link}',
                    style: TextStyle(fontSize: 11, color: Colors.blue[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

