import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/converter_service.dart';
import '../widgets/format_selector.dart';
import '../widgets/bitrate_selector.dart';
import '../widgets/conversion_progress.dart';

class HomeScreen extends StatefulWidget {
  final ConverterService converterService;

  const HomeScreen({super.key, required this.converterService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedVideoPath;
  String? _selectedVideoName;
  int? _selectedVideoSize;
  AudioFormat _selectedFormat = AudioFormat.mp3;
  int _selectedBitrate = 192;
  bool _isConverting = false;
  double _progress = 0.0;
  String? _outputPath;
  String? _errorMessage;

  late AnimationController _settingsAnimController;
  late Animation<double> _settingsAnim;

  @override
  void initState() {
    super.initState();
    _settingsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _settingsAnim = CurvedAnimation(
      parent: _settingsAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _settingsAnimController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      if (status.isDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('저장소 접근 권한이 필요합니다.'),
            action: SnackBarAction(
              label: '설정',
              onPressed: openAppSettings,
            ),
          ),
        );
        return;
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideoPath = result.files.single.path;
        _selectedVideoName = result.files.single.name;
        _selectedVideoSize = result.files.single.size;
        _outputPath = null;
        _errorMessage = null;
        _progress = 0.0;
      });
      _settingsAnimController.forward(from: 0);
    }
  }

  Future<void> startConversion() async {
    if (_selectedVideoPath == null) return;

    setState(() {
      _isConverting = true;
      _progress = 0.0;
      _outputPath = null;
      _errorMessage = null;
    });

    final result = await widget.converterService.convertVideoToAudio(
      inputPath: _selectedVideoPath!,
      format: _selectedFormat,
      bitrate: _selectedBitrate,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (!mounted) return;
    setState(() {
      _isConverting = false;
      if (result.success) {
        _outputPath = result.outputPath;
        _progress = 1.0;
      } else {
        _errorMessage = result.errorMessage;
      }
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('변환이 완료되었습니다!'),
          action: SnackBarAction(
            label: '공유',
            onPressed: () => _shareFile(_outputPath!),
          ),
        ),
      );
    }
  }

  Future<void> _shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: '변환된 오디오 파일');
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _outputFileSize(String? path) {
    if (path == null) return '';
    try {
      final s = File(path).lengthSync();
      if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)} KB';
      return '${(s / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Large App Bar ───────────────────────────────────────
          SliverAppBar.large(
            title: const Text('동영상 변환기'),
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            actions: [
              if (_selectedVideoPath != null && !_isConverting)
                IconButton.filledTonal(
                  icon: const Icon(Icons.videocam_rounded),
                  tooltip: '다른 동영상 선택',
                  onPressed: _pickVideo,
                ),
              const SizedBox(width: 8),
            ],
          ),

          // ─── Body ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 동영상 선택 카드
                  _isConverting
                      ? const SizedBox.shrink()
                      : _buildVideoPicker(cs, tt),

                  // 변환 진행 중
                  if (_isConverting) ...[
                    const SizedBox(height: 16),
                    ConversionProgress(
                      progress: _progress,
                      fileName: _selectedVideoName,
                    ),
                  ],

                  // 설정 패널 (파일 선택 후)
                  if (_selectedVideoPath != null && !_isConverting) ...[
                    SizeTransition(
                      sizeFactor: _settingsAnim,
                      axisAlignment: -1,
                      child: FadeTransition(
                        opacity: _settingsAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            FormatSelector(
                              selectedFormat: _selectedFormat,
                              onFormatChanged: (f) =>
                                  setState(() => _selectedFormat = f),
                            ),
                            const SizedBox(height: 12),
                            BitrateSelector(
                              selectedBitrate: _selectedBitrate,
                              selectedFormat: _selectedFormat,
                              onBitrateChanged: (b) =>
                                  setState(() => _selectedBitrate = b),
                            ),
                            const SizedBox(height: 24),
                            _buildConvertButton(cs),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // 변환 완료
                  if (_outputPath != null) ...[
                    const SizedBox(height: 20),
                    _buildSuccessCard(cs, tt),
                  ],

                  // 변환 실패
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _buildErrorCard(cs, tt),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // FAB: 파일 선택 (비어있을 때만)
      floatingActionButton: _selectedVideoPath == null && !_isConverting
          ? FloatingActionButton.extended(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_library_rounded),
              label: const Text('동영상 선택'),
              elevation: 3,
            )
          : null,
    );
  }

  Widget _buildVideoPicker(ColorScheme cs, TextTheme tt) {
    if (_selectedVideoPath == null) {
      // 빈 상태 카드
      return Card(
        color: cs.surfaceContainerLow,
        child: InkWell(
          onTap: _pickVideo,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.movie_creation_outlined,
                    size: 40,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '동영상을 선택해주세요',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MP4 · MOV · AVI · MKV 등 모든 형식 지원',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: _pickVideo,
                  child: const Text('파일 탐색기 열기'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 선택된 파일 카드
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.movie_rounded, color: cs.onPrimary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedVideoName ?? '선택된 파일',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatSize(_selectedVideoSize),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: cs.onPrimaryContainer.withOpacity(0.7)),
              onPressed: () {
                setState(() {
                  _selectedVideoPath = null;
                  _selectedVideoName = null;
                  _selectedVideoSize = null;
                  _outputPath = null;
                  _errorMessage = null;
                });
                _settingsAnimController.reset();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton(ColorScheme cs) {
    return FilledButton.icon(
      onPressed: startConversion,
      icon: const Icon(Icons.graphic_eq_rounded, size: 22),
      label: const Text(
        '오디오로 변환 시작',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSuccessCard(ColorScheme cs, TextTheme tt) {
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '변환 완료',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        _outputPath!.split('/').last,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _outputFileSize(_outputPath),
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareFile(_outputPath!),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('공유'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('새 파일 변환'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ColorScheme cs, TextTheme tt) {
    return Card(
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded,
                color: cs.onErrorContainer, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '변환에 실패했습니다',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage ?? '알 수 없는 오류',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onErrorContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: startConversion,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('다시 시도'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
