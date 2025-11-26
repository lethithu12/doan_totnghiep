import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/banner_service.dart';
import '../../../models/banner_model.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  final BannerService _bannerService = BannerService();
  int _currentPage = 0;
  Timer? _timer;
  List<BannerModel>? _banners;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _bannerService.getActiveBannersOnce();
      if (mounted) {
        setState(() {
          _banners = banners;
          _isLoading = false;
        });
        if (banners.isNotEmpty) {
          _startAutoPlay(banners.length);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startAutoPlay(int bannerCount) {
    if (bannerCount <= 1) return; // Không cần auto play nếu chỉ có 1 banner
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && bannerCount > 1 && mounted) {
        if (_currentPage < bannerCount - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: isMobile ? 200 : 500,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners == null || _banners!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: isMobile ? 200 : 500,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners!.length,
            itemBuilder: (context, index) {
              final banner = _banners![index];
              return InkWell(
                onTap: banner.link != null && banner.link!.isNotEmpty
                    ? () {
                        // Có thể mở link hoặc navigate
                        if (banner.link!.startsWith('/')) {
                          context.go(banner.link!);
                        } else {
                          // Mở URL external nếu cần
                        }
                      }
                    : null,
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
              );
            },
          ),
          // Indicator
          if (_banners!.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners!.length,
                  (index) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

