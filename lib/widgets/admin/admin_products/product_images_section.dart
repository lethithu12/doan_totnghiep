import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';

class ProductImagesSection extends StatelessWidget {
  final List<PlatformFile> selectedImageFiles;
  final List<String> imageUrls;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final bool isUploading;
  final bool isTablet;

  const ProductImagesSection({
    super.key,
    required this.selectedImageFiles,
    required this.imageUrls,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.isUploading,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final allImages = <Widget>[];
    
    // Add selected files
    for (int i = 0; i < selectedImageFiles.length; i++) {
      allImages.add(_buildImageItem(
        context: context,
        index: i,
        isFile: true,
        file: selectedImageFiles[i],
        isTablet: isTablet,
        onRemove: () => onRemoveImage(i),
      ));
    }
    
    // Add existing URLs
    for (int i = 0; i < imageUrls.length; i++) {
      allImages.add(_buildImageItem(
        context: context,
        index: selectedImageFiles.length + i,
        isFile: false,
        imageUrl: imageUrls[i],
        isTablet: isTablet,
        onRemove: () => onRemoveImage(selectedImageFiles.length + i),
      ));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hình ảnh sản phẩm',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 20,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: isUploading ? null : onPickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Thêm ảnh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isUploading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (allImages.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có hình ảnh',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: allImages,
              ),
            if (allImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Ảnh đầu tiên sẽ là ảnh chính (imageUrl), các ảnh còn lại là ảnh phụ (imageUrls)',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem({
    required BuildContext context,
    required int index,
    required bool isFile,
    PlatformFile? file,
    String? imageUrl,
    required bool isTablet,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: isTablet ? 120 : 150,
          height: isTablet ? 120 : 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isFile
                ? (kIsWeb
                    ? Image.memory(
                        file!.bytes!,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(file!.path!),
                        fit: BoxFit.cover,
                      ))
                : CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
          ),
        ),
        if (index == 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ảnh chính',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}

