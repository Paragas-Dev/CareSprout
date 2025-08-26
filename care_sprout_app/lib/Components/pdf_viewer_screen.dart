import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String? url;
  final String fileName;
  final String? filePath;

  const PdfViewerScreen({super.key, this.url, required this.fileName, this.filePath})
  : assert(url != null || filePath != null,
            'Either url or filePath must be provided.');

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: SfPdfViewer.network(widget.url ?? widget.filePath!),
    );
  }
}
