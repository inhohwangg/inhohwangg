import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/services/converter_service.dart';
import 'package:video_audio_converter/widgets/bitrate_selector.dart';

Widget _buildTestWidget({
  required int selectedBitrate,
  required AudioFormat selectedFormat,
  required ValueChanged<int> onBitrateChanged,
}) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: BitrateSelector(
        selectedBitrate: selectedBitrate,
        selectedFormat: selectedFormat,
        onBitrateChanged: onBitrateChanged,
      ),
    ),
  );
}

void main() {
  group('BitrateSelector 위젯', () {
    testWidgets('MP3 형식일 때 비트레이트 칩들이 표시됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.mp3,
        onBitrateChanged: (_) {},
      ));

      expect(find.text('64kbps'), findsOneWidget);
      expect(find.text('128kbps'), findsOneWidget);
      expect(find.text('192kbps'), findsOneWidget);
      expect(find.text('256kbps'), findsOneWidget);
      expect(find.text('320kbps'), findsOneWidget);
    });

    testWidgets('"비트레이트" 라벨이 표시됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.mp3,
        onBitrateChanged: (_) {},
      ));

      expect(find.text('비트레이트'), findsOneWidget);
    });

    testWidgets('WAV 형식일 때 위젯이 숨겨짐 (SizedBox)', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.wav,
        onBitrateChanged: (_) {},
      ));

      expect(find.text('비트레이트'), findsNothing);
      expect(find.text('192kbps'), findsNothing);
    });

    testWidgets('FLAC 형식일 때 위젯이 숨겨짐', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.flac,
        onBitrateChanged: (_) {},
      ));

      expect(find.text('비트레이트'), findsNothing);
    });

    testWidgets('비트레이트 탭 시 onBitrateChanged 콜백 호출', (tester) async {
      int? changedBitrate;

      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.mp3,
        onBitrateChanged: (bitrate) => changedBitrate = bitrate,
      ));

      await tester.tap(find.text('320kbps'));
      await tester.pump();

      expect(changedBitrate, equals(320));
    });

    testWidgets('64kbps 탭 시 저화질 설명 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 64,
        selectedFormat: AudioFormat.mp3,
        onBitrateChanged: (_) {},
      ));

      expect(find.textContaining('저화질'), findsOneWidget);
    });

    testWidgets('192kbps 탭 시 권장 설명 표시', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.mp3,
        onBitrateChanged: (_) {},
      ));

      expect(find.textContaining('권장'), findsOneWidget);
    });

    testWidgets('선택된 비트레이트의 ChoiceChip이 selected 상태', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 128,
        selectedFormat: AudioFormat.mp3,
        onBitrateChanged: (_) {},
      ));

      final chip128 = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('128kbps'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(chip128.selected, isTrue);

      final chip256 = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('256kbps'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(chip256.selected, isFalse);
    });

    testWidgets('AAC 형식일 때도 비트레이트 칩이 표시됨', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        selectedBitrate: 192,
        selectedFormat: AudioFormat.aac,
        onBitrateChanged: (_) {},
      ));

      expect(find.text('비트레이트'), findsOneWidget);
    });
  });
}
