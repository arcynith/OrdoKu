import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:ordoku/features/sheet/domain/sheet_provider.dart';
import 'package:ordoku/core/engines/export_engine.dart';

class SheetScreen extends ConsumerStatefulWidget {
  final String? filePath;

  const SheetScreen({super.key, this.filePath});

  @override
  ConsumerState<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends ConsumerState<SheetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.filePath != null) {
        ref.read(sheetNotifierProvider.notifier).loadFile(widget.filePath!);
      }
    });
  }

  String _getColLabel(int index) => String.fromCharCode(65 + index);

  @override
  Widget build(BuildContext context) {
    final sheetData = ref.watch(sheetNotifierProvider);
    final fileName = widget.filePath != null
        ? widget.filePath!.split(Platform.pathSeparator).last.replaceAll('.ords', '')
        : "Untitled Workbook";

    return Scaffold(
      backgroundColor: Colors.white,
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
                color: const Color(0xFF217346),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Text(fileName, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.undo, size: 18),
            tooltip: 'Undo',
            onPressed: ref.watch(sheetNotifierProvider.notifier).canUndo
                ? () => ref.read(sheetNotifierProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.redo, size: 18),
            tooltip: 'Redo',
            onPressed: ref.watch(sheetNotifierProvider.notifier).canRedo
                ? () => ref.read(sheetNotifierProvider.notifier).redo()
                : null,
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: const Icon(LucideIcons.download, size: 18),
            tooltip: 'Export CSV',
            onPressed: () async {
              final engine = ExportEngine();
              final defaultName = fileName;
              await engine.exportToCsv(sheetData.cells, defaultName);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.save, size: 18),
            tooltip: 'Save',
            onPressed: () async {
              await ref.read(sheetNotifierProvider.notifier).saveFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workbook saved')),
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
          // Formula bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('A1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                ),
                const SizedBox(width: 8),
                const Text('fx', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Color(0xFF666666))),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        _buildHeaderCell('', width: 40),
                        for (int c = 0; c < sheetData.cells[0].length; c++)
                          _buildHeaderCell(_getColLabel(c)),
                      ],
                    ),
                    // Data Rows
                    for (int r = 0; r < sheetData.cells.length; r++)
                      Row(
                        children: [
                          _buildRowNumberCell('${r + 1}'),
                          for (int c = 0; c < sheetData.cells[r].length; c++)
                            _buildDataCell(r, c, sheetData.cells[r][c]),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Status bar
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF217346),
            ),
            child: const Row(
              children: [
                Text('Ready', style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {double width = 90}) {
    return Container(
      width: width,
      height: 26,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F7),
        border: Border(
          right: BorderSide(color: Color(0xFFE0E0E0)),
          bottom: BorderSide(color: Color(0xFFD0D0D0)),
        ),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
    );
  }

  Widget _buildRowNumberCell(String label) {
    return Container(
      width: 40,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F7),
        border: Border(
          right: BorderSide(color: Color(0xFFD0D0D0)),
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
    );
  }

  Widget _buildDataCell(int r, int c, String value) {
    return Container(
      width: 90,
      height: 24,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE8E8E8)),
          bottom: BorderSide(color: Color(0xFFE8E8E8)),
        ),
      ),
      child: TextFormField(
        initialValue: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        onChanged: (newVal) {
          ref.read(sheetNotifierProvider.notifier).updateCell(r, c, newVal);
        },
      ),
    );
  }
}
