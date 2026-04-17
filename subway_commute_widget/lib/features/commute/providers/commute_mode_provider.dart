import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/commute_config.dart';

enum CommuteMode { commute, returnHome }

/// 현재 시간 기반 출근/퇴근 모드 판단
/// 00:00 ~ 12:59 = commute, 13:00 ~ 23:59 = returnHome
final commuteModeProvider = Provider<CommuteMode>((ref) {
  final now = DateTime.now();
  final switchMinutesOfDay =
      CommuteConfig.switchHour * 60 + CommuteConfig.switchMinute;
  final currentMinutesOfDay = now.hour * 60 + now.minute;
  return currentMinutesOfDay < switchMinutesOfDay
      ? CommuteMode.commute
      : CommuteMode.returnHome;
});

/// 시간을 주기적으로 갱신하여 자동 스위칭 지원
final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now())
      .map((_) => DateTime.now());
});
