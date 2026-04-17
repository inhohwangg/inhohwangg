import 'package:flutter/foundation.dart';

@immutable
class StationModel {
  const StationModel({
    required this.stationName,
    required this.lineNumber,
    required this.stationCode,
  });

  final String stationName;
  final String lineNumber;
  final String stationCode;

  @override
  bool operator ==(Object other) =>
      other is StationModel && other.stationCode == stationCode;

  @override
  int get hashCode => stationCode.hashCode;

  @override
  String toString() => '$stationName (${lineNumber}호선)';
}
