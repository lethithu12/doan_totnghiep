import 'package:flutter/material.dart';
import '../../../models/banner_model.dart';
import '../../../services/banner_service.dart';
import 'banners_list_view.dart';
import 'create_banner_dialog.dart';
import 'edit_banner_dialog.dart';
import 'delete_banner_dialog.dart';

class BannersManagementSection extends StatefulWidget {
  const BannersManagementSection({super.key});

  @override
  State<BannersManagementSection> createState() =>
      _BannersManagementSectionState();
}

class _BannersManagementSectionState extends State<BannersManagementSection> {
  final _bannerService = BannerService();

  Future<void> _handleCreateBanner() async {
    final result = await showDialog<BannerModel>(
      context: context,
      builder: (context) => const CreateBannerDialog(),
    );

    if (result != null && mounted) {
      try {
        await _bannerService.createBanner(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo banner thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi tạo banner: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEditBanner(BannerModel banner) async {
    final result = await showDialog<BannerModel>(
      context: context,
      builder: (context) => EditBannerDialog(banner: banner),
    );

    if (result != null && mounted) {
      try {
        await _bannerService.updateBanner(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật banner thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật banner: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteBanner(BannerModel banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteBannerDialog(banner: banner),
    );

    if (confirmed == true && mounted) {
      try {
        await _bannerService.deleteBanner(banner.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa banner thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa banner: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quản lý Banners',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: _handleCreateBanner,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm Banner'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<BannerModel>>(
              stream: _bannerService.getAllBanners(),
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
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }

                final banners = snapshot.data ?? [];
                if (banners.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Chưa có banner nào. Hãy thêm banner mới!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return BannersListView(
                  banners: banners,
                  onEdit: _handleEditBanner,
                  onDelete: _handleDeleteBanner,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

