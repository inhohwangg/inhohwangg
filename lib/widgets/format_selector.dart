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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '출력 형식',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: AudioFormat.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final format = AudioFormat.values[i];
              return _FormatCard(
                format: format,
                isSelected: format == selectedFormat,
                onTap: () => onFormatChanged(format),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(selectedFormat),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getFormatIcon(selectedFormat),
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getFormatDescription(selectedFormat),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFormatIcon(AudioFormat format) {
    switch (format) {
      case AudioFormat.mp3:
        return Icons.music_note_rounded;
      case AudioFormat.aac:
        return Icons.apple_rounded;
      case AudioFormat.wav:
        return Icons.waves_rounded;
      case AudioFormat.flac:
        return Icons.high_quality_rounded;
      case AudioFormat.ogg:
        return Icons.open_source_rounded;
    }
  }

  String _getFormatDescription(AudioFormat format) {
    switch (format) {
      case AudioFormat.mp3:
        return '가장 범용적인 형식 · 작은 파일 크기 · 모든 기기 호환';
      case AudioFormat.aac:
        return 'MP3보다 우수한 음질 · Apple 기기 최적화 · 스트리밍 표준';
      case AudioFormat.wav:
        return '무손실 원음 그대로 · 최대 파일 크기 · 스튜디오 작업용';
      case AudioFormat.flac:
        return '무손실 압축 · WAV 대비 50% 절약 · 하이파이 오디오';
      case AudioFormat.ogg:
        return '오픈소스 형식 · 우수한 압축률 · 게임 및 웹 환경';
    }
  }
}

class _FormatCard extends StatelessWidget {
  final AudioFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatCard({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bgColor =
        isSelected ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fgColor =
        isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 80,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: cs.primary, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIcon(), size: 24, color: fgColor),
              const SizedBox(height: 6),
              Text(
                format.displayName,
                style: tt.labelMedium?.copyWith(
                  color: fgColor,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (format) {
      case AudioFormat.mp3:
        return Icons.music_note_rounded;
      case AudioFormat.aac:
        return Icons.headphones_rounded;
      case AudioFormat.wav:
        return Icons.waves_rounded;
      case AudioFormat.flac:
        return Icons.high_quality_rounded;
      case AudioFormat.ogg:
        return Icons.settings_input_composite_rounded;
    }
  }
}
