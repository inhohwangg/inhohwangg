import 'package:flutter/foundation.dart';

@immutable
class ArrivalInfoModel {
  const ArrivalInfoModel({
    required this.trainLineName,
    required this.arrivalMessage,
    required this.remainingSeconds,
    required this.destinationName,
    required this.updatedAt,
    required this.isUpDirection,
  });

  final String trainLineName;
  final String arrivalMessage;
  final int remainingSeconds;
  final String destinationName;
  final DateTime updatedAt;
  final bool isUpDirection;

  int get remainingMinutes => (remainingSeconds / 60).floor();

  DateTime get estimatedArrivalTime =>
      updatedAt.add(Duration(seconds: remainingSeconds));

  @override
  String toString() =>
      'ArrivalInfo($trainLineName, ${remainingMinutes}분 후, 도착: $destinationName)';
}
