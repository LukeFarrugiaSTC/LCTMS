import 'package:flutter/material.dart';
import 'package:frontend/widgets/lctms.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // mobile devices will always view the app in portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(LCTMS());
}
