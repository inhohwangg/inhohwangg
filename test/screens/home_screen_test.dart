import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_audio_converter/screens/home_screen.dart';
import 'package:video_audio_converter/services/converter_service.dart';
import '../helpers/mock_converter_service.dart';

Widget _buildHomeScreen(MockConverterService service) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: HomeScreen(converterService: service),
  );
}

void main() {
  late MockConverterService mockService;

  setUp(() {
    mockService = MockConverterService();
  });

  group('HomeScreen 초기 상태', () {
    testWidgets('앱바 타이틀 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      expect(find.text('동영상 → 오디오 변환기'), findsOneWidget);
    });

    testWidgets('동영상 선택 안내 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      expect(find.text('동영상 파일 선택'), findsOneWidget);
      expect(find.textContaining('MP4'), findsOneWidget);
    });

    testWidgets('파일 선택 전 변환 버튼 비활성화', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('오디오로 변환'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('폴더 아이콘 버튼 표시됨 (파일 목록 이동)', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('형식 선택 위젯 초기에 숨겨짐', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      expect(find.text('출력 형식'), findsNothing);
    });
  });

  group('HomeScreen 변환 성공 시나리오', () {
    testWidgets('변환 성공 후 "변환 완료!" 카드 표시', (tester) async {
      setupConversionSuccess(mockService, outputPath: '/mock/result.mp3');

      final homeState = tester.state<dynamic>(
        find.byType(HomeScreen),
      );

      await tester.pumpWidget(_buildHomeScreen(mockService));

      // 직접 state를 통해 파일 경로 설정 후 변환 시작
      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('변환 완료!'), findsOneWidget);
    });

    testWidgets('변환 성공 후 공유 버튼 표시', (tester) async {
      setupConversionSuccess(mockService);

      await tester.pumpWidget(_buildHomeScreen(mockService));

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('공유'), findsWidgets);
    });
  });

  group('HomeScreen 변환 실패 시나리오', () {
    testWidgets('변환 실패 후 에러 카드 표시', (tester) async {
      setupConversionFailure(mockService, errorMessage: '지원하지 않는 형식입니다');

      await tester.pumpWidget(_buildHomeScreen(mockService));

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/input.mp4';
        state._selectedVideoName = 'input.mp4';
      });
      await tester.pump();

      await state.startConversion();
      await tester.pumpAndSettle();

      expect(find.text('변환 실패'), findsOneWidget);
      expect(find.text('지원하지 않는 형식입니다'), findsOneWidget);
    });
  });

  group('HomeScreen 형식/비트레이트 선택', () {
    testWidgets('파일 선택 시뮬레이션 후 형식 선택 위젯 표시', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/video.mp4';
        state._selectedVideoName = 'video.mp4';
      });
      await tester.pumpAndSettle();

      expect(find.text('출력 형식'), findsOneWidget);
      expect(find.text('비트레이트'), findsOneWidget);
    });

    testWidgets('파일 선택 후 변환 버튼 활성화', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(mockService));

      final state = tester.state(find.byType(HomeScreen)) as dynamic;
      state.setState(() {
        state._selectedVideoPath = '/mock/video.mp4';
        state._selectedVideoName = 'video.mp4';
      });
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('오디오로 변환'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
