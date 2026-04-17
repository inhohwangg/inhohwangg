import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/commute/providers/arrival_provider.dart';
import '../../../features/commute/providers/commute_mode_provider.dart';
import '../../../features/commute/providers/user_settings_provider.dart';
import '../../../data/repositories/arrival_repository.dart';
import '../../../shared/widgets/toss_card.dart';
import '../../../shared/widgets/section_label.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(commuteModeProvider);
    final settings = ref.watch(userSettingsProvider).valueOrNull;
    final arrivalAsync = ref.watch(arrivalWithCalcProvider);

    final isCommute = mode == CommuteMode.commute;
    final modeLabel = isCommute ? '출근' : '퇴근';
    final fromStation = isCommute
        ? (settings?.commuteFromStation ?? '-')
        : (settings?.commuteToStation ?? '-');
    final toStation = isCommute
        ? (settings?.commuteToStation ?? '-')
        : (settings?.commuteFromStation ?? '-');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('한구 공간 확인'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: '시간 검증',
            onPressed: () => Navigator.pushNamed(context, '/debug'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(arrivalWithCalcProvider.future),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _ModeChip(isCommute: isCommute),
            const SizedBox(height: 20),
            SectionLabel('현재 시간대 정보'),
            TossCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(fromStation,
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(toStation,
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$modeLabel 모드 중',
                      style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionLabel('열차 도착 정보'),
            arrivalAsync.when(
              data: (data) {
                final (arrivals, trace) = data;
                if (arrivals.isEmpty) {
                  return TossCard(
                    child: Center(
                      child: Text('도착정보를 불러오는 중...',
                          style: AppTextStyles.bodyMedium),
                    ),
                  );
                }
                return Column(
                  children: [
                    ...arrivals.take(3).map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ArrivalTile(
                            arrival: a,
                            trace: arrivals.indexOf(a) == 0
                                ? trace as CalculationTrace?
                                : null,
                          ),
                        )),
                  ],
                );
              },
              loading: () => const TossCard(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => TossCard(
                child: Text('오류: $e',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.isCommute});
  final bool isCommute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCommute ? AppColors.primaryLight : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommute ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
            size: 16,
            color: isCommute ? AppColors.primary : AppColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            isCommute ? '출근 시간대 (00:00~12:59)' : '퇴근 시간대 (13:00~23:59)',
            style: AppTextStyles.labelLarge.copyWith(
              color: isCommute ? AppColors.primary : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrivalTile extends StatelessWidget {
  const _ArrivalTile({required this.arrival, this.trace});
  final dynamic arrival;
  final CalculationTrace? trace;

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat('HH:mm');
    return TossCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(arrival.arrivalMessage,
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(arrival.destinationName ≠ ''
                    ? '종점: ${arrival.destinationName}'
                    : '',
                    style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                arrival.remainingMinutes ≤ 0
                    ? '콴 도착'
                    : '${arrival.remainingMinutes}분 후',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.primary),
              ),
              if (trace != null)
                Text(
                  '하차 ${tf.format(trace!.finalArrivalTime)}',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.success),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
