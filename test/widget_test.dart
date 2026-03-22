import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/main.dart';
import 'helpers/mock_converter_service.dart';

void main() {
  group('VideoAudioConverterApp 앱 스모크 테스트', () {
    testWidgets('앱이 정상적으로 실행됨', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      // 앱이 렌더링되는지 확인
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('앱 타이틀이 올바름', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.text('동영상 → 오디오 변환기'), findsOneWidget);
    });

    testWidgets('Material3 테마 적용 확인', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('홈 화면 Scaffold 렌더링', (tester) async {
      final mockService = MockConverterService();
      setupEmptyFileList(mockService);

      await tester.pumpWidget(VideoAudioConverterApp(
        converterService: mockService,
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
