import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/converter_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ConverterServiceImpl.initializeCallbacks();
  runApp(VideoAudioConverterApp(
    converterService: ConverterServiceImpl(),
  ));
}

class VideoAudioConverterApp extends StatelessWidget {
  final ConverterService converterService;

  const VideoAudioConverterApp({
    super.key,
    required this.converterService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '동영상 → 오디오 변환기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(converterService: converterService),
    );
  }
}
