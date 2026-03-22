import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/main.dart';
import 'package:video_audio_converter/screens/main_shell.dart';
import 'helpers/mock_converter_service.dart';

void main() {
  group('VideoAudioConverterApp 앱 스모크 테스트', () {
    testWidgets('앱이 정상적으로 실행됨', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Material3 테마 적용 확인', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      final theme = Theme.of(tester.element(find.byType(Scaffold).first));
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('MainShell이 렌더링됨', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('NavigationBar가 표시됨', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('NavigationBar에 "변환" 항목 표시', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.text('변환'), findsOneWidget);
    });

    testWidgets('NavigationBar에 "변환 목록" 항목 표시', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.text('변환 목록'), findsOneWidget);
    });
  });
}
