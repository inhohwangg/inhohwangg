import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/services/converter_service.dart';
import 'package:video_audio_converter/widgets/format_selector.dart';

Widget _buildTestWidget({
  required AudioFormat selectedFormat,
  required ValueChanged<AudioFormat> onFormatChanged,
}) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: FormatSelector(
        selectedFormat: selectedFormat,
        onFormatChanged: onFormatChanged,
      ),
    ),
  );
}

void main() {
  group('FormatSelector 위젯', () {
    testWidgets('모든 오디오 형식 칩이 표시됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.mp3,
        onFormatChanged: (_) {},
      ));

      expect(find.text('MP3'), findsOneWidget);
      expect(find.text('AAC'), findsOneWidget);
      expect(find.text('WAV'), findsOneWidget);
      expect(find.text('FLAC'), findsOneWidget);
      expect(find.text('OGG'), findsOneWidget);
    });

    testWidgets('"출력 형식" 라벨이 표시됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.mp3,
        onFormatChanged: (_) {},
      ));

      expect(find.text('출력 형식'), findsOneWidget);
    });

    testWidgets('MP3 선택 시 MP3 설명 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.mp3,
        onFormatChanged: (_) {},
      ));

      expect(find.textContaining('MP3'), findsWidgets);
      expect(find.textContaining('범용'), findsOneWidget);
    });

    testWidgets('WAV 선택 시 WAV 설명 텍스트 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.wav,
        onFormatChanged: (_) {},
      ));

      expect(find.textContaining('무손실'), findsOneWidget);
    });

    testWidgets('형식 탭 시 onFormatChanged 콜백 호출', (tester) async {
      AudioFormat? changedFormat;

      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.mp3,
        onFormatChanged: (format) => changedFormat = format,
      ));

      await tester.tap(find.text('AAC'));
      await tester.pump();

      expect(changedFormat, equals(AudioFormat.aac));
    });

    testWidgets('WAV 탭 시 onFormatChanged에 wav 전달', (tester) async {
      AudioFormat? changedFormat;

      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.mp3,
        onFormatChanged: (format) => changedFormat = format,
      ));

      await tester.tap(find.text('WAV'));
      await tester.pump();

      expect(changedFormat, equals(AudioFormat.wav));
    });

    testWidgets('선택된 형식의 ChoiceChip이 selected 상태', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedFormat: AudioFormat.flac,
        onFormatChanged: (_) {},
      ));

      // FLAC 칩이 존재하는지 확인
      final flacChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('FLAC'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(flacChip.selected, isTrue);
    });
  });
}
