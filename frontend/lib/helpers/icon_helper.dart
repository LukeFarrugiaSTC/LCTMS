import 'package:flutter/material.dart';

// Returns the IconData for a given icon name string
IconData getIconData(String iconName) {
  final Map<String, IconData> iconMap = {
    'edit_calendar': Icons.edit_calendar,
    'history': Icons.history,
    'post_add': Icons.post_add,
    'people': Icons.people,
    'email': Icons.email,
  };

  return iconMap[iconName] ?? Icons.error;
}
