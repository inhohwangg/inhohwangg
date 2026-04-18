import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api/seoul_subway_api.dart';
import '../../../data/repositories/arrival_repository.dart';
import '../../../domain/models/arrival_info_model.dart';
import 'commute_mode_provider.dart';
import 'user_settings_provider.dart';

final seoulSubwayApiProvider = Provider<SeoulSubwayApi>(
  (_) => SeoulSubwayApi(),
);

final arrivalRepositoryProvider = Provider<ArrivalRepository>(
  (ref) => ArrivalRepository(ref.watch(seoulSubwayApiProvider)),
);

final _activeStationsProvider = Provider<(String from, String to)>((ref) {
  final mode = ref.watch(commuteModeProvider);
  final settings = ref.watch(userSettingsProvider).valueOrNull;
  if (settings == null) return ('', '');
  return mode == CommuteMode.commute
      ? (settings.commuteFromStation, settings.commuteToStation)
      : (settings.commuteToStation, settings.commuteFromStation);
});

/// 도착정보 + 하차예상 시각 계산 결과
final arrivalWithCalcProvider =
    FutureProvider.autoDispose<(List<ArrivalInfoModel>, dynamic)>((ref) async {
  ref.watch(currentTimeProvider);
  final (from, to) = ref.watch(_activeStationsProvider);
  if (from.isEmpty || to.isEmpty) return ([], null);
  final repo = ref.watch(arrivalRepositoryProvider);
  return repo.fetchWithCalc(fromStation: from, toStation: to);
});

/// 디버그 전용: 수동 offset 주입·역 지정 후 재계산
final debugArrivalProvider = FutureProvider.autoDispose
    .family<(List<ArrivalInfoModel>, dynamic), (String, String, int, int)>(
  (ref, params) async {
    final (from, to, offsetSec, bufferSec) = params;
    final repo = ref.watch(arrivalRepositoryProvider);
    return repo.fetchWithCalc(
      fromStation: from,
      toStation: to,
      overrideOffsetSeconds: offsetSec,
      overrideTransferBufferSeconds: bufferSec,
    );
  },
);
