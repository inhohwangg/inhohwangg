import 'package:flutter/foundation.dart';

@immutable
class UserSettingsModel {
  const UserSettingsModel({
    required this.commuteFromStation,
    required this.commuteToStation,
    required this.commuteFromLine,
    required this.commuteToLine,
    this.travelTimeOffsetSeconds = 0,
    this.transferBufferSeconds = 0,
  });

  final String commuteFromStation;
  final String commuteToStation;
  final String commuteFromLine;
  final String commuteToLine;
  final int travelTimeOffsetSeconds;
  final int transferBufferSeconds;

  UserSettingsModel copyWith({
    String? commuteFromStation,
    String? commuteToStation,
    String? commuteFromLine,
    String? commuteToLine,
    int? travelTimeOffsetSeconds,
    int? transferBufferSeconds,
  }) {
    return UserSettingsModel(
      commuteFromStation: commuteFromStation ?? this.commuteFromStation,
      commuteToStation: commuteToStation ?? this.commuteToStation,
      commuteFromLine: commuteFromLine ?? this.commuteFromLine,
      commuteToLine: commuteToLine ?? this.commuteToLine,
      travelTimeOffsetSeconds:
          travelTimeOffsetSeconds ?? this.travelTimeOffsetSeconds,
      transferBufferSeconds:
          transferBufferSeconds ?? this.transferBufferSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'commuteFromStation': commuteFromStation,
        'commuteToStation': commuteToStation,
        'commuteFromLine': commuteFromLine,
        'commuteToLine': commuteToLine,
        'travelTimeOffsetSeconds': travelTimeOffsetSeconds,
        'transferBufferSeconds': transferBufferSeconds,
      };

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      UserSettingsModel(
        commuteFromStation: json['commuteFromStation'] as String,
        commuteToStation: json['commuteToStation'] as String,
        commuteFromLine: json['commuteFromLine'] as String,
        commuteToLine: json['commuteToLine'] as String,
        travelTimeOffsetSeconds:
            (json['travelTimeOffsetSeconds'] as int?) ?? 0,
        transferBufferSeconds: (json['transferBufferSeconds'] as int?) ?? 0,
      );

  static const UserSettingsModel defaultSettings = UserSettingsModel(
    commuteFromStation: '부평구청',
    commuteToStation: '금천구청',
    commuteFromLine: '7',
    commuteToLine: '1',
  );
}
