import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import '../services/converter_service.dart';

class ConvertedFilesScreen extends StatefulWidget {
  final ConverterService converterService;

  const ConvertedFilesScreen({super.key, required this.converterService});

  @override
  State<ConvertedFilesScreen> createState() => _ConvertedFilesScreenState();
}

class _ConvertedFilesScreenState extends State<ConvertedFilesScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final files = await widget.converterService.getConvertedFiles();
    if (mounted) {
      setState(() {
        _files = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    final success = await widget.converterService.deleteFile(file.path);
    if (success && mounted) {
      setState(() => _files.remove(file));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${p.basename(file.path)} 삭제됨'),
          action: SnackBarAction(
            label: '확인',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  String _formatSize(FileSystemEntity entity) {
    try {
      final bytes = (entity as File).lengthSync();
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(FileSystemEntity entity) {
    try {
      final d = entity.statSync().modified;
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return '오늘 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      }
      return '${d.month}월 ${d.day}일 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  (IconData, Color) _getFormatStyle(String filePath, ColorScheme cs) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.mp3':
        return (Icons.music_note_rounded, cs.primary);
      case '.aac':
        return (Icons.headphones_rounded, cs.secondary);
      case '.wav':
        return (Icons.waves_rounded, cs.tertiary);
      case '.flac':
        return (Icons.high_quality_rounded, const Color(0xFF6A1B9A));
      case '.ogg':
        return (Icons.settings_input_composite_rounded, const Color(0xFF00695C));
      default:
        return (Icons.audio_file_rounded, cs.primary);
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
          SliverAppBar.medium(
            title: const Text('변환 목록'),
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            actions: [
              if (!_isLoading)
                Badge(
                  isLabelVisible: _files.isNotEmpty,
                  label: Text('${_files.length}'),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _loadFiles,
                    tooltip: '새로고침',
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_files.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(cs, tt),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList.separated(
                itemCount: _files.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return _buildFileCard(file, cs, tt);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileCard(
      FileSystemEntity file, ColorScheme cs, TextTheme tt) {
    final fileName = p.basenameWithoutExtension(file.path);
    final ext = p.extension(file.path).toLowerCase().replaceFirst('.', '');
    final (icon, color) = _getFormatStyle(file.path, cs);

    return Dismissible(
      key: Key(file.path),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteFile(file),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
      ),
      child: Card(
        color: cs.surfaceContainerLow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () => _showOptions(file),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // 포맷 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),

                // 파일 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _Tag(
                            label: ext.toUpperCase(),
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatSize(file)} · ${_formatDate(file)}',
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 공유 버튼
                IconButton(
                  icon: const Icon(Icons.ios_share_rounded),
                  color: cs.onSurfaceVariant,
                  tooltip: '공유',
                  onPressed: () async {
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: '변환된 오디오 파일',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showOptions(FileSystemEntity file) async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fileName = p.basename(file.path);

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.ios_share_rounded, color: cs.primary),
              title: const Text('공유'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: () async {
                Navigator.pop(ctx);
                await Share.shareXFiles([XFile(file.path)],
                    text: '변환된 오디오 파일');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: cs.error),
              title: Text('삭제', style: TextStyle(color: cs.error)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.library_music_outlined,
                size: 48,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '변환된 파일이 없습니다',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '변환 탭에서 동영상을 오디오로\n변환하면 여기에 표시됩니다.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
