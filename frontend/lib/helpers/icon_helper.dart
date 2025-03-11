import 'package:flutter/material.dart';

IconData getIconData(String iconName){

  final Map<String, IconData> iconMap = {
    'edit_calendar' : Icons.edit_calendar,
    'history' : Icons.history,
    'post_add' : Icons.post_add,
    'people' : Icons.people,
    'email' : Icons.email,
  };

  return iconMap[iconName] ?? Icons.error;
}

