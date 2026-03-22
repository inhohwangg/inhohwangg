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

  static const _bitrates = [64, 128, 192, 256, 320];

  @override
  Widget build(BuildContext context) {
    if (!selectedFormat.supportsBitrate) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                '비트레이트',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selectedBitrate}kbps',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<int>(
          segments: _bitrates
              .map((b) => ButtonSegment<int>(
                    value: b,
                    label: Text(b == 192 ? '$b ★' : '$b'),
                  ))
              .toList(),
          selected: {selectedBitrate},
          onSelectionChanged: (s) => onBitrateChanged(s.first),
          style: SegmentedButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest,
            foregroundColor: cs.onSurfaceVariant,
            selectedBackgroundColor: cs.secondaryContainer,
            selectedForegroundColor: cs.onSecondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _BitrateInfo(
            key: ValueKey(selectedBitrate),
            bitrate: selectedBitrate,
          ),
        ),
      ],
    );
  }
}

class _BitrateInfo extends StatelessWidget {
  final int bitrate;

  const _BitrateInfo({super.key, required this.bitrate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final info = _getInfo(bitrate);

    return Row(
      children: [
        _QualityBar(quality: info.quality, cs: cs),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.label,
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                info.description,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(
          info.sizeHint,
          style: tt.labelSmall?.copyWith(color: cs.outline),
        ),
      ],
    );
  }

  _BitrateData _getInfo(int bitrate) {
    switch (bitrate) {
      case 64:
        return _BitrateData(
          quality: 0.2,
          label: '저품질',
          description: '음성·팟캐스트 용도',
          sizeHint: '~0.5MB/분',
        );
      case 128:
        return _BitrateData(
          quality: 0.45,
          label: '표준',
          description: '일반 음악 감상',
          sizeHint: '~1MB/분',
        );
      case 192:
        return _BitrateData(
          quality: 0.65,
          label: '고품질 (권장)',
          description: '대부분의 음악에 충분',
          sizeHint: '~1.5MB/분',
        );
      case 256:
        return _BitrateData(
          quality: 0.85,
          label: '매우 높음',
          description: '고급 스피커·이어폰',
          sizeHint: '~2MB/분',
        );
      default:
        return _BitrateData(
          quality: 1.0,
          label: '최고 품질',
          description: '스튜디오급 음질',
          sizeHint: '~2.5MB/분',
        );
    }
  }
}

class _QualityBar extends StatelessWidget {
  final double quality;
  final ColorScheme cs;

  const _QualityBar({required this.quality, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 6,
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: quality,
                minHeight: 40,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(cs.tertiary, cs.primary, quality) ?? cs.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BitrateData {
  final double quality;
  final String label;
  final String description;
  final String sizeHint;

  const _BitrateData({
    required this.quality,
    required this.label,
    required this.description,
    required this.sizeHint,
  });
}
