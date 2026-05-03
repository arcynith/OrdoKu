import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ExportEngine {
  
  /// Exports a 2D array of strings to a CSV file.
  Future<void> exportToCsv(List<List<String>> data, String defaultName) async {
    // Generate CSV string
    final StringBuffer csvBuffer = StringBuffer();
    for (var row in data) {
      final rowString = row.map((cell) {
        // Escape quotes
        final escapedCell = cell.replaceAll('"', '""');
        return '"$escapedCell"';
      }).join(',');
      csvBuffer.writeln(rowString);
    }
    
    final String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Export Sheet as CSV',
      fileName: '$defaultName.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csvBuffer.toString());
    }
  }

  /// Exports a plain text string to a TXT file.
  Future<void> exportToText(String content, String defaultName) async {
    final String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Export Notes as Text',
      fileName: '$defaultName.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(content);
    }
  }
}
