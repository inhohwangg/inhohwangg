import 'package:flutter/foundation.dart';
import 'station_model.dart';

@immutable
class CommuteRouteModel {
  const CommuteRouteModel({
    required this.departureStation,
    required this.arrivalStation,
    required this.travelMinutes,
    required this.isCommuteMode,
  });

  final StationModel departureStation;
  final StationModel arrivalStation;
  final int travelMinutes;
  final bool isCommuteMode;

  @override
  String toString() =>
      '${isCommuteMode ? "출근" : "퇴근"}: ${departureStation.stationName} → ${arrivalStation.stationName} (${travelMinutes}분)';
}
