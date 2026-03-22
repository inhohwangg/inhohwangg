import 'package:flutter/material.dart';
import '../services/converter_service.dart';

class BitrateSelector extends StatelessWidget {
  final int selectedBitrate;
  final AudioFormat selectedFormat;
  final ValueChanged<int> onBitrateChanged;

  const BitrateSelector({
    super.key,
    required this.selectedBitrate,
    required this.selectedFormat,
    required this.onBitrateChanged,
  });

  bool get _showsBitrate =>
      selectedFormat != AudioFormat.wav && selectedFormat != AudioFormat.flac;

  @override
  Widget build(BuildContext context) {
    if (!_showsBitrate) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final bitrates = [64, 128, 192, 256, 320];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '비트레이트',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bitrates.map((bitrate) {
                final isSelected = bitrate == selectedBitrate;
                return ChoiceChip(
                  label: Text('${bitrate}kbps'),
                  selected: isSelected,
                  onSelected: (_) => onBitrateChanged(bitrate),
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
              _getBitrateDescription(selectedBitrate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBitrateDescription(int bitrate) {
    if (bitrate <= 64) return '저화질: 음성 통화 수준. 파일 크기 최소';
    if (bitrate <= 128) return '표준: 일반 음악 감상에 적합';
    if (bitrate <= 192) return '고품질: 대부분의 음악에 권장 (기본값)';
    if (bitrate <= 256) return '매우 높은 품질: 고급 오디오';
    return '최고 품질: 스튜디오급 음질. 파일 크기 최대';
  }
}
