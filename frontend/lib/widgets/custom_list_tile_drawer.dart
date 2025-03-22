import 'package:flutter/material.dart';

//Class defining the tiles inside the nav bar menu
class CustomListTileDrawer extends StatelessWidget {
  const CustomListTileDrawer({
    super.key,
    required this.icon,
    required this.title,
    required this.destinationPath,
    required this.onSelectPage,
  });

  final IconData icon;
  final String title;
  final String destinationPath;
  final void Function(String identifier) onSelectPage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 24,
        ),
      ),
      onTap: () {
        onSelectPage(destinationPath);
      },
    );
  }
}
