import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/widgets/conversion_progress.dart';

Widget _buildTestWidget(double progress) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: ConversionProgress(progress: progress),
    ),
  );
}

void main() {
  group('ConversionProgress 위젯', () {
    testWidgets('"변환 중..." 텍스트가 표시됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.0));

      expect(find.text('변환 중...'), findsOneWidget);
    });

    testWidgets('진행률 0일 때 "처리 중..." 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.0));

      expect(find.text('처리 중...'), findsOneWidget);
    });

    testWidgets('진행률 0.5일 때 "50%" 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.5));

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('진행률 1.0일 때 "100%" 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(1.0));

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('진행률 0.3일 때 "30%" 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.3));

      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('Card 위젯이 렌더링됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(0.5));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('진행률이 0~1 사이로 클램핑 됨 - 음수값 처리', (tester) async {
      // 음수 진행률이어도 에러 없이 렌더링
      await tester.pumpWidget(_buildTestWidget(-0.1));
      expect(find.text('처리 중...'), findsOneWidget);
    });

    testWidgets('진행률이 0~1 사이로 클램핑 됨 - 1 초과값 처리', (tester) async {
      // 1 초과 진행률이어도 에러 없이 렌더링
      await tester.pumpWidget(_buildTestWidget(1.5));
      // 1.5 * 100 = 150, 150% 표시
      expect(find.text('150%'), findsOneWidget);
    });
  });
}
