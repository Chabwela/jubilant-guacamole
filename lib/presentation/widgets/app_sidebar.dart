import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A navigation item definition for the sidebar.
class SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

/// Persistent left-side navigation panel used by Admin and Bank dashboards.
class AppSidebar extends ConsumerWidget {
  final AppUser user;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<SidebarItem> items;

  const AppSidebar({
    super.key,
    required this.user,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 220,
      color: AppColors.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header
          _buildHeader(),
          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: items
                  .map((item) => _NavItem(
                        item: item,
                        isSelected: selectedIndex == item.index,
                        onTap: () => onItemSelected(item.index),
                      ))
                  .toList(),
            ),
          ),

          const Divider(color: Color(0xFF1E3A5A), thickness: 1),
          // User info + logout
          _buildUserFooter(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            _roleLabel(user.role),
            style: const TextStyle(
              color: AppColors.sidebarText,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFooter(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.sidebarActive,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                color: AppColors.sidebarText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout, size: 18),
            color: AppColors.sidebarText,
            tooltip: AppStrings.logout,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.bank:
        return 'Bank Officer';
      case UserRole.student:
        return 'Student';
    }
  }
}

class _NavItem extends StatelessWidget {
  final SidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isSelected ? AppColors.sidebarActive : Colors.transparent,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          size: 18,
          color: isSelected
              ? AppColors.sidebarActiveText
              : AppColors.sidebarText,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected
                ? AppColors.sidebarActiveText
                : AppColors.sidebarText,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
