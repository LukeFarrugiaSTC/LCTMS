import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/helpers/icon_helper.dart';
import 'package:frontend/models/role_nav_widgets_list.dart';
import 'package:frontend/widgets/custom_list_tile_drawer.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key, required this.onSelectPage, required this.roleId})
      : menuItems = RoleNavWidgetsList.navItems[roleId] ?? [];

  final void Function(String identifier) onSelectPage;
  final int roleId;
  final List<Map<String, String>> menuItems;

  // Logout function integrated into MainDrawer.
  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      // If no token, navigate to login.
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = Uri.parse('$apiBaseUrl/endpoints/user/logout.php');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Raw response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        // Remove the token and navigate to the login page.
        await storage.delete(key: 'jwt_token');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Logout failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred. Please try again later.')),
      );
      debugPrint('Logout error: $e');
    }
  }

  void printMenuItems() {
    for (var item in menuItems) {
      print('Title: ${item['title']}');
      print('Icon: ${item['icon']}');
      print('Destination Path: ${item['destinationPath']}');
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
                  const Color.fromARGB(255, 243, 231, 231),
                  const Color.fromARGB(200, 243, 231, 231),
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
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
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
          const Spacer(),
          CustomListTileDrawer(
            icon: Icons.person,
            title: 'My Profile',
            destinationPath: '/profile',
            onSelectPage: onSelectPage,
          ),
          CustomListTileDrawer(
            icon: Icons.logout_rounded,
            title: 'Logout',
            destinationPath: '/login', // fallback path if needed
            onSelectPage: (_) {
              _logout(context);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}