import 'package:flutter/material.dart';

class ConversionProgress extends StatefulWidget {
  final double progress;
  final String? fileName;

  const ConversionProgress({
    super.key,
    required this.progress,
    this.fileName,
  });

  @override
  State<ConversionProgress> createState() => _ConversionProgressState();
}

class _ConversionProgressState extends State<ConversionProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = (widget.progress * 100).clamp(0, 100).toInt();

    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // 원형 진행률 표시
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 원
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: cs.surfaceContainerHighest,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // 진행 원
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: widget.progress > 0 ? widget.progress : null,
                      strokeWidth: 8,
                      color: cs.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // 중앙 텍스트
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          widget.progress > 0 ? '$percent%' : '...',
                          key: ValueKey(percent),
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      if (widget.progress > 0)
                        Text(
                          '완료',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 파일명
            if (widget.fileName != null) ...[
              Text(
                widget.fileName!,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],

            // 변환 중 텍스트
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, _) {
                return Opacity(
                  opacity: 0.5 + _pulseAnim.value * 0.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.graphic_eq_rounded,
                          size: 18, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        widget.progress > 0 ? '오디오 추출 중...' : '분석 중...',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 선형 진행바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.progress > 0 ? widget.progress : null,
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
