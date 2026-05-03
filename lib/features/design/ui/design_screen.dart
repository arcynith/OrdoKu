import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:ordoku/features/design/domain/design_provider.dart';

class DesignScreen extends ConsumerStatefulWidget {
  final String? filePath;

  const DesignScreen({super.key, this.filePath});

  @override
  ConsumerState<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends ConsumerState<DesignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.filePath != null) {
        ref.read(designNotifierProvider.notifier).loadFile(widget.filePath!);
      }
    });
  }

  Widget _buildObject(DesignObject obj, bool isSelected) {
    Widget content;
    Color color = Color(int.parse(obj.color));

    if (obj.type == 'rect') {
      content = Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
    } else if (obj.type == 'circle') {
      content = Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    } else {
      content = Center(
        child: Text(obj.content, style: const TextStyle(fontSize: 20, color: Color(0xFF333333))),
      );
    }

    return Positioned(
      left: obj.x,
      top: obj.y,
      width: obj.width,
      height: obj.height,
      child: GestureDetector(
        onTap: () => ref.read(designNotifierProvider.notifier).selectObject(obj.id),
        onPanUpdate: (details) {
          ref.read(designNotifierProvider.notifier).updateObjectPosition(obj.id, details.delta.dx, details.delta.dy);
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: const Color(0xFF008B8B), width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: content),
              // Selection handles
              if (isSelected) ...[
                Positioned(top: -4, left: -4, child: _handle()),
                Positioned(top: -4, right: -4, child: _handle()),
                Positioned(bottom: -4, left: -4, child: _handle()),
                Positioned(bottom: -4, right: -4, child: _handle()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF008B8B), width: 1.5),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designData = ref.watch(designNotifierProvider);
    final fileName = widget.filePath != null
        ? widget.filePath!.split(Platform.pathSeparator).last.replaceAll('.ordd', '')
        : "Untitled Canvas";

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
                color: const Color(0xFF008B8B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Text('D', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Text(fileName, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.undo, size: 18),
            tooltip: 'Undo',
            onPressed: ref.watch(designNotifierProvider.notifier).canUndo
                ? () => ref.read(designNotifierProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.redo, size: 18),
            tooltip: 'Redo',
            onPressed: ref.watch(designNotifierProvider.notifier).canRedo
                ? () => ref.read(designNotifierProvider.notifier).redo()
                : null,
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: const Icon(LucideIcons.save, size: 18),
            tooltip: 'Save',
            onPressed: () async {
              await ref.read(designNotifierProvider.notifier).saveFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Design saved')),
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
          // Shape toolbar
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                _toolbarBtn(LucideIcons.square, 'Rectangle', () => ref.read(designNotifierProvider.notifier).addObject('rect')),
                _toolbarBtn(LucideIcons.circle, 'Circle', () => ref.read(designNotifierProvider.notifier).addObject('circle')),
                _toolbarBtn(LucideIcons.type, 'Text', () => ref.read(designNotifierProvider.notifier).addObject('text')),
                Container(width: 1, height: 20, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 8)),
                const Text('Shapes', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
              ],
            ),
          ),
          // Canvas
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(designNotifierProvider.notifier).selectObject(''),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.1,
                maxScale: 5.0,
                child: Stack(
                  children: [
                    // Grid
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(),
                      ),
                    ),
                    ...designData.objects.map((obj) => _buildObject(obj, obj.id == designData.selectedObjectId)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbarBtn(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Icon(icon, size: 16, color: const Color(0xFF555555)),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
