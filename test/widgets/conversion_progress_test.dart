import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/widgets/conversion_progress.dart';

Widget _buildTestWidget(double progress, {String? fileName}) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: ConversionProgress(progress: progress, fileName: fileName),
    ),
  );
}

void main() {
  group('ConversionProgress 위젯', () {
    testWidgets('Card 위젯이 렌더링됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.0));
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('진행률 0일 때 "분석 중..." 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.0));
      await tester.pump();

      expect(find.textContaining('분석 중'), findsOneWidget);
    });

    testWidgets('진행률 0.5일 때 "50%" 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.5));
      await tester.pump();

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('진행률 1.0일 때 "100%" 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(1.0));
      await tester.pump();

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('진행률 0.3일 때 "30%" 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.3));
      await tester.pump();

      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('파일명이 전달되면 표시됨', (tester) async {
      await tester.pumpWidget(
          _buildTestWidget(0.5, fileName: 'test_video.mp4'));
      await tester.pump();

      expect(find.text('test_video.mp4'), findsOneWidget);
    });

    testWidgets('파일명이 null이면 표시되지 않음', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.5));
      await tester.pump();

      expect(find.text('test_video.mp4'), findsNothing);
    });

    testWidgets('진행률 > 0 시 "오디오 추출 중" 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.4));
      await tester.pump();

      expect(find.textContaining('오디오 추출'), findsOneWidget);
    });

    testWidgets('음수 진행률도 에러 없이 렌더링', (tester) async {
      await tester.pumpWidget(_buildTestWidget(-0.1));
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
