import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    
    // Ẩn footer trên mobile
    if (isMobile) {
      return const SizedBox.shrink();
    }
    
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 24 : 48),
        vertical: isMobile ? 24 : (isTablet ? 32 : 48),
      ),
      child: ResponsiveRowColumn(
        layout: isMobile
            ? ResponsiveRowColumnType.COLUMN
            : ResponsiveRowColumnType.ROW,
        rowCrossAxisAlignment: CrossAxisAlignment.start,
        columnCrossAxisAlignment: CrossAxisAlignment.start,
        rowSpacing: isTablet ? 16 : 24,
        columnSpacing: isMobile ? 24 : 0,
        children: [
          ResponsiveRowColumnItem(
            child: isMobile 
                ? _FooterSection(
                    title: 'Về chúng tôi',
                    isMobile: isMobile,
                    children: [
                      _FooterLink('Giới thiệu', () {}, isMobile),
                      _FooterLink('Liên hệ', () {}, isMobile),
                      _FooterLink('Tuyển dụng', () {}, isMobile),
                      _FooterLink('Tin tức', () {}, isMobile),
                    ],
                  )
                : Expanded(
                    child: _FooterSection(
                      title: 'Về chúng tôi',
                      isMobile: isMobile,
                      children: [
                        _FooterLink('Giới thiệu', () {}, isMobile),
                        _FooterLink('Liên hệ', () {}, isMobile),
                        _FooterLink('Tuyển dụng', () {}, isMobile),
                        _FooterLink('Tin tức', () {}, isMobile),
                      ],
                    ),
                  ),
          ),
          ResponsiveRowColumnItem(
            child: isMobile
                ? _FooterSection(
                    title: 'Hỗ trợ',
                    isMobile: isMobile,
                    children: [
                      _FooterLink('Câu hỏi thường gặp', () {}, isMobile),
                      _FooterLink('Hướng dẫn mua hàng', () {}, isMobile),
                      _FooterLink('Chính sách đổi trả', () {}, isMobile),
                      _FooterLink('Bảo hành', () {}, isMobile),
                    ],
                  )
                : Expanded(
                    child: _FooterSection(
                      title: 'Hỗ trợ',
                      isMobile: isMobile,
                      children: [
                        _FooterLink('Câu hỏi thường gặp', () {}, isMobile),
                        _FooterLink('Hướng dẫn mua hàng', () {}, isMobile),
                        _FooterLink('Chính sách đổi trả', () {}, isMobile),
                        _FooterLink('Bảo hành', () {}, isMobile),
                      ],
                    ),
                  ),
          ),
          ResponsiveRowColumnItem(
            child: isMobile
                ? _FooterSection(
                    title: 'Liên kết',
                    isMobile: isMobile,
                    children: [
                      _FooterLink('Facebook', () {}, isMobile),
                      _FooterLink('Instagram', () {}, isMobile),
                      _FooterLink('Twitter', () {}, isMobile),
                      _FooterLink('YouTube', () {}, isMobile),
                    ],
                  )
                : Expanded(
                    child: _FooterSection(
                      title: 'Liên kết',
                      isMobile: isMobile,
                      children: [
                        _FooterLink('Facebook', () {}, isMobile),
                        _FooterLink('Instagram', () {}, isMobile),
                        _FooterLink('Twitter', () {}, isMobile),
                        _FooterLink('YouTube', () {}, isMobile),
                      ],
                    ),
                  ),
          ),
          ResponsiveRowColumnItem(
            child: isMobile
                ? _FooterSection(
                    title: 'Thông tin',
                    isMobile: isMobile,
                    children: [
                      _FooterLink('Địa chỉ: 123 Đường ABC, Quận XYZ', () {}, isMobile),
                      _FooterLink('Hotline: 1900 1234', () {}, isMobile),
                      _FooterLink('Email: info@doanelectronic.com', () {}, isMobile),
                    ],
                  )
                : Expanded(
                    child: _FooterSection(
                      title: 'Thông tin',
                      isMobile: isMobile,
                      children: [
                        _FooterLink('Địa chỉ: 123 Đường ABC, Quận XYZ', () {}, isMobile),
                        _FooterLink('Hotline: 1900 1234', () {}, isMobile),
                        _FooterLink('Email: info@doanelectronic.com', () {}, isMobile),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isMobile;

  const _FooterSection({
    required this.title,
    required this.children,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : 18,
              ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        ...children,
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isMobile;

  const _FooterLink(this.text, this.onTap, this.isMobile);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 10 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 4 : 0,
            vertical: isMobile ? 4 : 0,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: isMobile ? 14 : 16,
                ),
          ),
        ),
      ),
    );
  }
}

