import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileUtil {
  static Future<String> saveFile(Uint8List bytes, String fileName) async {
    Directory directory = await getApplicationSupportDirectory();
    String path = directory.path;
    File file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<void> openFile(String path) async {
    OpenAppFile.open(path);
  }

  static Future<Uint8List> mergeFiles(List<String> filePaths) async {
    PdfDocument newDocument = PdfDocument();
    PdfSection? section;

    for (String file in filePaths) {
      final bytes = await File(file).readAsBytes();
      PdfDocument loadedDocument = PdfDocument(inputBytes: bytes);
      for (int i = 0; i < loadedDocument.pages.count; i++) {
        PdfTemplate template = loadedDocument.pages[i].createTemplate();
        if (section == null || section.pageSettings.size != template.size) {
          section = newDocument.sections!.add();
          section.pageSettings.size = template.size;
          section.pageSettings.margins.all = 0;
        }
        section.pages.add().graphics.drawPdfTemplate(template, Offset.zero);
      }
      loadedDocument.dispose();
    }

    final mergedBytes = await newDocument.save();
    newDocument.dispose();
    return Uint8List.fromList(mergedBytes);
  }
}
