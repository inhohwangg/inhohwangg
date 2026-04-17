import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/models/user_settings_model.dart';
import '../../../features/commute/providers/user_settings_provider.dart';
import '../../../shared/widgets/toss_card.dart';
import '../../../shared/widgets/section_label.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _fromCtrl;
  late TextEditingController _toCtrl;
  late TextEditingController _fromLineCtrl;
  late TextEditingController _toLineCtrl;
  late TextEditingController _offsetCtrl;
  late TextEditingController _bufferCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(userSettingsProvider).valueOrNull ??
        UserSettingsModel.defaultSettings;
    _fromCtrl = TextEditingController(text: s.commuteFromStation);
    _toCtrl = TextEditingController(text: s.commuteToStation);
    _fromLineCtrl = TextEditingController(text: s.commuteFromLine);
    _toLineCtrl = TextEditingController(text: s.commuteToLine);
    _offsetCtrl =
        TextEditingController(text: s.travelTimeOffsetSeconds.toString());
    _bufferCtrl =
        TextEditingController(text: s.transferBufferSeconds.toString());
  }

  @override
  void dispose() {
    for (final c in [
      _fromCtrl, _toCtrl, _fromLineCtrl, _toLineCtrl, _offsetCtrl, _bufferCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final newSettings = UserSettingsModel(
      commuteFromStation: _fromCtrl.text.trim(),
      commuteToStation: _toCtrl.text.trim(),
      commuteFromLine: _fromLineCtrl.text.trim(),
      commuteToLine: _toLineCtrl.text.trim(),
      travelTimeOffsetSeconds:
          int.tryParse(_offsetCtrl.text.trim()) ?? 0,
      transferBufferSeconds:
          int.tryParse(_bufferCtrl.text.trim()) ?? 0,
    );
    await ref.read(userSettingsProvider.notifier).updateSettings(newSettings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SectionLabel('출근 경로'),
          TossCard(
            child: Column(
              children: [
                _SettingsField(
                  label: '출발역 (예: 부평구청)',
                  controller: _fromCtrl,
                  hint: '역명을 입력하세요',
                ),
                const Divider(height: 24),
                _SettingsField(
                  label: '출발역 호선 (예: 7)',
                  controller: _fromLineCtrl,
                  hint: '숫자만 입력',
                  keyboardType: TextInputType.number,
                ),
                const Divider(height: 24),
                _SettingsField(
                  label: '목적지역 (예: 금천구청)',
                  controller: _toCtrl,
                  hint: '역명을 입력하세요',
                ),
                const Divider(height: 24),
                _SettingsField(
                  label: '목적지역 호선 (예: 1)',
                  controller: _toLineCtrl,
                  hint: '숫자만 입력',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('시간 오차 보정 (카카오와 비교하며 조절)'),
          TossCard(
            child: Column(
              children: [
                _SettingsField(
                  label: '이동시간 Offset (초, 양수=늘림 / 음수=줄임)',
                  controller: _offsetCtrl,
                  hint: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true),
                ),
                const Divider(height: 24),
                _SettingsField(
                  label: '환승 버퍼 (초)',
                  controller: _bufferCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '※ 카카오 지하철과 시간이 다를 경우 Offset을 조정하세요.\n  예) 카카오보다 3분 빠르면 Offset = +180',
              style: AppTextStyles.labelSmall,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('저장', style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
            )),
          ),
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
