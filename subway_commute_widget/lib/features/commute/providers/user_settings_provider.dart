import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/user_settings_model.dart';

const _kSettingsKey = 'user_settings';

class UserSettingsNotifier extends AsyncNotifier<UserSettingsModel> {
  @override
  Future<UserSettingsModel> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettingsKey);
    if (raw == null) return UserSettingsModel.defaultSettings;
    try {
      return UserSettingsModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserSettingsModel.defaultSettings;
    }
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettingsKey, jsonEncode(settings.toJson()));
    state = AsyncValue.data(settings);
  }

  Future<void> updateOffset(int offsetSeconds) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await updateSettings(
        current.copyWith(travelTimeOffsetSeconds: offsetSeconds));
  }

  Future<void> updateTransferBuffer(int bufferSeconds) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await updateSettings(
        current.copyWith(transferBufferSeconds: bufferSeconds));
  }
}

final userSettingsProvider =
    AsyncNotifierProvider<UserSettingsNotifier, UserSettingsModel>(
  UserSettingsNotifier.new,
);
