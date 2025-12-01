import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../widgets/admin/admin_home_sections/sections_stats.dart';
import '../../widgets/admin/admin_home_sections/sections_search_and_filter_bar.dart';
import '../../widgets/admin/admin_home_sections/sections_data_table.dart';
import '../../widgets/admin/admin_home_sections/mobile_sections_view.dart';
import '../../widgets/admin/admin_home_sections/create_section_dialog.dart';
import '../../widgets/admin/admin_home_sections/edit_section_dialog.dart';
import '../../widgets/admin/admin_home_sections/delete_section_dialog.dart';
import '../../services/home_section_service.dart';
import '../../models/home_section_model.dart';

class AdminHomeSectionsPage extends StatefulWidget {
  const AdminHomeSectionsPage({super.key});

  @override
  State<AdminHomeSectionsPage> createState() => _AdminHomeSectionsPageState();
}

class _AdminHomeSectionsPageState extends State<AdminHomeSectionsPage> {
  final _sectionService = HomeSectionService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  List<HomeSectionModel> _allSections = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HomeSectionModel> _applyFilters(List<HomeSectionModel> sections) {
    return sections.where((section) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          section.title.toLowerCase().contains(searchQuery);

      // Status filter
      final matchesStatus = _selectedStatus == null ||
          (_selectedStatus == 'Active' && section.isActive) ||
          (_selectedStatus == 'Inactive' && !section.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _handleCreateSection() async {
    final result = await showDialog<HomeSectionModel>(
      context: context,
      builder: (context) => const CreateSectionDialog(),
    );

    if (result != null && mounted) {
      try {
        await _sectionService.createSection(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo section thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi tạo section: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEditSection(HomeSectionModel section) async {
    final result = await showDialog<HomeSectionModel>(
      context: context,
      builder: (context) => EditSectionDialog(section: section),
    );

    if (result != null && mounted) {
      try {
        await _sectionService.updateSection(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật section thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật section: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteSection(HomeSectionModel section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteSectionDialog(section: section),
    );

    if (confirmed == true && mounted) {
      try {
        await _sectionService.deleteSection(section.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa section thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa section: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sections Trang Chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleCreateSection,
            tooltip: 'Thêm section mới',
          ),
        ],
      ),
      body: StreamBuilder<List<HomeSectionModel>>(
        stream: _sectionService.getAllSections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          _allSections = snapshot.data ?? [];
          final filteredSections = _applyFilters(_allSections);

          return Column(
            children: [
              // Stats
              if (!isMobile)
              SectionsStats(sections: _allSections),

              // Search and Filter
              SectionsSearchAndFilterBar(
                searchController: _searchController,
                selectedStatus: _selectedStatus,
                onStatusChanged: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
                onClearFilters: () {
                  setState(() {
                    _selectedStatus = null;
                    _searchController.clear();
                  });
                },
              ),

              // Data Table or Mobile View
              Expanded(
                child: isMobile
                    ? MobileSectionsView(
                        sections: filteredSections,
                        onEdit: _handleEditSection,
                        onDelete: _handleDeleteSection,
                      )
                    : SectionsDataTable(
                        sections: filteredSections,
                        onEdit: _handleEditSection,
                        onDelete: _handleDeleteSection,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

