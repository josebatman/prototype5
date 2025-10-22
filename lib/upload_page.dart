
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:go_router/go_router.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  String? _fileName;
  List<List<dynamic>>? _excelData;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isNotEmpty) {
        final sheet = excel.tables[excel.tables.keys.first];
        if (sheet != null) {
          setState(() {
            _fileName = result.files.single.name;
            _excelData = sheet.rows.map((row) => row.map((cell) => cell?.value).toList()).toList();
          });
        }
      }
    }
  }

  void _analyzeData() {
    if (_excelData != null) {
      context.go('/analysis', extra: _excelData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Upload Your Student Data',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            MouseRegion(
              onEnter: (event) {
                setState(() {
                  _isHovering = true;
                });
                _controller.forward();
              },
              onExit: (event) {
                setState(() {
                  _isHovering = false;
                });
                _controller.reverse();
              },
              child: ScaleTransition(
                scale: _animation.drive(Tween(begin: 1.0, end: 1.1)),
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload Excel File'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_fileName != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    _fileName!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _excelData != null ? _analyzeData : null,
              child: const Text('Analyze'),
            ),
          ],
        ),
      ),
    );
  }
}
