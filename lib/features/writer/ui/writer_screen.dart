import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:ordoku/features/writer/domain/writer_provider.dart';

class WriterScreen extends ConsumerStatefulWidget {
  final String? filePath;

  const WriterScreen({super.key, this.filePath});

  @override
  ConsumerState<WriterScreen> createState() => _WriterScreenState();
}

class _WriterScreenState extends ConsumerState<WriterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.filePath != null) {
        ref.read(writerNotifierProvider.notifier).loadFile(widget.filePath!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(writerNotifierProvider);
    final fileName = widget.filePath != null
        ? widget.filePath!.split(Platform.pathSeparator).last.replaceAll('.ordw', '')
        : "Untitled Document";

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
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
                color: const Color(0xFF2B579A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Text('W', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Text(fileName, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.undo, size: 18),
            tooltip: 'Undo',
            onPressed: () { if (controller.hasUndo) controller.undo(); },
          ),
          IconButton(
            icon: const Icon(LucideIcons.redo, size: 18),
            tooltip: 'Redo',
            onPressed: () { if (controller.hasRedo) controller.redo(); },
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: const Icon(LucideIcons.save, size: 18),
            tooltip: 'Save',
            onPressed: () async {
              await ref.read(writerNotifierProvider.notifier).saveFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document saved')),
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
      body: Column(
        children: [
          // Quill Toolbar — styled as Office ribbon
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: QuillSimpleToolbar(controller: controller),
          ),
          // Document canvas — white paper on gray background
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 816), // A4 width in pixels at 96dpi
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 48),
                  child: QuillEditor.basic(controller: controller),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
