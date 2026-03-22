import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/screens/converted_files_screen.dart';
import '../helpers/mock_converter_service.dart';

Widget _buildScreen(MockConverterService service) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: ConvertedFilesScreen(converterService: service),
  );
}

void main() {
  late MockConverterService mockService;

  setUp(() {
    mockService = MockConverterService();
  });

  group('ConvertedFilesScreen', () {
    testWidgets('앱바 타이틀 "변환된 파일 목록" 표시', (tester) async {
      setupEmptyFileList(mockService);

      await tester.pumpWidget(_buildScreen(mockService));
      await tester.pumpAndSettle();

      expect(find.text('변환된 파일 목록'), findsOneWidget);
    });

    testWidgets('파일이 없을 때 빈 상태 화면 표시', (tester) async {
      setupEmptyFileList(mockService);

      await tester.pumpWidget(_buildScreen(mockService));
      await tester.pumpAndSettle();

      expect(find.text('변환된 파일이 없습니다'), findsOneWidget);
      expect(find.text('동영상을 변환하면 여기에 표시됩니다'), findsOneWidget);
    });

    testWidgets('파일이 없을 때 폴더 아이콘 표시', (tester) async {
      setupEmptyFileList(mockService);

      await tester.pumpWidget(_buildScreen(mockService));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('로딩 중 CircularProgressIndicator 표시', (tester) async {
      setupEmptyFileList(mockService);

      await tester.pumpWidget(_buildScreen(mockService));
      // pumpAndSettle 전에 확인 (로딩 중 상태)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('새로고침 버튼 표시', (tester) async {
      setupEmptyFileList(mockService);

      await tester.pumpWidget(_buildScreen(mockService));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('새로고침 버튼 탭 시 getConvertedFiles 재호출', (tester) async {
      setupEmptyFileList(mockService);

      await tester.pumpWidget(_buildScreen(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // initState + 새로고침 = 2번 호출
      verify(() => mockService.getConvertedFiles()).called(2);
    });
  });
}
