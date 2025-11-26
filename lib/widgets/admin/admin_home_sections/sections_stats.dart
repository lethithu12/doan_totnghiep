import 'package:flutter/material.dart';
import '../../../models/home_section_model.dart';

class SectionsStats extends StatelessWidget {
  final List<HomeSectionModel> sections;

  const SectionsStats({
    super.key,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final totalSections = sections.length;
    final activeSections = sections.where((s) => s.isActive).length;
    final inactiveSections = sections.where((s) => !s.isActive).length;
    final inTimeRangeSections = sections.where((s) => s.shouldDisplay).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _SectionStatCard(
              title: 'Tổng sections',
              value: totalSections.toString(),
              icon: Icons.view_list,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SectionStatCard(
              title: 'Đang active',
              value: activeSections.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SectionStatCard(
              title: 'Đang inactive',
              value: inactiveSections.toString(),
              icon: Icons.cancel,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SectionStatCard(
              title: 'Đang hiển thị',
              value: inTimeRangeSections.toString(),
              icon: Icons.visibility,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SectionStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

