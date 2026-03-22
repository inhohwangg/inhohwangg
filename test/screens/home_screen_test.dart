import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/screens/home_screen.dart';
import 'package:video_audio_converter/services/converter_service.dart';
import '../helpers/mock_converter_service.dart';

Widget _buildHomeScreen(MockConverterService service) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: HomeScreen(converterService: service),
    ),
  );
}

void main() {
  late MockConverterService mockService;

  setUp(() {
    mockService = MockConverterService();
  });

  group('HomeScreen 초기 상태', () {
    testWidgets('앱바 타이틀 "동영상 변환기" 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      expect(find.text('동영상 변환기'), findsOneWidget);
    });

    testWidgets('동영상 선택 안내 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      expect(find.text('동영상을 선택해주세요'), findsOneWidget);
    });

    testWidgets('파일 탐색기 열기 버튼 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      expect(find.text('파일 탐색기 열기'), findsOneWidget);
    });

    testWidgets('FAB "동영상 선택" 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      expect(find.text('동영상 선택'), findsOneWidget);
    });

    testWidgets('형식 선택 위젯 초기에 숨겨짐', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      expect(find.text('출력 형식'), findsNothing);
    });
  });

  group('HomeScreen 파일 선택 후 상태', () {
    testWidgets('파일 선택 후 형식/비트레이트 선택 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/video.mp4';
        state._selectedVideoName = 'video.mp4';
        state._selectedVideoSize = 1024 * 1024 * 50;
      });
      await tester.pumpAndSettle();

      expect(find.text('출력 형식'), findsOneWidget);
      expect(find.text('비트레이트'), findsOneWidget);
    });

    testWidgets('파일 선택 후 변환 버튼 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/video.mp4';
        state._selectedVideoName = 'video.mp4';
        state._selectedVideoSize = 1024 * 1024 * 50;
      });
      await tester.pumpAndSettle();

      expect(find.text('오디오로 변환 시작'), findsOneWidget);
    });

    testWidgets('파일 선택 후 파일명 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/my_video.mp4';
        state._selectedVideoName = 'my_video.mp4';
        state._selectedVideoSize = 1024 * 1024 * 30;
      });
      await tester.pumpAndSettle();

      expect(find.text('my_video.mp4'), findsOneWidget);
    });
  });

  group('HomeScreen 변환 성공 시나리오', () {
    testWidgets('변환 성공 후 "변환 완료" 카드 표시', (tester) async {
      setupConversionSuccess(mockService, outputPath: '/mock/result.mp3');

      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
        state._selectedVideoSize = 1024 * 1024 * 20;
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('변환 완료'), findsOneWidget);
    });

    testWidgets('변환 성공 후 공유 버튼 표시', (tester) async {
      setupConversionSuccess(mockService);

      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
        state._selectedVideoSize = 1024 * 1024;
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('공유'), findsWidgets);
    });
  });

  group('HomeScreen 변환 실패 시나리오', () {
    testWidgets('변환 실패 후 에러 메시지 표시', (tester) async {
      setupConversionFailure(mockService,
          errorMessage: '지원하지 않는 형식입니다');

      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
        state._selectedVideoSize = 1024 * 1024;
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('변환에 실패했습니다'), findsOneWidget);
      expect(find.text('지원하지 않는 형식입니다'), findsOneWidget);
    });

    testWidgets('변환 실패 후 "다시 시도" 버튼 표시', (tester) async {
      setupConversionFailure(mockService);

      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
        state._selectedVideoSize = 1024 * 1024;
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('다시 시도'), findsOneWidget);
    });
  });

  group('HomeScreen 형식 선택', () {
    testWidgets('형식 선택 후 selectedFormat 변경', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));
      await tester.pump();

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/video.mp4';
        state._selectedVideoName = 'video.mp4';
        state._selectedVideoSize = 1024 * 1024;
      });
      await tester.pumpAndSettle();

      expect(state._selectedFormat, equals(AudioFormat.mp3));
    });
  });
}
