import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf_merge_app/file_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Merger',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PDFMergeScreen(),
    );
  }
}

class PDFMergeScreen extends StatefulWidget {
  const PDFMergeScreen({super.key});

  @override
  _PDFMergeScreenState createState() => _PDFMergeScreenState();
}

class _PDFMergeScreenState extends State<PDFMergeScreen> {
  final TextEditingController _fileNameController = TextEditingController();
  final List<String> _pdfUrls = []; // Replace with actual Firebase URLs
  bool _isLoading = false;

  Future<void> _combinePDFs() async {
    if (_fileNameController.text.isEmpty) {
      _showError('Please enter a file name');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Merge the files
      final mergedBytes = await compute(FileUtil.mergeFiles, _pdfUrls);

      // Save the merged PDF
      String savedPath = await FileUtil.saveFile(
        Uint8List.fromList(mergedBytes),
        "${_fileNameController.text}.pdf",
      );
      FileUtil.openFile(savedPath);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Merger"),
        actions: [
          IconButton(
            onPressed: _pickFilesToAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pdfUrls.length > 1)
              TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: "Enter file name",
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _pdfUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("PDF ${index + 1}"),
                    subtitle: Text(_pdfUrls[index].split('/').last),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 50),
                      ),
                      onPressed: _pdfUrls.length > 1 ? _combinePDFs : null,
                      child: const Text(
                        "Merge PDFs",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _pickFilesToAdd() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _pdfUrls.addAll(result.files.map((file) => file.path!));
      });
    }
  }

  void _showError(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s)),
    );
  }
}
