import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/widgets/lctms.dart';
import 'package:frontend/config/api_config.dart';

class MyHttpOverrides extends HttpOverrides {
  final SecurityContext context;

  MyHttpOverrides(this.context);

  @override
  HttpClient createHttpClient(SecurityContext? _) {
    final HttpOverrides? currentOverride = HttpOverrides.current;
    HttpOverrides.global = null;
    final client = HttpClient(context: context);
    HttpOverrides.global = currentOverride;

    // Parse host and port from the apiBaseUrl
    final Uri parsedUri = Uri.parse(apiBaseUrl);
    final String apiHost = parsedUri.host;
    final int apiPort = parsedUri.hasPort
        ? parsedUri.port
        : (parsedUri.scheme == 'https' ? 443 : 80);

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final shouldTrust = host == apiHost && port == apiPort;
      if (kDebugMode) {
        print('Certificate check for $host:$port — trusted: $shouldTrust');
      }
      return shouldTrust;
    };

    return client;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final SecurityContext securityContext = SecurityContext(withTrustedRoots: false);

  try {
    final ByteData certData = await rootBundle.load('assets/certs/selfsigned.crt');
    securityContext.setTrustedCertificatesBytes(certData.buffer.asUint8List());
  } catch (e) {
    debugPrint('Failed to load certificate: $e');
  }

  HttpOverrides.global = MyHttpOverrides(securityContext);

  // Force portrait mode on mobile devices.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(ProviderScope(child: LCTMS()));
}