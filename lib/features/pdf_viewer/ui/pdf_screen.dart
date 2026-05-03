import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatefulWidget {
  final String? filePath;

  const PdfScreen({super.key, this.filePath});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath != null
        ? widget.filePath!.split(Platform.pathSeparator).last.replaceAll('.pdf', '')
        : "Unknown Document";

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
                color: const Color(0xFFD42A2A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Text('R', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Text(fileName, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.zoomIn, size: 18),
            tooltip: 'Zoom In',
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.5;
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.zoomOut, size: 18),
            tooltip: 'Zoom Out',
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.5;
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE0E0E0)),
        ),
      ),
      body: widget.filePath != null
          ? SfPdfViewer.file(
              File(widget.filePath!),
              controller: _pdfViewerController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
            )
          : const Center(
              child: Text('File path is required to view PDF.'),
            ),
    );
  }
}
