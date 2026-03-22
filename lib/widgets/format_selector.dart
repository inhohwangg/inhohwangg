import 'package:flutter/material.dart';
import '../services/converter_service.dart';

class FormatSelector extends StatelessWidget {
  final AudioFormat selectedFormat;
  final ValueChanged<AudioFormat> onFormatChanged;

  const FormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '출력 형식',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AudioFormat.values.map((format) {
                final isSelected = format == selectedFormat;
                return ChoiceChip(
                  label: Text(format.displayName),
                  selected: isSelected,
                  onSelected: (_) => onFormatChanged(format),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getFormatDescription(selectedFormat),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormatDescription(AudioFormat format) {
    switch (format) {
      case AudioFormat.mp3:
        return 'MP3: 가장 범용적인 오디오 형식. 작은 파일 크기와 높은 호환성';
      case AudioFormat.aac:
        return 'AAC: MP3보다 좋은 음질. Apple 기기에 최적화';
      case AudioFormat.wav:
        return 'WAV: 무손실 오디오. 최고 음질이지만 파일 크기가 큼';
      case AudioFormat.flac:
        return 'FLAC: 무손실 압축. WAV보다 작은 파일 크기';
      case AudioFormat.ogg:
        return 'OGG: 오픈소스 형식. 좋은 압축률과 음질';
    }
  }
}
