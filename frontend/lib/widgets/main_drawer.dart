import 'package:flutter/material.dart';
import 'package:frontend/helpers/icon_helper.dart';
import 'package:frontend/models/role_nav_widgets_list.dart';
import 'package:frontend/widgets/custom_list_tile_drawer.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key, required this.onSelectPage, required this.roleId})
    : menuItems = RoleNavWidgetsList.navItems[roleId] ?? [];

  final void Function(String identifier) onSelectPage;
  final int roleId;
  final List<Map<String, String>> menuItems;

  void printMenuItems() {
    for (var item in menuItems) {
      print('Title: ${item['title']}');
      print('Title: ${item['icon']}');
      print('Title: ${item['destinationPath']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_transportation,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 18),
                Text(
                  'LCTMS',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return CustomListTileDrawer(
                  icon: getIconData(item['icon']!),
                  title: item['title']!,
                  destinationPath: item['destinationPath']!,
                  onSelectPage: onSelectPage,
                );
              },
            ),
          ),
          Spacer(),
          CustomListTileDrawer(
            icon: Icons.person,
            title: 'My Profile',
            destinationPath: '/profile',
            onSelectPage: onSelectPage,
          ),
          CustomListTileDrawer(
            icon: Icons.logout_rounded,
            title: 'Logout',
            destinationPath: '/login',
            onSelectPage: onSelectPage,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
