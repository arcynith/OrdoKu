import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ordoku/core/theme/app_theme.dart';
import 'package:ordoku/features/file_manager/domain/file_manager_provider.dart';

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Recent';
  void select(String category) => state = category;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(
  () => SelectedCategoryNotifier(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getRouteForExt(String ext) {
    switch (ext) {
      case 'ordw': return '/writer';
      case 'ords': return '/sheet';
      case 'ordp': return '/slides';
      case 'ordd': return '/design';
      case 'ordn': return '/notes';
      default: return '/';
    }
  }

  void _createNewDocument(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Create New', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          children: [
            _NewDocTile(
              icon: LucideIcons.fileText,
              label: 'Writer Document',
              subtitle: 'Rich text editing',
              color: AppTheme.getModuleColor('ordw'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showNameDialog(context, ref, 'ordw', 'Writer Document');
              },
            ),
            _NewDocTile(
              icon: LucideIcons.table,
              label: 'Sheet Workbook',
              subtitle: 'Spreadsheet & tables',
              color: AppTheme.getModuleColor('ords'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showNameDialog(context, ref, 'ords', 'Sheet Workbook');
              },
            ),
            _NewDocTile(
              icon: LucideIcons.presentation,
              label: 'Slide Presentation',
              subtitle: 'Slides & presentations',
              color: AppTheme.getModuleColor('ordp'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showNameDialog(context, ref, 'ordp', 'Slide Presentation');
              },
            ),
            _NewDocTile(
              icon: LucideIcons.penTool,
              label: 'Design Canvas',
              subtitle: 'Vector shapes & drawing',
              color: AppTheme.getModuleColor('ordd'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showNameDialog(context, ref, 'ordd', 'Design Canvas');
              },
            ),
            _NewDocTile(
              icon: LucideIcons.stickyNote,
              label: 'Quick Note',
              subtitle: 'Fast text capture',
              color: AppTheme.getModuleColor('ordn'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showNameDialog(context, ref, 'ordn', 'Quick Note');
              },
            ),
            const Divider(height: 1),
            _NewDocTile(
              icon: LucideIcons.fileInput,
              label: 'Import Document (PDF)',
              subtitle: 'Open a PDF from your device',
              color: AppTheme.getModuleColor('pdf'),
              onTap: () {
                Navigator.pop(dialogContext);
                ref.read(fileManagerNotifierProvider.notifier).pickAndImportFile();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNameDialog(BuildContext context, WidgetRef ref, String ext, String typeLabel) {
    final controller = TextEditingController(text: 'Untitled');
    final color = AppTheme.getModuleColor(ext);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(_getIconForExt(ext), color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text('New $typeLabel', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Document Name',
                hintText: 'Enter a name...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              onSubmitted: (_) => _submitCreate(dialogContext, context, ref, controller.text, ext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () => _submitCreate(dialogContext, context, ref, controller.text, ext),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForExt(String ext) {
    switch (ext) {
      case 'ordw': return LucideIcons.fileText;
      case 'ords': return LucideIcons.table;
      case 'ordp': return LucideIcons.presentation;
      case 'ordd': return LucideIcons.penTool;
      case 'ordn': return LucideIcons.stickyNote;
      default: return LucideIcons.file;
    }
  }

  void _submitCreate(BuildContext dialogContext, BuildContext homeContext, WidgetRef ref, String name, String ext) async {
    final docName = name.trim().isEmpty ? 'Untitled' : name.trim();
    Navigator.pop(dialogContext);
    final file = await ref.read(fileManagerNotifierProvider.notifier).createDocument(docName, ext);
    if (homeContext.mounted) {
      homeContext.push(_getRouteForExt(ext), extra: file.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f11) {
          windowManager.isFullScreen().then((isFullScreen) {
            windowManager.setFullScreen(!isFullScreen);
          });
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: Column(
        children: [
          // Custom Title Bar (replaces native gray bar)
          GestureDetector(
            onPanStart: (_) => windowManager.startDragging(),
            onDoubleTap: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
            child: Container(
              height: 40,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B579A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text('O', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('OrdoKu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  const Spacer(),
                  // Window Controls
                  _WindowButton(
                    icon: Icons.remove,
                    onTap: () => windowManager.minimize(),
                  ),
                  _WindowButton(
                    icon: Icons.crop_square_outlined,
                    onTap: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                  ),
                  _WindowButton(
                    icon: Icons.close,
                    onTap: () => windowManager.close(),
                    isClose: true,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: const Color(0xFFE0E0E0)),
          // Main body
          Expanded(child: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _SidebarItem(icon: LucideIcons.clock, label: 'Recent', selected: ref.watch(selectedCategoryProvider) == 'Recent', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Recent')),
                _SidebarItem(icon: LucideIcons.star, label: 'Favorites', selected: ref.watch(selectedCategoryProvider) == 'Favorites', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Favorites')),
                _SidebarItem(icon: LucideIcons.folder, label: 'All Files', selected: ref.watch(selectedCategoryProvider) == 'All Files', onTap: () => ref.read(selectedCategoryProvider.notifier).select('All Files')),
                const Divider(indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'MODULES',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 1.2),
                  ),
                ),
                _SidebarModuleItem(label: 'Writer', color: AppTheme.getModuleColor('ordw'), selected: ref.watch(selectedCategoryProvider) == 'Writer', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Writer')),
                _SidebarModuleItem(label: 'Sheet', color: AppTheme.getModuleColor('ords'), selected: ref.watch(selectedCategoryProvider) == 'Sheet', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Sheet')),
                _SidebarModuleItem(label: 'Slides', color: AppTheme.getModuleColor('ordp'), selected: ref.watch(selectedCategoryProvider) == 'Slides', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Slides')),
                _SidebarModuleItem(label: 'Design', color: AppTheme.getModuleColor('ordd'), selected: ref.watch(selectedCategoryProvider) == 'Design', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Design')),
                _SidebarModuleItem(label: 'Notes', color: AppTheme.getModuleColor('ordn'), selected: ref.watch(selectedCategoryProvider) == 'Notes', onTap: () => ref.read(selectedCategoryProvider.notifier).select('Notes')),
                const Spacer(),
                const Divider(indent: 16, endIndent: 16),
                _SidebarItem(icon: LucideIcons.settings, label: 'Settings', selected: false, onTap: () {}),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        ref.watch(selectedCategoryProvider) == 'All Files' ? 'All Files' : '${ref.watch(selectedCategoryProvider)} Documents',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 240,
                        height: 36,
                        child: TextField(
                          onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
                          decoration: InputDecoration(
                            hintText: 'Search documents...',
                            prefixIcon: const Icon(LucideIcons.search, size: 16),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // File List
                Expanded(child: _FileList()),
              ],
            ),
          ),
        ],
      )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewDocument(context, ref),
        child: const Icon(LucideIcons.plus, size: 22),
      ),
    ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F0FE) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(icon, size: 18, color: selected ? const Color(0xFF2B579A) : const Color(0xFF666666)),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? const Color(0xFF2B579A) : const Color(0xFF333333),
          ),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
      ),
    );
  }
}

class _SidebarModuleItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarModuleItem({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        title: Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? color : const Color(0xFF333333))),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
      ),
    );
  }
}

class _NewDocTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NewDocTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: onTap,
    );
  }
}

class _FileList extends ConsumerWidget {
  IconData _getIconForExtension(String ext) {
    switch (ext) {
      case 'ordw':
        return LucideIcons.fileText;
      case 'ords':
        return LucideIcons.table;
      case 'ordp':
        return LucideIcons.presentation;
      case 'ordd':
        return LucideIcons.penTool;
      case 'ordn':
        return LucideIcons.stickyNote;
      case 'pdf':
        return LucideIcons.fileType;
      default:
        return LucideIcons.file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(fileManagerNotifierProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    return filesState.when(
      data: (allFiles) {
        // Filter logic
        var files = allFiles.where((file) {
          final name = file.path.split(Platform.pathSeparator).last;
          if (searchQuery.isNotEmpty && !name.toLowerCase().contains(searchQuery)) {
            return false;
          }
          final ext = name.split('.').last;
          if (selectedCategory == 'Writer' && ext != 'ordw') return false;
          if (selectedCategory == 'Sheet' && ext != 'ords') return false;
          if (selectedCategory == 'Slides' && ext != 'ordp') return false;
          if (selectedCategory == 'Design' && ext != 'ordd') return false;
          if (selectedCategory == 'Notes' && ext != 'ordn') return false;
          return true;
        }).toList();

        // Sort for 'Recent'
        if (selectedCategory == 'Recent') {
          files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        }

        if (files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.folderOpen, size: 36, color: Color(0xFFBBBBBB)),
                ),
                const SizedBox(height: 20),
                const Text('Your workspace is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                const SizedBox(height: 6),
                const Text('Tap + to create your first document', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          itemCount: files.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final file = files[index];
            final name = file.path.split(Platform.pathSeparator).last;
            final ext = name.split('.').last;
            final color = AppTheme.getModuleColor(ext);
            final moduleLabel = AppTheme.getModuleLabel(ext);
            final stat = file.statSync();

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                hoverColor: const Color(0xFFF5F5F5),
                onTap: () {
                  if (ext == 'ordw') {
                    context.push('/writer', extra: file.path);
                  } else if (ext == 'ords') {
                    context.push('/sheet', extra: file.path);
                  } else if (ext == 'ordp') {
                    context.push('/slides', extra: file.path);
                  } else if (ext == 'ordd') {
                    context.push('/design', extra: file.path);
                  } else if (ext == 'ordn') {
                    context.push('/notes', extra: file.path);
                  } else if (ext == 'pdf') {
                    context.push('/pdf', extra: file.path);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      // File Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIconForExtension(ext), color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      // File Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.replaceAll('.$ext', ''),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$moduleLabel • ${_formatDate(stat.modified)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                      ),
                      // Extension badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '.$ext',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      PopupMenuButton(
                        icon: const Icon(LucideIcons.moreVertical, size: 16, color: Color(0xFFBBBBBB)),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'open', child: Text('Open')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            ref.read(fileManagerNotifierProvider.notifier).deleteFile(file.path);
                          } else if (value == 'open') {
                            if (ext == 'ordw') context.push('/writer', extra: file.path);
                            if (ext == 'ords') context.push('/sheet', extra: file.path);
                            if (ext == 'ordp') context.push('/slides', extra: file.path);
                            if (ext == 'ordd') context.push('/design', extra: file.path);
                            if (ext == 'ordn') context.push('/notes', extra: file.path);
                            if (ext == 'pdf') context.push('/pdf', extra: file.path);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2B579A))),
      error: (e, st) => Center(child: Text('Error loading files: $e')),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowButton({required this.icon, required this.onTap, this.isClose = false});

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: Listener(
        // Listener bypasses the parent GestureDetector's double-tap delay
        onPointerUp: (_) => widget.onTap(),
        child: Container(
          width: 46,
          height: 32,
          alignment: Alignment.center,
          color: _isHovering
              ? (widget.isClose ? const Color(0xFFE81123) : Colors.black.withValues(alpha: 0.05))
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovering && widget.isClose ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
