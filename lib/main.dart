import 'package:aws_common/aws_common.dart';
import 'package:coffee/scaffold.dart';
import 'package:coffee/screens/home_screen.dart';
import 'package:coffee/theme.dart';
import 'package:coffee/util/provider_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  AWSLogger().logLevel = zDebugMode ? LogLevel.verbose : LogLevel.info;

  FlutterError.onError = (details) {
    showErrorSnackBar(details.exceptionAsString());
    if (zDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  runApp(
    const ProviderScope(
      observers: [ProviderLogger()],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coffeeBrown,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
