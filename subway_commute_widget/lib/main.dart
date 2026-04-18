import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subway_commute_widget/core/theme/app_theme.dart';
import 'package:subway_commute_widget/features/debug/presentation/time_verification_screen.dart';
import 'package:subway_commute_widget/features/settings/presentation/settings_screen.dart';
import 'package:subway_commute_widget/features/home/presentation/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SubwayApp()));
}

class SubwayApp extends StatelessWidget {
  const SubwayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '지하철 출퇴근',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/debug': (_) => const TimeVerificationScreen(),
      },
    );
  }
}
