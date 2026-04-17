import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/arrival_repository.dart';
import '../../../domain/models/arrival_info_model.dart';
import '../../../features/commute/providers/arrival_provider.dart';
import '../../../features/commute/providers/commute_mode_provider.dart';
import '../../../shared/widgets/toss_card.dart';
import '../../../shared/widgets/section_label.dart';

class TimeVerificationScreen extends ConsumerStatefulWidget {
  const TimeVerificationScreen({super.key});

  @override
  ConsumerState<TimeVerificationScreen> createState() =>
      _TimeVerificationScreenState();
}

class _TimeVerificationScreenState
    extends ConsumerState<TimeVerificationScreen> {
  final _fromCtrl = TextEditingController(text: '부평구청');
  final _toCtrl   = TextEditingController(text: '금천구청');
  final _offsetCtrl = TextEditingController(text: '0');
  final _bufferCtrl = TextEditingController(text: '0');

  (String, String, int, int)? _queryParams;

  void _fetch() {
    setState(() {
      _queryParams = (
        _fromCtrl.text.trim(),
        _toCtrl.text.trim(),
        int.tryParse(_offsetCtrl.text.trim()) ?? 0,
        int.tryParse(_bufferCtrl.text.trim()) ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _offsetCtrl.dispose();
    _bufferCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(commuteModeProvider);
    final now  = DateTime.now();
    final tff  = DateFormat('HH:mm:ss');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('시간 검증 디버그'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          TossCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('현재 시각', style: AppTextStyles.labelLarge),
                    Text(tff.format(now), style: AppTextStyles.headlineMedium),
                  ],
                ),
                _ModeBadge(isCommute: mode == CommuteMode.commute),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionLabel('역명 입력'),
          TossCard(
            child: Column(
              children: [
                _DebugField(label: '출발역', controller: _fromCtrl),
                const Divider(height: 20),
                _DebugField(label: '도착역', controller: _toCtrl),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionLabel('Offset 설정'),
          TossCard(
            child: Column(
              children: [
                _DebugField(
                  label: '이동시간 Offset (초)',
                  controller: _offsetCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                ),
                const Divider(height: 20),
                _DebugField(
                  label: '환승 버퍼 (초)',
                  controller: _bufferCtrl,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _fetch,
            icon: const Icon(Icons.refresh),
            label: const Text('조회 및 계산'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_queryParams != null)
            _DebugResultPanel(params: _queryParams!),
        ],
      ),
    );
  }
}

class _DebugResultPanel extends ConsumerWidget {
  const _DebugResultPanel({required this.params});
  final (String, String, int, int) params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(debugArrivalProvider(params));
    final tf  = DateFormat('HH:mm');
    final tff = DateFormat('HH:mm:ss');

    return result.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => TossCard(
        child: Text('오류: $e',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
      ),
      data: (data) {
        final (arrivals, trace) = data;
        final t = trace as CalculationTrace?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t != null) ...[
              const SectionLabel('하차 시각 계산 과정'),
              TossCard(
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TraceRow('출발역', params.$1),
                    _TraceRow('도착역', params.$2),
                    const Divider(height: 20),
                    _TraceRow(
                      'API 잔여 (초)',
                      '${t.rawArrivalSeconds}초  =  '
                      '${t.rawArrivalSeconds ~/ 60}분 '
                      '${t.rawArrivalSeconds % 60}초',
                    ),
                    _TraceRow('기준시각', tff.format(t.updatedAt)),
                    _TraceRow('출발역 도착 예상',
                        tff.format(t.estimatedArrivalTime),
                        highlight: true),
                    const Divider(height: 20),
                    _TraceRow('DB 역간시간', '${t.travelMinutesFromDb}분'),
                    _TraceRow('Offset', '${t.offsetSeconds}초'),
                    _TraceRow('환승버퍼', '${t.transferBufferSeconds}초'),
                    const Divider(height: 20),
                    _TraceRow(
                      '하차 예상 시각',
                      tf.format(t.finalArrivalTime),
                      valueStyle: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.success),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '카카오 지하철과 비교 후 Offset을 조정하세요',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SectionLabel('실시간 도착열차 목록'),
            ...arrivals.take(5).map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ArrivalDebugTile(arrival: a, tff: tff),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow(this.label, this.value,
      {this.highlight = false, this.valueStyle});
  final String label;
  final String value;
  final bool highlight;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelLarge),
          Text(
            value,
            style: valueStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  color: highlight
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight:
                      highlight ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _ArrivalDebugTile extends StatelessWidget {
  const _ArrivalDebugTile(
      {required this.arrival, required this.tff});
  final ArrivalInfoModel arrival;
  final DateFormat tff;

  @override
  Widget build(BuildContext context) {
    return TossCard(
      borderRadius: 14,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(arrival.arrivalMessage,
                    style: AppTextStyles.bodyMedium),
                Text('종점: ${arrival.destinationName}',
                    style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${arrival.remainingSeconds}초 = ${arrival.remainingMinutes}분',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primary),
              ),
              Text(
                '도착: ${tff.format(arrival.estimatedArrivalTime)}',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.isCommute});
  final bool isCommute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCommute
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isCommute ? '출근' : '퇴근',
        style: AppTextStyles.labelLarge.copyWith(
          color: isCommute ? AppColors.primary : AppColors.warning,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DebugField extends StatelessWidget {
  const _DebugField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: AppTextStyles.labelLarge),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '-',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
