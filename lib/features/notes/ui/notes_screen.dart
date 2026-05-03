import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:ordoku/features/notes/domain/notes_provider.dart';
import 'package:ordoku/core/engines/export_engine.dart';

class NotesScreen extends ConsumerStatefulWidget {
  final String? filePath;

  const NotesScreen({super.key, this.filePath});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.filePath != null) {
        await ref.read(notesNotifierProvider.notifier).loadFile(widget.filePath!);
        _contentController.text = ref.read(notesNotifierProvider).content;
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteData = ref.watch(notesNotifierProvider);
    final fileName = widget.filePath != null
        ? widget.filePath!.split(Platform.pathSeparator).last.replaceAll('.ordn', '')
        : "Untitled Note";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF7B57A0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Text(fileName, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.undo, size: 18),
            tooltip: 'Undo',
            onPressed: ref.watch(notesNotifierProvider.notifier).canUndo ? () {
              ref.read(notesNotifierProvider.notifier).undo();
              _contentController.text = ref.read(notesNotifierProvider).content;
            } : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.redo, size: 18),
            tooltip: 'Redo',
            onPressed: ref.watch(notesNotifierProvider.notifier).canRedo ? () {
              ref.read(notesNotifierProvider.notifier).redo();
              _contentController.text = ref.read(notesNotifierProvider).content;
            } : null,
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: const Icon(LucideIcons.download, size: 18),
            tooltip: 'Export Text',
            onPressed: () async {
              final engine = ExportEngine();
              await engine.exportToText(noteData.content, fileName);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.save, size: 18),
            tooltip: 'Save',
            onPressed: () async {
              await ref.read(notesNotifierProvider.notifier).saveFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved')),
                );
              }
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE0E0E0)),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.tag, size: 14, color: Color(0xFF999999)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...noteData.tags.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EEFB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('#$t', style: const TextStyle(fontSize: 11, color: Color(0xFF7B57A0), fontWeight: FontWeight.w500)),
                          )),
                          InkWell(
                            onTap: () => ref.read(notesNotifierProvider.notifier).addTag('Important'),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('+ Add', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Start typing your notes...',
                      hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 15),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    style: const TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF333333)),
                    onChanged: (value) {
                      ref.read(notesNotifierProvider.notifier).updateContent(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
