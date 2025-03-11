import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_list_tile_drawer.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.onSelectPage});

  final void Function(String identifier) onSelectPage;

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

          CustomListTileDrawer(
            icon: Icons.person,
            title: 'My Profile',
            destinationPath: '/profile',
            onSelectPage: onSelectPage,
          ),
          CustomListTileDrawer(
            icon: Icons.people,
            title: 'Users',
            destinationPath: '/users',
            onSelectPage: onSelectPage,
          ),
          Spacer(),
          CustomListTileDrawer(
            icon: Icons.logout_rounded,
            title: 'Logout',
            destinationPath: '/',
            onSelectPage: onSelectPage,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
