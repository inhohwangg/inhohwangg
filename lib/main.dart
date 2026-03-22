import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_shell.dart';
import 'services/converter_service.dart';

// M3 기본 seed color (동적 색상 미지원 기기 폴백)
const _seedColor = Color(0xFF6750A4);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ConverterServiceImpl.initializeCallbacks();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic != null
            ? lightDynamic.harmonized()
            : ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.light,
              );
        final darkScheme = darkDynamic != null
            ? darkDynamic.harmonized()
            : ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.dark,
              );

        return MaterialApp(
          title: '동영상 → 오디오 변환기',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(lightScheme),
          darkTheme: _buildTheme(darkScheme),
          themeMode: ThemeMode.system,
          home: MainShell(converterService: converterService),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: scheme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        indicatorColor: scheme.secondaryContainer,
        backgroundColor: scheme.surfaceContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 8,
      ),
    );
  }
}
