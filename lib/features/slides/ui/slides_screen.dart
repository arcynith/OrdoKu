import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:ordoku/features/slides/domain/slides_provider.dart';

class SlidesScreen extends ConsumerStatefulWidget {
  final String? filePath;

  const SlidesScreen({super.key, this.filePath});

  @override
  ConsumerState<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends ConsumerState<SlidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.filePath != null) {
        ref.read(slidesNotifierProvider.notifier).loadFile(widget.filePath!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final presData = ref.watch(slidesNotifierProvider);
    final fileName = widget.filePath != null
        ? widget.filePath!.split(Platform.pathSeparator).last.replaceAll('.ordp', '')
        : "Untitled Presentation";

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
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
                color: const Color(0xFFD24726),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Text('P', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Text(fileName, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.type, size: 18),
            tooltip: 'Add Text',
            onPressed: () {
              ref.read(slidesNotifierProvider.notifier).addObjectToCurrentSlide('text', 'New Text Box');
            },
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE0E0E0), margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: const Icon(LucideIcons.save, size: 18),
            tooltip: 'Save',
            onPressed: () async {
              await ref.read(slidesNotifierProvider.notifier).saveFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Presentation saved')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(LucideIcons.play, size: 18, color: const Color(0xFFD24726).withValues(alpha: 0.8)),
            tooltip: 'Present',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE0E0E0)),
        ),
      ),
      body: Row(
        children: [
          // Slide thumbnails panel
          Container(
            width: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6F7),
              border: Border(right: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: presData.slides.length + 1,
              itemBuilder: (context, index) {
                if (index == presData.slides.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(slidesNotifierProvider.notifier).addSlide(),
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('New Slide', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: const BorderSide(color: Color(0xFFD0D0D0)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  );
                }

                final isSelected = index == presData.selectedIndex;
                return GestureDetector(
                  onTap: () => ref.read(slidesNotifierProvider.notifier).selectSlide(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFFD24726) : const Color(0xFF999999)),
                          ),
                        ),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFD24726) : const Color(0xFFD0D0D0),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text('Slide ${index + 1}', style: const TextStyle(fontSize: 9, color: Color(0xFFBBBBBB))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Main canvas
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: presData.slides.isNotEmpty && presData.selectedIndex < presData.slides.length
                        ? presData.slides[presData.selectedIndex].objects.map((obj) {
                            return Positioned(
                              left: obj.x,
                              top: obj.y,
                              child: Container(
                                width: obj.width,
                                height: obj.height,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD24726).withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  obj.content,
                                  style: const TextStyle(color: Color(0xFF333333), fontSize: 24),
                                ),
                              ),
                            );
                          }).toList()
                        : [],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
